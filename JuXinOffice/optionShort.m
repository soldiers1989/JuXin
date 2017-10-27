% function optionShort % short less price for "buy/sell" according to their
%     stepShort=2; % gas between current value and void value;
%     holdDays=20; % trading days from "short" to expire date;
%     dateFrom='2014/5/1';
%     dateFrom=year(datenum(dateFrom))*100+month(datenum(dateFrom));
%     w=windmatlab;
%     loops=ceil((today-datenum(2015,2,9))/29);
%     
%     Year=2015;
%     Month=1;
%     monthTem=1;
%     Day=28;
%     Data=[];% store data for all options;
%     for j=1:loops
%         if monthTem==12
%             Year=Year+1;
%         end
%         Month=Month+1;
%         monthTem=mod(Month,12);
%         if monthTem==0
%             monthTem=12;
%         end
%         Date=datenum(Year,monthTem,Day);
%         if Date >today
%             Date=today;
%         end    
%         parameters=['date=',datestr(Date,'yyyy-mm-dd'),';','us_code=510050.SH;option_var=全部;',...
%             'call_put=认购;field=option_code,strike_price,month,call_put,first_tradedate,last_tradedate,option_name'];
%         data=w.wset('optionchain',parameters);
%         Data=[Data;data];
%         if Date==today
%             break;
%         end       
%     end
%     options=Data(:,1);
%     [options,indTem]=unique(options);
%     Data=Data(indTem,:);
%     prices=cell2mat(Data(:,2));
%     indTem=mod(prices,0.05)<0.00000001;
%     prices=prices(indTem);
%     months=cell2mat(Data(indTem,3));
%     starts=Data(indTem,5);
%     ends=Data(indTem,6);      
%     options=options(indTem);
%     
%     Year=2015;
%     Month=1;
%     monthTem=1;
%     Day=28;
%     Data=[];% store data for all options;
%     for j=1:loops
%         if monthTem==12
%             Year=Year+1;
%         end
%         Month=Month+1;
%         monthTem=mod(Month,12);
%         if monthTem==0
%             monthTem=12;
%         end
%         Date=datenum(Year,monthTem,Day);
%         if Date >today
%             Date=today;
%         end    
%         parameters=['date=',datestr(Date,'yyyy-mm-dd'),';','us_code=510050.SH;option_var=全部;',...
%             'call_put=认沽;field=option_code,strike_price,month,call_put,first_tradedate,last_tradedate,option_name'];
%         data=w.wset('optionchain',parameters);
%         Data=[Data;data];
%         if Date==today
%             break;
%         end       
%     end
%     optionsSell=Data(:,1);
%     [optionsSell,indTem]=unique(optionsSell);
%     Data=Data(indTem,:);
%     pricesSell=cell2mat(Data(:,2));
%     indTem=mod(pricesSell,0.05)<0.00000001;
%     pricesSell=pricesSell(indTem);
%     monthsSell=cell2mat(Data(indTem,3));     
%     optionsSell=optionsSell(indTem);    
%     
%     Re=[];
%     records=[];
%     recordOptions={};
%     optionsRec={};
%     Comm=[];%for commission of all;
%     etfMonth={};
%     UniMonth=unique(months);
%     loops=length(UniMonth);    
%     for i=1:loops  
%         if Year*100+month(today)<=UniMonth(i)
%             continue;
%         end
%         if dateFrom>UniMonth(i)
%             continue;
%         end
%         indT=months==UniMonth(i);
%         optionT=options(indT);
%         priceT=prices(indT);
%         startT=starts(indT);
%         endT=ends(indT);
%         [priceT,tem]=unique(priceT);
%         optionT=optionT(tem);
%         startT=startT(tem);
%         endT=endT(tem); 
%         tem=datenum(endT)-datenum(startT)>5;
%         priceT=priceT(tem);
%         optionT=optionT(tem);
%         startT=startT(tem);
%         endT=endT(tem); 
%         
%         tradeDays=w.tdays(datenum(endT(1))-50,endT(1));
%         tradeDay=tradeDays(end-holdDays);
%         etfP=w.wss('510050.SH','close',['tradeDate=',tradeDay{1}],'priceAdj=U','cycle=D');
%         difftem=abs(priceT-stepShort*0.05-etfP);
%         [~,tem]=sort(difftem);
%         optioni=optionT(tem(1));starti=startT(tem(1));endi=endT(tem(1));pricei=priceT(tem(1));
%         if min(difftem)>0.05 || datenum(starti)>datenum(tradeDay)
%             continue;
%         end
%         difftem=abs((etfP-(pricei-etfP))-priceT);
%         if min(difftem)>0.05
%             continue;
%         end
%         [~,tem]=sort(difftem);
%         priceiSell=priceT(tem(1));
%         monthiSell=UniMonth(i);
%         optioniSell=optionsSell((pricesSell==priceiSell)&(monthsSell==monthiSell));
%         tem=w.wss([optioni,optioniSell],'open',['tradeDate=',tradeDay{1}],'priceAdj=U','cycle=D');
%         if tem(1)>tem(2)
%             optioni=optioniSell;
%         end       
%         tem_1=w.wss(optioni,'open',['tradeDate=',tradeDay{1}],'priceAdj=U','cycle=D');
%         etf50_1=w.wss('510050.SH','open',['tradeDate=',tradeDay{1}],'priceAdj=U','cycle=D');
%         tem=w.wsd(optioni,'close',tradeDay{1},endi,'priceAdj=U');
%         ReTem=((tem(1)-tem(end))*10000-7.2)./commission(pricei,tem_1,etf50_1);
%         Re=[Re;ReTem];
%         etfMonth=[etfMonth;tradeDay{1}];
%         figure;
%         plot(tem);
%         title([endi{1},'--收益情况：',num2str(ReTem)]);
%     end
% 
%     figure;
%     ReCS=cumsum(Re);
%     plot(ReCS);
%     grid on;
%     Lre=length(Re);
%     step=max(floor(Lre/10),1);
%     set(gca,'xtick',1:step:Lre);
%     set(gca,'xticklabel',etfMonth(1:step:Lre),'XTickLabelRotation',60);
%     maxDown=0;
%     ReCS=[0;ReCS];
%     for i=2:Lre
%         tem=max(ReCS(1:i))-ReCS(i);
%         if tem>maxDown
%             maxDown=tem;
%         end
%     end
%     title(sprintf('年化收益估算：%.2f%%;最大回撤：%.2f%%',ReCS(end)*100/((datenum(etfMonth(end))-datenum(etfMonth(1)))/360), maxDown*100));
% end
    
  
    
    
%     function optionShort
%     stepShort=2; % gas between current value and void value;
%     holdDays=20; % trading days from "short" to expire date;
%     dateFrom='2014/5/1';
%     dateFrom=year(datenum(dateFrom))*100+month(datenum(dateFrom));
%     w=windmatlab;
%     loops=ceil((today-datenum(2015,2,9))/29);
%     Year=2015;
%     Month=1;
%     monthTem=1;
%     Day=28;
%     Data=[];% store data for all options;
%     for j=1:loops
%         if monthTem==12
%             Year=Year+1;
%         end
%         Month=Month+1;
%         monthTem=mod(Month,12);
%         if monthTem==0
%             monthTem=12;
%         end
%         Date=datenum(Year,monthTem,Day);
%         if Date >today
%             Date=today;
%         end    
%         parameters=['date=',datestr(Date,'yyyy-mm-dd'),';','us_code=510050.SH;option_var=全部;',...
%             'call_put=认购;field=option_code,strike_price,month,call_put,first_tradedate,last_tradedate,option_name'];
%         data=w.wset('optionchain',parameters);
%         Data=[Data;data];
%         if Date==today
%             break;
%         end       
%     end
%     options=Data(:,1);
%     [options,indTem]=unique(options);
%     Data=Data(indTem,:);
%     prices=cell2mat(Data(:,2));
%     indTem=mod(prices,0.05)<0.00000001;
%     prices=prices(indTem);
%     months=cell2mat(Data(indTem,3));
%     starts=Data(indTem,5);
%     ends=Data(indTem,6);      
%     options=options(indTem);
%     
%     Re=[];
%     records=[];
%     recordOptions={};
%     optionsRec={};
%     Comm=[];%for commission of all;
%     etfMonth={};
%     UniMonth=unique(months);
%     loops=length(UniMonth);
%     
%     for i=1:loops  
%         if Year*100+month(today)<=UniMonth(i)
%             continue;
%         end
%         if dateFrom>UniMonth(i)
%             continue;
%         end
%         indT=months==UniMonth(i);
%         optionT=options(indT);
%         priceT=prices(indT);
%         startT=starts(indT);
%         endT=ends(indT);
%         [priceT,tem]=unique(priceT);
%         optionT=optionT(tem);
%         startT=startT(tem);
%         endT=endT(tem); 
%         tem=datenum(endT)-datenum(startT)>5;
%         priceT=priceT(tem);
%         optionT=optionT(tem);
%         startT=startT(tem);
%         endT=endT(tem); 
%         
%         tradeDays=w.tdays(datenum(endT(1))-50,endT(1));
%         tradeDay=tradeDays(end-holdDays);
%         etfP=w.wss('510050.SH','close',['tradeDate=',tradeDay{1}],'priceAdj=U','cycle=D');
%         difftem=abs(priceT-stepShort*0.05-etfP);
%         [~,tem]=sort(difftem);
%         optioni=optionT(tem(1));starti=startT(tem(1));endi=endT(tem(1));pricei=priceT(tem(1));
%         if min(difftem)>0.05 || datenum(starti)>datenum(tradeDay)
%             continue;
%         end
%         
%         tem_1=w.wss(optioni,'open',['tradeDate=',tradeDay{1}],'priceAdj=U','cycle=D');
%         etf50_1=w.wss('510050.SH','open',['tradeDate=',tradeDay{1}],'priceAdj=U','cycle=D');
%         priceTem=w.wsd(optioni,'close',tradeDay{1},endi,'priceAdj=U');
%         priceStop=priceTem(end);
%         for i2=2:length(priceTem)
%             if priceTem(i2)>=priceTem(1)*2
%                 priceStop=priceTem(i2);
%             end
%         end
%         ReTem=((priceTem(1)-priceStop)*10000-7.2)./commission(pricei,tem_1,etf50_1);
%         Re=[Re;ReTem];
%         etfMonth=[etfMonth;tradeDay{1}];
%         figure;
%         plot(priceTem);
%         title([endi{1},'--收益情况：',num2str(ReTem)]);
%     end
% 
%     figure;
%     ReCS=cumsum(Re);
%     plot(ReCS);
%     grid on;
%     Lre=length(Re);
%     step=max(floor(Lre/10),1);
%     set(gca,'xtick',1:step:Lre);
%     set(gca,'xticklabel',etfMonth(1:step:Lre),'XTickLabelRotation',60);
%     maxDown=0;
%     ReCS=[0;ReCS];
%     for i=2:Lre
%         tem=max(ReCS(1:i))-ReCS(i);
%         if tem>maxDown
%             maxDown=tem;
%         end
%     end
%     title(sprintf('年化收益估算：%.2f%%;最大回撤：%.2f%%',ReCS(end)*100/((datenum(etfMonth(end))-datenum(etfMonth(1)))/360), maxDown*100));
% end
    

% function optionShort
%     stepShort=2; % gas between current value and void value;
%     holdDays=15; % trading days from "short" to expire date;
%     stopRatio=2;
%     dateFrom='2014/5/1';
%     dateFrom=year(datenum(dateFrom))*100+month(datenum(dateFrom));
%     w=windmatlab;
%     loops=ceil((today-datenum(2015,2,9))/29);
%     Year=2015;
%     Month=1;
%     monthTem=1;
%     Day=28;
%     Data=[];% store data for all options;
%     for j=1:loops
%         if monthTem==12
%             Year=Year+1;
%         end
%         Month=Month+1;
%         monthTem=mod(Month,12);
%         if monthTem==0
%             monthTem=12;
%         end
%         Date=datenum(Year,monthTem,Day);
%         if Date >today
%             Date=today;
%         end    
%         parameters=['date=',datestr(Date,'yyyy-mm-dd'),';','us_code=510050.SH;option_var=全部;',...
%             'call_put=认购;field=option_code,strike_price,month,call_put,first_tradedate,last_tradedate,option_name'];
%         data=w.wset('optionchain',parameters);
%         Data=[Data;data];
%         if Date==today
%             break;
%         end       
%     end
%     options=Data(:,1);
%     [options,indTem]=unique(options);
%     Data=Data(indTem,:);
%     prices=cell2mat(Data(:,2));
%     indTem=mod(prices,0.05)<0.00000001;
%     prices=prices(indTem);
%     months=cell2mat(Data(indTem,3));
%     starts=Data(indTem,5);
%     ends=Data(indTem,6);      
%     options=options(indTem);
%     
%     Re=[];
%     records=[];
%     recordOptions={};
%     optionsRec={};
%     Comm=[];%for commission of all;
%     etfMonth={};
%     UniMonth=unique(months);
%     loops=length(UniMonth);
%     
%     for i=1:loops  
%         if Year*100+month(today)<=UniMonth(i)
%             continue;
%         end
%         if dateFrom>UniMonth(i)
%             UniMonth(i)
%             continue;
%         end
%         indT=months==UniMonth(i);
%         optionT=options(indT);
%         priceT=prices(indT);
%         startT=starts(indT);
%         endT=ends(indT);
%         [priceT,tem]=unique(priceT);
%         optionT=optionT(tem);
%         startT=startT(tem);
%         endT=endT(tem); 
%         tem=datenum(endT)-datenum(startT)>5;
%         priceT=priceT(tem);
%         optionT=optionT(tem);
%         startT=startT(tem);
%         endT=endT(tem); 
%         
%         tradeDays=w.tdays(datenum(endT(1))-50,endT(1));
%         tradeDay=tradeDays(end-holdDays);
%         etfP=w.wss('510050.SH','close',['tradeDate=',tradeDay{1}],'priceAdj=U','cycle=D');
%         difftem=abs(priceT-stepShort*0.05-etfP);
%         [~,tem]=sort(difftem);
%         optioni=optionT(tem(1));starti=startT(tem(1));endi=endT(tem(1));pricei=priceT(tem(1));
%         if min(difftem)>0.05 || datenum(starti)>datenum(tradeDay)
%             continue;
%         end
%         
%         tem_1=w.wss(optioni,'open',['tradeDate=',tradeDay{1}],'priceAdj=U','cycle=D');
%         etf50_1=w.wss('510050.SH','open',['tradeDate=',tradeDay{1}],'priceAdj=U','cycle=D');
%         priceTem=w.wsd(optioni,'close',tradeDay{1},endi,'priceAdj=U');
%         priceStop=priceTem(end);
%         tem=w.wsd(optioni,'open,high,low',tradeDay{1},endi,'priceAdj=U');
%         openTem=tem(:,1);highTem=tem(:,2);lowTem=tem(:,3);closeTem=priceTem;
%         for i2=2:length(priceTem)
%             if highTem(i2)>=priceTem(1)*stopRatio
%                 priceStop=max(openTem(i2),priceTem(1)*stopRatio);
%                 break;
%             end
%         end
%         hands1=floor(0.1/(priceTem(1)*(stopRatio-1)));
%         hands2=floor(10000/commission(pricei,tem_1,etf50_1));
%         ReTem=((priceTem(1)-priceStop)*10000-7.2)*min(hands1,hands2);
%         Re=[Re;ReTem];
%         etfMonth=[etfMonth;tradeDay{1}];
%         figure;
%         candle(highTem,lowTem,closeTem,openTem);
% %         plot(priceTem);
%         title([endi{1},'--收益情况：',num2str(ReTem)]);
%     end
% 
%     figure;
%     winRatio=sum(Re>0)/length(Re);
%     ReCS=cumsum(Re)+10000;
%     plot(ReCS);
%     grid on;
%     Lre=length(Re);
%     step=max(floor(Lre/10),1);
%     set(gca,'xtick',1:step:Lre);
%     set(gca,'xticklabel',etfMonth(1:step:Lre),'XTickLabelRotation',60);
%     maxDown=0;
%     ReCS=[0;ReCS];
%     for i=2:Lre
%         tem=max(ReCS(1:i))-ReCS(i);
%         if tem>maxDown
%             maxDown=tem;
%         end
%     end
%     title(sprintf('年化收益估算：%.2f%%;最大回撤：%.2f%%;胜率：%.2f%%',100*((ReCS(end)/10000)^(1/((datenum(etfMonth(end))-datenum(etfMonth(1)))/360))-1), maxDown/100,winRatio*100));
% end

% function optionShort % final version-absolute short one time;
%     stepShort=2; % gas between current value and void value;
%     holdDays=15; % trading days from "short" to expire date;
%     stopRatio=1.3;
%     dateFrom='2014/5/1';
%     dateFrom=year(datenum(dateFrom))*100+month(datenum(dateFrom));
%     w=windmatlab;
%     loops=ceil((today-datenum(2015,2,9))/29);
%     Year=2015;
%     Month=1;
%     monthTem=1;
%     Day=28;
%     Data=[];% store data for all options;
%     for j=1:loops
%         if monthTem==12
%             Year=Year+1;
%         end
%         Month=Month+1;
%         monthTem=mod(Month,12);
%         if monthTem==0
%             monthTem=12;
%         end
%         Date=datenum(Year,monthTem,Day);
%         if Date >today
%             Date=today;
%         end    
%         parameters=['date=',datestr(Date,'yyyy-mm-dd'),';','us_code=510050.SH;option_var=全部;',...
%             'call_put=认沽;field=option_code,strike_price,month,call_put,first_tradedate,last_tradedate,option_name'];
%         data=w.wset('optionchain',parameters);
%         Data=[Data;data];
%         if Date==today
%             break;
%         end       
%     end
%     options=Data(:,1);
%     [options,indTem]=unique(options);
%     Data=Data(indTem,:);
%     prices=cell2mat(Data(:,2));
%     indTem=mod(prices,0.05)<0.00000001;
%     prices=prices(indTem);
%     months=cell2mat(Data(indTem,3));
%     starts=Data(indTem,5);
%     ends=Data(indTem,6);      
%     options=options(indTem);
%     
%     Re=[];
%     ReC=[];
%     records=[];
%     recordOptions={};
%     optionsRec={};
%     Comm=[];%for commission of all;
%     etfMonth={};
%     UniMonth=unique(months);
%     loops=length(UniMonth);
%     
%     for i=1:loops  
%         if Year*100+month(today)<=UniMonth(i)
%             continue;
%         end
%         if dateFrom>UniMonth(i)
%             UniMonth(i)
%             continue;
%         end
%         indT=months==UniMonth(i);
%         optionT=options(indT);
%         priceT=prices(indT);
%         startT=starts(indT);
%         endT=ends(indT);
%         [priceT,tem]=unique(priceT);
%         optionT=optionT(tem);
%         startT=startT(tem);
%         endT=endT(tem); 
%         tem=datenum(endT)-datenum(startT)>5;
%         priceT=priceT(tem);
%         optionT=optionT(tem);
%         startT=startT(tem);
%         endT=endT(tem); 
%         
%         tradeDays=w.tdays(datenum(endT(1))-50,endT(1));
%         tradeDay=tradeDays(end-holdDays);
%         etfP=w.wss('510050.SH','close',['tradeDate=',tradeDay{1}],'priceAdj=U','cycle=D');
%         difftem=abs(priceT+stepShort*0.05-etfP);
%         [~,tem]=sort(difftem);
%         optioni=optionT(tem(1));starti=startT(tem(1));endi=endT(tem(1));pricei=priceT(tem(1));
%         if min(difftem)>0.05 || datenum(starti)>datenum(tradeDay)
%             continue;
%         end
%         
%         tem_1=w.wss(optioni,'open',['tradeDate=',tradeDay{1}],'priceAdj=U','cycle=D');
%         etf50_1=w.wss('510050.SH','open',['tradeDate=',tradeDay{1}],'priceAdj=U','cycle=D');
%         priceTem=w.wsd(optioni,'close',tradeDay{1},endi,'priceAdj=U');
%         priceStop=priceTem(end);
%         tem=w.wsd(optioni,'open,high,low',tradeDay{1},endi,'priceAdj=U');
%         openTem=tem(:,1);highTem=tem(:,2);lowTem=tem(:,3);closeTem=priceTem;
%         for i2=2:length(priceTem)
%             if highTem(i2)>=priceTem(1)*stopRatio
%                 priceStop=max(openTem(i2),priceTem(1)*stopRatio);
%                 break;
%             end
%         end
%         hands1=floor(0.1/(priceTem(1)*(stopRatio-1)));
%         hands2=floor(10000/commission(pricei,tem_1,etf50_1));
%         ReTem=((priceTem(1)-priceStop)*10000-7.2)*min(hands1,hands2);
%         Re=[Re;ReTem];
%         etfMonth=[etfMonth;tradeDay{1}];
%         figure;
%         candle(highTem,lowTem,closeTem,openTem);
% %         plot(priceTem);
%         title([endi{1},'--收益情况：',num2str(ReTem)]);
%     end
% 
%     figure;
%     winRatio=sum(Re>0)/length(Re);
%     ReCS=cumsum(Re)+10000;
%     plot(ReCS);
%     grid on;
%     Lre=length(Re);
%     step=max(floor(Lre/10),1);
%     set(gca,'xtick',1:step:Lre);
%     set(gca,'xticklabel',etfMonth(1:step:Lre),'XTickLabelRotation',60);
%     maxDown=0;
%     ReCS=[0;ReCS];
%     for i=2:Lre
%         tem=max(ReCS(1:i))-ReCS(i);
%         if tem>maxDown
%             maxDown=tem;
%         end
%     end
%     title(sprintf('年化收益估算：%.2f%%;最大回撤：%.2f%%;胜率：%.2f%%',100*((ReCS(end)/10000)^(1/((datenum(etfMonth(end))-datenum(etfMonth(1)))/360))-1), maxDown/100,winRatio*100));
% end

% function optionShort % final version-absolute short one time;
%     stepShort=2; % gas between current value and void value;
%     holdDays=15; % trading days from "short" to expire date;
%     stopRatio=1.3;
%     dateFrom='2014/5/1';
%     dateFrom=year(datenum(dateFrom))*100+month(datenum(dateFrom));
%     w=windmatlab;
%     loops=ceil((today-datenum(2015,2,9))/29);
%     Year=2015;
%     Month=1;
%     monthTem=1;
%     Day=28;
%     Data=[];% store data for all options;
%     for j=1:loops
%         if monthTem==12
%             Year=Year+1;
%         end
%         Month=Month+1;
%         monthTem=mod(Month,12);
%         if monthTem==0
%             monthTem=12;
%         end
%         Date=datenum(Year,monthTem,Day);
%         if Date >today
%             Date=today;
%         end    
%         parameters=['date=',datestr(Date,'yyyy-mm-dd'),';','us_code=510050.SH;option_var=全部;',...
%             'field=option_code,strike_price,month,call_put,first_tradedate,last_tradedate,option_name'];
%         data=w.wset('optionchain',parameters);
%         Data=[Data;data];
%         if Date==today
%             break;
%         end       
%     end
%     options=Data(:,1);
%     [options,indTem]=unique(options);
%     Data=Data(indTem,:);
%     prices=cell2mat(Data(:,2));
%     indTem=mod(prices,0.05)<0.00000001;
%     prices=prices(indTem);
%     months=cell2mat(Data(indTem,3));
%     calls=Data(indTem,4);
%     starts=Data(indTem,5);
%     ends=Data(indTem,6);    
%     options=options(indTem);
%     tem=ismember(calls,'认购');
%     optionsB=options(tem);
%     pricesB=prices(tem);
%     monthsB=months(tem);
%     prices=prices(~tem);
%     months=months(tem);
%     calls=calls(~tem);
%     starts=starts(~tem);
%     ends=ends(~tem);    
%     options=options(~tem);
%     
%     Re=[];
%     ReC=[];
%     records=[];
%     recordOptions={};
%     optionsRec={};
%     Comm=[];%for commission of all;
%     etfMonth={};
%     UniMonth=unique(months);
%     loops=length(UniMonth);
%     
%     for i=1:loops  
%         if Year*100+month(today)<=UniMonth(i)
%             continue;
%         end
%         if dateFrom>UniMonth(i)
%             UniMonth(i)
%             continue;
%         end
%         indT=months==UniMonth(i);
%         optionT=options(indT);
%         priceT=prices(indT);
%         startT=starts(indT);
%         endT=ends(indT);
%         [priceT,tem]=unique(priceT);
%         optionT=optionT(tem);
%         startT=startT(tem);
%         endT=endT(tem); 
%         tem=datenum(endT)-datenum(startT)>5;
%         priceT=priceT(tem);
%         optionT=optionT(tem);
%         startT=startT(tem);
%         endT=endT(tem); 
%         
%         tradeDays=w.tdays(datenum(endT(1))-50,endT(1));
%         tradeDay=tradeDays(end-holdDays);
%         etfP=w.wss('510050.SH','close',['tradeDate=',tradeDay{1}],'priceAdj=U','cycle=D');
%         difftem=abs(priceT+stepShort*0.05-etfP);
%         [~,tem]=sort(difftem);
%         optioni=optionT(tem(1));starti=startT(tem(1));endi=endT(tem(1));pricei=priceT(tem(1));
%         if min(difftem)>0.05 || datenum(starti)>datenum(tradeDay)
%             continue;
%         end
%         
%         tem_1=w.wss(optioni,'open',['tradeDate=',tradeDay{1}],'priceAdj=U','cycle=D');
%         etf50_1=w.wss('510050.SH','open',['tradeDate=',tradeDay{1}],'priceAdj=U','cycle=D');
%         [priceTem,~,~,dayTem]=w.wsd(optioni,'close',tradeDay{1},endi,'priceAdj=U');
%         priceStop=priceTem(end);
%         hands1=floor(0.1/(priceTem(1)*(stopRatio-1)));
%         hands2=floor(10000/commission(pricei,tem_1,etf50_1));
%         ReTem=((priceTem(1)-priceStop)*10000-7.2)*min(hands1,hands2);
%         Re=[Re;ReTem];
%         tem=w.wsd(optioni,'open,high,low',tradeDay{1},endi,'priceAdj=U');
%         openTem=tem(:,1);highTem=tem(:,2);lowTem=tem(:,3);closeTem=priceTem;
%         for i2=2:length(priceTem)
%             if highTem(i2)>=priceTem(1)*stopRatio
%                 priceStop=max(openTem(i2),priceTem(1)*stopRatio);
%                 ReTem=((priceTem(1)-priceStop)*10000-7.2)*min(hands1,hands2);
%                 tem=(monthsB==UniMonth(i))&(pricesB==pricei-2*stepShort*0.05);
%                 optionNew=optionsB(tem);
%                 if ~isempty(optionNew)
%                     tem=w.wsd(optionNew,'close',datestr(dayTem(i2),'yyyy/mm/dd'),endi,'priceAdj=U');
%                     if 0% max(tem)/tem(1)>=stopRatio
%                         Re(end)=ReTem+((tem(1)-tem(1)*stopRatio)*10000-7.2)*min(hands1,hands2); 
%                     else
%                         Re(end)=ReTem+((tem(1)-tem(end))*10000-7.2)*min(hands1,hands2);     
%                     end
%                 else
%                     tem=(monthsB==UniMonth(i))&(pricesB<pricei-stepShort*0.05);
%                     pricesBtem=pricesB(tem);optionsBtem=optionsB(tem);
%                     [~,tem]=sort(pricesBtem);
%                     if isempty(tem)
%                         Re(end)=ReTem;
%                         display('No other options');
%                     else
%                         optionNew=optionsBtem(tem(1));
%                         tem=w.wsd(optionNew,'close',datestr(dayTem(i2),'yyyy/mm/dd'),endi,'priceAdj=U');
%                         if 0%max(tem)/tem(1)>=stopRatio
%                             Re(end)=ReTem+((tem(1)-tem(1)*stopRatio)*10000-7.2)*min(hands1,hands2); 
%                         else
%                             Re(end)=ReTem+((tem(1)-tem(end))*10000-7.2)*min(hands1,hands2);     
%                         end
%                         display('use reverse options');
%                     end
%                 end
%                 break;
%             end
%         end  
%         etfMonth=[etfMonth;tradeDay{1}];
%         figure;
%         candle(highTem,lowTem,closeTem,openTem);
% %         plot(priceTem);
%         title([endi{1},'--收益情况：',num2str(ReTem)]);
%     end
% 
%     figure;
%     winRatio=sum(Re>0)/length(Re);
%     ReCS=cumsum(Re)+10000;
%     plot(ReCS);
%     grid on;
%     Lre=length(Re);
%     step=max(floor(Lre/10),1);
%     set(gca,'xtick',1:step:Lre);
%     set(gca,'xticklabel',etfMonth(1:step:Lre),'XTickLabelRotation',60);
%     maxDown=0;
%     ReCS=[0;ReCS];
%     for i=2:Lre
%         tem=max(ReCS(1:i))-ReCS(i);
%         if tem>maxDown
%             maxDown=tem;
%         end
%     end
%     title(sprintf('年化收益估算：%.2f%%;最大回撤：%.2f%%;胜率：%.2f%%',100*((ReCS(end)/10000)^(1/((datenum(etfMonth(end))-datenum(etfMonth(1)))/360))-1), maxDown/100,winRatio*100));
% end
    
    


% % loop for final version-absolute short one time ;
% stepShortS=[1,2,3]; % gas between current value and void value;
% holdDaysS=[10,13,15,18,20,23,25,28,30,35]; % trading days from "short" to expire date;
% stopRatioS=[1.1,1.3,1.5,1.7,2.0];
% dateFrom='2014/5/1';
% dateFrom=year(datenum(dateFrom))*100+month(datenum(dateFrom));
% w=windmatlab;
% loops=ceil((today-datenum(2015,2,9))/29);
% Year=2015;
% Month=1;
% monthTem=1;
% Day=28;
% Data=[];% store data for all options;
% ReAll={};
% ReMean=[];
% monthAll={};
% paras={};
% for j=1:loops
%     if monthTem==12
%         Year=Year+1;
%     end
%     Month=Month+1;
%     monthTem=mod(Month,12);
%     if monthTem==0
%         monthTem=12;
%     end
%     Date=datenum(Year,monthTem,Day);
%     if Date >today
%         Date=today;
%     end    
%     parameters=['date=',datestr(Date,'yyyy-mm-dd'),';','us_code=510050.SH;option_var=全部;',...
%         'field=option_code,strike_price,month,call_put,first_tradedate,last_tradedate,option_name'];
%     data=w.wset('optionchain',parameters);
%     Data=[Data;data];
%     if Date==today
%         break;
%     end       
% end
% options=Data(:,1);
% [options,indTem]=unique(options);
% Data=Data(indTem,:);
% prices=cell2mat(Data(:,2));
% indTem=mod(prices,0.05)<0.00000001;
% prices=prices(indTem);
% months=cell2mat(Data(indTem,3));
% calls=Data(indTem,4);
% starts=Data(indTem,5);
% ends=Data(indTem,6);    
% options=options(indTem);
% tem=ismember(calls,'认购');
% optionsB=options(tem);
% pricesB=prices(tem);
% monthsB=months(tem);
% prices=prices(~tem);
% months=months(tem);
% calls=calls(~tem);
% starts=starts(~tem);
% ends=ends(~tem);    
% options=options(~tem);
% 
% j123=0;
% jall=string(length(stepShortS)*length(holdDaysS)*length(stopRatioS));
% for j1=1:length(stepShortS)
%     for j2=1:length(holdDaysS)
%         for j3=1:length(stopRatioS)
%             try
%                 j123=j123+1;
%                 display([j1,j2,j3]);
%                 display(strcat(string(j123),'/',jall));            
%                 stepShort=stepShortS(j1); % gas between current value and void value;
%                 holdDays=holdDaysS(j2); % trading days from "short" to expire date;
%                 stopRatio=stopRatioS(j3);
%                 Re=[];
%                 ReC=[];
%                 records=[];
%                 recordOptions={};
%                 optionsRec={};
%                 Comm=[];%for commission of all;
%                 etfMonth={};
%                 UniMonth=unique(months);
%                 loops=length(UniMonth);
% 
%                 for i=1:loops  
%                     if Year*100+month(today)<=UniMonth(i)
%                         continue;
%                     end
%                     if dateFrom>UniMonth(i)
%                         UniMonth(i)
%                         continue;
%                     end
%                     indT=months==UniMonth(i);
%                     optionT=options(indT);
%                     priceT=prices(indT);
%                     startT=starts(indT);
%                     endT=ends(indT);
%                     [priceT,tem]=unique(priceT);
%                     optionT=optionT(tem);
%                     startT=startT(tem);
%                     endT=endT(tem); 
%                     tem=datenum(endT)-datenum(startT)>5;
%                     priceT=priceT(tem);
%                     optionT=optionT(tem);
%                     startT=startT(tem);
%                     endT=endT(tem); 
% 
%                     tradeDays=w.tdays(datenum(endT(1))-50,endT(1));
%                     tradeDay=tradeDays(end-holdDays);
%                     etfP=w.wss('510050.SH','close',['tradeDate=',tradeDay{1}],'priceAdj=U','cycle=D');
%                     difftem=abs(priceT+stepShort*0.05-etfP);
%                     [~,tem]=sort(difftem);
%                     optioni=optionT(tem(1));starti=startT(tem(1));endi=endT(tem(1));pricei=priceT(tem(1));
%                     if min(difftem)>0.05 || datenum(starti)>datenum(tradeDay)
%                         continue;
%                     end
% 
%                     tem_1=w.wss(optioni,'open',['tradeDate=',tradeDay{1}],'priceAdj=U','cycle=D');
%                     etf50_1=w.wss('510050.SH','open',['tradeDate=',tradeDay{1}],'priceAdj=U','cycle=D');
%                     [priceTem,~,~,dayTem]=w.wsd(optioni,'close',tradeDay{1},endi,'priceAdj=U');
%                     priceStop=priceTem(end);
%                     hands1=floor(0.1/(priceTem(1)*(stopRatio-1)));
%                     hands2=floor(10000/commission(pricei,tem_1,etf50_1));
%                     ReTem=((priceTem(1)-priceStop)*10000-7.2)*min(hands1,hands2);
%                     Re=[Re;ReTem];
%                     tem=w.wsd(optioni,'open,high,low',tradeDay{1},endi,'priceAdj=U');
%                     openTem=tem(:,1);highTem=tem(:,2);lowTem=tem(:,3);closeTem=priceTem;
%                     for i2=2:length(priceTem)
%                         if highTem(i2)>=priceTem(1)*stopRatio
%                             priceStop=max(openTem(i2),priceTem(1)*stopRatio);
%                             ReTem=((priceTem(1)-priceStop)*10000-7.2)*min(hands1,hands2);
%                             tem=(monthsB==UniMonth(i))&(pricesB==pricei-2*stepShort*0.05);
%                             optionNew=optionsB(tem);
%                             if ~isempty(optionNew)
%                                 tem=w.wsd(optionNew,'close,open,high',datestr(dayTem(i2),'yyyy/mm/dd'),endi,'priceAdj=U');
%                                 if  max(max(tem))/tem(1,1)>=stopRatio
%                                     indT=find(tem(:,3)>tem(1,1)*stopRatio,1);
%                                     if tem(indT,2)>tem(1,1)*stopRatio
%                                         stopT=tem(indT,2);
%                                     else
%                                         stopT=tem(1,1)*stopRatio;
%                                     end
%                                     Re(end)=ReTem+((tem(1,1)-stopT)*10000-7.2)*min(hands1,hands2); 
%                                 else
%                                     Re(end)=ReTem+((tem(1,1)-tem(end,1))*10000-7.2)*min(hands1,hands2);     
%                                 end
%                             else
%                                 tem=(monthsB==UniMonth(i))&(pricesB<pricei-stepShort*0.05);
%                                 pricesBtem=pricesB(tem);optionsBtem=optionsB(tem);
%                                 [~,tem]=sort(pricesBtem);
%                                 if isempty(tem)
%                                     Re(end)=ReTem;
%                                     display('No other options');
%                                 else
%                                     optionNew=optionsBtem(tem(1));
%                                     tem=w.wsd(optionNew,'close,open,high',datestr(dayTem(i2),'yyyy/mm/dd'),endi,'priceAdj=U');
%                                     if max(max(tem))/tem(1,1)>=stopRatio
%                                         indT=find(tem(:,3)>tem(1,1)*stopRatio,1);
%                                         if tem(indT,2)>tem(1,1)*stopRatio
%                                             stopT=tem(indT,2);
%                                         else
%                                             stopT=tem(1,1)*stopRatio;
%                                         end
%                                         Re(end)=ReTem+((tem(1,1)-stopT)*10000-7.2)*min(hands1,hands2); 
%                                     else
%                                         Re(end)=ReTem+((tem(1,1)-tem(end,1))*10000-7.2)*min(hands1,hands2);     
%                                     end
%                                     display('use reverse options');
%                                 end
%                             end
%                             break;
%                         end
%                     end
%                     etfMonth=[etfMonth;tradeDay{1}];
%                 end
%                 tem=~isnan(Re);
%                 Re=Re(tem);
%                 etfMonth=etfMonth(tem);
%                 ReAll=[ReAll,Re];
%                 ReMean=[ReMean,mean(Re)/std(Re)];
%                 monthAll=[monthAll,{etfMonth}];
%                 paras=[paras,[j1,j2,j3]];
%             end
%         end
%     end
% end
% [~,tem]=sort(ReMean);
% Re=ReAll{tem(end)};
% etfMonth=monthAll{tem(end)};
% para=paras{tem(end)};
% figure;
% winRatio=sum(Re>0)/length(Re);
% ReCS=cumsum(Re)+10000;
% plot(ReCS);
% grid on;
% Lre=length(Re);
% step=max(floor(Lre/10),1);
% set(gca,'xtick',1:step:Lre);
% set(gca,'xticklabel',etfMonth(1:step:Lre),'XTickLabelRotation',60);
% maxDown=0;
% ReCS=[0;ReCS];
% for i=2:Lre
%     tem=max(ReCS(1:i))-ReCS(i);
%     if tem>maxDown
%         maxDown=tem;
%     end
% end
% title(sprintf('Step:%d,holdDays:%d,stopRatio:%.2f;\n 年化收益估算：%.2f%%;最大回撤：%.2f%%;胜率：%.2f%%.',stepShortS(para(1)),holdDaysS(para(2)),stopRatioS(para(3)),100*((ReCS(end)/10000)^(1/((datenum(etfMonth(end))-datenum(etfMonth(1)))/360))-1), maxDown/100,winRatio*100));

% loop for use next open short;
stepShortS=[1,2,3]; % gas between current value and void value;
holdDaysS=[15,18,20,23,25,28,30,35]; % trading days from "short" to expire date;
stopRatioS=[1.5,1.7,2.0,2.5,2.8,3.2,3.8];
dateFrom='2014/5/1';
dateFrom=year(datenum(dateFrom))*100+month(datenum(dateFrom));
w=windmatlab;
loops=ceil((today-datenum(2015,2,9))/29);
Year=2015;
Month=1;
monthTem=1;
Day=28;
Data=[];% store data for all options;
ReAll={};
ReMean=[];
monthAll={};
paras={};
for j=1:loops
    if monthTem==12
        Year=Year+1;
    end
    Month=Month+1;
    monthTem=mod(Month,12);
    if monthTem==0
        monthTem=12;
    end
    Date=datenum(Year,monthTem,Day);
    if Date >today
        Date=today;
    end    
    parameters=['date=',datestr(Date,'yyyy-mm-dd'),';','us_code=510050.SH;option_var=全部;',...
        'field=option_code,strike_price,month,call_put,first_tradedate,last_tradedate,option_name'];
    data=w.wset('optionchain',parameters);
    Data=[Data;data];
    if Date==today
        break;
    end       
end
options=Data(:,1);
[options,indTem]=unique(options);
Data=Data(indTem,:);
prices=cell2mat(Data(:,2));
indTem=mod(prices,0.05)<0.00000001;
prices=prices(indTem);
months=cell2mat(Data(indTem,3));
calls=Data(indTem,4);
starts=Data(indTem,5);
ends=Data(indTem,6);    
options=options(indTem);
tem=ismember(calls,'认购');
optionsB=options(tem);
pricesB=prices(tem);
monthsB=months(tem);
prices=prices(~tem);
months=months(tem);
calls=calls(~tem);
starts=starts(~tem);
ends=ends(~tem);    
options=options(~tem);

j123=0;
jall=string(length(stepShortS)*length(holdDaysS)*length(stopRatioS));
for j1=1:length(stepShortS)
    for j2=1:length(holdDaysS)
        for j3=1:length(stopRatioS)
            try
                j123=j123+1;
                display([j1,j2,j3]);
                display(strcat(string(j123),'/',jall));            
                stepShort=stepShortS(j1); % gas between current value and void value;
                holdDays=holdDaysS(j2); % trading days from "short" to expire date;
                stopRatio=stopRatioS(j3);
                Re=[];
                ReC=[];
                records=[];
                recordOptions={};
                optionsRec={};
                Comm=[];%for commission of all;
                etfMonth={};
                UniMonth=unique(months);
                loops=length(UniMonth);

                for i=1:loops  
                    if Year*100+month(today)<=UniMonth(i)
                        continue;
                    end
                    if dateFrom>UniMonth(i)
                        UniMonth(i)
                        continue;
                    end
                    indT=months==UniMonth(i);
                    optionT=options(indT);
                    priceT=prices(indT);
                    startT=starts(indT);
                    endT=ends(indT);
                    [priceT,tem]=unique(priceT);
                    optionT=optionT(tem);
                    startT=startT(tem);
                    endT=endT(tem); 
                    tem=datenum(endT)-datenum(startT)>5;
                    priceT=priceT(tem);
                    optionT=optionT(tem);
                    startT=startT(tem);
                    endT=endT(tem); 

                    tradeDays=w.tdays(datenum(endT(1))-50,endT(1));
                    tradeDay=tradeDays(end-holdDays);
                    etfP=w.wss('510050.SH','close',['tradeDate=',tradeDay{1}],'priceAdj=U','cycle=D');
                    difftem=abs(priceT+stepShort*0.05-etfP);
                    [~,tem]=sort(difftem);
                    optioni=optionT(tem(1));starti=startT(tem(1));endi=endT(tem(1));pricei=priceT(tem(1));
                    if min(difftem)>0.05 || datenum(starti)>datenum(tradeDay)
                        continue;
                    end

                    tem_1=w.wss(optioni,'open',['tradeDate=',tradeDay{1}],'priceAdj=U','cycle=D');
                    etf50_1=w.wss('510050.SH','open',['tradeDate=',tradeDay{1}],'priceAdj=U','cycle=D');
                    [priceTem,~,~,dayTem]=w.wsd(optioni,'close',tradeDay{1},endi,'priceAdj=U');
                    priceStop=priceTem(end);
                    hands1=floor(0.1/(priceTem(1)*(stopRatio-1)));
                    hands2=floor(10000/commission(pricei,tem_1,etf50_1));
                    minHands=min(hands1,hands2);
                    if minHands<1
                        ;%minHands=1;
                    end
                    ReTem=((priceTem(1)-priceStop)*10000-7.2)*minHands;
                    Re=[Re;ReTem];
                    tem=w.wsd(optioni,'open,high,low',tradeDay{1},endi,'priceAdj=U');
                    openTem=tem(:,1);highTem=tem(:,2);lowTem=tem(:,3);closeTem=priceTem;
                    for i2=2:length(priceTem)
                        if highTem(i2)>=priceTem(1)*stopRatio
                            priceStop=max(openTem(i2),priceTem(1)*stopRatio);
                            ReTem=((priceTem(1)-priceStop)*10000-7.2)*minHands;
                            tem=(monthsB==UniMonth(i))&(pricesB==pricei+2*stepShort*0.05);
                            optionNew=optionsB(tem);
                            if ~isempty(optionNew)
                                tem=w.wsd(optionNew,'close,open,high',datestr(dayTem(i2),'yyyy/mm/dd'),endi,'priceAdj=U');
                                if  max(tem(:,1))/tem(1,1)>=stopRatio
                                    indT=find(tem(:,1)>=tem(1,1)*stopRatio,1);
                                    if 1%tem(indT+1,2)>tem(1,1)*stopRatio
                                        stopT=tem(indT+1,2);
                                    else
                                        stopT=tem(1,1)*stopRatio;
                                    end
                                    Re(end)=ReTem+((tem(1,1)-stopT)*10000-7.2)*minHands; 
                                else
                                    Re(end)=ReTem+((tem(1,1)-tem(end,1))*10000-7.2)*minHands;     
                                end
                            else
                                tem=(monthsB==UniMonth(i))&(pricesB>pricei+stepShort*0.05);
                                pricesBtem=pricesB(tem);optionsBtem=optionsB(tem);
                                [~,tem]=sort(pricesBtem);
                                if isempty(tem)
                                    Re(end)=ReTem;
                                    display('No other options');
                                else
                                    optionNew=optionsBtem(tem(1));
                                    tem=w.wsd(optionNew,'close,open,high',datestr(dayTem(i2),'yyyy/mm/dd'),endi,'priceAdj=U');
                                    if max(tem(:,1))/tem(1,1)>=stopRatio
                                        indT=find(tem(:,1)>=tem(1,1)*stopRatio,1);
                                        if 1%tem(indT+1,2)>tem(1,1)*stopRatio
                                            stopT=tem(indT+1,2);
                                        else
                                            stopT=tem(1,1)*stopRatio;
                                        end
                                        Re(end)=ReTem+((tem(1,1)-stopT)*10000-7.2)*minHands; 
                                    else
                                        Re(end)=ReTem+((tem(1,1)-tem(end,1))*10000-7.2)*minHands;     
                                    end
                                    display('use reverse options');
                                end
                            end
                            break;
                        end
                    end
                    etfMonth=[etfMonth;tradeDay{1}];
                end
                tem=~isnan(Re);
                Re=Re(tem);
                etfMonth=etfMonth(tem);
                ReAll=[ReAll,Re];
                ReMean=[ReMean,mean(Re)/std(Re)];
                monthAll=[monthAll,{etfMonth}];
                paras=[paras,[j1,j2,j3]];
            end
        end
    end
end
[~,tem]=sort(ReMean);
Re=ReAll{tem(end)};
etfMonth=monthAll{tem(end)};
para=paras{tem(end)};
figure;
winRatio=sum(Re>0)/length(Re);
ReCS=cumsum(Re)+10000;
plot(ReCS);
grid on;
Lre=length(Re);
step=max(floor(Lre/10),1);
set(gca,'xtick',1:step:Lre);
set(gca,'xticklabel',etfMonth(1:step:Lre),'XTickLabelRotation',60);
maxDown=0;
ReCS=[0;ReCS];
for i=2:Lre
    tem=max(ReCS(1:i))-ReCS(i);
    if tem>maxDown
        maxDown=tem;
    end
end
title(sprintf('ordersAll:%d,Step:%d,holdDays:%d,stopRatio:%.2f;\n 年化收益估算：%.2f%%;最大回撤：%.2f%%;胜率：%.2f%%.',length(Re),stepShortS(para(1)),holdDaysS(para(2)),stopRatioS(para(3)),100*((ReCS(end)/10000)^(1/((datenum(etfMonth(end))-datenum(etfMonth(1)))/360))-1), maxDown/100,winRatio*100));
    
    
    
    
    
    
    