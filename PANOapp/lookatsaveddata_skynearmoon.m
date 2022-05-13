

%p_d0w0m0q0_20190401_201426_16707_0

%clear all
close all

dataset='skymoon_IMAth245'
thresh=245;
direc=['C:\Users\jerome\Documents\panoseti\DATA\mtlaguna_quabo1\skymoon_th245\'];
files = dir([direc 'p_d0w0m0q0_201904' '*.fits']);
threshdet=0.1;

 makeintro=1;
 
 %proc-Moon dist
 proRA=2*pi*(7*3600+39*60+17)/(3600*24)
  proDEC=pi*(5+13/60+10/3600)/(180)
  
   moonRA=2*pi*(6*3600+0*60+33)/(3600*24)
  moonDEC=pi*(21+13/60+21/3600)/(180)
  
  distProcMoondeg=(180/pi)*sqrt( (proRA-moonRA)^2 + (proDEC-moonDEC)^2)
 
 %%look at HK
  nbacq=51500;%numel(hvmon0tab);
 ind0=nbacq-4000;
 ind1=ind0+1221
 ind2=ind0+1318;
plotHK(ind1,ind2,dataset)
 
 
 video=1
for ii=1:numel(files)
    close all
    fig= figure('Position',[100, 1, 800, 800])
 set(gcf,'Color','w')

  
   totima=[];
ima=fitsread([direc files(ii).name]);
info = fitsinfo([direc files(ii).name]);

if isfield(info,'Image') == 0
    nbim=1
else
nbim=size(info.Image,2);
end
%nbim=10
images=zeros(16,16,nbim);
packetno=zeros(1,nbim);
boarloc=zeros(1,nbim);
utc=zeros(1,nbim);
nanosec=zeros(1,nbim);
timecomp=zeros(1,nbim);
format long
 nbpixsupfhwm=zeros(1,nbim)+nan;
 nbpixsup3std=zeros(1,nbim)+nan;
 
 Intensmax=zeros(1,nbim)+nan;
 Intenstot=zeros(1,nbim)+nan;
  IntensmaxQ1=zeros(1,nbim)+nan;
 IntenstotQ1=zeros(1,nbim)+nan;
  IntensmaxQ2=zeros(1,nbim)+nan;
 IntenstotQ2=zeros(1,nbim)+nan;
  IntensmaxQ3=zeros(1,nbim)+nan;
 IntenstotQ3=zeros(1,nbim)+nan;
  IntensmaxQ4=zeros(1,nbim)+nan;
 IntenstotQ4=zeros(1,nbim)+nan;
 nbnojump=1;
 
     for nima=1:nbim
         disp(['Reading image keywords #' num2str(nima) '/' num2str(nbim)])
        packetno(nima)=cell2mat(info.Image(nima).Keywords(13,2));
        boarloc(nima)=cell2mat(info.Image(nima).Keywords(14,2));
        utc(nima)=cell2mat(info.Image(nima).Keywords(15,2));
        nanosec(nima)=cell2mat(info.Image(nima).Keywords(16,2));
        timecomp(nima)=cell2mat(info.Image(nima).Keywords(17,2));
    images(:,:,nima)=fitsread([direc files(ii).name],'Image',nima,'Info',info);
     
   Imin=0;
   if nima==1
   Imax=max( images(:,:,1),[],'all');
   end
   
   %%"contrast"
   %[maxval]= max(ima,[],'all');
    filename=['dataset_' dataset '_'  num2str(ii) '.gif'];
   if (nima==1) && (video==1) && (makeintro)==1
     text(0.3,0.5,'Procyion','FontSize',28,'Color','b')
     text(0.3,0.4,['Mt Laguna obs.,'],'FontSize',20,'Color','b')
      text(0.3,0.3,[ datestr(timecomp(nima))],'FontSize',18,'Color','b')
     axis off
    
        
         frame = getframe(gcf,[1, 1, 800, 800]);
                          im = frame2im(frame); %,
                         [imind,cm] = rgb2ind(im,256);
                         delay=0;
                       %if (nima == 1) || (makeintro==0);
                            imwrite(imind,cm,filename,'gif', 'Loopcount',inf,'DelayTime',delay);%,'ScreenSize',[640 640]
                       % end
                       for iii=1:10
                        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',delay);
                       end
 end
   
   
   %  subplot(1,3,1)
    imagesc(  images(:,:,nima), ([Imin Imax]))
    axis image
%    text(1,1,['Distance Lens-Detector [mm]: ' num2str(pos)],'Color','y','FontSize',12)
     text(1,1,['procyion, PH, Th=' num2str(thresh) ' Gain=21'],'Color','y','FontSize',12)
     text(1,1.5,['Time comp:' datestr(timecomp(nima),'mmm.dd,yyyy HH:MM:SS.FFF') ' Packet No:' num2str(packetno(nima))],'Color','y','FontSize',12)
    cl=colorbar;
    cl.Label.String='Intensity';
    drawnow


ima=images(:,:,nima);
if nima==1
totima=ima;
totimanojump=ima;
else
    totima=totima+ima;
     if Intenstot(nima)<5000
         totimanojump=totimanojump+ima;
         nbnojump=nbnojump+1;
     end
end
    %pause(0.1)
     nbpixsupfhwm(nima)=numel(find(ima>=threshdet*max(ima,[],'all'))); 
%      stdlev=std(ima(12:16,1:4),1,'all');
%      meanlev=mean(ima(12:16,1:4),'all');
%      nbpixsup3std(nima)=numel(find(ima>meanlev+10*stdlev));
%      
%     
%     subplot(1,3,2)
%     plot(25.4*(24+1/8)+(1:numel(files))*0.8, nbpixsupfhwm,'+-')
%  %   plot(25.4*(24+1/8)+(1:numel(files))*0.8, nbpixsup3std,'+-')
%    axis square
%    xlim(25.4*(24+1/8)+0.8*[1 numel(files)])
%    %ylim([1 5])
%     ylabel(['Nb pix with I > ' num2str(threshdet) ' Imax'],'FontSize',22)
%   %  ylabel(['Nb pix with I > '  'mean(noise)+ 10 sigma(noise) '],'FontSize',16)
%     xlabel('Distance Lens-Detector [mm]','FontSize',22)
%     
  Intensmax(nima)=max(ima,[],'all');
  Intenstot(nima)=sum(ima,[1 2]);
  if Intenstot(nima)>5000
      disp('?')
  end
    IntensmaxQ1(nima)=max(ima(1:8,1:8),[],'all');
  IntenstotQ1(nima)=sum(ima(1:8,1:8),[1 2]);
    IntensmaxQ2(nima)=max(ima(1:8,9:16),[],'all');
  IntenstotQ2(nima)=sum(ima(1:8,9:16),[1 2]);
    IntensmaxQ3(nima)=max(ima(9:16,1:8),[],'all');
  IntenstotQ3(nima)=sum(ima(9:16,1:8),[1 2]);
    IntensmaxQ4(nima)=max(ima(9:16,9:16),[],'all');
  IntenstotQ4(nima)=sum(ima(9:16,9:16),[1 2]);
%  
%   subplot(1,3,3)
%   cla
%   hold on
%    plot(25.4*(24+1/8)+(1:numel(files))*0.8, Intensmax,'+-')
%       plot(25.4*(24+1/8)+(1:numel(files))*0.8, Intenstot,'+-')
%    hold off
%    axis square
%    xlim(25.4*(24+1/8)+0.8*[1 numel(files)])
%     ylabel(['Intensities'],'FontSize',22)
%     xlabel('Distance Lens-Detector [mm]','FontSize',22)
%     legend('Imax','Itotal')
%     
    if video==1
   % filename=['gif' dataset '_'  num2str(ii) '.gif'];
         frame = getframe(gcf,[1, 1, 800, 800]);
                          im = frame2im(frame); %,
                         [imind,cm] = rgb2ind(im,256);
                         delay=0;
                        if (nima == 1) && (makeintro==0);
                            imwrite(imind,cm,filename,'gif', 'Loopcount',inf,'DelayTime',delay);%,'ScreenSize',[640 640]
                            
                        else
                             imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',delay);
                        end
                        
    end                   
     end
     
       figure
      set(gcf,'Color','w')
  imagesc( (1/nbim)* totima, ([Imin Imax]))
    axis image
%    text(1,1,['Distance Lens-Detector [mm]: ' num2str(pos)],'Color','y','FontSize',12)
     text(1,1,['Averaged Procyion, PH, Th=' num2str(thresh) ' Gain=21'],'Color','y','FontSize',12)
     %text(1,1.5,['Time comp:' datestr(timecomp(nima),'mmm.dd,yyyy HH:MM:SS.FFF') ' Packet No:' num2str(packetno(nima))],'Color','y','FontSize',12)
    cl=colorbar;
    cl.Label.String='Intensity';
    drawnow
     saveas(gcf,[dataset 'alltimeIPH' num2str(ii) '.png'])
   saveas(gcf,[dataset 'alltimeIPH' num2str(ii) '.fig'])
 
     figure
      set(gcf,'Color','w')
  imagesc( (1/nbnojump)* totimanojump)
    axis image
%    text(1,1,['Distance Lens-Detector [mm]: ' num2str(pos)],'Color','y','FontSize',12)
     text(1,1,['Averaged Procyion (no jumps), PH, Th=' num2str(thresh) ' Gain=21'],'Color','y','FontSize',12)
     %text(1,1.5,['Time comp:' datestr(timecomp(nima),'mmm.dd,yyyy HH:MM:SS.FFF') ' Packet No:' num2str(packetno(nima))],'Color','y','FontSize',12)
    cl=colorbar;
    cl.Label.String='Intensity';
    drawnow
     saveas(gcf,[dataset 'alltimeIPHnojump' num2str(ii) '.png'])
   saveas(gcf,[dataset 'alltimeIPHnojump' num2str(ii) '.fig'])
 
     figure
      set(gcf,'Color','w')
       plot((3600*24)*(timecomp-timecomp(1)), nbpixsupfhwm,'+-')
 %   plot(25.4*(24+1/8)+(1:numel(files))*0.8, nbpixsup3std,'+-')
  % axis square
  % xlim(25.4*(24+1/8)+0.8*[1 numel(files)])
   %ylim([1 5])
    ylabel(['Nb pix with I > ' num2str(threshdet) ' Imax'],'FontSize',22)
  %  ylabel(['Nb pix with I > '  'mean(noise)+ 10 sigma(noise) '],'FontSize',16)
    xlabel('Time (s)','FontSize',22)
    saveas(gcf,[dataset 'sup_ima' num2str(ii) '.png'])
   saveas(gcf,[dataset 'sup_ima' num2str(ii) '.fig'])
 
   figure
    set(gcf,'Color','w')
  cla
  hold on
   plot((3600*24)*(timecomp-timecomp(1)), Intensmax,'+-')
      plot((3600*24)*(timecomp-timecomp(1)), Intenstot,'+-')
   hold off
   %axis square
   %xlim(25.4*(24+1/8)+0.8*[1 numel(files)])
    ylabel(['Intensities'],'FontSize',22)
    xlabel('Time (s)','FontSize',22)
    legend('Imax','Itotal')
       saveas(gcf,[dataset 'intens_ima' num2str(ii) '.png'])
   saveas(gcf,[dataset 'intens_ima' num2str(ii) '.fig'])
   
    figure
     set(gcf,'Color','w')
  cla
  hold on
   plot((3600*24)*(timecomp-timecomp(1)), IntensmaxQ1,'-r')
      plot((3600*24)*(timecomp-timecomp(1)), IntenstotQ1,'--r')
         plot((3600*24)*(timecomp-timecomp(1)), IntensmaxQ2,'-b')
      plot((3600*24)*(timecomp-timecomp(1)), IntenstotQ2,'--b')
         plot((3600*24)*(timecomp-timecomp(1)), IntensmaxQ3,'-g')
      plot((3600*24)*(timecomp-timecomp(1)), IntenstotQ3,'--g')
         plot((3600*24)*(timecomp-timecomp(1)), IntensmaxQ4,'-m')
      plot((3600*24)*(timecomp-timecomp(1)), IntenstotQ4,'--m')
   hold off
   %axis square
   %xlim(25.4*(24+1/8)+0.8*[1 numel(files)])
    ylabel(['Intensities'],'FontSize',22)
    xlabel('Time (s)','FontSize',22)
    legend('Imax Q1','Itotal Q1','Imax Q2','Itotal Q2','Imax Q3','Itotal Q3','Imax Q4','Itotal Q4')
       saveas(gcf,[dataset 'intensQ_ima' num2str(ii) '.png'])
   saveas(gcf,[dataset 'intensQ_ima' num2str(ii) '.fig'])
   
   figure
    set(gcf,'Color','w')
   hold on
   plot(packetno)
   plot((1:numel(packetno)),packetno(1)+(1:numel(packetno)),'r--')
   hold off
    ylabel(['Packet#'],'FontSize',22)
    xlabel('Time (acq#)','FontSize',22)
        saveas(gcf,[dataset 'packetnums_' num2str(ii) '.png'])
   saveas(gcf,[dataset 'packetnums' num2str(ii) '.fig'])
end

