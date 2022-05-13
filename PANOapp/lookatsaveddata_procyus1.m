

%p_d0w0m0q0_20190401_201426_16707_0

%clear all
close all

dataset='Procyon1'
direc=['C:\Users\jerome\Documents\panoseti\DATA\mtlaguna_quabo1\procyus1\'];
files = dir([direc 'p_d0w0m0q0_201904' '*.fits']);
threshdet=0.1;

 makeintro=1;
 
 
 %%look at HK
  nbacq=51500;%numel(hvmon0tab);
 ind0=nbacq-4000;
 ind1=ind0+440
 ind2=ind0+665;
plotHK(ind1,ind2,dataset)
 
 
 video=0
for ii=1:numel(files)
    close all
    fig= figure('Position',[100, 1, 800, 800])
 set(gcf,'Color','w')

  
   
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
 
   Intens5_4=zeros(1,nbim)+nan;
  Intens5_5=zeros(1,nbim)+nan;
  Intens5_6=zeros(1,nbim)+nan;
  Intens5_7=zeros(1,nbim)+nan;
   Intens6_4=zeros(1,nbim)+nan;
  Intens6_5=zeros(1,nbim)+nan;
  Intens6_6=zeros(1,nbim)+nan;
  Intens6_7=zeros(1,nbim)+nan;
  Intens7_4=zeros(1,nbim)+nan;
  Intens7_5=zeros(1,nbim)+nan;
  Intens7_6=zeros(1,nbim)+nan;
  Intens7_7=zeros(1,nbim)+nan;
  
 cx=zeros(1,nbim)+nan;
  cy=zeros(1,nbim)+nan;
     for nima=1:nbim
         disp(['Reading image keywords #' num2str(nima) '/' num2str(nbim)])
        packetno(nima)=cell2mat(info.Image(nima).Keywords(13,2));
        boarloc(nima)=cell2mat(info.Image(nima).Keywords(14,2));
        utc(nima)=cell2mat(info.Image(nima).Keywords(15,2));
        nanosec(nima)=cell2mat(info.Image(nima).Keywords(16,2));
        timecomp(nima)=cell2mat(info.Image(nima).Keywords(17,2));
    images(:,:,nima)=fitsread([direc files(ii).name],'Image',nima,'Info',info);
     
   Imin=0;
   Imax=max( images(:,:,nima),[],'all');
   
   %%"contrast"
   %[maxval]= max(ima,[],'all');
   if (nima==1) && (video==1) && (makeintro)==1
     text(0.3,0.5,'Procyion','FontSize',28,'Color','b')
     text(0.3,0.4,['Mt Laguna obs.,'],'FontSize',20,'Color','b')
      text(0.3,0.3,[ datestr(timecomp(nima))],'FontSize',18,'Color','b')
     axis off
    
         filename=['dataset_' dataset '_'  num2str(ii) '.gif'];
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
     text(1,1,'procyion, Imaging, Th=231 Gain=21','Color','y','FontSize',12)
     text(1,1.5,['Time comp:' datestr(timecomp(nima),'mmm.dd,yyyy HH:MM:SS.FFF') ' Packet No:' num2str(packetno(nima))],'Color','y','FontSize',12)
    cl=colorbar;
    cl.Label.String='Intensity';
    drawnow


ima=images(:,:,nima);
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
 IntensmaxQ2(nima)=max(ima(1:8,1:8),[],'all');
  IntenstotQ2(nima)=sum(ima(1:8,1:8),[1 2]);
    IntensmaxQ3(nima)=max(ima(1:8,9:16),[],'all');
  IntenstotQ3(nima)=sum(ima(1:8,9:16),[1 2]);
    IntensmaxQ1(nima)=max(ima(9:16,1:8),[],'all');
  IntenstotQ1(nima)=sum(ima(9:16,1:8),[1 2]);
    IntensmaxQ4(nima)=max(ima(9:16,9:16),[],'all');
  IntenstotQ4(nima)=sum(ima(9:16,9:16),[1 2]);
  
  imat=(ima)';
  Intens5_4(nima)=imat(5,4);
  Intens5_5(nima)=imat(5,5);
  Intens5_6(nima)=imat(5,6);
  Intens5_7(nima)=imat(5,7);
  
  Intens6_4(nima)=imat(6,4);
  Intens6_5(nima)=imat(6,5);
  Intens6_6(nima)=imat(6,6);
  Intens6_7(nima)=imat(6,7);
  
  Intens7_4(nima)=imat(7,4);
  Intens7_5(nima)=imat(7,5);
  Intens7_6(nima)=imat(7,6);
  Intens7_7(nima)=imat(7,7);
  
  %centroids
  valmax = max(max(ima));
  [ymax,xmax]=find(ima==valmax);
  ww=3;
  image=ima(ymax-ww:ymax+ww,xmax-ww:xmax+ww);
    cx(nima)=(xmax-ww-1)+(sum(image)*(1:length(sum(image)))')/sum(sum(image));
    cy(nima)=(ymax-ww-1)+(sum(image,2)'*(1:length(sum(image,2)'))')/sum(sum(image));
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
    filename=['dataset_' dataset '_'  num2str(ii) '.gif'];
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
       plot((3600*24)*(timecomp-timecomp(1)), nbpixsupfhwm,'+-')
 %   plot(25.4*(24+1/8)+(1:numel(files))*0.8, nbpixsup3std,'+-')
  % axis square
  % xlim(25.4*(24+1/8)+0.8*[1 numel(files)])
   %ylim([1 5])
    ylabel(['Nb pix with I > ' num2str(threshdet) ' Imax'],'FontSize',22)
  %  ylabel(['Nb pix with I > '  'mean(noise)+ 10 sigma(noise) '],'FontSize',16)
    xlabel('Time (s)','FontSize',22)
    saveas(gcf,['sup_ima' num2str(ii) '.png'])
   saveas(gcf,['sup_ima' num2str(ii) '.fig'])
 
   figure
    set(gcf,'Color','w')
  cla
  hold on
   plot((3600*24)*(timecomp-timecomp(1)), Intensmax,'+-')
      plot((3600*24)*(timecomp-timecomp(1)), Intenstot,'+-')
   hold off
   %axis square
   %xlim(25.4*(24+1/8)+0.8*[1 numel(files)])
    ylabel(['Raw Intensities'],'FontSize',22)
    xlabel('Time (s)','FontSize',22)
    legend(['Imax, \sigma_I=' num2str(std(Intensmax)) ', sqrt(mean_I)=' num2str(sqrt(mean(Intensmax)))],['Itotal, \sigma_I=' num2str(std(Intenstot)) ', sqrt(mean_I)=' num2str(sqrt(mean(Intenstot)))])
       saveas(gcf,['intens_ima' num2str(ii) '.png'])
   saveas(gcf,['intens_ima' num2str(ii) '.fig'])
   
   %convert in cps (x400 since exposure=2.5ms)
      figure
    set(gcf,'Color','w')
  cla
  hold on
   plot((3600*24)*(timecomp-timecomp(1)), 400*Intensmax,'+-')
      plot((3600*24)*(timecomp-timecomp(1)), 400*Intenstot,'+-')
   hold off
   %axis square
   %xlim(25.4*(24+1/8)+0.8*[1 numel(files)])
    ylabel(['Intensities (cps)'],'FontSize',22)
    xlabel('Time (s)','FontSize',22)
    legend(['Imax, \sigma_I=' num2str(std(400*Intensmax)) ', sqrt(mean_I)=' num2str(sqrt(mean(400*Intensmax)))],['Itotal, \sigma_I=' num2str(std(400*Intenstot)) ', sqrt(mean_I)=' num2str(sqrt(mean(400*Intenstot)))])
       saveas(gcf,['intensCPS_ima' num2str(ii) '.png'])
   saveas(gcf,['intensCPS_ima' num2str(ii) '.fig'])
   
    figure
  cla
   set(gcf,'Color','w')
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
    ylabel(['Raw Intensities'],'FontSize',22)
    xlabel('Time (s)','FontSize',22)
    legend('Imax Q1','Itotal Q1','Imax Q2','Itotal Q2','Imax Q3','Itotal Q3','Imax Q4','Itotal Q4')
       saveas(gcf,['intensQ_ima' num2str(ii) '.png'])
   saveas(gcf,['intensQ_ima' num2str(ii) '.fig'])


figure
set(gcf,'Color','w')
hold on

 plot((3600*24)*(timecomp-timecomp(1)), Intens5_4,'b+-')
 plot((3600*24)*(timecomp-timecomp(1)), Intens5_5,'bo-')
 plot((3600*24)*(timecomp-timecomp(1)), Intens5_6,'bs-')
 plot((3600*24)*(timecomp-timecomp(1)), Intens5_7,'bd-')
 plot((3600*24)*(timecomp-timecomp(1)), Intens6_4,'r+-')
 plot((3600*24)*(timecomp-timecomp(1)), Intens6_5,'ro-')
 plot((3600*24)*(timecomp-timecomp(1)), Intens6_6,'rs-')
 plot((3600*24)*(timecomp-timecomp(1)), Intens6_7,'rd-')
 plot((3600*24)*(timecomp-timecomp(1)), Intens7_4,'m+-')
 plot((3600*24)*(timecomp-timecomp(1)), Intens7_5,'mo-')
 plot((3600*24)*(timecomp-timecomp(1)), Intens7_6,'ms-')
 plot((3600*24)*(timecomp-timecomp(1)), Intens7_7,'md-')
hold off
 
  % xlim(25.4*(24+1/8)+0.8*[1 numel(files)])
    ylabel(['Raw Intensities'],'FontSize',22)
 xlabel('Time (s)','FontSize',22)
    legend('pix [5 4]',...
        'pix [5 5]',...
        'pix [5 6]',...
        'pix [5 7]',...
        'pix [6 4]',...
        'pix [6 5]',...
        'pix [6 6]',...
        'pix [6 7]',...
        'pix [7 4]',...
        'pix [7 5]',...
        'pix [7 6]',...
        'pix [7 7]'...
        )
      saveas(gcf,['intenspix_ima' num2str(ii) '.png'])
   saveas(gcf,['intenspix_ima' num2str(ii) '.fig'])
    
    figure
     set(gcf,'Color','w')
    subplot(2,2,1)
    scatter(Intens6_5,Intens6_6)
    xlabel('Intensity of Pixel [6,5]')
     ylabel('Intensity of Pixel [6,6]')
 subplot(2,2,2)
    scatter(Intens6_5,Intens7_6)
        xlabel('Intensity of Pixel [6,5]')
     ylabel('Intensity of Pixel [7,6]')
  subplot(2,2,3)
    scatter(Intens6_5,Intens7_5)
        xlabel('Intensity of Pixel [6,5]')
     ylabel('Intensity of Pixel [7,5]')
     subplot(2,2,4)
     scatter(Intens6_5,Intens5_5)
         xlabel('Intensity of Pixel [6,5]')
     ylabel('Intensity of Pixel [5,5]')
       saveas(gcf,['intensScatter' num2str(ii) '.png'])
   saveas(gcf,['intensScatter' num2str(ii) '.fig'])
    figure
    plot(cx, cy,'+')
     xlabel('Centroid X')
     ylabel('Centroid Y')
          saveas(gcf,['intensCentroids' num2str(ii) '.png'])
   saveas(gcf,['intensCentroids' num2str(ii) '.fig'])

   figure
    set(gcf,'Color','w')
plot((3600*24)*(timecomp-timecomp(1)),packetno)
 xlabel('comp. Time [s]')
     ylabel('Packet No')
    saveas(gcf,['packetno' num2str(ii) '.png'])
   saveas(gcf,['packetno' num2str(ii) '.fig'])
    end