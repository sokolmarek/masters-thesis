import numpy as np
import logging
import pickle

from utils import utils
from sklearn.linear_model import Lasso


def lasso_granger(series, lag, alpha):
    """Lasso Granger
    A. Arnold, Y. Liu, and N. Abe. Temporal causal modeling with graphical granger methods. In KDD, 2007
    """
    N, T = np.shape(series)
    Am = np.zeros((T - lag, lag * N))
    bm = np.zeros((T - lag, 1))
    for i in range(lag, T - 1):
        bm[i - lag] = series[0, i + 1]
        Am[i - lag, :] = np.fliplr(series[:, i - lag:i]).flatten()

    # Lasso using GLMnet
    # fit = glmnet(x=Am, y=bm, family="gaussian", alpha=1, lambdau=np.array([alpha]))
    # vals2 = fit["beta"]  # array of coefficient
    lasso = Lasso(alpha=alpha, max_iter=10000)
    lasso.fit(Am, bm)
    vals2 = lasso.coef_

    # Outputting aic metric for variable into (N,P) matrix
    th = 0
    # aic = (np.linalg.norm(Am @ vals2 - bm, 2)) ** 2 / (T - lag) + np.sum(np.abs(vals2) > th) * 2 / (T - lag)

    # Reformatting the results into (N,P) matrix
    n1Coeff = np.zeros((N, lag))
    for i in range(N):
        n1Coeff[i, :] = vals2[i * lag:(i + 1) * lag].reshape(lag)

    sumCause = np.sum(np.abs(n1Coeff), axis=1)
    sumCause[sumCause < th] = 0
    cause = sumCause
    return cause


def create_gcn_data(file, out_dir, n, max_lag, alpha=1.0):
    logging.info("Creating GCN dataset")
    with open(file, "rb") as f:
        data = pickle.load(f, encoding="latin1")

    # Create image channel for each biosignal
    labels = data[["label", "model_label"]]
    data.drop(["label", "model_label"], axis=1, inplace=True)

    k = 0
    l = len(data)
    result = []
    for row in data.iterrows():

        ch = []
        for var in row[1]:
            segment = var.reshape(-1, n)
            cause = np.zeros((n, n))

            idx1 = np.array(range(n))
            idx2 = np.array(range(n))
            for i in range(n):
                idx1[0], idx1[i] = idx1[i], idx1[0]
                tmp = lasso_granger(segment[idx1], max_lag, alpha)
                if i > 0:
                    idx2[i], idx2[i - 1] = 0, idx2[i]
                cause[i, :] = tmp[idx2].T

            cause = cause.reshape((n, n, 1))
            ch.append(cause)

        img = np.dstack((ch[0], ch[1], ch[2]))
        result.append(img)
        k += 1
        print("\rCompleted: ", np.round((k / l) * 100), "%", end="")

    print("\nDataset shape: ", np.shape(result))
    logging.info("Saving dataset")
    with open(out_dir + "GCN_" + file.split("/")[2], "wb") as f:
        pickle.dump(result, f)


if __name__ == "__main__":
    utils.setup_logging()

    file = "data/merged/merged_5s.pkl"
    out_dir = "data/GCN_Data/"
    shape = 32
    max_lag = 3
    alpha = 0.001

    # Create GCN data
    create_gcn_data(file, out_dir, shape, max_lag, alpha)
