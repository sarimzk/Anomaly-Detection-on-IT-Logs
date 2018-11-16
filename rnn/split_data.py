from optparse import OptionParser
import warnings
warnings.filterwarnings("ignore", message="numpy.dtype size changed")
warnings.filterwarnings("ignore", message="numpy.ufunc size changed")
import pandas as pd

# From: https://cs230-stanford.github.io/train-dev-test-split.html

if __name__=="__main__":
    parser = OptionParser()
    (options, args) = parser.parse_args()
    if len(args) == 1:
        filename = args[0]
        #filename = '/Users/necronet/Documents/repos/tensorflow-sink/data/data/logfile500k.csv'
        data = pd.read_csv(filename)

        split_1 = int(0.8 * len(data))
        split_2 = int(0.9 * len(data))

        train_data = data[:split_1]
        valid_data = data[split_1:split_2]
        test_data = data[split_2:]

        train_data.to_csv('{}-train.csv'.format(filename.split(".")[0]))
        test_data.to_csv('{}-test.csv'.format(filename.split(".")[0]))
        valid_data.to_csv('{}-valid.csv'.format(filename.split(".")[0]))
