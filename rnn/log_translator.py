from optparse import OptionParser
import pandas as pd

class LogTranslator:
    def __init__(self, data_path):
        self.data_path = data_path
        self.keys = pd.read_csv(self.template_file())

    def template_file(self):
        return "{}.csv_templates.csv".format(self.data_path)

    def translate(self,id):
        return self.keys[self.keys.EventId==id].iloc[0].EventTemplate

if "__main__"==__name__:
    parser = OptionParser()
    (options, args) = parser.parse_args()
    if len(args) == 1:
        translator = LogTranslator(args[0])
        print(translator.translate("c1497a41"))
