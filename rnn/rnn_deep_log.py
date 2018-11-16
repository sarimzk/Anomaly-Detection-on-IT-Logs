import collections
import os
import sys
import logging
import tensorflow as tf
import pandas as pd
import numpy as np
from keras.models import Sequential
from keras.layers import Dense, Activation, Embedding, Dropout, TimeDistributed
from keras.layers import LSTM
from keras.optimizers import Adam
from keras.utils import to_categorical
from keras.callbacks import ModelCheckpoint
from batch_generator import KerasBatchGenerator
from optparse import OptionParser
from loader import load_data

logger = logging.getLogger('RNN-DeepLog')
logger.setLevel(logging.DEBUG)
logger.addHandler(logging.StreamHandler(sys.stdout))


if "__main__"==__name__:
    parser = OptionParser()
    (options, args) = parser.parse_args()
    if len(args) == 1:
        data_path = args[0]
        train_data, test_data, valid_data, vocabulary, reversed_dictionary = load_data(data_path)
        logger.info('Data loaded Vocabulary [{}]'.format(vocabulary))
        num_steps = 30
        batch_size = 10
        num_epochs = 5

        train_data_generator = KerasBatchGenerator(train_data, num_steps, batch_size, vocabulary,
                                                   skip_step=num_steps)
        valid_data_generator = KerasBatchGenerator(valid_data, num_steps, batch_size, vocabulary,
                                                   skip_step=num_steps)

        hidden_size = 100
        model = Sequential()
        model.add(Embedding(vocabulary, hidden_size, input_length=num_steps))
        model.add(LSTM(hidden_size, return_sequences=True))
        model.add(LSTM(hidden_size, return_sequences=True))
        model.add(Dropout(0.5))
        model.add(TimeDistributed(Dense(vocabulary)))
        model.add(Activation('softmax'))

        optimizer = Adam()
        model.compile(loss='categorical_crossentropy', optimizer='adam', metrics=['categorical_accuracy'])
        checkpointer = ModelCheckpoint(filepath=data_path + '/model-{epoch:02d}.hdf5', verbose=1)
        model.fit_generator(train_data_generator.generate(), len(train_data)//(batch_size*num_steps), num_epochs,
                            validation_data=valid_data_generator.generate(),
                            validation_steps=len(valid_data)//(batch_size*num_steps), callbacks=[checkpointer])

        model.save(data_path + "final_model.hdf5")
