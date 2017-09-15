# -*- coding: utf-8 -*-
"""
Created on Wed Sep 13 15:45:15 2017

@author: Administrator
"""

from WindPy import *
import numpy as np
import time

objTrade=['RB.SHF','I.DCE']

w.start()
tem=np.zeros(len(objTrade))
hands=tem;stopLoss=tem.copy();
up20=tem.copy();down20=tem.copy();up10=tem.copy();down10=tem.copy();openPrice=tem.copy();ATR=tem.copy();holds=tem.copy()
#define the callback function
def myCallback(indata):
    global objTrade,hands,stopLoss,up20,down20,up10,down10,openPrice,ATR,holds
    if indata.ErrorCode!=0:
        print('error code:'+str(indata.ErrorCode)+'\n')
        return()
    loops=len(objTrade)
    now=time.localtime(time.time())
    if time.strftime('%H-%M',now)=='15-00':
        for i in range(loops):
            price20=w.wsd(objTrade[i],'high,low','ED-19TD',time.strftime('%Y-%m-%d',now)).Data
            up20[i]=max(price20[0])
            down20[i]=min(price20[1])
            up10[i]=max(price20[0][:10])
            down10[i]=min(price20[1][:10])
    
    
    x=indata.Codes
    print(x)
    print(x=='I.DCE')
    print(x[0]=='I.DCE')
    
#    for i in range(loops):
#        holdi=holds[i];handi=hands[i];stopLossi=stopLoss[i];up20i=up20[i];down20i=down20[i];
#        up10i=up10[i];down10i=down10[i];ATRi=ATR[i];openPricei=openPrice[i]
#        
#        if holdi==0:
            
        

        
    

##    global begintime
#    lastvalue =""
#    for k in range(0,len(indata.Fields)):
#         if(indata.Fields[k] == "RT_TIME"):
#            begintime = indata.Data[k][0]
#         if(indata.Fields[k] == "RT_LAST"):
#            lastvalue = str(indata.Data[k][0])
#
#    string = str(begintime) + " " + lastvalue +"\n"
#    pf.writelines(string)
#    tem=w.wsd('RB.SHF','close','ED-4TD','2017/9/14')
#    print(tem.Data)

    #应该在w.cancelRequest后调用pf.close()
    #pf.close();

data=w.wsq(','.join(objTrade),"rt_last",func=myCallback)
#w.cancelRequest(data.RequestID)
#pf.close()









