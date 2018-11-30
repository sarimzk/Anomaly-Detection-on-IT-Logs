import warnings
warnings.filterwarnings("ignore", message="numpy.dtype size changed")
warnings.filterwarnings("ignore", message="numpy.ufunc size changed")
import pandas as pd
import random
import nltk
from markov_chains import Markov
from optparse import OptionParser

if "__main__"==__name__:
    parser = OptionParser()
    (options, args) = parser.parse_args()

    if len(args) == 2:

        #filename = "/Users/necronet/Documents/repos/tensorflow-sink/data/data/logfile500k.csv"
        filename = args[0]
        start_noise_from = float(args[1])
        data_chunks = pd.read_csv(filename, chunksize=1000, header=None)

        markov = Markov()

        for chunk in data_chunks:
            change_log = chunk.sample(1)
            #change_log.iloc[0,4] = markov.generate_markov_text()
            current_line = change_log.iloc[0,0]
            if current_line > start_noise_from:
                change_log.iloc[0,3] = "anomaly"
                change_log.iloc[0,4] = markov.generate_markov_text()
                chunk = chunk.append(change_log)

            chunk.to_csv('./noisy_logs.log', mode='a')
