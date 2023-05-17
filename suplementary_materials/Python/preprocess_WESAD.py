import neurokit2 as nk
from glob import glob
import pandas as pd
import numpy as np
import logging
import pickle
import scipy

from utils import utils
from sklearn.preprocessing import StandardScaler


def load_subject_data(file):
    with open(file, "rb") as file:
        data = pickle.load(file, encoding="latin1")
        ecg = data["signal"]["chest"]["ECG"].flatten()
        rsp = data["signal"]["chest"]["Resp"].flatten()
        eda = data["signal"]["chest"]["EDA"].flatten()
        labels = data["label"]
        subject = data["subject"]

        df = pd.DataFrame({"label": labels})
        first = df[df["label"] == 2].index[0]
        last = df[df["label"] == 2].index[-1]
        df.loc[first + int(5.5 * 60 * 700):last, "label"] = 8

    return [ecg, rsp, eda, df["label"].values, subject]


def preprocess_data(data, fs, scaler):
    r1 = nk.signal_resample(data[0], sampling_rate=700, desired_sampling_rate=fs)
    r2 = nk.signal_resample(data[1], sampling_rate=700, desired_sampling_rate=fs)
    r3 = nk.signal_resample(data[2], sampling_rate=700, desired_sampling_rate=fs)
    #r4 = utils.downsample_labels(data[3], fs=700, desired_fs=fs)
    labels_down = nk.signal_resample(data[3], sampling_rate=700, desired_sampling_rate=fs)

    # labels = data[3]
    # xp = np.arange(0, len(labels), 700 / fs)
    # labels_down = scipy.interpolate.interp1d(np.arange(len(labels)), labels, kind='nearest')(xp)

    ecg_clean = nk.ecg_clean(r1, sampling_rate=fs)
    rsp_clean = nk.rsp_clean(r2, sampling_rate=fs)
    eda_clean = nk.eda_clean(r3, sampling_rate=fs)

    ecg_scaled = scaler.fit_transform(ecg_clean.reshape(-1, 1)).reshape(-1)
    rsp_scaled = scaler.fit_transform(rsp_clean.reshape(-1, 1)).reshape(-1)
    eda_scaled = scaler.fit_transform(eda_clean.reshape(-1, 1)).reshape(-1)

    return pd.DataFrame({"ECG": ecg_clean, "RSP": rsp_clean, "EDA": eda_clean, "label": labels_down})


def segment_data(df, fs, win):
    df_prep = df
    df_prep["group"] = df_prep["label"].ne(df_prep["label"].shift()).cumsum()
    df_grouped = df_prep.groupby("group")

    df_win = pd.DataFrame()
    for _, g in df_grouped:
        if len(g) > (fs * win):
            ecg_segments = utils.create_windows(g["ECG"].to_numpy(), fs, win)
            rsp_segments = utils.create_windows(g["RSP"].to_numpy(), fs, win)
            eda_segments = utils.create_windows(g["EDA"].to_numpy(), fs, win)
            label = g["label"].iloc[0]

            # Extend to get nice resolution after GCN conversion
            # ecg_segments = np.pad(ecg_segments, ((0, 0), (0, 4)), mode="edge")
            # rsp_segments = np.pad(rsp_segments, ((0, 0), (0, 4)), mode="edge")
            # eda_segments = np.pad(eda_segments, ((0, 0), (0, 4)), mode="edge")

            model_label = -1
            if label in [8]:
                model_label = 1
            elif label in [1]:
                model_label = 0

            df_tmp = pd.DataFrame({
                "ECG": ecg_segments,
                "RSP": rsp_segments,
                "EDA": eda_segments,
                "label": label,
                "model_label": model_label
            })
            df_win = pd.concat([df_win, df_tmp], ignore_index=True)

    return df_win


def preprocess_wesad(src_dir, out_dir, fs, win, scaler):
    logging.info("Preprocessing WESAD data")
    files = glob(f"{src_dir}/S*/S*.pkl")
    for file in files:
        data = load_subject_data(file)
        logging.info("Processing subject " + data[4])
        processed_data = preprocess_data(data, fs, scaler)
        segmented_data = segment_data(processed_data, fs, win)
        with open(out_dir + data[4] + ".pkl", "wb") as f:
            pickle.dump(segmented_data, f)


if __name__ == "__main__":
    utils.setup_logging()

    scaler = StandardScaler()

    fs = 1024
    win = 1
    src_dir = "D:/School/CL_Datasets/WESAD/data"
    out_dir = "data/WESAD/processed/"

    preprocess_wesad(src_dir, out_dir, fs, win, scaler)
