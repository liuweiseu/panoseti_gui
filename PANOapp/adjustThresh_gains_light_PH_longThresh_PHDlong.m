close all
 if ~exist('s','var')
     s = serial('COM6','BaudRate',9600);
     fopen(s)
 end
exposurestr='';
nbimperdac=1000;
dactab=[210:2:260 ]; 
%dactab=[235:2:265 ];  %works well for gain=33, Q1
%  dactab=[250:5:300 ]; %works well for gain=66

usegainmap=0
gaintabtab=[55];%11:31 %1:10:121;
gaintab=gaintabtab;%11:31 %1:10:121;
load(['pethresh_gain' num2str(gaintabtab) '.mat'])
petab=(1/A0)*(-B0 + dactab); % A0...A3
indcoldac=1; %%% 1...4 attention!
load(['gainmap_gain' num2str(gaintabtab) '.mat'])

resultdir=[getuserdir '\panoseti\PANOapp\results'];

%currtabExp=[0. round(logspace(0,log10(4000),10))];
currtabExp=[0.];
exptext=' Dark. ' %' Light ON (400uA) ' 
%currtabExp=[0. ];
maxtesttime = 60;

expstr='Light ON.';
shaperstr='Bipolar fs; ';
maskstr='All-pixels-masked-excepted-one [7,1]; ';
IntensmeanQ9G=zeros(numel(dactab),numel(gaintabtab),numel(currtabExp));

realhvQ0=[];realhvQ1=[];realhvQ2=[];realhvQ3=[];
realcurQ0=[];realcurQ1=[];realcurQ2=[];realcurQ3=[];
temp1=[];temp2=[];
timecomp=[];

cc=1;
%for cc=1:numel(currtabExp)
disp(['Testing Curr:' num2str(currtabExp(cc))])
disp(['Setting: U' num2str(currtabExp(cc),'%05g') ';'])
%setADU(['WR' num2str(currtab(ii),'%05g')]);
 setJimPS(s,currtabExp(cc))
disp('Changing Light intensity. Waiting 15s for HV to be adjusted...')

%     if cc>1
%     pause(15)
%     end

quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config.txt']);
[ig,indexstimon]=ismember(['STIMON '] ,quaboconfig);
quaboconfig(indexstimon,2)={"0"};
pausetime=0.5;
indcol=1:4;

[ig,indexacqmode]=ismember(['ACQMODE '] ,quaboconfig);
quaboconfig(indexacqmode,2)={"0x01"};

[ig,indexhold1]=ismember(['HOLD1 '] ,quaboconfig);
[ig,indexhold2]=ismember(['HOLD2 '] ,quaboconfig);



%

% [ig,indexacqint]=ismember(['ACQINT '] ,quaboconfig);
% acqint=(1e-5)*str2num(quaboconfig(indexacqint,2));
% exposurestr=['Exposure time [ms]:' num2str(1000*acqint,'%3.3g')];
normcps=1; %/acqint;
%set gain


for  gainkk=1:numel(gaintabtab)
     
    if usegainmap==0
    gaintab=gaintabtab(gainkk);
    for pp=0:63
        [ig,indexgain]=ismember(['GAIN' num2str(pp)] ,quaboconfig);
        
        quaboconfig(indexgain,indcol+1)={['0x' dec2hex(gaintab(1))]};
    end
    else
         for pp=0:63
        [ig,indexgainmap]=ismember(['GAIN' num2str(pp)] ,quaboconfig_gain);
        [ig,indexgain]=ismember(['GAIN' num2str(pp)] ,quaboconfig);
        
        quaboconfig(indexgain,indcol+1)=quaboconfig_gain(indexgainmap,indcol+1);
    end
    end
    %set masks MASKOR1_
    mask=1;
    if mask==0
        for pp=0:63
            [ig,indexmask]=ismember(['MASKOR1_' num2str(pp)] ,quaboconfig);
            quaboconfig(indexmask,indcol+1)={['0']};
        end
    else
        indcols=1
        for pp=0:63
            [ig,indexmask]=ismember(['MASKOR1_' num2str(pp)] ,quaboconfig);
            quaboconfig(indexmask,indcol+1)={['1']};
            [ig,indexmask2]=ismember(['MASKOR2_' num2str(pp)] ,quaboconfig);
            quaboconfig(indexmask2,indcol+1)={['1']};
        end
%         [ig,indexmask]=ismember(['MASKOR1_63'] ,quaboconfig);
%         quad=1; 
%         quaboconfig(indexmask,quad+1)={['0']};
%         [ig,indexmask2]=ismember(['MASKOR2_63'] ,quaboconfig);
%         quaboconfig(indexmask2,quad+1)={['0']};
        
            %marocmap(32,1,:)
        [ig,indexmask]=ismember(['MASKOR1_63'] ,quaboconfig);
        quad=1; 
        quaboconfig(indexmask,quad+1)={['0']};
        [ig,indexmask2]=ismember(['MASKOR2_63'] ,quaboconfig);
        quaboconfig(indexmask2,quad+1)={['0']};
%         [ig,indexmask]=ismember(['MASKOR1_53'] ,quaboconfig);
%       quaboconfig(indexmask,quad+1)={['0']};
%         [ig,indexmask2]=ismember(['MASKOR2_53'] ,quaboconfig);
%         quaboconfig(indexmask2,quad+1)={['0']};
                
%                         quaboconfig(indexmask,quad+1+1)={['0']};
%         [ig,indexmask2]=ismember(['MASKOR2_63'] ,quaboconfig);
%         quaboconfig(indexmask2,quad+1+1)={['0']};
%                 [ig,indexmask]=ismember(['MASKOR1_63'] ,quaboconfig);
    end
    
    
    %set masks CHANMASK_
    maskph=0;
    if maskph==0
        for pp=0:7
            [ig,indexmask]=ismember(['CHANMASK_' num2str(pp) ' '] ,quaboconfig);
            quaboconfig(indexmask,1+1)={['0x0']};
        end
    else
        for pp=0:7
            [ig,indexmask]=ismember(['CHANMASK_' num2str(pp) ' '] ,quaboconfig);
            quaboconfig(indexmask,1+1)={['0xFFFFFFFF']};
        end
        [ig,indexmask]=ismember(['CHANMASK_8 '] ,quaboconfig);
        quaboconfig(indexmask,1+1)={['0x1FF']};
        [ig,indexmask]=ismember(['CHANMASK_0 '] ,quaboconfig);
        % quad=2;
        quaboconfig(indexmask,1+1)={['0xEFFFFFFF']};
        sendPHmasks(quaboconfig)
    end
    load('Marocmap.mat')
    xt1=squeeze(marocmap(64,1,1));
    yt1=squeeze(marocmap(64,1,2));
    xt2=squeeze(marocmap(32,1,1));
    yt2=squeeze(marocmap(32,1,2));
    xt3=squeeze(marocmap(8,4,1));
    yt3=squeeze(marocmap(8,4,2));
    
    %put high thresh on all 4 quads
      [ia,indexdac]=ismember('DAC1',quaboconfig);
    dactabH0=1000;indcol=1:4;
    quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactabH0)]};
    % init the board?
    disp('Init Marocs...')
    sendconfig2Maroc(quaboconfig)
    disp('Waiting 3s...')
    pause(3)
    disp('Init Acq...')
    %  sentacqparams2board(quaboconfig)
    disp('Waiting 3s...')
    pause(3)
    
    %dactab=[ 240 250 260 270 280 290 300 305 310 320 350 400 450 500];
    %dactab=[288 290 292 294 296 298 300 305 310 320 350 400 450 500];
    %dactab=[550:1:650 ];
    
    %dactab=[185:5:305  ];
    figure
  
    
    %put high thresh on all 4 quads
    % dactabH0=500;
    %  quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactabH0)]};
    %  pause(pausetime)
    
    IntensmeanQ0=[];IntensmeanQ1=[];IntensmeanQ2=[];IntensmeanQ3=[];IntensmeanQ8=[];IntensmeanQ9=[];
    allima=zeros(16,16,numel(dactab),numel(indcol));
    indcol2=1;
    timetested=0;
    timetestedzero=tic;
    
    IntensmeanQ8GH=[];
    % IntensmeanQ8GSTDH=[IntensmeanQ8GSTDH; IntensmeanQ8GSTD];;
    IntenspixH=[];
    IntenspixSTDH=[];
     IntenspixHB=[];
    IntenspixSTDHB=[];
    
    pause(3)
    for hh=0:0
        quaboconfig(indexhold1,2)={num2str(hh)};
        %quaboconfig(indexhold2,2)={num2str(hh)};
       % quaboconfig(indexacqmode,2)={"0x01"};
        sentacqparams2board(quaboconfig)
        disp('Waiting 1s...')
        pause(1)
        %%SUBTRACT BASELINE EACH TIME
        subtractbaseline
        pause(3)
        %%%testing the crap PH change bizarro thing
        bizarro=1
        while bizarro==1
            bizarro=0;
              imagephtest=grabimagesnofits(100,1,1);
              spatialmeantest=(mean(imagephtest(:,:,:),[3]));
              timestdtest=std(mean(imagephtest(:,:,:),[1 2]));
               if max(spatialmeantest,[],'all')>3*mean(spatialmeantest,[1 2])
                  bizarro=1
                   disp(['Bizarre mode detected (peaks detected). Retrying...'])
               end
%               if timestdtest>1.5
%                   figure
%                  plot(squeeze( mean(imagephtest(:,:,:),[1 2])))
%                  clf
%                    bizarro=1
%                    disp(['Bizarre mode detected (large std ' num2str(timestdtest) '). Retrying...'])
%                end
%               if max(imagephtest,[],'all')>3000-2000
%                   bizarro=1
%               end
%               if mean(imagephtest(1:8,9:16),'all')> mean(imagephtest(9:16,1:8),'all')
%                   bizarro=1
%               end
              if bizarro==1
                  sentacqparams2board(quaboconfig)
                  pause(1)
              end
          end
        
        
        
         
%          sentacqparams2board(quaboconfig)
%          disp('Waiting 1s...')
%          pause(1)
%          sentacqparams2board(quaboconfig)
%          disp('Waiting 1s...')
%          pause(1)
%          sentacqparams2board(quaboconfig)
%          disp('Waiting 1s...')
%          pause(1)
%          sentacqparams2board(quaboconfig)
%          disp('Waiting 1s...')
         load gong.mat; gong = audioplayer(y, Fs); play(gong);
  %       pause(1)
        % IntensmeanQ9G(dd,gainkk,cc)=measframerate(10,1,1);
        nbtrig=0;
        Intenspix=[];
        IntenspixSTD=[];
          IntenspixB=[];
        IntenspixSTDB=[];
        
          IntenspixC=[];
        IntenspixSTDC=[];
        IntensmeanQ8G=[];
        tic;
        %    while timetested<maxtesttime
        for dd=1:numel(dactab)
            quaboconfig(indexdac,indcoldac+1)={['0x' dec2hex(dactab(dd))]};
            disp(['Sending Maroc comm...DAC1:' num2str(dactab(dd)) ' Gain:' num2str((gaintabtab(gainkk))) ' (' num2str(gainkk) '/' num2str(numel(gaintabtab)) ')' ...
                'Light I [step]: ' num2str(cc) '/' num2str(numel(currtabExp))])
            sendconfig2Maroc(quaboconfig)
            pause(3)
            
          %  images=grabimages(nbimperdac,1,1);
            nbtot=0;imageszeros=[];
            while nbtot<nbimperdac
              [imageszerostmp nbimafin]=grabimages2(nbimperdac,1,1);
              imageszerostmp=imageszerostmp(:,:,1:nbimafin-1);
               nbtot=nbtot+nbimafin-1;
               
               imageszeros2=cat(3,imageszeros,imageszerostmp );
               imageszeros=imageszeros2;
            end
          
             %  images=imageszeros(:,:,1:nbimafin-1);
             images=imageszeros(:,:,1:nbimperdac);
               imagesNZ=[];
               %double-check no zeros image
               imagesNZind=[];
               for zz=1:size(images,3)
                  if sum(images(:,:,zz))~=0
                      imagesNZind=[imagesNZind zz];
                  end
               end
               imagesNZ=images(:,:,imagesNZind);
               images=imagesNZ;
           
           % if dd==1
                figure('Position',[10 10 1400 900])
                subplot(2,1,1)
                hold on
                
                 [histsinglepix1 cent1]=hist(squeeze(images(xt1,yt1,:))) 
                 plot(cent1, histsinglepix1)
                 [histsinglepix2 cent2]=hist(squeeze(images(xt2,yt2,:)))
                plot(cent2, histsinglepix2)
                 [histsinglepix3 cent3]=hist(squeeze(images(xt3,yt3,:)))
                plot(cent3, histsinglepix3)
                 hold off
                legend(['pix[' num2str(xt1) ',' num2str(yt1) ']'],...
                    ['pix[' num2str(xt2) ',' num2str(yt2) ']'],...
                    ['pix[' num2str(xt3) ',' num2str(yt3) ']'])
                  xlabel('ADC value')
                 
                   subplot(2,1,2)
                hold on
               plot(squeeze(images(xt1,yt1,:)),'+')
                 %  plot(squeeze(images(3,7,:)),'+')
                 % plot(squeeze(images(10,7,:)),'+')
                 hold off
                    xlabel('Time [frame#]')
                  ylabel('ADC value (triggered pix)')
              legend(['pix[' num2str(xt1) ',' num2str(yt1) ']'])
                 datenow=datestr(now,'yymmddHHMMSS');
        saveas(gcf,[resultdir '\png\ ' 'meanpix_vs_timeacq' '_DAC' num2str(dactab(dd)) '_' 'Gain' num2str(gaintab(1))  '_' datenow '_nomask.png'])
        saveas(gcf,[resultdir '\fig\' 'meanpix_vs_timeacq' '_DAC' num2str(dactab(dd)) '_' 'Gain' num2str(gaintab(1)) '_' datenow '_nomask.fig'])
      close(gcf)
            % end
             spatialmeanvstime=squeeze(mean(images(:,:,:),[1 2]));
            spatialmedianvstime=squeeze(median(images(:,:,:),[1 2]));
             
             
             
            figure
           % subplot(2,2,3)
            set(gcf,'Color','w')
            hold on
            plot(squeeze(spatialmeanvstime),'-+b')
            plot(squeeze(spatialmedianvstime),'--r')
            hold off
            legend('Mean over all pixels', 'Median')
            xlabel('Time [frame#]')
            ylabel('mean ADC value (over pixels)')
            yl=ylim
            title([exptext 'Bipolar fs; All-trigmasked-except-one. STD: 1000 images/dac'])
            box on; grid on
            text(10,yl(1)+0.75*(yl(2)-yl(1)),['DAC:' num2str(dactab(dd))],'FontSize',16)
            text(100,yl(1)+0.5*(yl(2)-yl(1)),['HOLD [ns]:' num2str(hh*5)],'FontSize',18)
            %ylim([2090 2110])
               datenow=datestr(now,'yymmddHHMMSS');
        saveas(gcf,[resultdir '\png\' 'meanimage_vs_timeacq' '_DAC' num2str(dactab(dd)) '_' 'Gain' num2str(gaintab(1))  '_' datenow '_nomask.png'])
        saveas(gcf,[resultdir '\fig\' 'meanimage_vs_timeacq' '_DAC' num2str(dactab(dd)) '_' 'Gain' num2str(gaintab(1)) '_' datenow '_nomask.fig'])
      close(gcf)
            %what about outlier images?
            
            
            meanimage=mean(images(:,:,:),[3])';
            stdimage=std(images(:,:,:),0,[3])';
            figure
            set(gcf,'Color','w')
            subplot(1,2,1)
            imagesc(meanimage')
            axis image
            colorbar
            title('mean image')
             text(1,-2,[exptext 'Bipolar fs; All-trigmasked-except-one. STD: 1000 images/dac'])
            
            text(1,-4,['DAC:' num2str(dactab(dd))],'FontSize',12)
            text(1,-6,['HOLD [ns]:' num2str(hh*5)],'FontSize',12)
            
            subplot(1,2,2)
            imagesc(stdimage')
             axis image
            colorbar
             title('STD image')
             datenow=datestr(now,'yymmddHHMMSS');
                 saveas(gcf,[resultdir '\png\' 'mean2dimage_STD2dimage' '_DAC' num2str(dactab(dd)) '_' 'Gain' num2str(gaintab(1))  '_' datenow '_nomask.png'])
        saveas(gcf,[resultdir '\fig\' 'mean2dimage_STD2dimage' '_DAC' num2str(dactab(dd)) '_' 'Gain' num2str(gaintab(1)) '_' datenow '_nomask.fig'])
      close(gcf)
             
             
             
            toctoc=toc;
            timetested=toctoc;
            if sum(images,'all')>0
                Intenspix=[Intenspix; meanimage(xt1,yt1)];
                IntenspixSTD=[IntenspixSTD; stdimage(xt1,yt1)];
                IntenspixB=[IntenspixB; meanimage(xt2,yt2)];
                IntenspixSTDB=[IntenspixSTDB; stdimage(xt3,yt3)];
                IntenspixC=[IntenspixC; meanimage(xt3,yt3)];
                IntenspixSTDC=[IntenspixSTDC; stdimage(xt3,yt3)];
                [Ma, indmlin] =max(meanimage);
                [Ma2, indmcol] =max(Ma);
                  
                disp(['pix ' num2str(indmlin(indmcol)) ' ' num2str(indmcol)])
                IntensmeanQ8G=[IntensmeanQ8G; Ma2];
                
                nbtrig=nbtrig+1
                if Ma2<meanimage(1,7)
                    disp('Stop')
                end
            end
        end
        
        
        
        
        figure('Position',[10 10 1400 900],'Color','w')
        hold on
        plot(dactab,IntensmeanQ8G,'ro-')
        errorbar(dactab,Intenspix,0.5*IntenspixSTD)
         errorbar(dactab,IntenspixB,0.5*IntenspixSTDB)
         errorbar(dactab,IntenspixC,0.5*IntenspixSTDC)
        box on
        
      %  hold off
        %nbimperdac
        xlabel('DAC1 value')
        ylabel(' mean ADC value')
        title(['HOLD [ns]:' num2str(hh*5) ' Gain:' num2str(gaintab(1)) exptext ' All-pix-masked-exc.-one. Errorbar STD ' num2str(nbimperdac) ' images/DAC1pts'],'FontSize',12)
      %  legend('Max intensity in trig. images (diff. pixel#)','Triggering pix', 'other pixel')
    

        set(gca, 'YScale','lin')
        box on; grid on
           
        yl=ylim
        %%pe levels
        peaksdac3=zeros(1,ceil(petab(1))-1);
        for pp=ceil(petab(1)):floor(petab(end))
           [minval minind] =  min(abs(dactab-(B0+A0*pp)));
            peaksdac3=[peaksdac3 dactab(minind(1))];
           pepplot=plot([peaksdac3(end) peaksdac3(end)] , yl,'--')
           pepplot.Annotation.LegendInformation.IconDisplayStyle = 'off';
         text(peaksdac3(end) ,-3+yl(2),[num2str(pp) 'pe'],'FontSize',16)
        end
        
        
        %best fit
        [countfit, gof] = fit(dactab',IntensmeanQ8G, 'poly1')
        ADCDACfit=plot(dactab,(countfit.p1*dactab + countfit.p2),'--','LineWidth',2.)
     leg= [{'Max intensity in trig. images (diff. pixel#)'} {['pix[' num2str(xt1) ',' num2str(yt1) ']']} ...
                    {['pix[' num2str(xt2) ',' num2str(yt2) ']']} ...
                    {['pix[' num2str(xt3) ',' num2str(yt3) ']']} ...
                    {['ADC = ' num2str(countfit.p1) ' DAC + ' num2str(countfit.p2) ' OR ' 'ADC = ' num2str(A0*countfit.p1) ' PE + ' num2str(B0*countfit.p1+countfit.p2)]}]   
      legend(leg,'Location','SouthEast')
        
        
       % text(dactab(2),yl(2)-5,['HOLD [ns]:' num2str(hhh*5)],'FontSize',18)
        hold off
        datenow=datestr(now,'yymmddHHMMSS');
        saveas(gcf,[resultdir '\png\' 'ADC_DACHOLD' num2str(hh) '_' 'Gain' num2str(gaintab(1))  '_' datenow '_nomask.png'])
        saveas(gcf,[resultdir '\fig\' 'ADC_DACHOLD' num2str(hh) '_' 'Gain' num2str(gaintab(1)) '_' datenow '_nomask.fig'])
        close(gcf)
   
    IntensmeanQ8GH=[IntensmeanQ8GH IntensmeanQ8G];
    % IntensmeanQ8GSTDH=[IntensmeanQ8GSTDH; IntensmeanQ8GSTD];;
    IntenspixH=[IntenspixH Intenspix];
    IntenspixSTDH=[IntenspixSTDH IntenspixSTD];
     IntenspixHB=[IntenspixHB IntenspixB];
    IntenspixSTDHB=[IntenspixSTDHB IntenspixSTDB];
     end
end

%%%%%%%%%%
%%%%%%%%%%
%%%%%%%%%%
%%%%%  
%%%%%%%%%%
dd=1;
dactab=220; %[260];
dactab0=dactab;
nbimperdac=100;timemax=300;
  quaboconfig(indexdac,indcoldac+1)={['0x' dec2hex(dactab(dd))]};
            disp(['Sending Maroc comm...DAC1:' num2str(dactab(dd)) ' Gain:' num2str((gaintabtab(gainkk))) ' (' num2str(gainkk) '/' num2str(numel(gaintabtab)) ')' ...
                'Light I [step]: ' num2str(cc) '/' num2str(numel(currtabExp))])
            sendconfig2Maroc(quaboconfig)
            pause(3)
            tic
          %  images=grabimages(nbimperdac,1,1);
            nbtot=0;imagespix=[];higheventframe=[];imagespixhighevent=[];loweventframe=[];imagespixlowevent=[];
            while nbtot<nbimperdac || (timeacq<timemax)
                imageszeros=[];
              [imageszerostmp nbimafin]=grabimages2(100,1,1);
              imageszerostmp=imageszerostmp(:,:,1:nbimafin-1);
               nbtot=nbtot+nbimafin-1;
               
             %  imageszeros2=cat(3,imageszeros,imageszerostmp );
              % imageszeros=imageszeros2;
           
          
             %  images=imageszeros(:,:,1:nbimafin-1);
             images=imageszerostmp;%(:,:,1:nbimafin-1);
               imagesNZ=[];
               %double-check no zeros image
               imagesNZind=[];
               for zz=1:size(images,3)
                  if sum(images(:,:,zz))~=0
                      imagesNZind=[imagesNZind zz];
                  end
               end
               imagesNZ=images(:,:,imagesNZind);
               images=permute(imagesNZ,[2 1 3]);
               
               imagespix=[imagespix; squeeze(images(xt1,yt1,:))];
              [indhigheventframe]= find(squeeze(images(xt1,yt1,:))>1.8*mean(imagespix))
                 higheventframe=  cat(3,higheventframe,images(:,:,indhigheventframe)) ;
                imagespixhighevent=[imagespixhighevent;  squeeze(images(xt1,yt1,indhigheventframe))];
              [indloweventframe]= find(squeeze(images(xt1,yt1,:))<0.5*mean(imagespix))
                 loweventframe=  cat(3,loweventframe,images(:,:,indloweventframe)) ;
                imagespixlowevent=[imagespixlowevent;  squeeze(images(xt1,yt1,indloweventframe))];
              timeacq=toc; 
            end
             
             disp(['It tooks ' num2str(timeacq) 's'])
allADCpixt=imagespix;%squeeze(images(xt1,yt1,:));
%%%PHD
minp=min(allADCpixt);
maxp=max(allADCpixt);
factbin=10;
nbin=factbin*(maxp-minp);
xc=minp:(maxp-minp)/nbin:maxp;
h=hist(allADCpixt,xc);
hcr=cumsum(h(end:-1:1));
hc=hcr(end:-1:1);

   ADCDACfit=plot(dactab,(countfit.p1*dactab + countfit.p2),'--','LineWidth',2.)
    

figure('Position',[10 10 1400 900],'Color','w')
hold on
plot(xc,(1/timeacq)*hc,'LineWidth',3)
h2=hist(allADCpixt,minp:maxp);
bar(minp:maxp,(1/timeacq)*h2)
hold off
set(gca,'YScale','log')
xlabel('Pulse height [ADC]')
ylabel(['Pulse counts per sec over threshold (DAC1=' num2str(dactab0) ' OR PE=' num2str((dactab0-B0)/A0) ')'])
box on
title(['hold [ns]:' num2str(hh*5) ' Gain:' num2str(gaintab(1)) exptext ' All-pix-masked-exc.-one. ' num2str(nbtot) ' trigger events'],'FontSize',12)
   

        %pe levels
        
        petab=0:(maxp-countfit.p1*B0-countfit.p2)/(countfit.p1*A0);
        dactab=A0*petab+B0;
       % [countfit, gof] = fit(dactab',IntensmeanQ8G, 'poly1')
        ADCDACfitPH=(countfit.p1*dactab + countfit.p2)
     hold on
      %  peaksdac3=[];
      yl=ylim;
        for pp=1:numel(petab)
            ppp=petab(pp);
                %[minval minind] =  min(abs(petab-(B0+A0*pp)));
               % ADCDACfitPH= petab(minind);
              
                % peaksdac3=[peaksdac3 petab(minind(1))];
                plot([ADCDACfitPH(pp) ADCDACfitPH(pp)] , yl,'--')
                text(ADCDACfitPH(pp) ,0.7*yl(2),[num2str(ppp) 'pe'],'FontSize',10)
        end
        %%make pe line for threshold
         plot([(countfit.p1*dactab0 + countfit.p2) (countfit.p1*dactab0 + countfit.p2)] , yl,'--r')
                text((countfit.p1*dactab0 + countfit.p2) ,0.1*yl(2),'threshold','FontSize',16,'Rotation',90)
       % (dactab0-B0)/A0 
        hold off
        
        
datenow=datestr(now,'yymmddHHMMSS');
saveas(gcf,[resultdir '\png\' 'PHD_ADC_DACHOLDAll'  '_' 'Gain' num2str(gaintab(1))  '_' datenow '_nomask.png'])
saveas(gcf,[resultdir '\fig\' 'PHD_ADC_DACHOLDAll'  '_' 'Gain' num2str(gaintab(1)) '_' datenow '_nomask.fig'])
   
        %%highest events
        
      [highvals,indhigh] =   sort( imagespixhighevent);
      figure('Position',[10 10 1400 600],'Color','w')
for nn=1:min(5,numel(indhigh))
      subplot(1,min(5,numel(indhigh)),nn)
    
      imagesc(higheventframe(:,:,indhigh(end-nn+1))')
      axis image
      colorbar
        if nn==3
            title(['HIGHEST TRIGGERS hold [ns]:' num2str(hh*5) ' Gain:' num2str(gaintab(1)) exptext ' All-pix-masked-exc.-one. ' num2str(nbtot) ' trigger events'],'FontSize',12)
      end
end
    
datenow=datestr(now,'yymmddHHMMSS');
saveas(gcf,[resultdir '\png\' 'Highevents_ADC_DACHOLDAll'  '_' 'Gain' num2str(gaintab(1))  '_' datenow '_nomask.png'])
saveas(gcf,[resultdir '\fig\' 'Highevents_ADC_DACHOLDAll'  '_' 'Gain' num2str(gaintab(1)) '_' datenow '_nomask.fig'])
 
%LOW events
[lowvals,indlow] =   sort( imagespixlowevent);
figure('Position',[10 10 1400 600],'Color','w')
for nn=1:min(5,numel(indlow))
      subplot(1,min(5,numel(indlow)),nn)
    
      imagesc(loweventframe(:,:,indlow(nn))')
      axis image
      colorbar
        if nn==3
            title(['LOWEST TRIGGERS hold [ns]:' num2str(hh*5) ' Gain:' num2str(gaintab(1)) exptext ' All-pix-masked-exc.-one. ' num2str(nbtot) ' trigger events'],'FontSize',12)
      end
end
    
datenow=datestr(now,'yymmddHHMMSS');
saveas(gcf,[resultdir '\png\' 'Lowevents_ADC_DACHOLDAll'  '_' 'Gain' num2str(gaintab(1))  '_' datenow '_nomask.png'])
saveas(gcf,[resultdir '\fig\' 'Lowevents_ADC_DACHOLDAll'  '_' 'Gain' num2str(gaintab(1)) '_' datenow '_nomask.fig'])
   