%%%Threshold vs p.e.
datadir='C:\DATA\20181206\'

quaboconfig=importquaboconfig('C:\DATA\configs\tests\quabo_config_phd.txt');
[ia,indexacqint]=ismember('ACQINT ',quaboconfig);
  [ia,indexdac]=ismember('DAC1',quaboconfig);
acqint = str2num(quaboconfig(indexacqint,2));
expsec=10.24e-6*acqint;
% [ia,indexdac]=ismember('DAC1',quaboconfig);
%iniate board:
%         sendconfig2Maroc(quaboconfig)
sendconfig2Maroc(quaboconfig)
pause(3)
sentacqparams2board(quaboconfig)
pause(3)
%give time to apply change:

% quaboconfig(index,2)=string(value);
% app.currentconfig=quaboconfig;
 indcol=1:4;
%stimleveltab=[ 10 25 50 75 100 125 150 175 200 225 250];
dactab=[ 290  295  300 305 310 320 350 400 450 500];
 gaintab=21:50:171; 
phd3d=zeros(16,16,numel(dactab),numel(gaintab));
 gain3d=zeros(16,16,numel(dactab),numel(gaintab));


       
for igain=1:numel(gaintab)
  %change gain
     for pp=0:63 
        [ig,indexgain]=ismember(['GAIN' num2str(pp)] ,quaboconfig);

        quaboconfig(indexgain,indcol+1)={['0x' dec2hex(gaintab(igain))]};
     end
for dd=1:numel(dactab)
 quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactab(dd))]};
sendconfig2Maroc(quaboconfig)
pause(3)
% sentacqparams2board(quaboconfig)
% pause(3)
%indcol=1:4;
%stimvspe=zeros(size(stimleveltab,2),size(dactab,2));
%for istimlevel=1:size(stimleveltab,2)
%   disp(['Starting istem ' num2str(istimlevel) '/' num2str(size(stimleveltab,2))])
%apply change:
%       quaboconfig(indexstim,2)=string(num2str(stimleveltab(istimlevel)));

%pause(3)
%  idac=1;%stopiter=0
% while (idac <=size(dactab,2)) && (stopiter==0)
% for idac=1:size(dactab,2)
% disp(['Starting idac ' num2str(idac) '/' num2str(size(dactab,2))])
%apply change:




%give time to acquire:
% pause(5)
olddir=dir(datadir);
pause(2)
%test if new data arrived:
newdir=dir(datadir);
if ~isequal(newdir, olddir)
    'New files'
    % stopiter=1
    %if new data, do sanity check (pulse detected?)
    %open data and read max value
    latestfile = getlatestfile(datadir)
    %open fits file
    import matlab.io.*
    fptr = fits.openFile([datadir latestfile]);
    pixels = fits.readImg(fptr);
    fits.closeFile(fptr);
    
    
    %             info = fitsinfo([path file])
    %             testifmsind=any(strcmp(info.PrimaryData.Keywords,'MSIND'));
    % stimvspe(istimlevel)=max(max(pixels));
    %if needed, use HK
    
    %idac=idac+1
    %   end
    
    
    %figure stimvspe
    
   phd3d(:,:,dd,igain)= (1/expsec)*reshape(pixels,[16,16]);
    
    figure
    imagesc((1:16),(1:16),(1/expsec)*reshape(pixels,[16,16]))
    axis('image')
    %  if
    CLOW=0
    CHIGH=1000
    gca.CLim=[CLOW CHIGH];
    % end
    hc= colorbar;
    hc.FontSize=16;
    %set(hc,'FontSize',18)
    title('>1pe (cps)')
    xlabel('X (pix)')
    ylabel('Y (pix)')
    %set(gca,'FontSize',18)
    set(gcf,'Color','w')
    
    current=50.e-6/64;
    gain=((1.6e-19/current)*(1/expsec)*double(reshape(pixels,[16,16]))).^(-1);
    
    gain3d(:,:,dd,igain)=gain;
    if 1==0
    figure
    CLOW=0
    CHIGH=17e8;%max(max(gain));
    imagesc((1:16),(1:16),gain,[CLOW CHIGH])
    axis('image')
    gca.CLim=[CLOW CHIGH];
    % end
    hc= colorbar;
    hc.FontSize=16;
    %set(hc,'FontSize',18)
    title('>1pe (cps)')
    xlabel('X (pix)')
    ylabel('Y (pix)')
    %set(gca,'FontSize',18)
    set(gcf,'Color','w')
    end
end


end

figure
hold on
for ir=1:8
    for ic=1:8
        plot(dactab,squeeze(phd3d(ir,ic,:,igain)),'+-')
    end
end
hold off
title(['Gain pix:' num2str(gaintab(igain))])
ax=gca;
ax.YScale='log'
figure
hold on

        plot(dactab,squeeze(mean(phd3d(1:8,1:8,:,igain),[1 2])),'+-b')
        plot(dactab,squeeze(mean(phd3d(9:16,1:8,:,igain),[1 2])),'+-r')
        plot(dactab,squeeze(mean(phd3d(1:8,9:16,:,igain),[1 2])),'+-g')
        plot(dactab,squeeze(mean(phd3d(9:16,9:16,:,igain),[1 2])),'+-k')

hold off
title(['Gain pix:' num2str(gaintab(igain))])
ax=gca;
ax.YScale='log'
end   
load gong.mat
sound(y)