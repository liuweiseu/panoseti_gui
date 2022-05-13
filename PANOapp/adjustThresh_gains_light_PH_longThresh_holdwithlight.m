close all
 if ~exist('s','var')
     s = serial('COM6','BaudRate',9600);
     fopen(s)
 end
exposurestr='';
nbimperdac=1000;
dactab=[235:2:265 ];  %works well for gain=33
%  dactab=[250:5:300 ]; %works well for gain=66
petab=(1/8)*(-182 + dactab);

gaintabtab=[33];%11:31 %1:10:121;
%currtabExp=[0. round(logspace(0,log10(4000),10))];
currtabExp=[0.];
exptext=' Darks. ' 
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
    gaintab=gaintabtab(gainkk);
    for pp=0:63
        [ig,indexgain]=ismember(['GAIN' num2str(pp)] ,quaboconfig);
        
        quaboconfig(indexgain,indcol+1)={['0x' dec2hex(gaintab(1))]};
    end
    
    
    %set masks MASKOR1_
    mask=0;
    if mask==0
        for pp=0:63
            [ig,indexmask]=ismember(['MASKOR1_' num2str(pp)] ,quaboconfig);
            quaboconfig(indexmask,indcol+1)={['0']};
        end
    else
        for pp=0:63
            [ig,indexmask]=ismember(['MASKOR1_' num2str(pp)] ,quaboconfig);
            quaboconfig(indexmask,indcol+1)={['1']};
            [ig,indexmask2]=ismember(['MASKOR2_' num2str(pp)] ,quaboconfig);
            quaboconfig(indexmask2,indcol+1)={['1']};
        end
        [ig,indexmask]=ismember(['MASKOR1_0'] ,quaboconfig);
        quad=2;
        quaboconfig(indexmask,quad+1)={['0']};
        [ig,indexmask2]=ismember(['MASKOR2_0'] ,quaboconfig);
        quaboconfig(indexmask2,quad+1)={['0']};
    end
    
    
    %set masks CHANMASK_
    maskph=1;
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
        [ig,indexmask]=ismember(['CHANMASK_0 '] ,quaboconfig);
        % quad=2;
        quaboconfig(indexmask,1+1)={['0xFFFFFFFE']};
        
    end
    load('Marocmap.mat')
    xt1=squeeze(marocmap(1,1,1));
    yt1=squeeze(marocmap(1,1,2));
    xt2=squeeze(marocmap(32,1,1));
    yt2=squeeze(marocmap(32,1,2));
    xt3=squeeze(marocmap(8,4,1));
    yt3=squeeze(marocmap(8,4,2));
    
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
    [ia,indexdac]=ismember('DAC1',quaboconfig);
    
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
    for hh=0:15
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
            quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactab(dd))]};
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
        saveas(gcf,['meanpix_vs_timeacq' '_DAC' num2str(dactab(dd)) '_' 'Gain' num2str(gaintab(1))  '_' datenow '_nomask.png'])
        saveas(gcf,['meanpix_vs_timeacq' '_DAC' num2str(dactab(dd)) '_' 'Gain' num2str(gaintab(1)) '_' datenow '_nomask.fig'])
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
        saveas(gcf,['meanimage_vs_timeacq' '_DAC' num2str(dactab(dd)) '_' 'Gain' num2str(gaintab(1))  '_' datenow '_nomask.png'])
        saveas(gcf,['meanimage_vs_timeacq' '_DAC' num2str(dactab(dd)) '_' 'Gain' num2str(gaintab(1)) '_' datenow '_nomask.fig'])
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
                 saveas(gcf,['mean2dimage_STD2dimage' '_DAC' num2str(dactab(dd)) '_' 'Gain' num2str(gaintab(1))  '_' datenow '_nomask.png'])
        saveas(gcf,['mean2dimage_STD2dimage' '_DAC' num2str(dactab(dd)) '_' 'Gain' num2str(gaintab(1)) '_' datenow '_nomask.fig'])
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
        
        
        
        
        figure
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
        title(['HOLD [ns]:' num2str(hh*5) ' Gain:' num2str(gaintab(1)) exptext ' All-pix-masked-exc.-one. Errorbar STD ' num2str(nbimperdac) ' images/DAC1pts'],'FontSize',10)
        legend('Max intensity in trig. images (diff. pixel#)','Triggering pix', 'other pixel')
         legend(['pix[' num2str(xt1) ',' num2str(yt1) ']'],...
                    ['pix[' num2str(xt2) ',' num2str(yt2) ']'],...
                    ['pix[' num2str(xt3) ',' num2str(yt3) ']'])

        set(gca, 'YScale','log')
        box on; grid on
           
        yl=ylim
        %%pe levels
        peaksdac3=zeros(1,ceil(petab(1))-1);
        for pp=ceil(petab(1)):floor(petab(end))
           [minval minind] =  min(abs(dactab-(182+8*pp)));
            peaksdac3=[peaksdac3 dactab(minind(1))];
        plot([peaksdac3(pp) peaksdac3(pp)] , yl,'--')
         text(peaksdac3(pp) ,-3+yl(2),[num2str(pp) 'pe'],'FontSize',16)
        end
        
       % text(dactab(2),yl(2)-5,['HOLD [ns]:' num2str(hhh*5)],'FontSize',18)
        hold off
        datenow=datestr(now,'yymmddHHMMSS');
        saveas(gcf,['ADC_DACHOLD' num2str(hh) '_' 'Gain' num2str(gaintab(1))  '_' datenow '_nomask.png'])
        saveas(gcf,['ADC_DACHOLD' num2str(hh) '_' 'Gain' num2str(gaintab(1)) '_' datenow '_nomask.fig'])
        close(gcf)
   
    IntensmeanQ8GH=[IntensmeanQ8GH IntensmeanQ8G];
    % IntensmeanQ8GSTDH=[IntensmeanQ8GSTDH; IntensmeanQ8GSTD];;
    IntenspixH=[IntenspixH Intenspix];
    IntenspixSTDH=[IntenspixSTDH IntenspixSTD];
     IntenspixHB=[IntenspixHB IntenspixB];
    IntenspixSTDHB=[IntenspixSTDHB IntenspixSTDB];
     end
end

figure
hold on
leg={};
for hhh=0:15
    %plot(dactab,IntensmeanQ8G,'r+-')
    hhh
    errorbar(dactab,IntenspixH(:,hhh+1),0.5*IntenspixSTDH(:,hhh+1))
    leg(hhh+1)={ ['Hold [ns]: ' num2str(5*hhh)  ]};
end
box on

hold off
%nbimperdac
xlabel('DAC1 value')
ylabel(' mean ADC value')
title(['Gain:' num2str(gaintab(1)) exptext ' No mask. Errorbar STD ' num2str(nbimperdac) ' images/DAC1pts'])
legend(leg)
box on; grid on
set(gca, 'YScale','log')
datenow=datestr(now,'yymmddHHMMSS');
saveas(gcf,['ADC_DACHOLDAll'  '_' 'Gain' num2str(gaintab(1))  '_' datenow '_nomask.png'])
saveas(gcf,['ADC_DACHOLDAll'  '_' 'Gain' num2str(gaintab(1)) '_' datenow '_nomask.fig'])

save(['ADC_DACHOLDAll'  '_' 'Gain' num2str(gaintab(1)) '_' datenow '_nomask.mat'])

%end
for hhh=0:15
 figure('Position',[10 10 1400 900])
 set(gcf,'Color','w')
 
        hold on
        plot(dactab,IntensmeanQ8GH(:,hhh+1),'ro-','LineWidth',2.2)
        e1=errorbar(dactab,IntenspixH(:,hhh+1),0.5*IntenspixSTDH(:,hhh+1))
        e2=errorbar(dactab,IntenspixHB(:,hhh+1),0.5*IntenspixSTDHB(:,hhh+1))
        set(e1,'LineWidth',2.2)
        set(e2,'LineWidth',2.2)
        box on
        yl=ylim
        %%pe levels
        peaksdac3=zeros(1,ceil(petab(1))-1);
        for pp=ceil(petab(1)):floor(petab(end))
           [minval minind] =  min(abs(dactab-(182+8*pp)));
            peaksdac3=[peaksdac3 dactab(minind(1))];
        plot([peaksdac3(pp) peaksdac3(pp)] , yl,'--')
         text(peaksdac3(pp) ,-3+yl(2),[num2str(pp) 'pe'],'FontSize',16)
        end
        
        text(dactab(2),yl(2)-5,['HOLD [ns]:' num2str(hhh*5)],'FontSize',18)
        hold off
        set(gca,'FontSize',16) 
        %nbimperdac
        xlabel('DAC1 value') % 
        ylabel(' mean ADC value')
        box on; grid on
        title(['Gain:' num2str(gaintab(1)) exptext ' All-pix-masked-excepted-one. Errorbar: STD ' num2str(nbimperdac) ' images/DAC1pts'])
        legend('Max intensity in trig. images (may be different pixel#)','triggering pixel','one other pix')
        %set(gca, 'YScale','log')
        datenow=datestr(now,'yymmddHHMMSS');
        saveas(gcf,['ADC_DACLightHOLD' num2str(hhh) '_' 'Gain' num2str(gaintab(1))  '_' datenow '_nomask.png'])
        saveas(gcf,['ADC_DACLightHOLD' num2str(hhh) '_' 'Gain' num2str(gaintab(1)) '_' datenow '_nomask.fig'])
end       





 figure('Position',[10 10 1400 900])
 set(gcf,'Color','w')
 htab=5*(0:15);
        hold on
        for dachhh=1:numel(dactab)
        plot(htab,IntensmeanQ8GH(dachhh,:),'ro-','LineWidth',2.2)
        e1=errorbar(htab,IntenspixH(dachhh,:),0.5*IntenspixSTDH(dachhh,:))
        e2=errorbar(htab,IntenspixHB(dachhh,:),0.5*IntenspixSTDHB(dachhh,:))
        end
        set(e1,'LineWidth',2.2)
        set(e2,'LineWidth',2.2)
        box on
        yl=ylim
%         %%pe levels
%         peaksdac3=zeros(1,ceil(petab(1))-1);
%         for pp=ceil(petab(1)):floor(petab(end))
%            [minval minind] =  min(abs(dactab-(182+8*pp)));
%             peaksdac3=[peaksdac3 dactab(minind(1))];
%         plot([peaksdac3(pp) peaksdac3(pp)] , yl,'--')
%          text(peaksdac3(pp) ,-3+yl(2),[num2str(pp) 'pe'],'FontSize',16)
%         end
        
     %   text(dactab(2),yl(2)-5,['HOLD [ns]:' num2str(hhh*5)],'FontSize',18)
        hold off
        set(gca,'FontSize',16) 
        %nbimperdac
        xlabel('H1 [ns]') % 
        ylabel(' mean ADC value')
        box on; grid on
        title(['Gain:' num2str(gaintab(1)) exptext ' All-pix-masked-excepted-one. Errorbar: STD ' num2str(nbimperdac) ' images/DAC1pts'])
        legend('Max intensity in trig. images (may be different pixel#)','triggering pixel','one other pix')
        %set(gca, 'YScale','log')
        datenow=datestr(now,'yymmddHHMMSS');
        saveas(gcf,['ADC_HOLD1' num2str(hhh) '_' 'Gain' num2str(gaintab(1))  '_' datenow '_nomask.png'])
        saveas(gcf,['ADC_HOLD1' num2str(hhh) '_' 'Gain' num2str(gaintab(1)) '_' datenow '_nomask.fig'])
       