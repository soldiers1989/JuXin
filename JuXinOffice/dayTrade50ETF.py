# -*- coding: utf-8 -*-
"""
Created on Wed Oct 11 15:36:46 2017

@author: Administrator
"""

from WindPy import *
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.finance as mpf
import datetime,pickle,pdb


timeStart='2014-01-01'
timeEnd=(datetime.date.today()-timedelta(days=1)).strftime('%Y-%m-%d')

stopAbsList=np.linspace(0.001,0.015,10)
stopMovList=np.linspace(0.001,0.020,20)
ratioVList=[0.5,0.6,0.7,0.75,0.8,0.85,0.9,1.0]
fig=2

try:
    tem=open('dayTrade50ETF','rb')
    dataPKL=pickle.load(tem)
    tem.close()
    opens=dataPKL['opens']
    closes=dataPKL['closes']
    highs=dataPKL['highs']
    lows=dataPKL['lows']
    vols=dataPKL['vols']
    times=dataPKL['times']
except:
    w.start()
    dataTem=w.wsi('510050.SH','open,high,low,close,volume',timeStart+' 09:00:00',timeEnd+' 15:01:00','periodstart=09:30:00;periodend=15:01:00;Fill=Previous;PriceAdj=F')
    opens=dataTem.Data[0]
    highs=dataTem.Data[1]
    lows=dataTem.Data[2]
    closes=dataTem.Data[3]
    vols=dataTem.Data[4]
    times=dataTem.Times
    dataPKL={'opens':opens,'highs':highs,'lows':lows,'closes':closes,'vols':vols,'times':times}
    tem=open('dayTrade50ETF','wb')
    pickle.dump(dataPKL,tem)
    tem.close()
loops=len(opens)//241
ReAll=[]
stop=[]
maxOrder=5

for j1 in stopAbsList:
    for j2 in stopMovList:
        for j3 in ratioVList:
            stopAbs=j1
            stopMov=j2
            ratioV=j3
            Re=[]
            for i in range(loops):
                Open=opens[i*241:(i+1)*241]
                Close=closes[i*241:(i+1)*241]
                High=highs[i*241:(i+1)*241]
                Low=lows[i*241:(i+1)*241]
                Vol=vols[i*241:(i+1)*241]
                i2=5
                xi1=[]
                xi2=[]
                yi1=[]    
                yi2=[]
                colori=[]
                while i2<236:
                    maxV=np.mean(Vol[i2-5:i2])
                    if Vol[i2]>maxV*ratioV and Vol[i2+1]>maxV*ratioV:
                        priceOpen=[Open[i2+3]]
                        barOpen=[i2+3]
                        if round(Close[i2+2],3)>=round(Open[i2+2],3):
                            Hold=1
                        else:
                            Hold=-1
                        for i3 in range(i2+3,241):
                            if Hold>0:
                                for i4 in range(abs(Hold)):
                                    if Low[i3]<=priceOpen[i4]-stopAbs:
                                        Re.append(-stopAbs/priceOpen[i4]-0.0004)
                                        priceClose=priceOpen-stopAbs
                                        break
                                    elif max(High[barOpen:i3+1])-Low[i3]>=stopMov:
                                        priceClose=max(High[barOpen:i3+1])-stopMov
                                        Re.append(priceClose/priceOpen[i4]-1.0004)
                                        break
                                    else:
                                        pass
                                    
                                
                            elif Hold<0:
                                if High[i3]>=priceOpen+stopAbs:
                                    Re.append(-stopAbs/priceOpen-0.0004)
                                    priceClose=priceOpen+stopAbs
                                    break
                                if High[i3]-min(Low[barOpen:i3+1])>=stopMov:
                                    priceClose=min(Low[barOpen:i3+1])+stopMov
                                    Re.append(1-priceClose/priceOpen-0.0004)
                                    break
                            if i3==240:
                                Re.append((Close[i3]-priceOpen)*Hold/priceOpen-0.0004)  
                                priceClose=Close[i3]
                        i2=i3
                        xi1.append(barOpen)
                        xi2.append(i3)
                        yi1.append(priceOpen)
                        yi2.append(priceClose)
                        if Re[-1]>0:
                            colori.append('purple')
                        else:
                            colori.append('cyan')
                    else:
                        i2=i2+1
                    
                if fig>0 and len(xi1)>=2:
                    fig=fig-1
                    plt.figure(figsize=(25,8))
                    ax=plt.subplot2grid((3,1),(0,0),rowspan=2)
                    plt.title(times[i*241].strftime('%Y-%m-%d'))
                    candleData=np.column_stack([list(range(len(Open))),Open,High,Low,Close])
                    mpf.candlestick_ohlc(ax,candleData,width=0.5,colorup='r',colordown='g')
                    for i2 in range(len(colori)):
                        ax.plot([xi1[i2],xi2[i2]],[yi1[i2],yi2[i2]],colori[i2],linewidth=3)
                    plt.xticks(range(len(Open))[::5])
                    plt.grid()
                    ax1=plt.subplot2grid((3,1),(2,0))
                    ax1.bar(range(len(Vol)),Vol)
                    plt.xticks(range(len(Open))[::5])
                    plt.grid()
            
            ReAll.append(Re)
            stop.append([stopAbs,stopMov,ratioV])
            #plt.figure()
            #plt.plot(np.cumsum(Re))
indMax=np.argsort(list(map(sum,ReAll)))[-1]
plt.figure(figsize=(25,8))
plt.plot(np.cumsum(ReAll[indMax]))
plt.title('stopAbs:'+str(stop[indMax][0])+';stopMove:'+str(stop[indMax][1])+';ratioV:'+str(stop[indMax][2]) )








#from WindPy import *
#import numpy as np
#import matplotlib.pyplot as plt
#import matplotlib.finance as mpf
#import datetime,pickle,pdb
#
#
#timeStart='2014-01-01'
#timeEnd=(datetime.date.today()-timedelta(days=1)).strftime('%Y-%m-%d')
#
#stopAbsList=np.linspace(0.001,0.015,10)
#stopMovList=np.linspace(0.001,0.020,20)
#ratioVList=[0.5,0.6,0.7,0.75,0.8,0.85,0.9,1.0]
#fig=2
#
#try:
#    tem=open('dayTrade50ETF','rb')
#    dataPKL=pickle.load(tem)
#    tem.close()
#    opens=dataPKL['opens']
#    closes=dataPKL['closes']
#    highs=dataPKL['highs']
#    lows=dataPKL['lows']
#    vols=dataPKL['vols']
#    times=dataPKL['times']
#except:
#    w.start()
#    dataTem=w.wsi('510050.SH','open,high,low,close,volume',timeStart+' 09:00:00',timeEnd+' 15:01:00','periodstart=09:30:00;periodend=15:01:00;Fill=Previous;PriceAdj=F')
#    opens=dataTem.Data[0]
#    highs=dataTem.Data[1]
#    lows=dataTem.Data[2]
#    closes=dataTem.Data[3]
#    vols=dataTem.Data[4]
#    times=dataTem.Times
#    dataPKL={'opens':opens,'highs':highs,'lows':lows,'closes':closes,'vols':vols,'times':times}
#    tem=open('dayTrade50ETF','wb')
#    pickle.dump(dataPKL,tem)
#    tem.close()
#loops=len(opens)//241
#ReAll=[]
#stop=[]
#maxOrder=5
#
#for j1 in stopAbsList:
#    for j2 in stopMovList:
#        for j3 in ratioVList:
#            stopAbs=j1
#            stopMov=j2
#            ratioV=j3
#            Re=[]
#            for i in range(loops):
#                Open=opens[i*241:(i+1)*241]
#                Close=closes[i*241:(i+1)*241]
#                High=highs[i*241:(i+1)*241]
#                Low=lows[i*241:(i+1)*241]
#                Vol=vols[i*241:(i+1)*241]
#                i2=5
#                xi1=[]
#                xi2=[]
#                yi1=[]    
#                yi2=[]
#                colori=[]
#                while i2<236:
#                    maxV=np.mean(Vol[i2-5:i2])
#                    if Vol[i2]>maxV*ratioV and Vol[i2+1]>maxV*ratioV:
#                        priceOpen=Open[i2+3]
#                        barOpen=i2+3
#                        if round(Close[i2+2],3)>=round(Open[i2+2],3):
#                            Hold=1
#                        else:
#                            Hold=-1
#                        for i3 in range(i2+3,241):
#                            if Hold>0:
#                                if Low[i3]<=priceOpen-stopAbs:
#                                    Re.append(-stopAbs/priceOpen-0.0004)
#                                    priceClose=priceOpen-stopAbs
#                                    break
#                                elif max(High[barOpen:i3+1])-Low[i3]>=stopMov:
#                                    priceClose=max(High[barOpen:i3+1])-stopMov
#                                    Re.append(priceClose/priceOpen-1.0004)
#                                    break
#                                else:
#                                    pass
#                                    
#                                
#                            elif Hold<0:
#                                if High[i3]>=priceOpen+stopAbs:
#                                    Re.append(-stopAbs/priceOpen-0.0004)
#                                    priceClose=priceOpen+stopAbs
#                                    break
#                                if High[i3]-min(Low[barOpen:i3+1])>=stopMov:
#                                    priceClose=min(Low[barOpen:i3+1])+stopMov
#                                    Re.append(1-priceClose/priceOpen-0.0004)
#                                    break
#                            if i3==240:
#                                Re.append((Close[i3]-priceOpen)*Hold/priceOpen-0.0004)  
#                                priceClose=Close[i3]
#                        i2=i3
#                        xi1.append(barOpen)
#                        xi2.append(i3)
#                        yi1.append(priceOpen)
#                        yi2.append(priceClose)
#                        if Re[-1]>0:
#                            colori.append('purple')
#                        else:
#                            colori.append('cyan')
#                    else:
#                        i2=i2+1
#                    
#                if fig>0 and len(xi1)>=2:
#                    fig=fig-1
#                    plt.figure(figsize=(25,8))
#                    ax=plt.subplot2grid((3,1),(0,0),rowspan=2)
#                    plt.title(times[i*241].strftime('%Y-%m-%d'))
#                    candleData=np.column_stack([list(range(len(Open))),Open,High,Low,Close])
#                    mpf.candlestick_ohlc(ax,candleData,width=0.5,colorup='r',colordown='g')
#                    for i2 in range(len(colori)):
#                        ax.plot([xi1[i2],xi2[i2]],[yi1[i2],yi2[i2]],colori[i2],linewidth=3)
#                    plt.xticks(range(len(Open))[::5])
#                    plt.grid()
#                    ax1=plt.subplot2grid((3,1),(2,0))
#                    ax1.bar(range(len(Vol)),Vol)
#                    plt.xticks(range(len(Open))[::5])
#                    plt.grid()
#            
#            ReAll.append(Re)
#            stop.append([stopAbs,stopMov,ratioV])
#            #plt.figure()
#            #plt.plot(np.cumsum(Re))
#indMax=np.argsort(list(map(sum,ReAll)))[-1]
#plt.figure(figsize=(25,8))
#plt.plot(np.cumsum(ReAll[indMax]))
#plt.title('stopAbs:'+str(stop[indMax][0])+';stopMove:'+str(stop[indMax][1])+';ratioV:'+str(stop[indMax][2]) )

        
      
                




#from WindPy import *
#import numpy as np
#import matplotlib.pyplot as plt
#import matplotlib.finance as mpf
#import datetime,pickle,pdb
#
#
#timeStart='2016-01-01'
#timeEnd=(datetime.date.today()-timedelta(days=1)).strftime('%Y-%m-%d')
#stopAbs=0.003
#stopMov=0.008
#fig=2
#
#try:
#    tem=open('dayTrade50ETF','rb')
#    dataPKL=pickle.load(tem)
#    tem.close()
#    opens=dataPKL['opens']
#    closes=dataPKL['closes']
#    highs=dataPKL['highs']
#    lows=dataPKL['lows']
#    vols=dataPKL['vols']
#    times=dataPKL['times']
#except:
#    w.start()
#    dataTem=w.wsi('510050.SH','open,high,low,close,volume',timeStart+' 09:00:00',timeEnd+' 15:01:00','periodstart=09:30:00;periodend=15:01:00;Fill=Previous;PriceAdj=F')
#    opens=dataTem.Data[0]
#    highs=dataTem.Data[1]
#    lows=dataTem.Data[2]
#    closes=dataTem.Data[3]
#    vols=dataTem.Data[4]
#    times=dataTem.Times
#    dataPKL={'opens':opens,'highs':highs,'lows':lows,'closes':closes,'vols':vols,'times':times}
#    tem=open('dayTrade50ETF','wb')
#    pickle.dump(dataPKL,tem)
#    tem.close()
#
#loops=len(opens)//241
#Re=[]
#for i in range(loops):
#    Open=opens[i*241:(i+1)*241]
#    Close=closes[i*241:(i+1)*241]
#    High=highs[i*241:(i+1)*241]
#    Low=lows[i*241:(i+1)*241]
#    Vol=vols[i*241:(i+1)*241]
#    i2=60
#    xi1=[]
#    xi2=[]
#    yi1=[]    
#    yi2=[]
#    colori=[]
#    while i2<236:
#        maxV=max(Vol[i2-60:i2])
#        if Vol[i2]>maxV/2 and Vol[i2+1]>maxV/2:
#            priceOpen=Open[i2+3]
#            barOpen=i2+3
#            if round(Close[i2+2],3)>=round(Open[i2+2],3):
#                Hold=1
#            else:
#                Hold=-1
#            for i3 in range(i2+3,241):
#                if Hold>0:
#                    if Low[i3]<=priceOpen-stopAbs:
#                        Re.append(-stopAbs/priceOpen-0.0004)
#                        priceClose=priceOpen-stopAbs
#                        break
#                    if max(High[barOpen:i3+1])-Low[i3]>=stopMov:
#                        priceClose=max(High[barOpen:i3+1])-stopMov
#                        Re.append(priceClose/priceOpen-1.0004)
#                        break
#                else:
#                    if High[i3]>=priceOpen+stopAbs:
#                        Re.append(-stopAbs/priceOpen-0.0004)
#                        priceClose=priceOpen+stopAbs
#                        break
#                    if High[i3]-min(Low[barOpen:i3+1])>=stopMov:
#                        priceClose=min(Low[barOpen:i3+1])+stopMov
#                        Re.append(1-priceClose/priceOpen-0.0004)
#                        break
#                if i3==240:
#                    Re.append((Close[i3]-priceOpen)*Hold/priceOpen-0.0004)  
#                    priceClose=Close[i3]
#            i2=i3
#            xi1.append(barOpen)
#            xi2.append(i3)
#            yi1.append(priceOpen)
#            yi2.append(priceClose)
#            if Re[-1]>0:
#                colori.append('purple')
#            else:
#                colori.append('cyan')
#        else:
#            i2=i2+1
#        
#    if fig>0 and len(xi1)>=2:
#        fig=fig-1
#        plt.figure(figsize=(25,8))
#        ax=plt.subplot2grid((3,1),(0,0),rowspan=2)
#        plt.title(times[i*241].strftime('%Y-%m-%d'))
#        candleData=np.column_stack([list(range(len(Open))),Open,High,Low,Close])
#        mpf.candlestick_ohlc(ax,candleData,width=0.5,colorup='r',colordown='g')
#        for i2 in range(len(colori)):
#            ax.plot([xi1[i2],xi2[i2]],[yi1[i2],yi2[i2]],colori[i2],linewidth=3)
##            ax.plot(xi1[i2],Low[xi1[i2]]-0.0015,colori[i2],linewidth=5)
#        plt.xticks(range(len(Open))[::5])
#        plt.grid()
#        ax1=plt.subplot2grid((3,1),(2,0))
#        ax1.bar(range(len(Vol)),Vol)
#        plt.xticks(range(len(Open))[::5])
#        plt.grid()
#
#plt.figure()
#plt.plot(np.cumsum(Re))

























