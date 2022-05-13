%%%Threshold vs p.e.
datadir='C:\DATA\20181212\'

quaboconfig=importquaboconfig('C:\DATA\configs\tests\quabo_config_phd4.txt');
[ia,indexacqint]=ismember('ACQINT ',quaboconfig);
acqint = str2num(quaboconfig(indexacqint,2));
expsec=10.24e-6*acqint;
% [ia,indexdac]=ismember('DAC1',quaboconfig);
%iniate board:
%         sendconfig2Maroc(quaboconfig)
%give time to apply change:
pause(5)
% quaboconfig(index,2)=string(value);
% app.currentconfig=quaboconfig;

%stimleveltab=[ 10 25 50 75 100 125 150 175 200 225 250];
%dactab=[300];
% quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactab(1))]};
%%sendconfig2Maroc(quaboconfig)
%%pause(3)
%%sentacqparams2board(quaboconfig)
%%pause(3)
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
    
    
    %             info = fitsinfo([path file])
    %             testifmsind=any(strcmp(info.PrimaryData.Keywords,'MSIND'));
    % stimvspe(istimlevel)=max(max(pixels));
    %if needed, use HK
    
    %idac=idac+1
    %   end
    
    
    %figure stimvspe
    
    
    figure
        CLOW=0
    CHIGH=400000
    imagesc((1:16),(1:16),(1/expsec)*reshape(pixels,[16,16]),[CLOW CHIGH])
    axis('image')
    %  if

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
    
    current=140.e-6/64;
    gain=((1.6e-19/current)*(1/expsec)*double(reshape(pixels,[16,16]))).^(-1);
    figure
    
    %  if
    CLOW=0
    CHIGH=9e7;%max(max(gain));
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
%load gong.mat
%sound(y)