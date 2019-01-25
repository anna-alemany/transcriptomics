import sys, os
from pandas.io.parsers import read_csv
import numpy as np
import pandas as pd
from collections import Counter

try:
    bedintronfile=sys.argv[1]
    bedexonfile = sys.argv[2]
    output = sys.argv[3]
except:
    sys.exit("Please, provide input bed (1) intron and (2) exon files; (3) output file")

def getCellUmi(h):
    d = {}
    if h[0] == '@':
        h = h[1:]
    for l in h.rsplit(';'):
        k, v = l.rsplit(':')
        d[k] = v
    return d['CBI'].zfill(3), d['UMI']


cnt = {}
for label, bedfile in [('intron', bedintronfile), ('exon', bedexonfile)]:
    with open(bedfile) as f:
        for line in f:
            ch, x0, x1, name, strand, gene = line.rsplit('\t')
            gene = '__'.join([gene.rstrip(), ch])
#            cell, umi = getCellUmi(name)
            umi = name.rsplit(':')[-3]
            cell = name.rsplit(':')[-1]
            try:
                cnt[cell][gene][umi].update([label])
            except:
                try:
                    cnt[cell][gene][umi] =  Counter([label])
                except:
                    try:
                        cnt[cell][gene] = {umi: Counter([label])}
                    except:
                        cnt[cell] = {gene: {umi: Counter([label])}}

df = pd.DataFrame(cnt)

def countUnsplicedReads(x):
    y = 0
    if type(x) == dict:
        for umi in x:
            if 'intron' in x[umi]:
                y += x[umi]['intron']
    return y

def countSplicedReads(x):
    y = 0
    if type(x) == dict:
        for umi in x:
            if 'intron' not in x[umi]:
                y += x[umi]['exon']
    return y

def countTotalReads(x):
    y = 0
    if type(x) == dict:
        y = sum([d[umi][ex] for umi in x for ex in x[umi]])
    return y

def countUnsplicedMolecules(x):
    y = 0
    if type(x) == dict:
        for umi in x:
            if 'intron' in x[umi]:
                y += 1
    return y

def countSplicedMolecules(x):
    y = 0
    if type(x) == dict:
        for umi in x:
            if 'intron' not in x[umi]:
                y += 1
    return y

def countReads(x):
    y = 0
    if type(x) == dict:
        for umi in x:
            for label in x[umi]:
                y += x[umi][label]
    return y
    
def bc2trans(x):
    if x >= K:
        t = np.log(1.-(float(K)-1e-3)/K)/np.log(1.-1./K)
    elif x > 0 and x < K:
        t = np.log(1.-float(x)/K)/np.log(1.-1./K)
    elif x == 0:
        t = 0
    return  t

udf = df.applymap(countUnsplicedReads)
sdf = df.applymap(countSplicedReads)

udf.to_csv(output + '_unspliced.coutc.tsv', sep = '\t')
sdf.to_csv(output + '_spliced.coutc.tsv', sep = '\t')

udf = df.applymap(countUnsplicedMolecules)
sdf = df.applymap(countSplicedMolecules)
bdf = df.applymap(lambda x: len(x) if type(x)==dict else 0)

udf.to_csv(output + '_unspliced.coutb.tsv', sep = '\t')
sdf.to_csv(output + '_spliced.coutb.tsv', sep = '\t')
bdf.to_csv(output + '_total.coutb.tsv', sep = '\t')

K = 4**len(umi)

tudf = udf.applymap(bc2trans)
tsdf = sdf.applymap(bc2trans)
tbdf = bdf.applymap(bc2trans)

tudf.to_csv(output + '_unspliced.coutt.tsv', sep = '\t')
tsdf.to_csv(output + '_spliced.coutt.tsv', sep = '\t')
tbdf.to_csv(output + '_total.coutt.tsv', sep = '\t')
