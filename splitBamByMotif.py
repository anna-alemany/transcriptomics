import sys, os
from pandas.io.parsers import read_csv
import numpy as np
from collections import Counter
import pandas as pd
import pysam

### Initialize ###

try:
    inputBamFile = sys.argv[1]
    motifnum = int(sys.argv[2])
    motifs = []
    for i in range(motifnum):
        motifs.append(sys.argv[3+i])
except:
    sys.exit('Please, give input (1) bamfile')

if not os.path.isfile(inputBamFile):
    sys.exit('bamfile not found')

bamfile = pysam.AlignmentFile(inputBamFile, 'rb')
output = inputBamFile[:-4]
fout = [pysam.AlignmentFile(output + '_' + m + '.bam','wb', template = bamfile) for m in motifs]

def reverseseq(seq):
    d = {'A': 'T', 'C': 'G', 'T': 'A', 'G': 'C', 'N': 'N'}
    rs = ''.join([d[s] for s in seq][::-1])
    return rs

for idx, r in enumerate(bamfile.fetch(until_eof = True)):
    if r.flag == 0:
        x = [r.seq[:len(m)]==m for m in motifs]
        if sum(x) == 1:
            idx = x.index(True)
            fout[idx].write(r)

    if r.flag == 16:
        seq = reverseseq(r.seq)
        x = [seq[:len(m)]==m for m in motifs]
        if sum(x) == 1:
            idx = x.index(True)
            fout[idx].write(r)

sys.exit()
