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

### extract introns ###
for idx in xdf['transcript']:
    
    
    
    
