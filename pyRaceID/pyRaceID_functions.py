import numpy as np
import pandas as pd
from collections import Counter

def filterCells(df, n):
    return df[df.columns[df.sum()>n]]

def downsample(df, n):
    df = df.round().astype(int)
    ddf = pd.DataFrame({c: Counter(np.random.choice([i for i in Counter(dict(df[c])).elements()], size=n, replace=False)) for c in df.columns})
    ddf = ddf.fillna(0)
    ddf = ddf.loc[ddf.sum(axis=1).sort_values(ascending=False).index]
    ddf = ddf.astype(int)
    return ddf

def filterGenes(df, ncell, minexpr):
    return df.loc[df.index[(((df>minexpr)*df)>0).sum(axis=1)>=ncell]]
    
