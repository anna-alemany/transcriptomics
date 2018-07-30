import numpy as np
import pandas as pd
from collections import Counter

def filterCells(df, n):
    return df[df.columns[df.sum()>n]]

def downsample(df, n):
    df = df.round().astype(int)
    try:
        n = int(n)
    except:
        return "ERR: downsampling parameter needs to be a number"
    ddf = pd.DataFrame({c: Counter(np.random.choice([i for i in Counter(dict(df[c])).elements()], size=n, replace=False)) for c in df.columns})
    ddf = ddf.fillna(0)
    ddf = ddf.loc[ddf.sum(axis=1).sort_values(ascending=False).index]
    ddf = ddf.astype(int)
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
    
