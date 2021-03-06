import numpy as np
import pandas as pd
from collections import Counter
from scipy.stats import binom
from scipy.cluster.hierarchy import dendrogram, linkage
from multiprocessing import Pool
from MulticoreTSNE import MulticoreTSNE as TSNE
import sklearn.cluster as cluster

# glossary of functions #
# filterCells
# zscore
# downsample /  downsample_p
# filterGenes
# selectGenesbyCV
# findGeneInDataFrame
# findCorrGenes
# diffgeneexpr

def filterCells(df, n):
    return df[df.columns[df.sum()>n]]

def zscore(df):
    zdf = df.T
    zdf = (zdf-zdf.mean())/zdf.std()
    zdf = zdf.T
    return zdf

def dwn_p(x):
    c, v, n = x
    v = v.astype(int)
    cnt = Counter(np.random.choice([i for i in Counter(dict(v)).elements()], size=n, replace=False))
    return c, cnt

def downsample_p(fmdf, n):
    p = Pool(8)

    try:
        n = int(n)
    except:
        return 'ERR: downsampling n parameter needs to be integer'
    
    xdf = {c: Counter() for c in fmdf.columns}
    for c, cnt in p.imap_unordered(dwn_p, [(c, fmdf[c], n) for c in xdf]):
        xdf[c] = cnt

    xdf = pd.DataFrame(xdf)
    xdf = xdf.fillna(0)
    return xdf

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

def vargenes(df, n):
    df = df.loc[df.index[df.sum(axis=1)!=0]]
    cvdf = pd.DataFrame({'mu': df.mean(axis=1), 'var': df.var(axis=1)})
    cvdf['cv'] = np.sqrt(cvdf['var'])/cvdf['mu']
    cvdf['r'] = np.log10(cvdf['mu'])
    cvdf['s'] = np.log10(cvdf['cv'])
    a = -0.5; b = 0 # straight line for poisson cv
    cvdf['xmin'] = (a*cvdf['s']-a*b-cvdf['r'])/(a**2-1)
    cvdf['ymin'] = a*cvdf['xmin'] + b
    cvdf['dist'] = np.sqrt((cvdf['r']-cvdf['xmin'])**2+(cvdf['s']-cvdf['ymin'])**2)
    cvdf = cvdf.sort_values(by='dist', ascending = False)
    return cvdf.index[:n]
    
def comtsneprecomputed(cdf, rndstate):
    tsne = TSNE(n_jobs=12, metric='precomputed', random_state=rndstate, early_exaggeration = 50) #312
    Y = tsne.fit_transform(cdf)
    return pd.DataFrame({'V1': [y[0] for y in Y], 'V2': [y[1] for y in Y]}, index=cdf.columns)

def clusteringAgg(fdmdf, ncl):
    cl = cluster.AgglomerativeClustering(n_clusters=ncl).fit(fdmdf.T)
    hcl = pd.DataFrame({'cluster': cl.labels_, 'cells': dmdf.columns})
    return hcl.sort_values(by='cluster')

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

def diffgeneexpr(ndata, names1, names2, label1='mean1', label2='mean2', pvalmax = 0.01):
    mean1 = ndata[names1].sum(axis=1)
    mean1[mean1==0] = mean1[mean1>0].min()/10.
    mean2 = ndata[names2].sum(axis=1)
    mean2[mean2==0] = mean2[mean2>0].min()/10.
    trials = int(round(mean1.sum()))
    probs = mean2/mean2.sum()
    pval = binom(trials, probs).cdf(mean1)
    pval = [i if i <= 0.5 else 1-i for i in pval]
    dge = pd.DataFrame({'pval': pval, label1: mean1, label2: mean2})
    dge['fc'] = dge[label1]/dge[label2]
    dge = dge[dge['pval'] <= pvalmax]
    return dge.sort_values('fc', ascending=False)

def hierarchicalClustering(df):
    Z = linkage(df.loc[selectG], method='ward')
    dg = dendrogram(Z, no_labels=True, color_threshold=100, no_plot = True)
    plt.show()
    return Z, dg

def getClusterByColor(dg, labels):
      kk = []
      ii = 0
      cluster = 0
      color = dg['color_list'][0]
      clusters = {cluster: []}
      for i in range(len(dg['icoord'])):
          v = dg['icoord'][i]
          for j in [0,2]:
              vj = int(round((v[j]-5.)/10))
              if (v[j]-5.)/10 == vj and vj not in kk:
                  kk.append(vj)
                  if dg['color_list'][i] == color:
                      clusters[cluster].append(labels[dg['leaves'][vj]])
                  else:
                      color = dg['color_list'][i]
                      cluster += 1
                      clusters[cluster] = [labels[dg['leaves'][vj]]]
        return clusters
          
