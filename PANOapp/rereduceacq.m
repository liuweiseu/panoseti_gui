
clear all
direc='C:\Users\jerome\Documents\panoseti\DATA\MtLaguna20190815\'

foc=0;
if foc==1
%%dataset focus
% dataset='Arcturus, 5.5 pe, adjusted gain:33, no mask '
% hhstart=032935;
% hhend=033037;
% direction='tl';
dataset='Arcturus, 5.5 pe, adjusted gain:33, no mask '
hhstart=033428;
hhend=033521;
direction='tb';
% dataset='Arcturus, 5.5 pe, adjusted gain:33, no mask '
% hhstart=034414;
% hhend=034516;
% direction='tb';
% dataset='Arcturus, 10.5 pe, adjusted gain:33, no mask '
% hhstart=034759;
% hhend=034902;
% direction='tb';
% % dataset='Arcturus, 10.5 pe, adjusted gain:33, no mask '
% % hhstart=035019;
% % hhend=035121;
% % direction='tb';
dataset='Arcturus, 10.5 pe, adjusted gain:33, no mask '
hhstart=035902;
hhend=035921;
direction='tl';
files=findacquisition(direc,hhstart,hhend)

reducefocusDfunc(files,direc,dataset,direction)

end

%%%TRAIL
trail=0;
if trail==1
arcturus=0
if arcturus==1
    dataset='Arcturus Trail, 9.5 pe, adjusted gain:33, no mask '
    hhstart=042803;
    hhend=043803; %042805%
    files=findacquisition(direc,hhstart,hhend)
    reducetrail(files,direc,dataset)
else
    dataset='\beta Her Trail, 4.5 pe, adjusted gain:33, no mask '
    hhstart=045616;
    hhend=045915; %042805%
    files=findacquisition(direc,hhstart,hhend)
    reducetrail(files,direc,dataset)
end
end

psf=0;
if psf==1
    dataset='Arcturus Trail, 9.5 pe, adjusted gain:33, no mask '
    hhstart=042835;
    hhend=042835; %042805%
    files=findacquisition(direc,hhstart,hhend)
    
    
    for ii=1:1%numel(files)

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
     for nima=1:nbim
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
   
   
   contra=0;
  szi=size(ima,1);
  for ssx=2:szi-1
       for ssy=2:szi-1
           contra=contra+sum((ima(ssx,ssy)-ima(ssx-1:ssx+1,ssy-1:ssy+1)).^2,'all') ;
          
       end
  end
  disp(contra)
   
   
   [max_num, max_idx]=max(ima(:));
    [maxX,maxY]=ind2sub(size(ima),max_idx);
   
    figure('Color','w')
    hold on
    plot( 18*((1:16)-maxX),(1/maxval)*ima(:,maxY),'-+b')
     plot( 18*((1:16)-maxY),(1/maxval)*ima(maxX,:),'-+r')
     hold off
     box on
     set(gca,'YScale','log')
     grid on
     title('Arcturus, Gain:33, 9.5 pe, no mask')
     axis tight
     legend('X-cut','Y-cut')
     xlabel('Distance from center [Arcmin]')
     ylabel('Normalized Intensity')
     set(gca, 'FontSize',14)
           datenow=datestr(now,'yymmddHHMMSS');
        saveas(gcf,[direc  'onskyPSF.png'])
        saveas(gcf,[direc 'onskyPSF.fig'])
   
end
end
