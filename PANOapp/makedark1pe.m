
%%put the board at 2pe, take an image, normalize time, extroplate 1pe
thpecal(2);
dactab2pe=thpecal(2);
%dactab=[185:5:305  ];
 phd3d2pe=zeros(16,16,numel(dactab2pe));
 gain3d2pe=zeros(16,16,numel(dactab2pe));
for dd=1:numel(dactab2pe)
 quaboconfig(indexdac,indcol+1)={['0x' dec2hex(floor(dactab2pe(dd)))]};
%sendconfig2Maroc(quaboconfig)
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
   phd3d1pe(1:8,1:8)=ratpe1*phd3d1pe(1:8,1:8);
   phd3d1pe(9:16,1:8)=ratpe2*phd3d1pe(9:16,1:8);
   phd3d1pe(1:8,9:16)=ratpe3*phd3d1pe(1:8,9:16);
   phd3d1pe(9:16,9:16)=ratpe4*phd3d1pe(9:16,9:16);
   

   
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
    current=175.e-6/64;
    gain1pe=((1.6e-19/current)*double(phd3d1pe)).^(-1);
    
    
    if 1==1
    figure
    CLOW=0
    CHIGH=10e6;%max(max(gain));
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