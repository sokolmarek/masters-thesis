import numpy as np
import logging
import pickle

from utils import utils


def concat_data(data1, data2):
    L = len(data1)

    result = []
    for i in range(L):
        result.append(data1[i] + data2[i])
        print("\rCompleted: ", np.round((i / L) * 100), "%", end="")

    return np.array(result)


def create_dataset(f1, f2, out_dir):
    with open(f1, "rb") as file:
        data1 = pickle.load(file, encoding="latin1")

    with open(f2, "rb") as file:
        data2 = pickle.load(file, encoding="latin1")

    result = concat_data(data1, data2)

    print("\nDataset shape: ", np.shape(result))
    logging.info("Saving dataset")
    with open(out_dir + "Dataset_5s_All.pkl", "wb") as f:
        pickle.dump(np.array(result), f)


if __name__ == "__main__":
    utils.setup_logging()

    GCN_file = "data/GCN_Data/GCN_merged_5s.pkl"
    GADF_file = "data/GADF_Data/GADF_merged_5s.pkl"
    out_dir = "data/Final/"

    create_dataset(GCN_file, GADF_file, out_dir)
