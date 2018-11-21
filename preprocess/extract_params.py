from optparse import OptionParser
import re
import warnings
warnings.filterwarnings("ignore", message="numpy.dtype size changed")
warnings.filterwarnings("ignore", message="numpy.ufunc size changed")
import pandas as pd

def diff(l1, l2):
        l2 = set(l2)
        return [item for item in l1 if item not in l2]

def extract_params(time, message, template):
    params = [time]

    if message is not None:

        seq = [x for x in re.split(r'[\s=:,]', message) if x != '']
        seq2 = [x for x in re.split(r'[\s=:,]', template) if x != '']
        params.extend(diff(seq,seq2))

    return params


def load_csv(filename):
    return pd.read_csv(filename)

if __name__=='__main__':
    parser = OptionParser()
    (options, args) = parser.parse_args()
    if len(args) == 1:
        spell_file_path = args[0]
        print('Parametarized the data {}'.format(spell_file_path))
        structured_file = "{}.csv_structured.csv".format(spell_file_path)
        structured_data = load_csv(structured_file)
        print('Data loaded')

        #structured_data.apply(lambda ix: extract_params(structured_data.Content[ix],structured_data.EventTemplate[ix]), axis=1)
        structured_data['Params'] = structured_data.apply(lambda ix: extract_params(ix.Time,ix.Content,ix.EventTemplate), axis=1)
        print('Params extracted')
        structured_data.to_csv('{}-parametarized.csv'.format(spell_file_path))
        
