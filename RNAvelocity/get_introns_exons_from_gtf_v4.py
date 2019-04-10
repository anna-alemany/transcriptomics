#!/usr/bin/env python3
import sys, os
from pandas.io.parsers import read_csv
import numpy as np
import pandas as pd
import multiprocessing

try:
    gtffile = sys.argv[1]
    outputfile = sys.argv[2]
except:
    sys.exit("Please, give: (1) gtf file; (2) exons")

#### Convert gtf file in an easy to handle data frame ####
df = read_csv(gtffile, comment='#', header=None, sep = '\t', low_memory = False)
df.columns = ['seqname', 'source', 'feature', 'start', 'end', 'score', 'strand', 'frame', 'attribute']
df['seqname'] = df['seqname'].astype(str)
df['attribute'] = [{f.rsplit()[0]:f.rsplit()[1].replace('"','') for f in df.loc[idx,'attribute'].rsplit(';') if len(f.rsplit())==2} for idx in df.index]

ats = set()
for idx in df.index:
    ats.update(df.loc[idx, 'attribute'].keys())

for c in ats:
    df[c] = [a[c] if c in a else '-' for a in df['attribute']]

del df['attribute']

### extract introns ###

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
                chrm, strand, genename = tdf['exon'].loc[idx,['seqname','strand','gene_id']]
                idf.loc[ni] = [chrm, x0, xa-1, strand, genename]
            x0 = xb
        if xb < x1:
            ni += 1
            chrm, strand, genename = tdf['exon'].loc[idx,['seqname','strand','gene_id']]
            idf.loc[ni] = [chrm, x0, xa-1, strand, genename]
    return idf

def findGeneIntrons_v2(gddf):
    geneid, ddf = gddf
    idf = pd.DataFrame(columns = ['chr','start','end','strand','gene_name']); ni = 0
    edf = pd.DataFrame(columns = ['chr','start','end','strand','gene_name']); ne = 0
    xa, xb = ddf[ddf['feature']=='gene'][['start','end']].values[0]
    ch, strand = ddf[ddf['feature']=='gene'][['seqname', 'strand']].values[0]
    exon_pos = []
    for x0, x1 in ddf[ddf['feature']=='exon'][['start','end']].values:
        exon_pos += range(x0, x1+1)
    exon_pos = set(exon_pos)
    intron = False
    exon = False
    for x in range(xa, xb+1):
        if x not in exon_pos and not intron:
            intron = True
            x0 = x
        if x in exon_pos and intron:
            x1 = x-1
            ni += 1
            idf.loc[ni] = [ch, x0, x1, strand, geneid]
            intron = False
        if x in exon_pos and not exon:
            exon = True
            xe0 = x
        if x not in exon_pos and exon:
            xe1 = x-1
            ne += 1
            edf.loc[ne] = [ch, xe0, xe1, strand, geneid]
            exon = False
        if exon and intron:
            print('ep!')
    if exon:
        ne += 1
        edf.loc[ne] = [ch, xe0, x, strand, geneid]
    if intron:
        ni += 1
        idf.loc[ni] = [ch, x0, x, strand, geneid]
    return edf, idf

idf = pd.DataFrame(columns = ['chr','start','end','strand','gene_name'])
edf = pd.DataFrame(columns = ['chr','start','end','strand','gene_name'])

#xdf = {ch: df_ch for ch, df_ch in df.groupby('gene_id')}
xdf = {'_'.join(ch): df_ch for ch, df_ch in df.groupby(['gene_id','gene_name','gene_biotype'])}

from multiprocessing import Pool
p = Pool(8)
for exdf,indf in p.imap_unordered(findGeneIntrons_v2, [(g,xdf[g]) for g in xdf.keys()]):
    idf = idf.append(indf)
    edf = edf.append(exdf)

idf = idf.sort_values(by=['chr','start'])
edf = edf.sort_values(by=['chr','start'])
idf.index = range(len(idf))
edf.index = range(len(edf))
#idf.to_csv('raw_introns.bed', sep = '\t')
#edf.to_csv('raw_exons.bed', sep = '\t')

### extract exons ###
xdf = {ch: df_ch for ch, df_ch in df.groupby('feature')}
tdf = xdf['gene'][['gene_id', 'gene_name','gene_biotype']].set_index('gene_id')

egdf = edf.groupby(['chr','start','end'])
egdf2 = pd.DataFrame([edf.loc[egdf.groups[k]].values[0] for k in egdf.groups.keys() if len(set(edf.loc[egdf.groups[k]]['gene_name'])) == 1])
egdf2.columns = ['chr','start','end','strand','gene_name']
egdf2 = egdf2.sort_values(by=['chr','start'])

igdf = idf.groupby(['chr','start','end'])
igdf2 = pd.DataFrame([idf.loc[igdf.groups[k]].values[0] for k in igdf.groups.keys() if len(set(idf.loc[igdf.groups[k]]['gene_name'])) == 1])
igdf2.columns = ['chr','start','end','strand','gene_name']
igdf2 = igdf2.sort_values(by=['chr','start'])

igdf2.to_csv(outputfile + '_introns.bed', sep = '\t', index = None)
egdf2.to_csv(outputfile + '_exons.bed', sep = '\t', index = None)


