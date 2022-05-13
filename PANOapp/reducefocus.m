

%p_d0w0m0q0_20190401_201426_16707_0

clear all
close all

dataset='stage2b'
direc=['C:\Users\jerome\Documents\panoseti\DATA\' dataset '\'];
files = dir([direc 'p_d0w0m0q0_20190401_20' '*.fits']);

 figure('Position',[100, 1, 1800, 900])
 set(gcf,'Color','w')
 nbpixsupfhwm=zeros(1,numel(files))+nan;
 nbpixsup3std=zeros(1,numel(files))+nan;
 Intensmax=zeros(1,numel(files))+nan;
 Intenstot=zeros(1,numel(files))+nan;
for ii=1:numel(files)
    if dataset(numel(dataset))=='b'
         iir=ii;
    else
       iir=numel(files)-ii+1;
    end
    pos=25.4*(24+1/8)+iir*0.8;
ima=fitsread([direc files(ii).name]);
info = fitsinfo([direc files(ii).name]);

if isfield(info,'Image') == 0
    nbim=1
else
nbim=size(info.Image,2);
end
images=zeros(16,16,nbim);
packetno=zeros(1,nbim);
boarloc=zeros(1,nbim);
utc=zeros(1,nbim);
nanosec=zeros(1,nbim);
timecomp=zeros(1,nbim);
format long
%      for nima=1:nbim
%          disp(['Reading image keywords #' num2str(nima) '/' num2str(nbim)])
%         packetno(nima)=cell2mat(info.Image(nima).Keywords(13,2));
%         boarloc(nima)=cell2mat(info.Image(nima).Keywords(14,2));
%         utc(nima)=cell2mat(info.Image(nima).Keywords(15,2));
%         nanosec(nima)=cell2mat(info.Image(nima).Keywords(16,2));
%         timecomp(nima)=cell2mat(info.Image(nima).Keywords(17,2));
%      %   images(:,:,nima)=fitsread([direc files(i).name],'Image',nima);
%      end
   Imin=0;
   Imax=3000;
   
     subplot(1,3,1)
    
    imagesc(sqrt(ima),sqrt([Imin max(ima,[],'all')]))
    axis image
    text(1,1,['Distance Lens-Detector [mm]: ' num2str(pos)],'Color','y','FontSize',12)
     text(1,-1,'Red laser, Imaging, Th=222 Gain=21','Color','b','FontSize',12)
    cl=colorbar
    cl.Label.String='SQRT(I)';
    threshdet=0.005;
    nbpixsupfhwm(iir)=numel(find(ima>=threshdet*max(ima,[],'all'))); 
    stdlev=std(ima(12:16,1:4),1,'all')
    meanlev=mean(ima(12:16,1:4),'all')
    nbpixsup3std(iir)=numel(find(ima>=meanlev+10*stdlev));
    
    subplot(1,3,2)
  % plot(25.4*(24+1/8)+(1:numel(files))*0.8, nbpixsupfhwm,'+-')
    plot(25.4*(24+1/8)+(1:numel(files))*0.8, nbpixsup3std,'+-')
   axis square
   xlim(25.4*(24+1/8)+0.8*[1 numel(files)])
   %ylim([1 5])
  %  ylabel(['Nb pix with I > ' num2str(threshdet) ' Imax'],'FontSize',22)
    ylabel(['Nb pix with I > '  'mean(noise)+ 10 sigma(noise) '],'FontSize',22)
    xlabel('Distance Lens-Detector [mm]','FontSize',22)
    
     Intensmax(iir)=max(ima,[],'all');
 Intenstot(iir)=sum(ima,[1 2]);
 
  subplot(1,3,3)
  cla
  hold on
   plot(25.4*(24+1/8)+(1:numel(files))*0.8, Intensmax,'+-')
      plot(25.4*(24+1/8)+(1:numel(files))*0.8, Intenstot,'+-')
   hold off
   axis square
   xlim(25.4*(24+1/8)+0.8*[1 numel(files)])
    ylabel(['Intensities'],'FontSize',22)
    xlabel('Distance Lens-Detector [mm]','FontSize',22)
    legend('Imax','Itotal')
    
    
    filename=['focus_change_red_sig_' dataset  '.gif'];
         frame = getframe(gcf,[100, 250, 1600, 450]);
                          im = frame2im(frame); %,
                         [imind,cm] = rgb2ind(im,256);
                         delay=0.2;
                        if ii == 1;
                            imwrite(imind,cm,filename,'gif', 'Loopcount',inf,'DelayTime',delay);%,'ScreenSize',[640 640]
                        else
                             imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',delay);
                        end
                        
                      
    
end