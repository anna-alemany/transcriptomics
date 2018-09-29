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
xdf = {ch: df_ch for ch, df_ch in df.groupby('gene_id')}

def findGeneIntrons(df):
    idf = pd.DataFrame(columns = ['chr','start','end','strand','gene_name']); ni = 0
    ni = 0
    trans_gdf = {ch: df_ch for ch, df_ch in df.groupby('transcript_id') if ch != '-'}
    for transID in trans_gdf.keys():
        tdf = {ch: df_ch for ch, df_ch in trans_gdf[transID].groupby('feature')}
        x0, x1 = tdf['transcript'].iloc[0][['start','end']]
        for idx in tdf['exon'][['start','end']].sort_values(by='start').index:
            xa, xb = tdf['exon'].loc[idx,['start','end']]
            if xa > x0:
                ni += 1
                chrm, strand, genename = tdf['exon'].loc[idx,['seqname','strand','gene_name']]
                idf.loc[ni] = [chrm, x0, xa-1, strand, genename]
            x0 = xb
        if xb < x1:
            ni += 1
            chrm, strand, genename = tdf['exon'].loc[idx,['seqname','strand','gene_name']]
            idf.loc[ni] = [chrm, x0, xa-1, strand, genename]
    return idf

idf = pd.DataFrame(columns = ['chr','start','end','strand','gene_name']); ni = 0

from multiprocessing import Pool
p = Pool(8)
for mdf in p.imap_unordered(findGeneIntrons, [xdf[g] for g in xdf.keys()]):
    idf = idf.append(mdf)

idf = idf.sort_values(by=['chr','start'])

### extract exons ###
xdf = {ch: df_ch for ch, df_ch in df.groupby('feature')}
edf = xdf['exon'][['seqname','start','end','strand','gene_name']]
edf.columns = ['chr','start','end','strand','gene_name']

idf.to_csv(output + '_introns.bed', sep = '\t', index = None)
edf.to_csv(output + '_exons.bed', sep = '\t', index = None)
