import sys, os
from pandas.io.parsers import read_csv
import numpy as np
import pandas as pd

gtffile = 'transcripts.gtf'

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

#### focus on trancripts ####
ddf = {k: df_k for k, df_k in df.groupby('feature')}
tdf = ddf['transcript']
xdf = pd.Series({tdf.loc[idx, 'transcript_id']: '__chr'.join([tdf.loc[idx, 'gene_name'], str(tdf.loc[idx, 'seqname'])]) for idx in tdf.index})

xdf.to_csv('transcript2geneID_mm10_fromGTF.tsv', sep = '\t')
