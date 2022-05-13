close all

direction='tl' ;%toward lens='tl'  dir='0' // toward back='tb'  dir='1'
dataset='ProcyonStagetestb' ;%
nim=10;
minsteps=200;


    if strncmp(direction,'tl',2)
        dir='0';
    else
        dir='1';
    end
    comm=[dir ',' num2str(minsteps)]


direc=['C:\Users\jerome\Documents\panoseti\DATA\'];
resultdir=direc;



%  if count(py.sys.path,['C:\Users\jerome\Documents\panoseti\pythonlib\']) == 0
%                 insert(py.sys.path,int32(0),['C:\Users\jerome\Documents\panoseti\pythonlib\']); 
%                 % uialert(app.UIFigure,char(py.sys.path),'py.sys.path2')
%              end
ini=0
if ini==1
ser=py.step_control_matlab.start(1)
end
files=1:30;
 nbpixsupfhwm=zeros(1,numel(files))+nan;
% nbpixsup3std=zeros(1,numel(files))+nan;
 Intensmax=zeros(1,numel(files))+nan;
 Intenstot=zeros(1,numel(files))+nan;
  contra=zeros(1,numel(files));
    contra2=zeros(1,numel(files));

%move stage
allmeanima=zeros(16,16,30);
for pp=1:30
    disp(pp)

py.step_control_matlab.main2(comm,ser)
pause(2)
%%take images
%im=recordimage;

 images=grabimages(nim,1,1);
        
        ima=mean(images(:,:,:),[3])';
        allmeanima(:,:,pp)=ima;




    
end

%%%REDUCING
 figure('Position',[100, 1, 1800, 900])
 set(gcf,'Color','w')
for ii=1:size(allmeanima,3)
    if dir=='1'
         iir=ii;
    else
       iir=size(allmeanima,3)-ii+1;
    end
    pos=25.4*(24+1/8)+iir*0.8;

     ima= allmeanima(:,:,iir);
    
     nbpixsupfhwm(iir)=numel(find(ima>=60)); 
%     stdlev(iir)=std(ima(1:4,1:4),1,'all');
%     meanlev(iir)=mean(ima(1:4,1:4),'all');
  %  nbpixsup3std(iir)=numel(find(ima>meanlev+10*stdlev));
         Intensmax(iir)=max(ima,[],'all');
 Intenstot(iir)=sum(ima,[1 2]);
  
  szi=size(ima,1);
  for ssx=2:szi-1
       for ssy=2:szi-1
           contra(iir)=contra(iir)+sum((ima(ssx,ssy)-ima(ssx-1:ssx+1,ssy-1:ssy+1)).^2,'all')
       end
  end
  [maxcontra, posatmaxcontrast]=max(contra);
    
  
  for ssx=1:szi-1
       for ssy=1:szi-1
          
             contra2(iir)=contra2(iir)+((ima(ssx,ssy)-ima(ssx+1,ssy))^2+(ima(ssx,ssy)-ima(ssx,ssy+1))^2) ;
       end
  end
 
  
     Imin=0;
   Imax=3000;
   
   %%"contrast"
   [maxval]= max(ima,[],'all');
   clf
   
     subplot(2,2,1)
    % ax = axes('Position',[0.05 0.5 0.4 0.4])
    imagesc( (ima), ([Imin max(Intensmax,[],'all')]))
    axis image
    text(1,1,['Distance Lens-Detector [mm]: ' num2str(pos)],'Color','y','FontSize',12)
     text(1,-1,[dataset ', Imaging, Th=231 Gain=21'],'Color','b','FontSize',12)
    cl=colorbar;
    cl.Label.String='Intensity';
    
  %  nbpixsupfhwm2=numel(find(ima>=threshdet*max(ima,[],'all'))); 
   % stdlev=std(ima(12:16,1:4),1,'all')
  %  meanlev=mean(ima(12:16,1:4),'all')
   % nbpixsup3std2=numel(find(ima>meanlev+10*stdlev));
    
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
    
    % Intensmax2=max(ima,[],'all');
% Intenstot2=sum(ima,[1 2]);
 
subplot(2,2,3)
 % ax = axes('Position',[0.05 0.1 0.4 0.4])
  cla
  hold on
       plot(25.4*(24+1/8)+(1:numel(files))*0.8, Intenstot,'r+-')
   plot(25.4*(24+1/8)+(1:numel(files))*0.8, Intensmax,'b+-')
 
         plot(25.4*(24+1/8)+(iir)*0.8, Intensmax(iir),'bo','MarkerSize',8)
      plot(25.4*(24+1/8)+(iir)*0.8, Intenstot(iir),'ro','MarkerSize',8)
   hold off
 % axis square
   xlim(25.4*(24+1/8)+0.8*[1 numel(files)])
    ylabel(['Intensities'],'FontSize',22)
    xlabel('Distance Lens-Detector [mm]','FontSize',22)
     legend('sum I over pix','max I over pix','Location','NorthWest')
        box on 
    grid on
    
  
      subplot(2,2,4) 
   %  ax = axes('Position',[0.55 0.1 0.4 0.4])
     cla
     hold on
      plot(25.4*(24+1/8)+(1:numel(files))*0.8, contra,'b+-')
       plot(25.4*(24+1/8)+(1:numel(files))*0.8, contra2,'r+-')
 %   plot(25.4*(24+1/8)+(1:numel(files))*0.8, nbpixsup3std,'+-')
   plot(25.4*(24+1/8)+(iir)*0.8, contra(iir),'bo','MarkerSize',8)
    plot(25.4*(24+1/8)+(iir)*0.8, contra2(iir),'bo','MarkerSize',8)
   
   hold off
  % axis square
   xlim(25.4*(24+1/8)+0.8*[1 numel(files)])
   %ylim([1 5])
    ylabel(['Contrast (cnts^2)'],'FontSize',22)
  %  ylabel(['Nb pix with I > '  'mean(noise)+ 10 sigma(noise) '],'FontSize',16)
    xlabel('Distance Lens-Detector [mm]','FontSize',22)
      legend('using 8 adjacent pix','using right and up pixels','Location','NorthWest')
   box on 
    grid on
    
      
         frame = getframe(gcf,[10, 10, 1700, 880]);
                          im = frame2im(frame); %,
                         [imind,cm] = rgb2ind(im,256);
                         delay=0.2;
                        if ii == 1;
                              datenow=datestr(now,'yymmddHHMMSS');
    filename=[resultdir 'focus_change_wl_' dataset  'b' datenow '.gif'];
                            imwrite(imind,cm,filename,'gif', 'Loopcount',inf,'DelayTime',delay);%,'ScreenSize',[640 640]
                        else
                             imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',delay);
                        end
                        
                      
    
    
    
end
  

%%%%%PUT IT AT FOCUS?
x = input( prompt)
 prompt = {'Put it at focus? y/n'};
 if strncmp(x,'y',1)
     
    if dir=='1'
        dirF='0';
         indmaxcontr= size(allmeanima,3)-posatmaxcontrast+1;
    else
      
        dirF='1';
         indmaxcontr= posatmaxcontrast;
    end
    nbstepsfoc=indmaxcontr*minsteps;
    comm=[dirF ',' num2str(minsteps)]

     disp(['Moving to best focus... '])
     disp(['Moving stage with dir/steps: ' comm])
     py.step_control_matlab.main2(comm,ser)
 end