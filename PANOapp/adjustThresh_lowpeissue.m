close all
%IP='192.168.3.248'
%IP='192.168.3.252'
IP='192.168.0.4'
dacPH=280; nim=1000;
 load('MarocMap.mat');
 % boardSN=
quaboSN=num2str(IP2SN(IP));%input('Enter quabo SN:','s');
quaboSNstr=num2str(str2num(quaboSN),'%03d');
%disp(['You decided to use quabo SN' quaboSNstr])
pausetime=1;

%quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config.txt']);
quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config_DUAL.txt']);
%quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config_PHdual.txt']);
expo=25; %*1us
[ig,indexacqint]=ismember(['ACQINT '] ,quaboconfig);
quaboconfig(indexacqint,2)=expo-1;

disp('Starting HV...')
szq=size(quaboconfig,1);
quaboconfig(szq+1,1)={'IP'};quaboconfig(szq+1,3)={IP};
szq=size(quaboconfig,1);
quaboconfig(szq+1,1)={'QuaboSN'};quaboconfig(szq+1,3)={str2num(quaboSN)};

maskmode=0;
% maskpix1=[63, 4];
% %maskpix2=[12 2];
% marocmap(maskpix1(1),maskpix1(2),:)
%maskpix1=marocmap16(7,9,:);
xa=13;ya=13;
maskpix1=marocmap16(xa,ya,:);

    quaboconfig = changemask(maskmode,maskpix1,quaboconfig); %maskmode: unmask all pix (=0); mask all excepted some (=1)
 
if maskmode==0
    masklabel='no mask.';
else
    masklabel=['all-pix-masked-excepted pix#' num2str(maskpix1(1)-1) 'on Q' num2str(maskpix1(2)-1)]; % ' AND pix#' num2str(maskpix2(1)-1) 'on Q' num2str(maskpix2(2)-1)
end




 
gain=60;
quaboconfig=changegain(gain, quaboconfig,0); % third param is using an adjusted gain map (=1) or not (=0)
quaboconfig=changepe(30.,gain,quaboconfig);
%quaboconfig=changepedual(30,30.,gain,quaboconfig);
%sendconfigCHANMASK(quaboconfig)
[ig,indexacqmode]=ismember(['ACQMODE '] ,quaboconfig);
    quaboconfig(indexacqmode,2)={"0x02"};
   
% quaboconfig=changepe(30.,gain,quaboconfig);   
        
        % init the board?
%         disp('Init Marocs...')
%         sendconfig2Maroc(quaboconfig)
%         disp('Waiting 3s...')
%         pause(1)
%         disp('Init Acq...')
         sentacqparams2board(quaboconfig)
%         disp('Waiting 3s...')
%         pause(1)
%          sendHV(quaboconfig)
%          pause(1)

% subtractbaseline(quaboconfig)
         %       pause(3)
       %  gain=40.;
       
%quaboconfig=changepedual(20.,8.,gain,quaboconfig); 
[ia,indexdac2]=ismember('DAC2',quaboconfig);
indcol=1:4;
quaboconfig(indexdac2,indcol+1)={['0x' dec2hex(dacPH)]};
%dactab=[ 240 250 260 270 280 290 300 305 310 320 350 400 450 500];
%dactab=[288 290 292 294 296 298 300 305 310 320 350 400 450 500];
%dactab=[550:1:650 ];
dactab=[180:1:250 ];
%dactab=[200  ];
     figure('Position',[10 100 600 800])
   [ia,indexdac]=ismember('DAC1',quaboconfig);
   
     %put high thresh on all 4 quads
% dactabH0=500;
%  quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactabH0)]};
%  pause(pausetime)
 
IntensmeanQ0=[];IntensmeanQ1=[];IntensmeanQ2=[];IntensmeanQ3=[];IntensmeanQ8=[];IntensmeanQ9=[];
allima=zeros(16,16,numel(dactab));allph=zeros(16,16,numel(dactab));
    allnph=zeros(1,numel(dactab));
    allnima=zeros(1,numel(dactab));
indcol2=1;
for dd=1:numel(dactab)
 quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactab(dd))]};
 disp(['Sending Maroc comm...DAC1:' num2str(dactab(dd))])
sendconfig2Maroc(quaboconfig)

%timepause=10;
 %disp(['Q' num2str(indcol2) '  ' num2str( timepause*(numel(dactab)-dd)) 's left...'])
 pause(pausetime) 
 %pause(pausetime)
    [images nimafin  nano packnum acqm]=grabimages2key(nim,2,0);
    
   
indima= find(acqm==2);
%indph=find(acqm==1);
nima=numel(indima);
    meanimage=mean(images(:,:,indima),[3])';
  %    meanph=mean(images(:,:,indph),[3])';
    allima(:,:,dd)=meanimage;
  %  allph(:,:,dd)=meanph;
 %   allnph(dd)=numel(indph);
    allnima(dd)=nima;
    disp([num2str(dd) '/' num2str(numel(dactab)) ' dacIma:' num2str(dactab(dd))...
        ' nbIma=' num2str(allnima(dd)) ])
 
   
subplot(3,2,1)
    imagesc(meanimage);axis image;
    colorbar;
text(0,23,[num2str(dd) '/' num2str(numel(dactab)) ' dacIma:' num2str(dactab(dd))...
        ' nbIma=' num2str(allnima(dd)) ' nbph=' num2str(allnph(dd))])

%         subplot(3,2,2)
%     imagesc(meanph);axis image;
%     colorbar
 
  
    subplot(3,2,3)
    plot(nano(indima));ylabel('Ima Nanosec')
     subplot(3,2,4)
cla;
    hold on; plot(packnum(indima));legend('Ima'),ylabel('Packet num')
     drawnow 
    
    subplot(3,2,5)
nanoima=nano(indima);
nanodiff=nanoima(2:end)-nanoima(1:end-1);
    plot(nanodiff);ylabel('Ima Nanosec diff (ns)');set(gca,'YScale','log')
     subplot(3,2,6)
packima=packnum(indima);
packimadiff=packima(2:end)-packima(1:end-1);
% packph=packnum(indph);
% packphdiff=packph(2:end)-packph(1:end-1);
cla;
    hold on; plot(packimadiff,'-+');legend('Ima'),ylabel('Packet num DIFF')
     drawnow   
    timenow=now;
%     import matlab.io.*
%     utcshift=7/24;
%     filename = ['b_d0w0m0q0_' datestr(timenow+utcshift,'yyyymmdd_HHMMSS_FFF') ];
%     fullfilename=[ getuserdir '\panoseti\DATA\' filename];
%     fptr = fits.createFile([fullfilename '.fits']);
%     
%     fits.createImg(fptr,'int32',[16 16]);
%     %fitsmode='overwrite';
%     img=int32(meanimage);
%     fits.writeImg(fptr,img)
%     fits.closeFile(fptr);
%     
        %  IntensmaxQ1(nima)=max(ima(9:16,1:8),[],'all');
    IntensmeanQ0=[IntensmeanQ0 mean(meanimage(9:16,1:8),[1 2])];
    % IntensmaxQ2(nima)=max(ima(1:8,1:8),[],'all');
    IntensmeanQ1=[IntensmeanQ1 mean(meanimage(1:8,1:8),[1 2])];
    %   IntensmaxQ3(nima)=max(ima(1:8,9:16),[],'all');
    IntensmeanQ2=[IntensmeanQ2 mean(meanimage(1:8,9:16),[1 2])];
    %   IntensmaxQ4(nima)=max(ima(9:16,9:16),[],'all');
    IntensmeanQ3=[IntensmeanQ3 mean(meanimage(9:16,9:16),[1 2])];
        %   IntensmaxQ4(nima)=max(ima(9:16,9:16),[],'all');
    IntensmeanQ8=[IntensmeanQ8 (meanimage(xa,ya))];
    

end

figure('Position',[100 100 700 500])
hold on
% plot(dactab, IntensmeanQ0,'-+b')
%  plot(dactab, IntensmeanQ1,'-+r')
%  plot(dactab, IntensmeanQ2,'-+g')
%  plot(dactab, IntensmeanQ3,'-+m')
normima1=(1e-6*expo).^(-1);
normima=(1e-6*expo*allnima).^(-1);

 plot(dactab, normima1.*IntensmeanQ8,'-+b')
%  plot(dactab, normima.*allnph,'-+r')
%  legend('Imaging mode', ['simultaneous PH mode (DAC2=' num2str(dacPH) ')'])


xlabel('Threshold DAC1 ')
ylabel('Counts per second]')
hold off
set(gca, 'YScale','log')
%legend('Q0','Q1','Q2','Q3','Single pix: [1,1]')
box on 
grid on
set(gcf,'Color','w')
title(['Simultaneous IMA/PH; Gain:' num2str(gain) 'd(' dec2hex(gain) 'h); all-pixels-masked-excepted-one '])
 datenow=datestr(now,'yymmddHHMMSS');
  saveas(gcf,['threshImalowpe' num2str(dacPH) '_' datenow '_expo' num2str(expo) '_masked.png'])
    saveas(gcf,['threshImalowpe' num2str(dacPH) '_' datenow '_expo' num2str(expo) '_masked.fig'])
