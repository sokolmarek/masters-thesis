from glob import glob
import pandas as pd
import logging
import pickle

from utils import utils


def load_subject(file):
    logging.info(f"Loading data for: {file}")
    with open(file, "rb") as f:
        data = pickle.load(f, encoding="latin1")
    return data


def merge_datasets(files, out_dir):
    logging.info("Merging datasets")
    data = []
    for file in files:
        subject = load_subject(file)
        data.append(subject)

    df = pd.concat(data, ignore_index=True)
    df = df.loc[(df["model_label"] == 1) | (df["model_label"] == 0)]
    df.reset_index(drop=True, inplace=True)

    logging.info("Saving merged data")
    with open(out_dir + "merged_5s_2s_overlap.pkl", "wb") as f:
        pickle.dump(df, f)


def merge_wesad(files, out_dir):
    logging.info("Merging only WESAD data")
    data = []
    for file in files:
        subject = load_subject(file)
        data.append(subject)

    df = pd.concat(data, ignore_index=True)
    df = df.loc[(df["model_label"] == 1) | (df["model_label"] == 0)]
    df.reset_index(drop=True, inplace=True)

    logging.info("Saving merged data")
    with open(out_dir + "WESAD_merged_1s.pkl", "wb") as f:
        pickle.dump(df, f)


def merge_clas(files, out_dir):
    logging.info("Merging only CLAS data")
    data = []
    for file in files:
        subject = load_subject(file)
        data.append(subject)

    df = pd.concat(data, ignore_index=True)
    df = df.loc[(df["model_label"] == 1) | (df["model_label"] == 0)]
    df.reset_index(drop=True, inplace=True)

    logging.info("Saving merged data")
    with open(out_dir + "CLAS_merged_5s_2s_overlap.pkl", "wb") as f:
        pickle.dump(df, f)


if __name__ == "__main__":
    utils.setup_logging()

    out_dir = "data/merged/"
    WESAD_out = "data/WESAD/processed/"
    CLAS_out = "data/CLAS/processed/"

    WESAD_files = glob(WESAD_out + "*.pkl")
    CLAS_files = glob(CLAS_out + "*.pkl")
    files = WESAD_files + CLAS_files

    #merge_datasets(files, out_dir)
    merge_wesad(WESAD_files, out_dir)
    #merge_clas(CLAS_files, out_dir)
