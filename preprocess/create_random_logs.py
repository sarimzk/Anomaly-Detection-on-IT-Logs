import pandas as pd
import random
import nltk
from markov_chains import Markov

filename = "/Users/necronet/Documents/repos/tensorflow-sink/data/data/logfile500k.csv"
data_chunks = pd.read_csv(filename, chunksize=250, header=None)

markov = Markov()
#print(markov.generate_markov_text())

for chunk in data_chunks:
    change_log = chunk.sample(1)
    change_log.iloc[0,4] = markov.generate_markov_text()
    #change_log.iloc[0,4] = markov.generate_markov_text()
    #print(change_log)
    chunk = chunk.append(change_log)
    chunk.to_csv('/Users/necronet/Documents/repos/tensorflow-sink/data/data/noisy_logs.log', mode='a')
    #break
