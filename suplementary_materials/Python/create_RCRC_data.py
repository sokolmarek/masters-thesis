import numpy as np
import pandas as pd
import logging
import pickle

from utils import utils
from skimage.transform import resize
from pyts.image import RecurrencePlot


def create_rcrc_map(data):
    rcrc = RecurrencePlot(dimension=7, time_delay=3, threshold="distance", percentage=20)
    ecg = rcrc.fit_transform([data["ECG"]])
    rsp = rcrc.fit_transform([data["RSP"]])
    eda = rcrc.fit_transform([data["EDA"]])

    ecg_res = resize(ecg.squeeze(), (32, 32))
    rsp_res = resize(rsp.squeeze(), (32, 32))
    eda_res = resize(eda.squeeze(), (32, 32))

    return np.dstack((ecg_res, rsp_res, eda_res))


def create_rcrc_data(file, out_dir):
    logging.info("Creating RCRC dataset")
    with open(file, "rb") as f:
        data = pickle.load(f, encoding="latin1")

    # Create image channel for each biosignal
    labels = data[["label", "model_label"]]
    data.drop(["label", "model_label"], axis=1, inplace=True)

    i = 0
    l = len(data)
    result = []
    for row in data.iterrows():
        img = create_rcrc_map(row[1])
        result.append(img)
        i += 1
        print("\rCompleted: ", np.round((i / l) * 100), "%", end="")

    print("\nDataset shape: ", np.shape(result))
    logging.info("Saving dataset")
    with open(out_dir + "RCRC_" + file.split("/")[2], "wb") as f:
        pickle.dump(np.array(result), f)


if __name__ == "__main__":
    utils.setup_logging()

    file = "data/merged/merged_5s.pkl"
    out_dir = "data/RCRC_Data/"

    # Create GADF data
    create_rcrc_data(file, out_dir)
