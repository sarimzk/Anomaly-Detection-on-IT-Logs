import Spell
import sys
import numpy as np
sys.path.append('../')

input_dir  = '/Users/necronet/Documents/repos/cse741/data'
log_format = '<Time> <Machine> <Daemon> <Content>'
log_file   = 'logfilemarch-10K.csv'
taus = np.arange(0.1,0.9,0.2)

for tau in taus:
    tau = np.around(tau,2)
    output_dir = 'Spell_result-{}/'.format(tau)
    regex  = []
    parser = Spell.LogParser(indir=input_dir,outdir=output_dir, log_format=log_format, tau=tau, rex=regex)
    parser.parse(log_file)
