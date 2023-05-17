import numpy as np
import pandas as pd
import logging
import pickle

from utils import utils
from pyts.image import GramianAngularField


def create_gadf_map(data, image_size, method="summation"):
    gadf = GramianAngularField(image_size=image_size, method=method)
    ecg = gadf.fit_transform(data["ECG"].reshape(1, -1))
    rsp = gadf.fit_transform(data["RSP"].reshape(1, -1))
    eda = gadf.fit_transform(data["EDA"].reshape(1, -1))

    return np.dstack((ecg.squeeze(), rsp.squeeze(), eda.squeeze()))


def create_gadf_data(file, out_dir, n):
    logging.info(f"Creating GASF dataset for {file.split('/')[2]}")
    with open(file, "rb") as f:
        data = pickle.load(f, encoding="latin1")

    # Create image channel for each biosignal
    labels = data[["label", "model_label"]]
    data.drop(["label", "model_label"], axis=1, inplace=True)

    i = 0
    l = len(data)
    result = []
    for row in data.iterrows():
        img = create_gadf_map(row[1], n)
        result.append(img)
        i += 1
        print("\rCompleted: ", np.round((i / l) * 100), "%", end="")

    print("\nDataset shape: ", np.shape(result))
    logging.info("Saving dataset")
    with open(out_dir + "GASF_" + file.split("/")[2], "wb") as f:
        pickle.dump(np.array(result), f)


if __name__ == "__main__":
    utils.setup_logging()

    file = "data/merged/merged_10s.pkl"
    CLAS_file = "data/merged/CLAS_merged_10s.pkl"
    WESAD_file = "data/merged/WESAD_merged_10s.pkl"
    out_dir = "data/GASF_Data/"
    shape = 32

    # Create GADF data
    create_gadf_data(file, out_dir, shape)
    create_gadf_data(CLAS_file, out_dir, shape)
    create_gadf_data(WESAD_file, out_dir, shape)
