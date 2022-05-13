clear all
close all
format
%figini
tickns=1.; %ns

 load('MarocMap.mat');
 startq5ph; 
 resis='';%', [New R] ';
 %startq9ph; 

extfile='coin_'
%direc='/Users/jeromemaire/Documents/SETI/PANOSETI/detectors/coincid/';
%files = dir([direc 'p_d0w0m0q0_20190215_020025_57385' '*.fits']);
%files = dir([direc 'p_d0w0m0q0_20190215_184639_60566' '*.fits']);

%(init dataset) 1Hz only:
%files = dir([direc 'p_d0w0m0q0_20190217_011115_36685' '*.fits']);
%1Hz only:
%direc='C:\Users\jerome\Documents\panoseti\DATA\1Hzonly\';
%files = dir([direc 'p_d0w0m0q0_20190219_210419_151' '*.fits']);
%1Hz low thresh:
direc=[getuserdir '\panoseti\DATA\singlemobo\'];
newd=direc;
files = dir([direc  '*.fits']);


[A,I]= max([files(:).datenum]);
if ~isempty(I)
    latestfiledatenum=dirc(I).datenum;
end

nbim=numel(files);
images=zeros(16,16,nbim);
packetno=zeros(1,nbim);
boarloc=zeros(1,nbim);
utc=zeros(1,nbim);
nanosec=zeros(1,nbim);
timecomp=zeros(1,nbim);

nim0=300;binw=7e-5;
petab=[ 20.];
gaintab=[60];
% NDtab=[0.00125 0.0025 0.005 0.01 0.05 0.125 0.25 0.5];
NDtab=[ 0.01 ];
h=6.63e-34;
c=3.e8;
lam=0.47e-6;
en1phot=h*c/lam
Thorpui1mz=55e-9;%W in front of det at 1MHz
convpixarea=(pi*(0.5*9.4e-3)^2)/(3e-3)^2;
enpixpulse=Thorpui1mz/convpixarea/1e6
nbphotpulsepix=enpixpulse/en1phot
phottab=nbphotpulsepix*NDtab


%truedet=zeros(numel(petab),numel(gaintab));
%totframes=zeros(numel(petab),numel(gaintab));
P=zeros(numel(petab),numel(gaintab),numel(NDtab));
N=zeros(numel(petab),numel(gaintab),numel(NDtab));
TP=zeros(numel(petab),numel(gaintab),numel(NDtab));
%FP=zeros(numel(petab),numel(gaintab)); %si numel(indtruenano)>P
FNmissed=zeros(numel(petab),numel(gaintab),numel(NDtab));
duratall=zeros(numel(petab),numel(gaintab),numel(NDtab));
ADCmax=zeros(numel(petab),numel(gaintab),numel(NDtab));
ADCmean=zeros(numel(petab),numel(gaintab),numel(NDtab));
ADCmedian=zeros(numel(petab),numel(gaintab),numel(NDtab));
ADCstd=zeros(numel(petab),numel(gaintab),numel(NDtab));
nanosecshift=zeros(numel(petab),numel(gaintab),numel(NDtab));

for NDi=1:numel(NDtab)
    if NDi>1
        vol=10;freqtab=[466 392 466 392 466 392] ;dur=0.6;
        for ssL=1:2
        for ss=1:5
        gong(vol,freqtab(ss),dur);pause(0.5);
        end
        pause(5)
        end
    end
    x = input(['Set the ND filters to: ' num2str(NDtab(NDi)) '(' num2str(NDi) '/' num2str(numel(NDtab)) ')' ' and press enter.'])
close all
  for gaini=1:numel(gaintab)
    quaboconfig=changegain(gaintab(gaini), quaboconfig,1);
    gain=gaintab(gaini);
    for pei=1:numel(petab)
        datenow=datestr(now,'yymmddHHMMSS');
          disp(['Gain ' num2str(gaini) '/' num2str(numel(gaintab)) ' ' 'Pe ' num2str(pei) '/' num2str(numel(petab)) ])
        thresh=petab(pei);
        quaboconfig=changepe(petab(pei),gaintab(gaini),quaboconfig);
        pause(3)
        nim=nim0;
        [images nbimafin nanosec timecomp boardloc]=grabimages2key(nim,2,1);
        durat=3600*24*(timecomp(end)- timecomp(1));
        if 3600*24*(timecomp(end)- timecomp(1)) <3
            nim=round(nim0*30/durat);
            [images nbimafin nanosec timecomp boardloc]=grabimages2key(nim,2,1);
        else
            
        end
        
           indquabo1 = find(boardloc==4660);
       % packetno1=packetno(indquabo1);
       % boarloc1=boarloc(indquabo1);
       % utc1=utc(indquabo1);
        nanosec1=nanosec(indquabo1);
        timecomp1=timecomp(indquabo1);
        
     indquabo2 = find(boardloc==4661);
      %  packetno2=packetno(indquabo2);
      %  boarloc2=boarloc(indquabo2);
      %  utc2=utc(indquabo2);
        nanosec2=nanosec(indquabo2);
        timecomp2=timecomp(indquabo2);
   
        
     t1=3600*24*(timecomp1- timecomp2(1));
  t2=3600*24*(timecomp2- timecomp2(1));
 tdiff=t2(2:end)-t2(1:end-1);
 %%%FIRST
 %ind1h=find((abs(tdiff-1)<0.35) & t1(1:end-1)<100);
  ind1h=find((abs(tdiff-1)<0.35));
  ind1h=[ind1h ind1h(end)+1];
 ind1h0=ind1h(1);
 indcyc1=ind1h;
% ind1hz=find((abs(tdiff-floor(tdiff))<0.25) & tdiff>0.5 & t1<220);
 

 ind2hz=zeros(1,numel(ind1h));
 ind2t=zeros(1,numel(ind1h));
 if numel(t1)>0
 for ii=1:numel(ind1h)
     [M, ind]=min(abs(t1-t2(ind1h(ii))));
     ind2hz(ii)=ind;
     ind2t(ii)=M;
 end

 
 diffns=zeros(1,numel(ind2hz)); indgood=[];
 for  dd=1:numel(ind1h)
     diffns(dd)=  nanosec2(ind1h(dd)) - nanosec1(ind2hz(dd));
     if abs(diffns(dd))>30
         disp('Removing outliers')
         diffns(dd)=NaN;
     else
        
     end
 end
else
    diffns=NaN+zeros(1,numel(ind2hz));

end
 
 truepos=sum(isfinite(diffns))
 
 
        nanosec1=tickns*(1e-9)*nanosec1;
             sz1=numel(t1);
        durat=t2(end)-t2(1);
        %channel 2 is not ND filtered so it will serve as a reference
        
        


 figure
 histogram(diffns,'BinMethod','integers')
 xlabel('nanosec difference [ns]')
 ylabel('Occurrence')
 
 figure
 hold on
 tabcolor=['b';'g' ;'r';'k';'m';'y']
 for oo=1:numel(ind1h)
     hold on
       plot( t2(ind1h(oo)) ,nanosec2(ind1h(oo)),'+','Color',tabcolor(mod(oo,5)+1) )
       if numel(t1)>0
       plot(t1(ind2hz(oo)) ,nanosec1(ind2hz(oo)),'o','Color',tabcolor(mod(oo,5)+1) )
       end
     % plot( 3600*24*(timecomp1- timecomp1(1)) ,2*ones(1,numel( indquabo1)),'+b' )
      % plot( 3600*24*(timecomp2- timecomp2(1)) ,2*ones(1,numel( indquabo2)),'or')
       hold off
 end
     % plot(utc1,ones(1,numel(utc1)))
      ylabel('NANOSEC [ns]')
      xlabel(' time comp')
     
         filenm=['DriftG' num2str(gain) 'Tpe' num2str(thresh) 'Mask' num2str(maskmode)]
        saveas(gcf,[newd extfile filenm '_' datenow '.png'])
        saveas(gcf,[newd extfile filenm '_' datenow '.fig'])
  diffns1=diffns;
        
%  %%%
%   
 figure('Position',[100 100 1200 900],'Color','w')
 %subplot(3,2,1)
hn= histogram((1/1.)*diffns1,'BinMethod','integers')
 xlabel('nanosec counter difference [ns]')
 ylabel('Occurrence')
ti=title([resis 'fresnelized mobos blue-flashed at 1Hz, Gain=' num2str(gain) ', thr=' num2str(thresh) 'pe, ' masklabel])
['fresnelized mobos blue-flashed at 1Hz, Gain=' num2str(gain) ', thr=' num2str(thresh) 'pe, ' masklabel]
set(ti,'FontSize',12)
legend('nanosec2 -nanosec1')
xlim([-20 20])
grid on
 
        
    
         filenm=['G' num2str(gain) 'Tpe' num2str(thresh) 'Mask' num2str(maskmode)]
        saveas(gcf,[newd extfile filenm 'sidebysidedoublemobost_' datenow '.png'])
        saveas(gcf,[newd extfile filenm 'sidebysidedoublemobost_' datenow '.fig'])
        
  [maxval indmax ]=max(hn.Values);
    val=hn.BinEdges;
    maxhistnanosec=val(indmax);
        if 1==1
            
          unmaskcoor=marocmap(maskpix1(1),maskpix1(2),:);
        unmask1=squeeze(images(unmaskcoor(2),unmaskcoor(1),indquabo1));
        %unmask2=images(unmaskcoor(1),unmaskcoor(2),indquabo2);
        
   figure('Position',[100 100 1200 900],'Color','w')
    hold on
    if maskmode==1 
        if numel(unique(ind2hz))>1
    h1=histogram(unmask1(unique(ind2hz)),'BinWidth',10,'FaceColor','b','FaceAlpha',1,'BinMethod', 'integers')
    [maxval indmax ]=max(h1.Values);
    val=h1.BinEdges;
    maxhistADC=val(indmax);
    meanADC=mean(unmask1(unique(ind2hz)));
    medianADC=median(unmask1(unique(ind2hz)));
    stdADC=std(unmask1(unique(ind2hz)));
        else
                maxhistADC=NaN;
    meanADC=NaN;
    medianADC=NaN;
    stdADC=NaN;
        end
    %histogram(unmask2(ind2hz),'BinWidth',10,'FaceColor','g','FaceAlpha',0.5)
    else
      histogram( squeeze(images(:,:,indquabo1)),'BinWidth',10,'FaceColor','b','FaceAlpha',1)
  histogram( squeeze(images(:,:,indquabo2)),'BinWidth',10,'FaceColor','g','FaceAlpha',0.5)
    end
    hold off
    xlim([0 4100])
    xlabel('Intensity (ADC)')
    ylabel('Occurrence')
    legend('Quabo#1','Quabo#2')
    ti=title([resis 'fresnelized mobos blue-flashed at 1Hz, Gain=' num2str(gain) ', thr=' num2str(thresh) 'pe, ' masklabel])
set(ti,'FontSize',12)
  filenm=['G' num2str(gain) 'Tpe' num2str(thresh) 'Mask' num2str(maskmode)]
        saveas(gcf,[newd extfile filenm 'ADC_' datenow '.png'])
        saveas(gcf,[newd extfile filenm 'ADC_' datenow '.fig'])
        end


%         disp(['Number of positives (comp): ' num2str(numel(indtrue)) ' / ' num2str(sz1) ' tot.frames'])
%         disp(['Number of true positives (comp): ' num2str(numel(indtrue)) ' / '  num2str(round(durat)+1) ' expected'])
%         disp(['Number of positives (nanosec): ' num2str(numel(indtruenano)) ' / ' num2str(sz1) ' tot.frames'])
%         disp(['Number of positives (nanosec): ' num2str(numel(indtruenano)) ' / '  num2str(round(durat)+1) ' expected'])
%         disp(['nb of positives (nanosec2): ' num2str(numel(C)) ' / '  num2str(round(durat)+1) ' expected'])
         disp(['Duration[s]: ' num2str(durat)])
         disp(['P (based on mobo2): ' num2str(ind1h)])
%           
%         truedet(pei,gaini)=numel(indtruenano);
%         totframes(pei,gaini)=sz1;
          duratall(pei,gaini,NDi)=durat;
         P(pei,gaini,NDi)=numel(ind1h);
         N(pei,gaini,NDi)=sz1-numel(ind1h);
       TP(pei,gaini,NDi)=truepos;
%         FP(pei,gaini)=max([numel(indtruenano)-(round(durat)+1) 0]); %si numel(indtruenano)>P
         FNmissed(pei,gaini,NDi)=P(pei,gaini)-TP(pei,gaini);
         ADCmax(pei,gaini,NDi)=maxhistADC;
         ADCmean(pei,gaini,NDi)=meanADC;
         ADCmedian(pei,gaini,NDi)=medianADC;
         ADCstd(pei,gaini,NDi)=stdADC;
         nanosecshift(pei,gaini,NDi)=maxhistnanosec;
%         
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% end of measurements %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for NDi=1:numel(NDtab)
figure('Position',[100 100 1200 900],'Color','w')

hold on
leg={};

for gaini = 1:numel(gaintab)
    hitrate= TP(:,gaini,NDi)./P(:,gaini,NDi);
    leg=[leg {['Gain: ' num2str(gaintab(gaini))]}]
    plot(petab,hitrate,'-+','LineWidth',2)
    
end

hold off
xlabel('pe#')
ylabel('True Positive Rate (TP/P)')
le=legend(leg)
set(gca,'FontSize',16)
box on 
grid on
title( ['ND filter:' num2str(NDtab(NDi)) resis 'quabo SN00' num2str(quaboSN) ', PH mode,' masklabel])
% subplot(1,3,2)
% hold on
% for gaini=1:numel(gaintab)
%     missedrate= FNmissed(:,gaini)./P(:,gaini);
%     plot(petab,missedrate,'-+')
% end
% hold off
% xlabel('pe#')
% ylabel('Missed Rate (P-TP)/P)')
       filenm=[ 'ND' num2str(NDtab(NDi)) 'Mask' num2str(maskmode)]
        saveas(gcf,[newd extfile filenm 'DETEC_TPP_' datenow '.png'])
        saveas(gcf,[newd extfile filenm 'DETEC_TPP_' datenow '.fig'])
        
figure('Position',[100 100 1200 900],'Color','w')
hold on
for gaini=1:numel(gaintab)
    psurn= (N(:,gaini,NDi)+P(:,gaini,NDi)-TP(:,gaini,NDi))./P(:,gaini,NDi);
    plot(petab,psurn,'-+','LineWidth',2)
end
hold off
xlabel('pe#')
ylabel('N/P')
le2=legend(leg)
set(gca,'FontSize',16)
box on 
grid on
title( ['ND filter:' num2str(NDtab(NDi)) resis 'quabo SN00' num2str(quaboSN) ', PH mode,' masklabel])

       filenm=[ 'ND' num2str(NDtab(NDi)) 'Mask' num2str(maskmode)]
        saveas(gcf,[newd extfile filenm 'DETEC_NP_' datenow '.png'])
        saveas(gcf,[newd extfile filenm 'DETEC_NP_' datenow '.fig'])
% 
% for ii =1 :4 
% disp(numel(find(nanodiffs0(ii,:)<binw)))
% end



figure('Position',[100 100 1200 900],'Color','w')

hold on
leg={};

for gaini = 1:numel(gaintab)
    mobo2missed= abs(duratall(:,gaini,NDi)-P(:,gaini,NDi));
    leg=[leg {['Gain: ' num2str(gaintab(gaini))]}]
    plot(petab,mobo2missed,'-+','LineWidth',2)
    
end

hold off
xlabel('pe#')
ylabel('mobo2missed (durat-P)')
le=legend(leg)
set(gca,'FontSize',16)
box on 
grid on
title( ['ND filter:' num2str(NDtab(NDi)) resis 'quabo SN00' num2str(quaboSN) ', PH mode,' masklabel])

 filenm=[ 'ND' num2str(NDtab(NDi)) 'Mask' num2str(maskmode)]
        saveas(gcf,[newd extfile filenm 'DETEC_miss_' datenow '.png'])
        saveas(gcf,[newd extfile filenm 'DETEC_miss_' datenow '.fig'])
end



%% figure ADC vs light level
for pei = 1:numel(petab)
    %fig nanosec delay vs phot level
    figure('Position',[100 100 1200 900],'Color','w')
hold on
leg={};
for gaini = 1:numel(gaintab)
   plot(phottab,squeeze(nanosecshift(pei,gaini,:)),'-+','LineWidth',2)
    leg=[leg {['Gain: ' num2str(gaintab(gaini))]}]
   
    
end
hold off
xlabel('Nb of photons per pulse per pixel')
ylabel('Nanosec shift [ns]')
le=legend(leg)
set(gca,'FontSize',16,'XScale','log','YScale','log')
box on 
grid on
ti=title( ['Nanosec shift (max occur. in hist.), pe:' num2str(petab(pei)) resis ' quabo SN00' num2str(quaboSN) ', PH mode,' masklabel])
set(ti, 'FontSize',12) 
filenm=[ 'NanoShift_pe' num2str(petab(pei)) 'Mask' num2str(maskmode)]
 saveas(gcf,[newd extfile filenm '_' datenow '.png'])
 saveas(gcf,[newd extfile filenm '_' datenow '.fig'])
 
 %%%%%ADCmax
figure('Position',[100 100 1200 900],'Color','w')
hold on
leg={};
for gaini = 1:numel(gaintab)
   plot(phottab,squeeze(ADCmax(pei,gaini,:)),'-+','LineWidth',2)
    leg=[leg {['Gain: ' num2str(gaintab(gaini))]}]
   
    
end
hold off
xlabel('Nb of photons per pulse per pixel')
ylabel('ADC (most occurences) ')
le=legend(leg)
set(gca,'FontSize',16,'XScale','log','YScale','log')
box on 
grid on
title( ['ADC (max occur. in hist.), pe:' num2str(petab(pei)) resis ' quabo SN00' num2str(quaboSN) ', PH mode,' masklabel])
 filenm=[ 'ADCphotmax_pe' num2str(petab(pei)) 'Mask' num2str(maskmode)]
 saveas(gcf,[newd extfile filenm '_' datenow '.png'])
 saveas(gcf,[newd extfile filenm '_' datenow '.fig'])
 
 %%mean ADC
 figure('Position',[100 100 1200 900],'Color','w')
hold on
leg={};
for gaini = 1:numel(gaintab)
   plot(phottab,squeeze(ADCmean(pei,gaini,:)),'-+','LineWidth',2)
    leg=[leg {['Gain: ' num2str(gaintab(gaini))]}]
  
    
end
hold off
xlabel('Nb of photons per pulse per pixel')
ylabel('ADC mean (baseline subtracted)')
le=legend(leg)
set(gca,'FontSize',16,'XScale','log','YScale','log')
box on 
grid on
title( ['ADC (mean), pe:' num2str(petab(pei)) resis ' quabo SN00' num2str(quaboSN) ', PH mode,' masklabel])
 filenm=[ 'ADCmean_pe' num2str(petab(pei)) 'Mask' num2str(maskmode)]
 saveas(gcf,[newd extfile filenm '_' datenow '.png'])
 saveas(gcf,[newd extfile filenm '_' datenow '.fig'])
 
 
 %%median ADC
 figure('Position',[100 100 1200 900],'Color','w')
hold on
leg={};
for gaini = 1:numel(gaintab)
   plot(phottab,squeeze(ADCmedian(pei,gaini,:)),'-+','LineWidth',2)
    leg=[leg {['Gain: ' num2str(gaintab(gaini))]}]
   
    
end
hold off
xlabel('Nb of photons per pulse per pixel')
ylabel('ADC median (baseline subtracted)')
le=legend(leg)
set(gca,'FontSize',16,'XScale','log','YScale','log')
box on 
grid on
title( ['ADC (median), pe:' num2str(petab(pei)) resis ' quabo SN00' num2str(quaboSN) ', PH mode,' masklabel])
 filenm=[ 'ADCphotMEDIAN_pe' num2str(petab(pei)) 'Mask' num2str(maskmode)]
 saveas(gcf,[newd extfile filenm '_' datenow '.png'])
 saveas(gcf,[newd extfile filenm '_' datenow '.fig'])
 
  %%STD ADC
 figure('Position',[100 100 1200 900],'Color','w')
hold on
leg={};
for gaini = 1:numel(gaintab)
   plot(phottab,squeeze(ADCstd(pei,gaini,:)),'-+','LineWidth',2)
    leg=[leg {['Gain: ' num2str(gaintab(gaini))]}]
   
    
end
hold off
xlabel('Nb of photons per pulse per pixel')
ylabel('ADC STD (baseline subtracted)')
le=legend(leg)
set(gca,'FontSize',16,'XScale','log','YScale','log')
box on 
grid on
title( ['ADC (STD), pe:' num2str(petab(pei)) resis 'quabo SN00' num2str(quaboSN) ', PH mode,' masklabel])
 filenm=[ 'ADCphotSTD' num2str(petab(pei)) 'Mask' num2str(maskmode)]
 saveas(gcf,[newd extfile filenm '_' datenow '.png'])
 saveas(gcf,[newd extfile filenm '_' datenow '.fig'])
 
end
      





