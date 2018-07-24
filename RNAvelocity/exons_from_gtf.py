import sys, os
from pandas.io.parsers import read_csv
import numpy as np
import pandas as pd

try:
    gtffile = sys.argv[1]
    outputfile = sys.argv[2]
except:
    sys.exit("Please, give: (1) gtf file; (2) exons")

#### Convert gtf file in an easy to handle data frame ####
df = read_csv(gtffile, comment='#', header=None, sep = '\t')
df.columns = ['seqname', 'source', 'feature', 'start', 'end', 'score', 'strand', 'frame', 'attribute']
df['attribute'] = [{f.rsplit()[0]:f.rsplit()[1].replace('"','') for f in df.loc[idx,'attribute'].rsplit(';') if len(f.rsplit())==2} for idx in df.index]

ats = set()
for idx in df.index:
    ats.update(df.loc[idx, 'attribute'].keys())

for c in ats:
    df[c] = [a[c] if c in a else '-' for a in df['attribute']]

del df['attribute']

#### extract exons ####
xdf = {ch: df_ch for ch, df_ch in df.groupby('feature')}
exondf = df.groupby('feature')['exon']

edf = allexondf.groupby(['seqname','start','end','strand','gene_name'])
edf2 = pd.DataFrame(edf.groups.keys(), columns=['chr','start','end','strand','gene_name'])
edf2 = edf2.sort_values(by='chr')

edf2.to_csv(outptufile, sep = '\t', index = None, header = None)
