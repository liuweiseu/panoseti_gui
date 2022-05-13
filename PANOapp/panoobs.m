
quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config.txt']);


 [ig,indexacqmode]=ismember(['ACQMODE '] ,quaboconfig);
    quaboconfig(indexacqmode,2)={"0x01"};
   
subtractbaseline


%% Gain
gain=33;
quaboconfig = changegain(gain, quaboconfig,1); % third param is using an adjusted gain map (=1) or not (=0)

%%DAC
pelevel=10.5;
quaboconfig = changepe(pelevel,gain,quaboconfig);

%%Mask
% maskallexceptedcoor=[1 1]; %this will unmask MASK_0 quad 0
% maskallexceptedcoor=[1 1; 1 2];
  load('Marocmap.mat')  %     xt1=squeeze(marocmap(mx,my,1)); %     yt1=squeeze(marocmap(mx,my,2));
xt1=6;yt1=8;maskallexceptedcoor=[marocmap16(xt1,yt1,1) marocmap16(xt1,yt1,2)];
maskmode=0;
quaboconfig = changemask(maskmode,maskallexceptedcoor,quaboconfig); %maskmode: unmask all pix (=0); mask all excepted some (=1)
 
%%Taking data...
%% Imaging mode
maskmode=0;
quaboconfig = changemask(maskmode,[],quaboconfig); %maskmode: unmask all pix (=0); mask all excepted some (=1)
[ig,indexacqmode]=ismember(['ACQMODE '] ,quaboconfig);
    quaboconfig(indexacqmode,2)={"0x02"};
          disp('Init Acq mode...')
        sentacqparams2board(quaboconfig)

   %% Taking successive frames 
    nbframes=100;
    images=grabimages(nbframes,1,1);
    
 %% taking short images, average, store the average for time analysis   
 %% Taking successive frames (for long time analysis)
  exp='vega'
totduration=180;
  duration=0;allima=[];durationtab=[];
    nbframes=100;
      tic
      while duration < totduration
            images=grabimages(nbframes,1,1);
            
%              %double-check no zeros image
%                imagesNZind=[];
%                for zz=1:size(images,3)
%                   if sum(images(:,:,zz))~=0
%                       imagesNZind=[imagesNZind zz];
%                   end
%                end
%                imagesNZ=images(:,:,imagesNZind);
%                images=imagesNZ;
%            
%                
            meanimage=mean(images(:,:,:),[3])';
            if size(allima,1)==0
            allima=meanimage;
            else
                allima=cat(3,allima, meanimage);
            end
            duration=toc;
            durationtab=[durationtab duration];
      end
      
      resultdir=''
      figure('Position',[50 50 1200 900],'Color','w')
      hold on
      for xi=1:16
          for yi=1:16
               plot(durationtab,squeeze(allima(xi,yi,:)),'Color',rand(1,3))
          end
      end
      box on; 
      xlabel('Time [s]')
      ylabel('Counts per sec')
      title([exp ' ' 'Imaging mode; gain:' num2str(gain) 'Thresh(pe):' num2str(pelevel) '.No mask.'])
       datenow=datestr(now,'yymmddHHMMSS');
        saveas(gcf,[resultdir exp '_Ima_gain' num2str(gain) 'Threshpe' num2str(pelevel)  '_nomask' datenow '.png'])
        saveas(gcf,[resultdir  exp '_Ima_gain' num2str(gain) 'Threshpe' num2str(pelevel)  '_nomask' datenow '.fig'])
   %%%%        
