dd=1;
dactab=[260];
dactab0=dactab;
nbimperdac=100;timemax=30;
  quaboconfig(indexdac,indcoldac+1)={['0x' dec2hex(dactab(dd))]};
            disp(['Sending Maroc comm...DAC1:' num2str(dactab(dd)) ' Gain:' num2str((gaintabtab(gainkk))) ' (' num2str(gainkk) '/' num2str(numel(gaintabtab)) ')' ...
                'Light I [step]: ' num2str(cc) '/' num2str(numel(currtabExp))])
            sendconfig2Maroc(quaboconfig)
            pause(3)
            tic
          %  images=grabimages(nbimperdac,1,1);
            nbtot=0;imagespix=[];higheventframe=[];imagespixhighevent=[];loweventframe=[];imagespixlowevent=[];
             spatialmeanvstime=[];
             spatialmedianvstime=[];
             indloweventframetab=[];
             indhigheventframetab=[];
            while nbtot<nbimperdac || (timeacq<timemax)
                imageszeros=[];nbimstep=100;
              [imageszerostmp nbimafin]=grabimages2(nbimstep,1,1);
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
               
            spatialmeanvstime=[spatialmeanvstime squeeze(mean(images(:,:,:),[1 2]))'];
            spatialmedianvstime=[spatialmedianvstime squeeze(median(images(:,:,:),[1 2]))'];
               
               imagespix=[imagespix; squeeze(images(xt1,yt1,:))];
              [indhigheventframe]= find(squeeze(images(xt1,yt1,:))>1.8*mean(imagespix))
                 higheventframe=  cat(3,higheventframe,images(:,:,indhigheventframe)) ;
                 indhigheventframetab=[indhigheventframetab indhigheventframe'+nbtot-(nbimafin-1)];
                imagespixhighevent=[imagespixhighevent;  squeeze(images(xt1,yt1,indhigheventframe))];
              [indloweventframe]= find(squeeze(images(xt1,yt1,:))<0.5*mean(imagespix))
                 loweventframe=  cat(3,loweventframe,images(:,:,indloweventframe)) ;
                imagespixlowevent=[imagespixlowevent;  squeeze(images(xt1,yt1,indloweventframe))];
                indloweventframetab=[indloweventframetab indloweventframe'+nbtot-(nbimafin-1)];
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
title(['hold [ns]:' num2str(hh*5) ' Gain:' num2str(gaintab(1)) exptext ' All-pix-masked-exc.-one. ' num2str(nbtot) ' trigger events; Duration[h]: ' num2str(timeacq/3600,'%4.1f')],'FontSize',12)
   

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
                text(ADCDACfitPH(pp) ,0.7*yl(2),[num2str(ppp) 'pe'],'FontSize',6)
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
      set(gca,'FontSize',10')
       text(0,20,['Frame#' num2str(indhigheventframetab(indhigh(end-nn+1))) ],'FontSize',10)
    text(0,22,['trig-pix ADC:' num2str(allADCpixt(indhigheventframetab(indhigh(end-nn+1)))) ],'FontSize',10)
     text(0,24,[' meanADC=' num2str(spatialmeanvstime(indhigheventframetab(indhigh(end-nn+1)))) ],'FontSize',10)
text(0,26,[' medianADC=' num2str(spatialmedianvstime(indhigheventframetab(indhigh(end-nn+1))))],'FontSize',10)
 
      colorbar
        if nn==3
            title(['HIGHEST TRIGGERS hold [ns]:' num2str(hh*5) ' Gain:' num2str(gaintab(1)) exptext ' All-pix-masked-exc.-one. ' num2str(nbtot) ' trigger events'],'FontSize',10)
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
      set(gca,'FontSize',10')
   text(0,20,['Frame#' num2str(indloweventframetab(indlow(nn))) ],'FontSize',10)
   text(0,22,['trig-pix ADC:' num2str(allADCpixt(indloweventframetab(indlow(nn)))) ],'FontSize',10)
   text(0,24,[' meanADC=' num2str(spatialmeanvstime(indloweventframetab(indlow(nn)))) ],'FontSize',10)
   text(0,26,[' medianADC=' num2str(spatialmedianvstime(indloweventframetab(indlow(nn))))],'FontSize',10)
  
   %   text(0,25,['Frame#' num2tr(indlow(nn)) ' meanADC=' num2str(spatialmeanvstime) '  medianADC=' num2str(spatialmedianvstime)],'FontSize',10)
            colorbar 
      if nn==3
            title(['LOWEST TRIGGERS hold [ns]:' num2str(hh*5) ' Gain:' num2str(gaintab(1)) exptext ' All-pix-masked-exc.-one. ' num2str(nbtot) ' trigger events'],'FontSize',12)
      end
end
    
datenow=datestr(now,'yymmddHHMMSS');
saveas(gcf,[resultdir '\png\' 'Lowevents_ADC_DACHOLDAll'  '_' 'Gain' num2str(gaintab(1))  '_' datenow '_nomask.png'])
saveas(gcf,[resultdir '\fig\' 'Lowevents_ADC_DACHOLDAll'  '_' 'Gain' num2str(gaintab(1)) '_' datenow '_nomask.fig'])


%%%%%

            figure('Position',[10 10 2000 900],'Color','w')
          % subplot(2,1,1)
            set(gcf,'Color','w')
            hold on
            plot(squeeze(spatialmeanvstime),'-+b','LineWidth',1)
            plot(squeeze(spatialmedianvstime),'--r','LineWidth',1)
            hold off
            legend('Mean over all pixels','median')
            xlabel('Time [frame#]')
            ylabel('mean ADC value (over pixels)')
            yl=ylim
            set(gca,'FontSize',12)
            title([exptext 'Bipolar fs; All-trigmasked-except-one.'],'FontSize',10)
            box on; grid on
            text(10,yl(1)+0.65*(yl(2)-yl(1)),['DAC:' num2str(dactab0(dd))],'FontSize',16)
            text(100,yl(1)+0.5*(yl(2)-yl(1)),['HOLD [ns]:' num2str(hh*5)],'FontSize',10)
            %ylim([2090 2110])
%              subplot(2,1,2)
%             set(gcf,'Color','w')
%             hold on
%           %  plot(squeeze(spatialmeanvstime),'-+b','LineWidth',1)
%             plot(squeeze(spatialmedianvstime),'--r','LineWidth',1.5)
%             hold off
%             legend(['Median over all pixels','')
%             xlabel('Time [frame#]')
%             ylabel('median ADC value (over pixels)')
%             yl=ylim
%             set(gca,'FontSize',12)
%             title([exptext 'Bipolar fs; All-trigmasked-except-one.'],'FontSize',10)
%             box on; grid on
%             text(10,yl(1)+0.65*(yl(2)-yl(1)),['DAC:' num2str(dactab0(dd))],'FontSize',16)
%             text(100,yl(1)+0.5*(yl(2)-yl(1)),['HOLD [ns]:' num2str(hh*5)],'FontSize',10)
%             %ylim([2090 2110])
               datenow=datestr(now,'yymmddHHMMSS');
        saveas(gcf,[resultdir '\png\' 'meanimage_vs_timeacq' '_DAC' num2str(dactab(dd)) '_' 'Gain' num2str(gaintab(1))  '_' datenow '_nomask.png'])
        saveas(gcf,[resultdir '\fig\' 'meanimage_vs_timeacq' '_DAC' num2str(dactab(dd)) '_' 'Gain' num2str(gaintab(1)) '_' datenow '_nomask.fig'])
 if timeacq>3600
     save([resultdir '\fig\' 'longrunMAT' '_DAC' num2str(dactab0(dd)) '_' 'Gain' num2str(gaintab(1)) '_' datenow '_nomask.mat']) 
 end
     
     