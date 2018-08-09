import numpy as np
import pandas as pd
from collections import Counter
# glossary of functions #
# 1) filterCells
# 2) downsample
# 3) filterGenes
# 4) selectGenesbyCV
# 5) findGeneInDataFrame


def filterCells(df, n):
    return df[df.columns[df.sum()>n]]

def downsample(df, n, DS = 1, seed = 12345):
    np.random.seed(seed)
    df = df.round().astype(int)
    try:
        n = int(n)
    except:
        return 'ERR: Downsampling parameter needs to be integer' 
    if any(df.sum() < n):
        return "ERR: Please, decrease downsampling size"
    ddf = [0 for i in range(DS)]
    for i in range(DS):
        ddf[i] = pd.DataFrame({c: Counter(np.random.choice([i for i in Counter(dict(df[c])).elements()], size=n, replace=False)) for c in df.columns})
        ddf[i] = ddf[i].fillna(0)
        ddf[i] = ddf[i].loc[ddf[i].sum(axis=1).sort_values(ascending=False).index]
        ddf[i] = ddf[i].astype(int)
    if DS == 1:
        ddf = ddf[0]
    return ddf

def filterGenes(df, ncell, minexpr):
    return df.loc[df.index[(((df>minexpr)*df)>0).sum(axis=1)>=ncell]]

def selectGenesbyCV(df, n):
    cvdf = pd.DataFrame({'mu': df.mean(axis=1), 'cv': df.std(axis=1)/df.mean(axis=1)})
    a = True
    Ct = 1e3
    while a:
        gs = cvdf.index[Ct/np.sqrt(cvdf['mu']) < cvdf['cv']]
        if len(gs) < n:
            Ct = Ct-0.1
        else:
            a = False
    return gs  
    
def findGeneInDataFrame(g, df):
    x = [idx for idx in df.index if g in idx]
    return x

def findCorrGenes(df, g):
    gene = [idx for idx in df.index if g in idx]
    df = df.T
    if len(gene) == 0:
        print 'gene not found'
        return
    elif len(gene) > 1:
        print gene
        print 'Please, be more specific'
        return
    elif len(gene) == 1:
        gene = gene[0]
        cdf = pd.DataFrame(columns = [gene + '-Pearson', gene + '-Spearman'])
        for col in df.columns:
            if df[col].sum() > 0:
                cdf.loc[col] = [df[[col, gene]].corr().iloc[0,1], df[[col, gene]].corr('spearman').iloc[0,1]]
    cdf = cdf.sort_values(by = cdf.columns[0], ascending = False)
    return cdf
