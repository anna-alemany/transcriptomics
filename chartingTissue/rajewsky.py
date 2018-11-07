import pandas as pd
import numpy as np
from scipy.spatial.distance import pdist, squareform
from sklearn.neighbors import NearestNeighbors
import itertools as it
from multiprocessing import Pool

# gastruloid dimensions (as a rectangle)
radi = 3. # 
length = 15. #
Mx = 10
My = 20
Mpos = pd.DataFrame([(x,y) for x in np.linspace(0,length,Mx) for y in np.linspace(-radi,radi,My)], columns=['x','y'])

MpairDist = pd.DataFrame(squareform(pdist(Mpos, metric = 'euclidean')))
Mnnbs = NearestNeighbors(n_neighbors=10, algorithm='ball_tree', metric = 'euclidean').fit(Mpos)
Mnngraph = pd.DataFrame(Mnnbs.kneighbors_graph(Mpos).toarray()).astype(int)

def rmIdx(df, idx):
    df = df.T
    del df[idx]
    df = df.T
    return df

def nodeDistance(MpairDist, path):
    d = np.sum([MpairDist.loc[path[i],path[i+1]] for i in range(len(path)-1)])
    return d

def heuristicDist(MpairDist, path, x1):
    d = nodeDistance(MpairDist, path) + MpairDist.loc[path[-1],x1]
    return d

def findShortPathAstar(x0, x1, Mnngraph, MpairDist):        
    x = x0
    path = [str(x)]
    dd = pd.DataFrame([0,np.infty], index = ['w','d'], columns = path).T.sort_values(by=['d','w'])
    
    while True:
        path = [int(x) for x in dd.index[0].rsplit('-')]
        x = path[-1]
        if x == x1:
            break
        if len(dd) == 0:
            print 'Increase neighbor number'
            return np.nan
        queue = [idx for idx in Mnngraph.columns[Mnngraph.loc[x]!=0] if idx not in path]    
        dd0 = pd.DataFrame(columns=['w','d'])
        for i in queue:
            p0 = path + [i]
            dd0.loc['-'.join([str(k) for k in p0])] = [nodeDistance(MpairDist,p0), heuristicDist(MpairDist, p0, x1)]
        dd = pd.concat([dd,dd0])
        dd = rmIdx(dd, dd.index[0])
        cnt = Counter([str(x.rsplit('-')[-1]) for x in dd.index])
        for i in cnt:
            if cnt[i] > 1:
                paths = [idx for idx in dd.index if idx.rsplit('-')[-1]==i]
                pm = dd.loc[paths].index[dd.loc[paths,'w'] == dd.loc[paths,'w'].min()][0]
                for p in paths:
                    if p != pm:
                        dd = rmIdx(dd, p)
        dd = dd.sort_values(by = ['d','w'])
    return dd.iloc[0]

def findShortPathAStar_p(x):
    x0, x1, Mnngraph, MpairDist = x
    return findShortPathAstar(x0, x1, Mnngraph, MpairDist)

Dphys = pd.DataFrame(0, columns = Mnngraph.columns, index = Mnngraph.index)

p = Pool(8)

for dd in p.imap_unordered(findShortPathAStar_p, [(x0,x1,Mnngraph,MpairDist) for x0,x1 in it.product(Mnngraph.columns,Mnngraph.columns)]):
    x0 = int(dd.name.rsplit('-')[0])
    x1 = int(dd.name.rsplit('-')[-1])
    print x0, x1
    Dphys.loc[x0, x1] = dd['w']
