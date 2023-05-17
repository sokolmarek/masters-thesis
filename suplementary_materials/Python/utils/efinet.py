# Copyright 2021 Vittorio Mazzia & Francesco Salvetti. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================
# Revision for Keras 2.10.0 and Tensorflow 2.10.0 for academic purposes by
# Marek Sokol, Github: `https://github.com/sokolmarek`

import numpy as np
import tensorflow as tf
from EfficientCapsNet.efinetlayers import PrimaryCaps, FCCaps, Length, Mask
from keras import backend as K

K.set_image_data_format("channels_last")


def efficient_capsnet_graph(input_shape, n_classes):
    """
    Efficient-CapsNet graph architecture.

    Parameters
    ----------
    input_shape: list
        network input shape
    """
    x = tf.keras.layers.Input(input_shape)

    # Layer 1:
    conv1 = tf.keras.layers.Conv2D(filters=32, kernel_size=5, strides=1, padding="same", activation="relu",
                                   kernel_initializer="he_normal", name="conv1")(x)
    conv1 = tf.keras.layers.BatchNormalization()(conv1)

    # Layer 2:
    conv2 = tf.keras.layers.Conv2D(filters=64, kernel_size=5, strides=1, padding="same", activation="relu",
                                   kernel_initializer="he_normal", name="conv2")(conv1)
    conv2 = tf.keras.layers.BatchNormalization()(conv2)
    conv2 = tf.keras.layers.MaxPool2D(pool_size=(2, 2), padding="same")(conv2)
    conv2 = tf.keras.layers.Dropout(0.25)(conv2)

    # Layer 3:
    conv3 = tf.keras.layers.Conv2D(filters=64, kernel_size=3, strides=1, padding="same", activation="relu",
                                   kernel_initializer="he_normal", name="conv3")(conv2)
    conv3 = tf.keras.layers.BatchNormalization()(conv3)

    # Layer 4:
    conv4 = tf.keras.layers.Conv2D(filters=128, kernel_size=3, strides=2, padding='same', activation='relu',
                                   kernel_initializer="he_normal", name="conv4")(conv3)
    conv4 = tf.keras.layers.BatchNormalization()(conv4)
    conv4 = tf.keras.layers.MaxPool2D(pool_size=(2, 2), strides=(2, 2), padding="same")(conv4)
    conv4 = tf.keras.layers.Dropout(0.25)(conv4)

    primarycaps = PrimaryCaps(128, 8, 16, 8)(conv4)
    digit_caps = FCCaps(n_classes, 16)(primarycaps)
    digit_caps_len = Length(name="length_capsnet_output")(digit_caps)

    return tf.keras.Model(inputs=x, outputs=[digit_caps, digit_caps_len], name="Efficient_CapsNet")


def generator_graph(input_shape, n_classes):
    """
    Generator graph architecture.

    Parameters
    ----------
    input_shape: list
        network input shape
    """
    inputs = tf.keras.Input(16 * n_classes)

    x = tf.keras.layers.Flatten()(inputs)
    x = tf.keras.layers.Dense(256, activation="relu", input_dim=32 * 2, kernel_initializer="he_normal")(x)
    x = tf.keras.layers.Dropout(0.5)(x)
    x = tf.keras.layers.Dense(512, activation="relu", kernel_initializer="he_normal")(x)
    x = tf.keras.layers.Dense(1024, activation="relu", kernel_initializer="he_normal")(x)
    x = tf.keras.layers.Dense(np.prod(input_shape), activation="sigmoid", kernel_initializer="glorot_normal")(x)
    x = tf.keras.layers.Reshape(target_shape=input_shape, name="out_generator")(x)

    return tf.keras.Model(inputs=inputs, outputs=x, name="Generator")


def build_graph(input_shape, n_classes, verbose=False):
    """
    Efficient-CapsNet graph architecture with reconstruction regularizer. The network can be initialize with different modalities.
    """
    inputs = tf.keras.Input(input_shape)
    y_true = tf.keras.Input(shape=(n_classes,))

    efficient_capsnet = efficient_capsnet_graph(input_shape, n_classes)

    if verbose:
        efficient_capsnet.summary()
    print("\n\n")

    digit_caps, digit_caps_len = efficient_capsnet(inputs)

    masked_by_y = Mask()([digit_caps, y_true])
    masked = Mask()(digit_caps)

    generator = generator_graph(input_shape, n_classes)

    if verbose:
        generator.summary()
    print("\n\n")

    x_gen_train = generator(masked_by_y)
    x_gen_eval = generator(masked)

    train_model = tf.keras.Model([inputs, y_true], [digit_caps_len, x_gen_train], name="Efficinet_CapsNet_Generator")
    eval_model = tf.keras.Model(inputs, [digit_caps_len, x_gen_eval], name="Efficinet_CapsNet_Generator")

    return train_model, eval_model


def marginLoss(y_true, y_pred):
    lbd = 0.5
    m_plus = 0.9
    m_minus = 0.1

    L = y_true * tf.square(tf.maximum(0., m_plus - y_pred)) + \
        lbd * (1 - y_true) * tf.square(tf.maximum(0., y_pred - m_minus))

    return tf.reduce_mean(tf.reduce_sum(L, axis=1))


def learn_scheduler(lr_dec, lr):
    def learning_scheduler_fn(epoch):
        lr_new = lr * (lr_dec ** epoch)
        return lr_new if lr_new >= 5e-5 else 5e-5

    return learning_scheduler_fn


def get_callbacks(tb_log_save_path, saved_model_path, model_name, lr_dec, lr):
    # tb = tf.keras.callbacks.TensorBoard(log_dir=tb_log_save_path, histogram_freq=0)
    tb = tf.keras.callbacks.CSVLogger(f"{tb_log_save_path}/{model_name}_log.csv")
    model_checkpoint = tf.keras.callbacks.ModelCheckpoint(saved_model_path, monitor="val_Efficient_CapsNet_accuracy",
                                                          save_best_only=True, save_weights_only=True, verbose=1)
    lr_decay = tf.keras.callbacks.LearningRateScheduler(learn_scheduler(lr_dec, lr))
    # reduce_lr = tf.keras.callbacks.ReduceLROnPlateau(monitor="val_Efficient_CapsNet_accuracy", factor=0.9,
    #                                                  patience=4, min_lr=0.00001, min_delta=0.0001, mode="max")
    return [tb, model_checkpoint, lr_decay]


def train(model,  # type: tf.keras.models.Model
          data, epochs, lr, model_name, batch_size):
    (x_train, y_train), (x_test, y_test) = data

    callbacks = get_callbacks("../results/logs", "../results/models", model_name, 0.97, lr)

    # compile the model
    # Adam(learning_rate=lr)
    model.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=lr),
                  loss=[marginLoss, "mse"],
                  loss_weights=[1., 0.392],
                  metrics={"Efficient_CapsNet": "accuracy"})

    # Training without data augmentation:
    model.fit([x_train, y_train], [y_train, x_train], batch_size=batch_size, epochs=epochs,
              validation_data=[[x_test, y_test], [y_test, x_test]], callbacks=callbacks)

    model.save_weights(f"../results/models/{model_name}.h5")
    print(f"Trained model saved to results/models/{model_name}.h5")

    return model
