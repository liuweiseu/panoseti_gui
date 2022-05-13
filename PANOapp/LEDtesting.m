gain=60;nim=100;
quaboconfig=changegain(gain, quaboconfig,1); % third param is using an adjusted gain map (=1) or not (=0)

quaboconfig=changepe(2.5,gain,quaboconfig);
pause(2)
images=grabimages(nim,1,1);
meanimagedark25=mean(images(:,:,:),[3])';

quaboconfig=changepe(4.5,gain,quaboconfig);
pause(2)
images=grabimages(nim,1,1);
meanimagedark45=mean(images(:,:,:),[3])';



            figure
            subplot(2,2,1)
            imagesc(meanimagedark25)
            axis image
            colorbar
           
             subplot(2,2,2)
             histogram(meanimagedark25,64,'BinWidth',4)
               set(gcf,'Color','w')
        ti= title(['Pixel cnts, Gain ini:' num2str(gain)  ' Thresh:' num2str(2.5) 'pe' ])
        set(ti,'FontSize',12)
        xlabel('Pixel intensity [cnts per exposure]')
        ylabel('Occurence')
         subplot(2,2,3)
            imagesc(meanimagedark45)
            axis image
            colorbar
             subplot(2,2,4)
             histogram(meanimagedark45,64,'BinWidth',0.1)
               set(gcf,'Color','w')
        ti= title(['Pixel cnts, Gain ini:' num2str(gain)  ' Thresh:' num2str(4.5) 'pe' ])
        set(ti,'FontSize',12)
        xlabel('Pixel intensity [cnts per exposure]')
        ylabel('Occurence')
        
void=input('Did you turn the light on and wait for HV loop green go-ahead?','s');


quaboconfig=changepe(2.5,gain,quaboconfig);
pause(2)
images=grabimages(nim,1,1);
meanimagelight25=mean(images(:,:,:),[3])';
maxL25=max(meanimagelight25,[],'all');

quaboconfig=changepe(4.5,gain,quaboconfig);
pause(2)
images=grabimages(nim,1,1);
meanimagelight45=mean(images(:,:,:),[3])';
maxL45=max(meanimagelight45,[],'all');

            figure('Position',[100 100 1200 900],'Color','w')
             subplot(2,3,1)
            imagesc(meanimagedark25,[0 maxL25])
            axis image
            colorbar
               ti= title(['Dark Cnts, Thresh:' num2str(3.5) 'pe' ', Gain:' num2str(gain)   ])
            
            subplot(2,3,2)
            imagesc(meanimagelight25,[0 maxL25])
            axis image
            colorbar
            title('Flasher ON ')
            
             subplot(2,3,3)
             hold on
             histogram(meanimagedark25,64,'BinWidth',4)
             histogram(meanimagelight25,64,'BinWidth',4)
             hold off
               set(gcf,'Color','w')
               legend('dark','Flasher on (4kHz)')
             %  set(gca,'XLim',[0 50])
      
        set(ti,'FontSize',12)
        xlabel('Pixel intensity [cnts per exposure]')
        ylabel('Occurence')
        
         subplot(2,3,4)
            imagesc(meanimagedark45,[0 maxL45])
            axis image
            colorbar
             ti= title(['Dark Cnts, Thresh:' num2str(4.5) 'pe'  ])
            
            
            subplot(2,3,5)
            imagesc(meanimagelight45,[0 maxL45])
            axis image
            colorbar
            title('Flasher ON ')
            
             subplot(2,3,6)
             hold on
             histogram(meanimagedark45,64,'BinWidth',1)
             histogram(meanimagelight45,64,'BinWidth',1)
             hold off
               set(gcf,'Color','w')
          %     set(gca,'XLim',[0 50])
     
        set(ti,'FontSize',12)
        xlabel('Pixel intensity [cnts per exposure]')
        ylabel('Occurrence')
        datenow=datestr(now,'yymmddHHMMSS');
        saveas(gcf,[getuserdir '/panoseti/tmpres2/' 'LEDtestingG' num2str(gain) '_' datenow '.png'])
        saveas(gcf,[getuserdir 'LEDtestingG' num2str(gain) '_'  datenow '.fig'])
       
 