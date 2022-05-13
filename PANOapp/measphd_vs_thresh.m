%%%Threshold vs p.e.
datadir='C:\DATA\20181206\'

quaboconfig=importquaboconfig('C:\DATA\configs\tests\quabo_config_phd4.txt');
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
%%%%%%%%%pause(3)
%give time to apply change:

% quaboconfig(index,2)=string(value);
% app.currentconfig=quaboconfig;
 indcol=1:4;
%stimleveltab=[ 10 25 50 75 100 125 150 175 200 225 250];
%dactab=[ 290 291 292 293 294 295 296 297 298 299 300 305 310 320 350 400 450 500];
dactab=[ 240 250 260 270 280 290 300 305 310 320 350 400 450 500];
%dactab=[288 290 292 294 296 298 300 305 310 320 350 400 450 500];
%dactab=[288:2:300 305:5:500];
%dactab=[185:5:305  ];
 phd3d=zeros(16,16,numel(dactab));
 gain3d=zeros(16,16,numel(dactab));
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
    
   phd3d(:,:,dd)= (1/expsec)*reshape(pixels,[16,16]);
    
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
    
    gain3d(:,:,dd)=gain;
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
        plot(dactab,squeeze(phd3d(ir,ic,:)),'+-')
    end
end
hold off
title(['Gain pix:'])
xlabel('Threshold DAC1 (int)')
ylabel('CPS)')
%set(gca,'FontSize',18)
ax=gca;
ax.FontSize=16
set(gcf,'Color','w')
ax.YScale='log';
%ylim([0 700])
        
figure
hold on

        plot(dactab,squeeze(mean(phd3d(1:8,1:8,:),[1 2])),'+-b')
        plot(dactab,squeeze(mean(phd3d(9:16,1:8,:),[1 2])),'+-r')
        plot(dactab,squeeze(mean(phd3d(1:8,9:16,:),[1 2])),'+-g')
        plot(dactab,squeeze(mean(phd3d(9:16,9:16,:),[1 2])),'+-k')

hold off


title(['Gain pix:'])
xlabel('Threshold DAC1 (int)')
ylabel('CPS)')
%set(gca,'FontSize',18)
ax=gca;
ax.FontSize=16
set(gcf,'Color','w')
ax.YScale='log';
%ylim([0 700])

%%QUAD1
%%%Trace pe levels
phd1=squeeze(mean(phd3d(1:8,1:8,:),[1 2]))';
petab=1:5;
thpecal=interp1(datape2,datath2,petab,'cubic')
phdpe=interp1(dactab,phd1,thpecal,'pchip')



ratiospe=[]
for ii=2:numel(petab)-1
    ratiospe=[ratiospe phdpe(ii)/phdpe(ii+1)]
end
ratpe=mean(ratiospe)
ratpe1=ratpe;
cps1pe=ratpe*phdpe(2)

hold on 
plot(thpecal(1),cps1pe,'ob','MarkerSize',6)
hold off
cps1peQ1=cps1pe;

%%QUAD2
%%%Trace pe levels
phd1=squeeze(mean(phd3d(9:16,1:8,:),[1 2]))';
petab=1:5;
thpecal=interp1(datape2,datath2,petab,'cubic')
phdpe=interp1(dactab,phd1,thpecal,'pchip')



ratiospe=[]
for ii=2:numel(petab)-1
    ratiospe=[ratiospe phdpe(ii)/phdpe(ii+1)]
end
ratpe=mean(ratiospe)
ratpe2=ratpe;
cps1pe=ratpe*phdpe(2)

hold on 
plot(thpecal(1),cps1pe,'or','MarkerSize',6)
hold off
cps1peQ2=cps1pe;

%%QUAD3
%%%Trace pe levels
phd1=squeeze(mean(phd3d(1:8,9:16,:),[1 2]))';
petab=1:5;
thpecal=interp1(datape2,datath2,petab,'cubic')
phdpe=interp1(dactab,phd1,thpecal,'pchip')



ratiospe=[]
for ii=2:numel(petab)-1
    ratiospe=[ratiospe phdpe(ii)/phdpe(ii+1)]
end
ratpe=mean(ratiospe)

cps1pe=ratpe*phdpe(2)
ratpe3=ratpe;
hold on 
plot(thpecal(1),cps1pe,'og','MarkerSize',6)
hold off
cps1peQ3=cps1pe;

%%QUAD4
%%%Trace pe levels
phd1=squeeze(mean(phd3d(9:16,9:16,:),[1 2]))';
petab=1:5;
thpecal=interp1(datape2,datath2,petab,'cubic')
phdpe=interp1(dactab,phd1,thpecal,'pchip')



ratiospe=[]
for ii=2:numel(petab)-1
    ratiospe=[ratiospe phdpe(ii)/phdpe(ii+1)]
end
ratpe=mean(ratiospe)

cps1pe=ratpe*phdpe(2)
ratpe4=ratpe;
hold on 
plot(thpecal(1),cps1pe,'ok','MarkerSize',6)
hold off
cps1peQ4=cps1pe;

%%make pe dashed lines

petab=1:5;
thtab2=interp1(datape2,datath2,petab,'cubic')

hold on
for ii=1:numel(petab)
   plot([thtab2(ii) thtab2(ii)], [1 1e6], '--')
   text(thtab2(ii),2,[num2str(petab(ii)) ' pe'],'FontSize',16)
end
hold off
legend(['Quad 1, Dark 1pe (cps):' num2str(floor(cps1peQ1))],...
    ['Quad 2, Dark 1pe (cps):' num2str(floor(cps1peQ2))],...
    ['Quad 3, Dark 1pe (cps):' num2str(floor(cps1peQ3))],...
    ['Quad 4, Dark 1pe (cps):' num2str(floor(cps1peQ4))]...
    )
   legtxt={}

%%put the board at 2pe, take an image, normalize time, extroplate 1pe
thpecal(2);
dactab2pe=thpecal(2);
%dactab=[185:5:305  ];
 phd3d2pe=zeros(16,16,numel(dactab2pe));
 gain3d2pe=zeros(16,16,numel(dactab2pe));
for dd=1:numel(dactab2pe)
 quaboconfig(indexdac,indcol+1)={['0x' dec2hex(floor(dactab2pe(dd)))]};
sendconfig2Maroc(quaboconfig)
pause(3)
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

   phd3d2pe= (1/expsec)*reshape(pixels,[16,16]);
    
   phd3d1pe=phd3d2pe;
   %TO do :check good order Q1...4
   phd3d1pe(1:8,1:8)=cps1peQ1*phd3d1pe(1:8,1:8);
   phd3d1pe(9:16,1:8)=cps1peQ2*phd3d1pe(9:16,1:8);
   phd3d1pe(1:8,9:16)=cps1peQ3*phd3d1pe(1:8,9:16);
   phd3d1pe(9:16,9:16)=cps1peQ4*phd3d1pe(9:16,9:16);
   

   
    figure
    imagesc((1:16),(1:16),phd3d1pe)
    axis('image')
    %  if
    CLOW=0
    CHIGH=1000
    gca.CLim=[CLOW CHIGH];
    % end
    hc= colorbar;
    hc.FontSize=16;
    %set(hc,'FontSize',18)
    title('>=1pe (cps)')
    xlabel('X (pix)')
    ylabel('Y (pix)')
    %set(gca,'FontSize',18)
    set(gcf,'Color','w')
    
    %%%ATTENTION CURRENT
    current=50.e-6/64;
    gain1pe=((1.6e-19/current)*phd3d1pe).^(-1);
    
    
    if 1==1
    figure
    CLOW=0
    CHIGH=17e8;%max(max(gain));
    imagesc((1:16),(1:16),gain1pe,[CLOW CHIGH])
    axis('image')
    gca.CLim=[CLOW CHIGH];
    % end
    hc= colorbar;
    hc.FontSize=16;
    %set(hc,'FontSize',18)
    title('>=1pe (cps)')
    xlabel('X (pix)')
    ylabel('Y (pix)')
    %set(gca,'FontSize',18)
    set(gcf,'Color','w')
    end
end


end


load gong.mat
sound(y)