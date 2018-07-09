import sys, os
import numpy as np
from collections import Counter
import pandas as pd

class samSingleRead(object):

    def __init__(self, read):
        self.qname = read[0]
        self.flag = read[1]
        self.rname = read[2]
        self.pos = read[3]
        self.mapq = int(read[4])
        self.cigar = read[5]
        self.rnext = read[6]
        self.pnext = read[7]
        self.tlen = read[8]
        self.seq = read[9]
        self.qual = read[10]
        self.opt = {}
        if len(read) > 11:
            for i in range(11,len(read)):
                l = read[i].rsplit(':')
                if l[1] == 'i':
                    self.opt[l[0]] = int(l[2])
                elif l[1] == 'f':
                    self.opt[l[0]] = float(l[2])
                else:
                    self.opt[l[0]] = l[2]
        return

    def isMapped(self):
        k = bin(int(self.flag))[2:].zfill(12)
        return k[-3] == '0'

    def isUniquelyMapped(self): # defined for bwa MEM but
        return self.mapq >= 20 and 'XA' not in self.opt and 'SA' not in self.opt

    def isReverseStrand(self):
        k = bin(int(self.flag))[2:].zfill(12)
        return k[-5] == '1'
        
### Initialize ###

try:
    inputSamFile = sys.argv[1]
except:
    sys.exit('Please, give input samefile')

if not os.path.isfile(inputSamFile):
    sys.exit('samfile not found')
    
### Count ####
cnt = {}
with open(inputSamFile) as f:
    for line in f:
        if line[0] == '@':
            continue
        r = line.rstrip()
        r = r.rsplit('\t')
        read = samSingleRead(r)

        if read.isMapped() and read.isUniquelyMapped() and not read.isReverseStrand():
            gene = read.rname
            umi = read.qname.rsplit(':')[-3]
            cell = read.qname.rsplit(':')[-1]
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
    if x == K:
        t = np.log(1.-(float(x)-1e-3)/K)/np.log(1.-1./K)
    else:
        t = np.log(1.-float(x)/K)/np.log(1.-1./K)
    return int(round(t))

tdf = bdf.applymap(bc2trans)

### output tables ####
cdf.index.name = 'GENEID'
bdf.index.name = 'GENEID'
tdf.index.name = 'GENEID'

ftrunk = inputSamFile[:-4]

cdf.to_csv(ftrunk + '.coutc.tsv', sep = '\t')
bdf.to_csv(ftrunk + '.coutb.tsv', sep = '\t')
tdf.to_csv(ftrunk + '.coutt.tsv', sep = '\t')

### log file ####
f = open(ftrunk + '.log', 'a')
print >> f, 'reads mapped:', cdf.sum().sum()
print >> f, 'mappability:', 1.0*cdf.sum().sum()/idx
f.close()
