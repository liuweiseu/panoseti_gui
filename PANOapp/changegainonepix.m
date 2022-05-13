%quaboconfig0=quaboconfig;
xx=8;yy=4;
load('MarocMap.mat');
pp=marocmap16(xx,yy,1);
qq=marocmap16(xx,yy,2);

 [ig,indexgain]=ismember(['GAIN' num2str(pp)] ,quaboconfig);

           % quaboconfig(indexgain,indcol+1)=quaboconfig_gain(indexgainmap,indcol+1);
           
             quaboconfig(indexgain,1+qq)={['0x0']};
sendconfig2Maroc(quaboconfig)