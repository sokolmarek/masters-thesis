from matplotlib import pyplot as plt
import pandas as pd
import numpy as np
import logging
import scipy
import math

import tensorflow as tf
from sklearn.metrics import confusion_matrix, ConfusionMatrixDisplay, accuracy_score, f1_score, precision_score, \
    recall_score, auc, roc_curve, RocCurveDisplay


def segment_signal(x, window=30, overlap=None, fs=500, copy=True):
    w = int(window * fs)

    if overlap is None or overlap == 0:
        view = np.lib.stride_tricks.sliding_window_view(x, w)[::w]
    else:
        o = int(overlap * fs)
        view = np.lib.stride_tricks.sliding_window_view(x, w)[::o]

    if copy:
        return view.copy()
    else:
        return view


def setup_logging():
    logger = logging.getLogger()
    logger.setLevel(logging.DEBUG)
    ch = logging.StreamHandler()
    ch.setLevel(logging.INFO)
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    ch.setFormatter(formatter)
    logger.addHandler(ch)


def downsample_labels(labels, fs, desired_fs):
    factor = fs / desired_fs
    n = int(np.ceil(labels.size / factor))
    f = scipy.interpolate.interp1d(np.linspace(0, 1, labels.size), labels, kind="nearest")
    return f(np.linspace(0, 1, n))


def create_windows(ecg_signal, sample_rate, window_len):
    split_num = int(len(ecg_signal) / (sample_rate * window_len))
    short = ecg_signal[len(ecg_signal) % int(sample_rate * window_len):]
    return np.split(short, split_num)


def plot_log(filename, show=True):
    data = pd.read_csv(filename)

    fig = plt.figure(figsize=(4, 6))
    fig.subplots_adjust(top=0.95, bottom=0.05, right=0.95)
    fig.add_subplot(211)
    for key in data.keys():
        if key.find('loss') >= 0 and not key.find('val') >= 0:  # training loss
            plt.plot(data['epoch'].values, data[key].values, label=key)
    plt.legend()
    plt.title('Training loss')

    fig.add_subplot(212)
    for key in data.keys():
        if key.find('acc') >= 0:  # acc
            plt.plot(data['epoch'].values, data[key].values, label=key)
    plt.legend()
    plt.title('Training and validation accuracy')

    # fig.savefig('result/log.png')
    if show:
        plt.show()


def marginLoss(y_true, y_pred):
    lbd = 0.5
    m_plus = 0.9
    m_minus = 0.1

    L = y_true * tf.square(tf.maximum(0., m_plus - y_pred)) + \
        lbd * (1 - y_true) * tf.square(tf.maximum(0., y_pred - m_minus))

    return tf.reduce_mean(tf.reduce_sum(L, axis=1))


def multiAccuracy(y_true, y_pred):
    label_pred = tf.argsort(y_pred, axis=-1)[:, -2:]
    label_true = tf.argsort(y_true, axis=-1)[:, -2:]

    acc = tf.reduce_sum(tf.cast(label_pred[:, :1] == label_true, tf.int8), axis=-1) + \
          tf.reduce_sum(tf.cast(label_pred[:, 1:] == label_true, tf.int8), axis=-1)
    acc /= 2
    return tf.reduce_mean(acc, axis=-1)


def plot_confusion_matrix(y_test, Y_pred, normalize="pred", cb=False):
    # Convert predictions classes to one hot vectors
    Y_pred_classes = np.argmax(Y_pred[0], axis=1)

    # Convert validation observations to one hot vectors
    Y_true = np.argmax(y_test, axis=1)

    # Create confusion matrix and normalizes it over predicted (columns)
    cm = confusion_matrix(Y_true, Y_pred_classes, normalize=normalize)
    disp = ConfusionMatrixDisplay(confusion_matrix=cm)
    disp.plot(cmap=plt.cm.Blues)
    if ~cb:
        disp.im_.colorbar.remove()
    plt.ylabel("Skutečná třída")
    plt.xlabel("Predikovaná třída")


def print_stats(y_test, Y_pred):
    # Convert predictions classes to one hot vectors
    Y_pred_classes = np.argmax(Y_pred[0], axis=1)

    # Convert validation observations to one hot vectors
    Y_true = np.argmax(y_test, axis=1)

    fpr, tpr, thresholds = roc_curve(Y_true, Y_pred[0][:, 1])
    roc_auc = auc(fpr, tpr)

    print("Accuracy =", accuracy_score(Y_true, Y_pred_classes))
    print("F1 Score =", f1_score(Y_true, Y_pred_classes, average="macro"))
    print("TPR =", precision_score(Y_true, Y_pred_classes, average="macro"))
    # print("Recall =", recall_score(Y_true, Y_pred_classes, average="macro"))
    print("TNR = ", recall_score(np.logical_not(Y_true), np.logical_not(Y_pred_classes), average="macro"))
    print("AUC =", roc_auc)


def plot_roc(y_test, Y_pred, name):
    # Convert validation observations to one hot vectors
    Y_true = np.argmax(y_test, axis=1)

    fpr, tpr, thresholds = roc_curve(Y_true, Y_pred[0][:, 1])
    roc_auc = auc(fpr, tpr)

    rocdisp = RocCurveDisplay(fpr=fpr, tpr=tpr, roc_auc=roc_auc, estimator_name=name)
    rocdisp.plot()
    plt.plot([0, 1], [0, 1], "k--")
    plt.axis("square")
    plt.xlabel("False Positive Rate")
    plt.ylabel("True Positive Rate")


def plot_history(history):
    # Plot the loss and accuracy curves for training and validation
    fig, ax = plt.subplots(2, 1)
    ax[0].plot(history.history["Efficient_CapsNet_loss"], color="b", label="Training loss")
    ax[0].plot(history.history["val_Efficient_CapsNet_loss"], color="r", label="validation loss", axes=ax[0])
    legend = ax[0].legend(loc="best")

    ax[1].plot(history.history["Efficient_CapsNet_accuracy"], color='b', label="Training accuracy")
    ax[1].plot(history.history["val_Efficient_CapsNet_accuracy"], color='r', label="Validation accuracy")
    legend = ax[1].legend(loc="best")
