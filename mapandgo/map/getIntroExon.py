import sys, os
import sys, os
from pandas.io.parsers import read_csv
import numpy as np
import pandas as pd
from collections import Counter
import pickle

try:
    bedfile = sys.argv[1]
    gtffile = sys.argv[2]
except:
    sys.exit("Please, give: (1) bed file; (2) gtf file")

#### Convert gtf file in an easy to handle data frame ####
df = read_csv(gtffile, comment='#', header=None, sep = '\t')
df.columns = ['seqname', 'source', 'feature', 'start', 'end', 'score', 'strand', 'frame', 'attribute']
df['attribute'] = [{f.rsplit()[0]:f.rsplit()[1].replace('"','') for f in df.loc[idx,'attribute'].rsplit(';') if len(f.rsplit())==2} for idx in df.index]

#ats = set(df.loc[idx, 'attribute'].keys() for idx in df.index)
for c in ['gene_name']: #ats:
    df[c] = [a[c] if c in a else '-' for a in df['attribute']]

del df['attribute']

#### split gtf file in seqname dataframes ####
xdf = {ch: df_ch for ch, df_ch in df.groupby('seqname')}

#### count ####
cnt = {}; name0 = ''

with open(bedfile, 'r') as f:
    for line in f:
        ch, x0, x1, name, q, strand, cell, umi = line.rsplit('\t')
        x0 = int(x0); x1 = int(x1); ch = int(ch)
        obs = set()
        umi = umi.rstrip()
        for x in range(x0+1,x1+1):
            gdf = xdf[ch][(xdf[ch]['start']<x)&(xdf[ch]['end']>x)]
            if len(set(gdf['gene_name'])) == 1 and all(gdf['strand']==strand) and Counter(gdf['feature'])['transcript']==1:
                gene = gdf['gene_name'].iloc[0]
                if 'exon' in list(gdf['feature']):
                    obs.add('exon')
                else:
                    obs.add('intron')
        for p in obs:
            try:
                cnt[cell][gene][p].update([umi])
            except:
                try:
                    cnt[cell][gene] = {'exon': Counter(), 'intron': Counter(), 'splicing': Counter()}
                except:
                    cnt[cell] = {gene: {'exon': Counter(), 'intron': Counter(), 'splicing': Counter()}}
                cnt[cell][gene][p].update([umi])

        if name == name0 and len(obs)>=1 and name0 != '':
            cnt[cell][gene]['splicing'].update([umi])

        name0 = name

cdf = pd.DataFrame(cnt)

introndfb = cdf.applymap(lambda x: len(x['intron']) if type(x)==dict and type(x['intron'])==Counter else 0)
exondfb = cdf.applymap(lambda x: len(x['exon']) if type(x)==dict and type(x['exon'])==Counter else 0)
splicdfb = cdf.applymap(lambda x: len(x['splicing']) if type(x)==dict and type(x['splicing'])==Counter else 0)

introndfb.to_csv( bedfile[:bedfile.index('.bed')] + '_introns.coutb.tsv', sep = '\t')
exondfb.to_csv( bedfile[:bedfile.index('.bed')] + '_exons.coutb.tsv', sep = '\t')
splicdfb.to_csv( bedfile[:bedfile.index('.bed')] + '_splicing.coutb.tsv', sep = '\t')

introndfc = cdf.applymap(lambda x: sum(x['intron'].values()) if type(x)==dict and type(x['intron'])==Counter else 0)
exondfc = cdf.applymap(lambda x: sum(x['exon'].values()) if type(x)==dict and type(x['exon'])==Counter else 0)
splicdfc = cdf.applymap(lambda x: sum(x['splicing'].values()) if type(x)==dict and type(x['splicing'])==Counter else 0)

introndfc.to_csv( bedfile[:bedfile.index('.bed')] + '_introns.coutc.tsv', sep = '\t')
exondfc.to_csv( bedfile[:bedfile.index('.bed')] + '_exons.coutc.tsv', sep = '\t')
splicdfc.to_csv( bedfile[:bedfile.index('.bed')] + '_splicing.coutc.tsv', sep = '\t')

pickle.dump(cdf, open(bedfile[:bedfile.index('.bed')] + '.pickle','w'))
