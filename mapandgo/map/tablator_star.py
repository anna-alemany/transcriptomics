import sys, os
from pandas.io.parsers import read_csv
import numpy as np
from collections import Counter
import pandas as pd
import localInstall
localInstall.require(['pysam'])
import pysam

### Initialize ###

try:
    inputBamFile = sys.argv[1]
    transcript2geneID = sys.argv[2]
except:
    sys.exit('Please, give input (1) bamfile; (2) transcript to gene ID conversion')

if not os.path.isfile(inputBamFile):
    sys.exit('bamfile not found')

if not os.path.isfile(transcript2geneID):
    sys.exit('transcript to gene ID file not found')

bamfile = pysam.AlignmentFile(inputBamFile, 'rb')
translist =  [d['SN'] for d in bamfile.header['SQ']]
trans2gene = read_csv(transcript2geneID, sep = '\t', index_col = 0, header = None)

### Count ####
cnt = {}
for idx,r in enumerate(bamfile.fetch(until_eof = True)):
    tags = [x[0] for x in r.get_tags()]
    if r.get_tag('NH') == 1:
       gene = trans2gene.loc[translist[r.rname],1]
       umi = r.qname.rsplit(':')[-3]
       cell = r.qname.rsplit(':')[-1]
       try:
           cnt[cell][gene].update([umi])
       except:
           try:
               cnt[cell][gene] = Counter([umi])
           except:
               cnt[cell] = {gene: Counter([umi])}

df = pd.DataFrame(cnt)
cdf = df.applymap(lambda x: sum(x.values()) if type(x)==Counter else 0)
bdf = df.applymap(lambda x: len(x) if type(x)==Counter else 0)

K = 4**len(umi)
def bc2trans(x):
    if x >= K:
        t = np.log(1.-(float(K)-1e-3)/K)/np.log(1.-1./K)
    elif x > 0 and x < K:
        t = np.log(1.-float(x)/K)/np.log(1.-1./K)
    elif x == 0:
        t = 0
    return int(round(t))

tdf = bdf.applymap(bc2trans)

### output tables ####
cdf.index.name = 'GENEID'
bdf.index.name = 'GENEID'
tdf.index.name = 'GENEID'

ftrunk = inputBamFile[:-4]

cdf.to_csv(ftrunk + '.coutc.tsv', sep = '\t')
bdf.to_csv(ftrunk + '.coutb.tsv', sep = '\t')
tdf.to_csv(ftrunk + '.coutt.tsv', sep = '\t')

### log file ####
f = open(ftrunk + '.log', 'a')
print >> f, 'reads mapped:', cdf.sum().sum()
print >> f, 'mappability:', 1.0*cdf.sum().sum()/idx
print >> f, 'mean overseq:', (cdf/bdf).mean().mean()
f.close()
