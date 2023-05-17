import neurokit2 as nk
import pandas as pd
import numpy as np
import logging
import os
import re

from utils import utils
from sklearn.preprocessing import StandardScaler

CLAS_LABEL_STRINGS = {
    "Baseline": 0,
    "Neutral": 1,
    "Video clip": 2,
    "Math Test": 3,
    "Math Test Response": 4,
    "Pictures": 5,
    "Stroop Test": 6,
    "Stroop Test Response": 7,
    "IQ Test": 8,
    "IQ Test Response": 9
}


def preprocess_clas(src_dir, out_dir, fs, win, scaler):
    logging.info("Preprocessing CLAS dataset")
    bd_dir = os.path.join(src_dir, "Block_details")
    part_dir = os.path.join(src_dir, "Participants")

    bd_parts = os.listdir(bd_dir)
    bd_parts = sorted(bd_parts, key=lambda a: int(a.split('_')[0][4:]))

    for i, b in enumerate(bd_parts):
        if i in [0, 11, 14, 20, 25]:
            continue

        part_df = pd.DataFrame()
        part = b.split('_')[0]
        block_df = pd.read_csv(os.path.join(bd_dir, b))

        out = os.path.join(out_dir, f"{i}.pkl")
        file_list = os.listdir(os.path.join(part_dir, part, "by_block"))

        logging.info(f"{os.path.join(part_dir, part)} -> {out}")

        part_df = pd.DataFrame()
        for _, row in block_df.iterrows():
            block = row["Block"]

            r1 = re.compile(f"^{block}_ecg_")
            file_name1 = list(filter(r1.match, file_list))[0]

            r2 = re.compile(f"^{block}_gsr_ppg_")
            file_name2 = list(filter(r2.match, file_list))[0]

            label = CLAS_LABEL_STRINGS[row["Block Type"]]
            ecg_raw = pd.read_csv(os.path.join(part_dir, part, "by_block", file_name1))["ecg2"].to_numpy()
            gsr_raw = pd.read_csv(os.path.join(part_dir, part, "by_block", file_name2))["gsr"].to_numpy()

            ecg_downsample = nk.signal_resample(ecg_raw, sampling_rate=256, desired_sampling_rate=fs)
            gsr_downsample = nk.signal_resample(gsr_raw, sampling_rate=256, desired_sampling_rate=fs)

            if len(ecg_downsample) > 18:
                ecg_prep = nk.ecg_clean(ecg_downsample, sampling_rate=fs)
                gsr_prep = nk.ecg_clean(gsr_downsample, sampling_rate=fs)

                ecg_scaled = scaler.fit_transform(ecg_prep.reshape(-1, 1)).reshape(-1)
                rsp_scaled = scaler.fit_transform(gsr_prep.reshape(-1, 1)).reshape(-1)

                if len(ecg_prep) > (win * fs):
                    # ecg_segments = utils.create_windows(ecg_prep, 100, 5)
                    ecg_segments = utils.create_windows(ecg_scaled, fs, win)
                    gsr_segments = utils.create_windows(rsp_scaled, fs, win)

                    rpeaks, info = nk.ecg_peaks(ecg_prep, sampling_rate=fs)
                    ecg_rate = nk.ecg_rate(rpeaks, sampling_rate=fs, desired_length=len(ecg_prep))
                    edr = nk.ecg_rsp(ecg_rate, sampling_rate=fs)
                    eda_scaled = scaler.fit_transform(edr.reshape(-1, 1)).reshape(-1)
                    edr_segments = utils.create_windows(eda_scaled, fs, win)

                    model_label = -1
                    if label in [3, 6, 8]:
                        model_label = 1
                    elif label in [0, 1]:
                        model_label = 0

                    if len(ecg_segments) > len(gsr_segments):
                        # Extend to get nice resolution after GCN conversion
                        # ecg_segments[i] = np.pad(ecg_segments[i], ((0, 0), (0, 4)), mode="edge")
                        # edr_segments[i] = np.pad(edr_segments[i], ((0, 0), (0, 4)), mode="edge")
                        # gsr_segments[i] = np.pad(gsr_segments[i], ((0, 0), (0, 4)), mode="edge")

                        df_tmp = pd.DataFrame({
                            "ECG": ecg_segments[:len(gsr_segments)],
                            "RSP": edr_segments[:len(gsr_segments)],
                            "EDA": gsr_segments,
                            "label": label,
                            "model_label": model_label
                        })
                    else:
                        # Extend to get nice resolution after GCN conversion
                        # ecg_segments[i] = np.pad(ecg_segments[i], ((0, 0), (0, 4)), mode="edge")
                        # edr_segments[i] = np.pad(edr_segments[i], ((0, 0), (0, 4)), mode="edge")
                        # gsr_segments[i] = np.pad(gsr_segments[i], ((0, 0), (0, 4)), mode="edge")

                        df_tmp = pd.DataFrame({
                            "ECG": ecg_segments,
                            "RSP": edr_segments,
                            "EDA": gsr_segments[:len(ecg_segments)],
                            "label": label,
                            "model_label": model_label
                        })
                    part_df = pd.concat([part_df, df_tmp], ignore_index=True)
        part_df.to_pickle(out)


if __name__ == "__main__":
    utils.setup_logging()

    scaler = StandardScaler()

    fs = 1024
    win = 1
    src_dir = "D:/School/CL_Datasets/CLAS/"
    out_dir = "data/CLAS/processed/"

    preprocess_clas(src_dir, out_dir, fs, win, scaler)
