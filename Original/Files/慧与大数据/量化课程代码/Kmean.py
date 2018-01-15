import numpy as np
import matplotlib.pyplot as plt
from sklearn.datasets import make_blobs
from sklearn.cluster import KMeans
import pdb

def kmeanDIY(Samples, k):
    Samples=np.array(Samples) #生成numpy数组；
    nSamples=Samples.shape[0]
    pointSelected = np.random.choice(nSamples, k, replace=False)
    centroids = Samples[pointSelected, :].copy() #生成随机聚类中心；

    # Kmeans++
    centroids=Samples[np.random.randint(0,nSamples,1),:].copy() #随机选择一个样本作为聚类中心；
    tmp=np.argmax(np.sum(np.square(Samples-centroids),axis=1)) #选择第二个样本作为聚类中心
    centroids=np.row_stack([Samples[tmp].copy(),centroids]) #合并聚类中心
    if k>2: #如果聚类中心大于2个的话；
        for i2 in range(2,k): #遍历剩余聚类中心
            distances=[]
            for i in range(nSamples): #遍历所有样本点
                distances.append(min(np.sum(np.square(Samples[i] - centroids), axis=1)))
            tmp=np.argmax(distances)
            centroids = np.row_stack([Samples[tmp].copy(), centroids])

    clusterAssment=np.zeros([nSamples,2]) #创建[nSamples X k ]二维数组记录聚类详情,第1列记录该样本属于哪个聚类中心，第二列记录该点距离聚类中心的距离；
    clusterChanged = True
    while clusterChanged:
        clusterChanged = False

        # Dtmp=np.sum(np.square(Samples[:,np.newaxis,:]-centroids),axis=2) #代替两个for循环
        # IndexT=np.argmin(Dtmp,axis=1)
        # if (~np.equal(clusterAssment[:,0],IndexT)).sum():
        #     clusterChanged=True
        #     tmp=[Dtmp[i,IndexT[i]] for i in range(len(IndexT))]
        #     clusterAssment=np.column_stack([IndexT,tmp])

        for i in range(nSamples): #遍历每一个样本；
            minIndex = 0 #记录距离哪个聚类中心最近；
            minDist  = np.inf #记录距离最近聚类中心的距离；
            # distances=np.square(np.sum(np.square(Samples[i]-centroids),axis=1))#代替一个for循环
            # minIndex=np.argmin(distances)
            # minDist=distances[minIndex]
            for j in range(k): #遍历每个聚类中心；
                distance=sum(np.square(Samples[i]-centroids[j]))#计算距离；
                if distance < minDist: #判断是否有更近的聚类中心点出现；
                    minDist  = distance
                    minIndex = j
            if clusterAssment[i, 0] != minIndex: #判断该点是否需要更新聚类中心；
                clusterChanged = True
                clusterAssment[i, :] = minIndex, minDist

        for j in range(k): #遍历每个聚类中心
            pointsInCluster = Samples[clusterAssment[:,0]==j,:]
            centroids[j, :] = np.mean(pointsInCluster, axis = 0)

        # for i in range(k):  # 遍历所有聚类中心
        #     tmp = clusterAssment[:, 0] == i  # 选择属于i个聚类中心点的index;
        #     tmp = Samples[tmp, :]  # 选出这些点
        #     plt.scatter(tmp[:, 0], tmp[:, 1], c=colors[i], s=50)
        # plt.show()

    return centroids, clusterAssment

X,y=make_blobs(n_samples=150,n_features=2,centers=3,cluster_std=0.5,random_state=0) #生成随机点；

#plt.scatter(X[:,0],X[:,1],c='k',marker='o',s=50)
nClusters=3
colors=['k','g','r','y','c','tan','gold','gray','steelblue','darkred']

# centroids,clusterAssment=kmeanDIY(X,nClusters)
# for i in range(nClusters): #遍历所有聚类中心
#     tmp=clusterAssment[:,0]==i #选择属于第i个聚类中心点的index;
#     tmp=X[tmp,:] #选出这些点
#     plt.scatter(tmp[:,0],tmp[:,1],c=colors[i],s=50)
# plt.show()

loss=[] #做肘形图；
for i in range(2,7):
    _, clusterAssment = kmeanDIY(X, i) #返回距离值
    loss.append(sum(clusterAssment[:,1]))
plt.plot(list(range(2,7)),loss)
plt.show()



































