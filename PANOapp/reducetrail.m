function reducetrail(files,direc,dataset)

%p_d0w0m0q0_20190401_201426_16707_0

%clear all
close all




%dataset='ProcyonStagetest'
%direc=['C:\Users\jerome\Documents\panoseti\DATA\mtlaguna_quabo1\focusstage\'];

resultdir=direc;
%files = dir([direc 'p_d0w0m0q0_201904' '*.fits']);
threshdet=0.02;
 figure('Position',[100, 1, 1800, 900])
 set(gcf,'Color','w')
 nbpixsupfhwm=zeros(1,numel(files))+nan;
 nbpixsup3std=zeros(1,numel(files))+nan;
 Intensmax=zeros(1,numel(files))+nan;
 Intenstot=zeros(1,numel(files))+nan;
  Intens8_8=zeros(1,numel(files))+nan;
  Intens8_9=zeros(1,numel(files))+nan;
  Intens8_6=zeros(1,numel(files))+nan;
  Intens8_7=zeros(1,numel(files))+nan;
   Intens9_8=zeros(1,numel(files))+nan;
  Intens9_9=zeros(1,numel(files))+nan;
  Intens9_6=zeros(1,numel(files))+nan;
  Intens9_7=zeros(1,numel(files))+nan;
    Intens7_8=zeros(1,numel(files))+nan;
  Intens7_9=zeros(1,numel(files))+nan;
  Intens7_6=zeros(1,numel(files))+nan;
  Intens7_7=zeros(1,numel(files))+nan;
  
   stdlev=zeros(1,numel(files))+nan;
    meanlev=zeros(1,numel(files))+nan;
    contra=zeros(1,numel(files));
    contra2=zeros(1,numel(files));
 %%look at HK
  nbacq=51500;%numel(hvmon0tab);
 ind0=nbacq-4000;
 ind1=ind0+440
 ind2=ind0+665;
%plotHK(ind1,ind2,dataset)
 
 
for ii=1:numel(files)
%     if direct==1
         iir=ii;
%     else
%        iir=numel(files)-ii+1;
%     end
%     pos=25.4*(24+1/8)+iir*0.8;
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
     for nima=1:nbim/10
         disp(['Acq:' num2str(ii) '/' num2str(numel(files)) '. Reading image keywords #' num2str(nima) '/' num2str(nbim)])
      
        packetno(nima)=cell2mat(info.Image(nima).Keywords(13,2));
        boarloc(nima)=cell2mat(info.Image(nima).Keywords(14,2));
        utc(nima)=cell2mat(info.Image(nima).Keywords(15,2));
        nanosec(nima)=cell2mat(info.Image(nima).Keywords(16,2));
        timecomp(nima)=cell2mat(info.Image(nima).Keywords(17,2));
       images(:,:,nima)=fitsread([direc files(ii).name],'Image',nima);
     end
   Imin=0;
   Imax=3000;
   
   ima=mean(images,3);
   %%
   [maxval]= max(ima,[],'all');
   
   
   
     subplot(2,2,1)
    imagesc( (ima), ([Imin max(ima,[],'all')]))
    axis image
  %  text(1,1,['Distance Lens-Detector [mm]: ' num2str(pos)],'Color','y','FontSize',12)
     text(1,-1,[dataset ],'Color','b','FontSize',12)
    cl=colorbar;
    cl.Label.String='Intensity';
    
   % nbpixsupfhwm(iir)=numel(find(ima>=threshdet*max(ima,[],'all'))); 
     nbpixsupfhwm(iir)=numel(find(ima>=60)); 
    stdlev(iir)=std(ima(1:4,1:4),1,'all');
    meanlev(iir)=mean(ima(1:4,1:4),'all');
  %  nbpixsup3std(iir)=numel(find(ima>meanlev+10*stdlev));
    
  
  szi=size(ima,1);
  for ssx=2:szi-1
       for ssy=2:szi-1
           contra(iir)=contra(iir)+sum((ima(ssx,ssy)-ima(ssx-1:ssx+1,ssy-1:ssy+1)).^2,'all') ;
          
       end
  end

  for ssx=1:szi-1
       for ssy=1:szi-1
          
             contra2(iir)=contra2(iir)+((ima(ssx,ssy)-ima(ssx+1,ssy))^2+(ima(ssx,ssy)-ima(ssx,ssy+1))^2) ;
       end
  end
 
  
    subplot(2,2,2)
    plot(25.4*(24+1/8)+(1:numel(files))*0.8, nbpixsupfhwm,'+-')
 %   plot(25.4*(24+1/8)+(1:numel(files))*0.8, nbpixsup3std,'+-')
   axis square
   xlim(25.4*(24+1/8)+0.8*[1 numel(files)])
   %ylim([1 5])
   % ylabel(['Nb pix with I > ' num2str(threshdet) ' Imax'],'FontSize',22)
     ylabel(['Nb pix with I > cst thresh'],'FontSize',22)
  %  ylabel(['Nb pix with I > '  'mean(noise)+ 10 sigma(noise) '],'FontSize',16)
    xlabel('Distance Lens-Detector [mm]','FontSize',22)
        box on 
    grid on
    
     Intensmax(iir)=max(ima,[],'all');
 Intenstot(iir)=sum(ima,[1 2]);
 
 imat=(ima)';
   Intens8_8(iir)=imat(8,8);
  Intens8_9(iir)=imat(8,9);
  Intens8_6(iir)=imat(8,6);
  Intens8_7(iir)=imat(8,7);
   Intens9_8(iir)=imat(9,8);
  Intens9_9(iir)=imat(9,9);
  Intens9_6(iir)=imat(9,6);
  Intens9_7(iir)=imat(9,7);
    Intens7_8(iir)=imat(7,8);
  Intens7_9(iir)=imat(7,9);
  Intens7_6(iir)=imat(7,6);
  Intens7_7(iir)=imat(7,7);
 
  subplot(2,2,3)
  cla
  hold on
   plot(25.4*(24+1/8)+(1:numel(files))*0.8, Intenstot,'+-')
   plot(25.4*(24+1/8)+(1:numel(files))*0.8, Intensmax,'+-')
     
   hold off
   axis square
   xlim(25.4*(24+1/8)+0.8*[1 numel(files)])
    ylabel(['Intensities (cnts per exposure)'],'FontSize',22)
    xlabel('Distance Lens-Detector [mm]','FontSize',22)
    legend('sum I over pix','max I over pix','Location','NorthWest')
        box on 
    grid on
    
    
%     filename=['focus_change_' dataset  '.gif'];
%          frame = getframe(gcf,[10, 10, 1600, 750]);
%                           im = frame2im(frame); %,
%                          [imind,cm] = rgb2ind(im,256);
%                          delay=0.2;
%                         if ii == 1;
%                             imwrite(imind,cm,filename,'gif', 'Loopcount',inf,'DelayTime',delay);%,'ScreenSize',[640 640]
%                         else
%                              imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',delay);
%                         end
%                         
     
  subplot(2,2,4)                 
      plot(25.4*(24+1/8)+(1:numel(files))*0.8, contra,'+-')
 %   plot(25.4*(24+1/8)+(1:numel(files))*0.8, nbpixsup3std,'+-')
   axis square
   xlim(25.4*(24+1/8)+0.8*[1 numel(files)])
   %ylim([1 5])
    ylabel(['Contrast (cnts^2)'],'FontSize',22)
  %  ylabel(['Nb pix with I > '  'mean(noise)+ 10 sigma(noise) '],'FontSize',16)
    xlabel('Distance Lens-Detector [mm]','FontSize',22)
        box on 
    grid on
%     
%           datenow=datestr(now,'yymmddHHMMSS');
%         saveas(gcf,[resultdir 'Focus'  '_'   datenow '_nomask.png'])
%         saveas(gcf,[resultdir  'Focus' '_' datenow '_nomask.fig'])
    
end

%  figure
%    plot(25.4*(24+1/8)+(1:numel(files))*0.8, contra,'+-')
%  %   plot(25.4*(24+1/8)+(1:numel(files))*0.8, nbpixsup3std,'+-')
%    axis square
%    xlim(25.4*(24+1/8)+0.8*[1 numel(files)])
%    %ylim([1 5])
%     ylabel(['Contrast'],'FontSize',22)
%   %  ylabel(['Nb pix with I > '  'mean(noise)+ 10 sigma(noise) '],'FontSize',16)
%     xlabel('Distance Lens-Detector [mm]','FontSize',22)
%     

for ii=1:numel(files)
%    if direct==1
          iir=ii;
%     else
%        iir=numel(files)-ii+1;
%     end
  %  pos=25.4*(24+1/8)+iir*0.8;
ima=fitsread([direc files(ii).name]);
info = fitsinfo([direc files(ii).name]);

if isfield(info,'Image') == 0
    nbim=1;
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
     for nima=1:nbim/10
         disp(['Acq:' num2str(ii) '/' num2str(numel(files)) '. Reading image keywords #' num2str(nima) '/' num2str(nbim)])
        packetno(nima)=cell2mat(info.Image(nima).Keywords(13,2));
        boarloc(nima)=cell2mat(info.Image(nima).Keywords(14,2));
        utc(nima)=cell2mat(info.Image(nima).Keywords(15,2));
        nanosec(nima)=cell2mat(info.Image(nima).Keywords(16,2));
        timecomp(nima)=cell2mat(info.Image(nima).Keywords(17,2));
        images(:,:,nima)=fitsread([direc files(ii).name],'Image',nima);
     end
   Imin=0;
   Imax=3000;
   
   ima=mean(images,3);
   %%"contrast"
   [maxval]= max(ima,[],'all');
   clf
   
   allmeth=0;
   if allmeth==1
     subplot(2,2,1)
   else
       subplot(1,2,1)
   end
    % ax = axes('Position',[0.05 0.5 0.4 0.4])
    imagesc( log10(ima), log10([Imin max(Intensmax,[],'all')]))
    axis image
    %text(1,1,['Distance Lens-Detector [mm]: ' num2str(pos)],'Color','y','FontSize',12)
     text(1,-1,[dataset ' ' datestr(timecomp(1),'dd-mmm-yyyy HH:MM:SS')],'Color','b','FontSize',12)
    cl=colorbar;
    cl.Label.String='log10(Intensity [cnts/exposure])';
     cl.Label.FontSize=18;
    nbpixsupfhwm2=numel(find(ima>=threshdet*max(ima,[],'all'))); 
   % stdlev=std(ima(12:16,1:4),1,'all')
  %  meanlev=mean(ima(12:16,1:4),'all')
   % nbpixsup3std2=numel(find(ima>meanlev+10*stdlev));
    
      if allmeth==1
 
   
   subplot(2,2,2)
   %ax = axes('Position',[0.55 0.5 0.4 0.4])
    cla
    hold on
    plot(25.4*(24+1/8)+(1:numel(files))*0.8, nbpixsupfhwm,'+-')
    plot(25.4*(24+1/8)+(iir)*0.8, nbpixsupfhwm(iir),'o','MarkerSize',8)
 %   plot(25.4*(24+1/8)+(1:numel(files))*0.8, nbpixsup3std,'+-')
  % axis square
   xlim(25.4*(24+1/8)+0.8*[1 numel(files)])
   %ylim([1 5])
   % ylabel(['Nb pix with I > ' num2str(threshdet) ' Imax'],'FontSize',22)
     ylabel(['Nb pix with I > cst thresh'],'FontSize',22)
  %  ylabel(['Nb pix with I > '  'mean(noise)+ 10 sigma(noise) '],'FontSize',16)
    xlabel('Distance Lens-Detector [mm]','FontSize',22)
    box on 
    grid on
      end
     Intensmax2=max(ima,[],'all');
 Intenstot2=sum(ima,[1 2]);
 
    if allmeth==1
    
subplot(2,2,3)
 % ax = axes('Position',[0.05 0.1 0.4 0.4])
  cla
  hold on
       plot(25.4*(24+1/8)+(1:numel(files))*0.8, Intenstot,'r+-')
   plot(25.4*(24+1/8)+(1:numel(files))*0.8, Intensmax,'b+-')
 
         plot(25.4*(24+1/8)+(iir)*0.8, Intensmax2,'bo','MarkerSize',8)
      plot(25.4*(24+1/8)+(iir)*0.8, Intenstot2,'ro','MarkerSize',8)
   hold off
 % axis square
   xlim(25.4*(24+1/8)+0.8*[1 numel(files)])
    ylabel(['Intensities'],'FontSize',22)
    xlabel('Distance Lens-Detector [mm]','FontSize',22)
     legend('sum I over pix','max I over pix','Location','NorthWest')
        box on 
    grid on
    end
  
       if allmeth==1
     subplot(2,2,4) 
   else
      subplot(1,2,2) 
   end
      
   %  ax = axes('Position',[0.55 0.1 0.4 0.4])
     cla
     hold on
      plot( contra,'b+-')
      plot( contra2,'r+-')
 %   plot(25.4*(24+1/8)+(1:numel(files))*0.8, nbpixsup3std,'+-')
    plot(iir, contra(iir),'bo','MarkerSize',8)
     plot(iir, contra2(iir),'ro','MarkerSize',8)
%    hold off
  % axis square
   legend('using 8 adjacent pix','using right and up pixels','Location','NorthWest')
   %xlim(25.4*(24+1/8)+0.8*[1 numel(files)])
   %ylim([1 5])
    ylabel(['Contrast (cnts^2)'],'FontSize',22)
  %  ylabel(['Nb pix with I > '  'mean(noise)+ 10 sigma(noise) '],'FontSize',16)
    xlabel('Time [acq#]','FontSize',22)
   box on 
    grid on
    
      
         frame = getframe(gcf,[10, 10, 1700, 880]);
                          im = frame2im(frame); %,
                         [imind,cm] = rgb2ind(im,256);
                         delay=0.2;
                        if ii == 1;
                              datenow=datestr(now,'yymmddHHMMSS');
    filename=[resultdir 'trail_' datenow '.gif'];
                            imwrite(imind,cm,filename,'gif', 'Loopcount',inf,'DelayTime',delay);%,'ScreenSize',[640 640]
                        else
                             imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',delay);
                        end
                        
                      
    
end
figure
set(gcf,'Color','w')
hold on

 plot(25.4*(24+1/8)+(1:numel(files))*0.8, Intens8_8,'b+-')
 plot(25.4*(24+1/8)+(1:numel(files))*0.8, Intens8_9,'bo-')
 plot(25.4*(24+1/8)+(1:numel(files))*0.8, Intens8_6,'bs-')
 plot(25.4*(24+1/8)+(1:numel(files))*0.8, Intens8_7,'bd-')
 plot(25.4*(24+1/8)+(1:numel(files))*0.8, Intens9_8,'r+-')
 plot(25.4*(24+1/8)+(1:numel(files))*0.8, Intens9_9,'ro-')
 plot(25.4*(24+1/8)+(1:numel(files))*0.8, Intens9_6,'rs-')
 plot(25.4*(24+1/8)+(1:numel(files))*0.8, Intens9_7,'rd-')
 plot(25.4*(24+1/8)+(1:numel(files))*0.8, Intens7_8,'m+-')
 plot(25.4*(24+1/8)+(1:numel(files))*0.8, Intens7_9,'mo-')
 plot(25.4*(24+1/8)+(1:numel(files))*0.8, Intens7_6,'ms-')
 plot(25.4*(24+1/8)+(1:numel(files))*0.8, Intens7_7,'md-')

 
     
   hold off
 
   xlim(25.4*(24+1/8)+0.8*[1 numel(files)])
    ylabel(['Intensities'],'FontSize',22)
    xlabel('Distance Lens-Detector [mm]','FontSize',22)
    legend('pix [8 8]',...
        'pix [8 9]',...
        'pix [8 6]',...
        'pix [8 7]',...
        'pix [9 8]',...
        'pix [9 9]',...
        'pix [9 6]',...
        'pix [9 7]',...
        'pix [7 8]',...
        'pix [7 9]',...
        'pix [7 6]',...
        'pix [7 7]'...
        )
    
end