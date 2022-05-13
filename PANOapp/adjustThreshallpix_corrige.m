figini;
close all
nim=100;
quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config.txt']);
[ig,indexstimon]=ismember(['STIMON '] ,quaboconfig);
  quaboconfig(indexstimon,2)={"0"};
pausetime=0.5;
indcol=1:4;
 %set gain
 gaintab=33;
   for pp=0:63 
        [ig,indexgain]=ismember(['GAIN' num2str(pp)] ,quaboconfig);

        quaboconfig(indexgain,indcol+1)={['0x' dec2hex(gaintab(1))]};
   end
   
   gainmap=zeros(16,16);
   gainmap(:,:)=gaintab;
  
   loopgain=1;
   loopgaincnt=0;
   
   while loopgain==1
       loopgaincnt=loopgaincnt+1;
     %set masks MASKOR1_
     mask=0;
     if mask==0
         masklabel='no mask, ';
       for pp=0:63 
        [ig,indexmask]=ismember(['MASKOR1_' num2str(pp)] ,quaboconfig);
         [ig,indexmask2]=ismember(['MASKOR2_' num2str(pp)] ,quaboconfig);
        quaboconfig(indexmask,indcol+1)={['0']};
        quaboconfig(indexmask2,indcol+1)={['0']};
       end

     else
         masklabel='all-pixel-masked-excepted-one, ';
       for pp=0:63 
        [ig,indexmask]=ismember(['MASKOR1_' num2str(pp)] ,quaboconfig);
        quaboconfig(indexmask,indcol+1)={['1']};
        [ig,indexmask2]=ismember(['MASKOR2_' num2str(pp)] ,quaboconfig);
        quaboconfig(indexmask2,indcol+1)={['1']};
       end
        [ig,indexmask]=ismember(['MASKOR1_0'] ,quaboconfig);
        quad=2;
        quaboconfig(indexmask,quad+1)={['0']};
        [ig,indexmask2]=ismember(['MASKOR2_0'] ,quaboconfig);
        quaboconfig(indexmask2,quad+1)={['0']};
     end
    
       
       
     
% init the board?
disp('Init Marocs...')
sendconfig2Maroc(quaboconfig)
disp('Waiting 3s...')
pause(3)
disp('Init Acq...')
sentacqparams2board(quaboconfig)
disp('Waiting 3s...')
pause(3)

%dactab=[ 240 250 260 270 280 290 300 305 310 320 350 400 450 500];
%dactab=[288 290 292 294 296 298 300 305 310 320 350 400 450 500];
%dactab=[550:1:650 ];
dactab=[150:1:250 ];
%dactab=[185:5:305  ];
     figure
   [ia,indexdac]=ismember('DAC1',quaboconfig);
   
     %put high thresh on all 4 quads
dactabH0=500;
 quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactabH0)]};
 pause(pausetime)
 
IntensmeanQ0=[];IntensmeanQ1=[];IntensmeanQ2=[];IntensmeanQ3=[];IntensmeanQ8=[];IntensmeanQ9=[];
allima=zeros(16,16,numel(dactab),numel(indcol));
indcol2=1;
for dd=1:numel(dactab)
 quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactab(dd))]};
 disp(['Sending Maroc comm...DAC1:' num2str(dactab(dd))])
sendconfig2Maroc(quaboconfig)

%timepause=10;
 %disp(['Q' num2str(indcol2) '  ' num2str( timepause*(numel(dactab)-dd)) 's left...'])
 pause(pausetime) 
 %pause(pausetime)
    images=grabimages(nim,1,1);

    meanimage=mean(images(:,:,:),[3])';
    allima(:,:,dd,indcol2)=meanimage;
    
    imagesc(meanimage)
    colorbar
    timenow=now;
    import matlab.io.*
    utcshift=7/24;
    filename = ['b_d0w0m0q0_' datestr(timenow+utcshift,'yyyymmdd_HHMMSS_FFF') ];
    fullfilename=[ getuserdir '\panoseti\DATA\' filename];
    fptr = fits.createFile([fullfilename '.fits']);
    
    fits.createImg(fptr,'int32',[16 16]);
    %fitsmode='overwrite';
    img=int32(meanimage);
    fits.writeImg(fptr,img)
    fits.closeFile(fptr);
    
        %  IntensmaxQ1(nima)=max(ima(9:16,1:8),[],'all');
    IntensmeanQ0=[IntensmeanQ0 mean(meanimage(9:16,1:8),[1 2])];
    % IntensmaxQ2(nima)=max(ima(1:8,1:8),[],'all');
    IntensmeanQ1=[IntensmeanQ1 mean(meanimage(1:8,1:8),[1 2])];
    %   IntensmaxQ3(nima)=max(ima(1:8,9:16),[],'all');
    IntensmeanQ2=[IntensmeanQ2 mean(meanimage(1:8,9:16),[1 2])];
    %   IntensmaxQ4(nima)=max(ima(9:16,9:16),[],'all');
    IntensmeanQ3=[IntensmeanQ3 mean(meanimage(9:16,9:16),[1 2])];
        %   IntensmaxQ4(nima)=max(ima(9:16,9:16),[],'all');
    IntensmeanQ8=[IntensmeanQ8 (meanimage(1,7))];
    

end
%  %put high thresh on all 4 quads
% dactabH0=500;
%  quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactabH0)]};
%  pause(pausetime)
% indcol2=2;
% for dd=1:numel(dactab)
%  quaboconfig(indexdac,indcol2+1)={['0x' dec2hex(dactab(dd))]};
%  disp(['Sending Maroc comm...DAC1:' num2str(dactab(dd))])
% sendconfig2Maroc(quaboconfig)
% % disp(['Q' num2str(indcol2) '  ' num2str( timepause*(numel(dactab)-dd)) 's left...'])
% 
% pause(pausetime)
% %timepause=10;
%    % pause(timepause)
%     images=grabimages(10,1,1);
%     figure
%     meanimage=mean(images(:,:,:),[3])';
%     allima(:,:,dd,indcol2)=meanimage;
%     
%     imagesc(meanimage)
%     colorbar
%     timenow=now;
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
%         %  IntensmaxQ1(nima)=max(ima(9:16,1:8),[],'all');
%    % IntensmeanQ0=[IntensmeanQ0 mean(meanimage(9:16,1:8),[1 2])];
%     % IntensmaxQ2(nima)=max(ima(1:8,1:8),[],'all');
%     IntensmeanQ1=[IntensmeanQ1 mean(meanimage(1:8,1:8),[1 2])];
%     %   IntensmaxQ3(nima)=max(ima(1:8,9:16),[],'all');
%     %IntensmeanQ2=[IntensmeanQ2 mean(meanimage(1:8,9:16),[1 2])];
%     %   IntensmaxQ4(nima)=max(ima(9:16,9:16),[],'all');
%     %IntensmeanQ3=[IntensmeanQ3 mean(meanimage(9:16,9:16),[1 2])];
%     
% 
% end
%  %put high thresh on all 4 quads
% dactabH0=500;
%  quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactabH0)]};
%  pause(pausetime)
% indcol2=3;
% for dd=1:numel(dactab)
%  quaboconfig(indexdac,indcol2+1)={['0x' dec2hex(dactab(dd))]};
%  disp('Sending Maroc comm...')
% sendconfig2Maroc(quaboconfig)
%  disp(['Q' num2str(indcol2) '  ' num2str( timepause*(numel(dactab)-dd)) 's left...'])
% 
% pause(pausetime)
% %timepause=10;
%     %pause(pausetime)
%     images=grabimages(10,1,1);
%     figure
%     meanimage=mean(images(:,:,:),[3])';
%     allima(:,:,dd,indcol2)=meanimage;
%     
%     imagesc(meanimage)
%     colorbar
%     timenow=now;
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
%         %  IntensmaxQ1(nima)=max(ima(9:16,1:8),[],'all');
%    % IntensmeanQ0=[IntensmeanQ0 mean(meanimage(9:16,1:8),[1 2])];
%     % IntensmaxQ2(nima)=max(ima(1:8,1:8),[],'all');
%     %IntensmeanQ1=[IntensmeanQ1 mean(meanimage(1:8,1:8),[1 2])];
%     %   IntensmaxQ3(nima)=max(ima(1:8,9:16),[],'all');
%     IntensmeanQ2=[IntensmeanQ2 mean(meanimage(1:8,9:16),[1 2])];
%     %   IntensmaxQ4(nima)=max(ima(9:16,9:16),[],'all');
%    % IntensmeanQ3=[IntensmeanQ3 mean(meanimage(9:16,9:16),[1 2])];
%     
% 
% end
%  %put high thresh on all 4 quads
% dactabH0=500;
%  quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactabH0)]};
%  pause(pausetime)
% indcol2=4;
% for dd=1:numel(dactab)
%  quaboconfig(indexdac,indcol2+1)={['0x' dec2hex(dactab(dd))]};
%  disp('Sending Maroc comm...')
% sendconfig2Maroc(quaboconfig)
%  disp(['Q' num2str(indcol2) '  ' num2str( timepause*(numel(dactab)-dd)) 's left...'])
% 
% pause(pausetime)
% %timepause=10;
%    % pause(timepause)
%     images=grabimages(10,1,1);
%     figure
%     meanimage=mean(images(:,:,:),[3])';
%     allima(:,:,dd,indcol2)=meanimage;
%     
%     imagesc(meanimage)
%     colorbar
%     timenow=now;
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
%         %  IntensmaxQ1(nima)=max(ima(9:16,1:8),[],'all');
%     %IntensmeanQ0=[IntensmeanQ0 mean(meanimage(9:16,1:8),[1 2])];
%     % IntensmaxQ2(nima)=max(ima(1:8,1:8),[],'all');
%     %IntensmeanQ1=[IntensmeanQ1 mean(meanimage(1:8,1:8),[1 2])];
%     %   IntensmaxQ3(nima)=max(ima(1:8,9:16),[],'all');
%     %IntensmeanQ2=[IntensmeanQ2 mean(meanimage(1:8,9:16),[1 2])];
%     %   IntensmaxQ4(nima)=max(ima(9:16,9:16),[],'all');
%     IntensmeanQ3=[IntensmeanQ3 mean(meanimage(9:16,9:16),[1 2])];
%     

%end

figure('Position',[50 50 1600 900])
hold on
figquad=0; 
if figquad==1
% plot(dactab, IntensmeanQ0,'-+b')
%  plot(dactab, IntensmeanQ1,'-+r')
%  plot(dactab, IntensmeanQ2,'-+g')
%  plot(dactab, IntensmeanQ3,'-+m')
 plot(dactab, IntensmeanQ8,'-+k')
else
    allima2=allima(:,:,:,1);
    for ii=1:8
        for jj=9:16
            plot(dactab,  squeeze(allima2(jj,ii,:)),'-+','Color',[0.5 ii/8 jj/16])
        end
    end
end
xlabel('Threshold DAC1 ')
ylabel('Mean intensity [counts per exposure]')
hold off
set(gca, 'YScale','log')
%legend('Q0','Q1','Q2','Q3','Single pix: [1,1]')
box on 
grid on
set(gcf,'Color','w')
title(['Bipolar fs; Gain:' num2str(gaintab) 'd(' dec2hex(gaintab) 'h); ' masklabel])
xlim([dactab(1) dactab(end)])

%    
% gain adjustement
load('MarocMap.mat');

refpixelxy=[10 3];
hold on
  plot(dactab,  squeeze(allima2(refpixelxy(1),refpixelxy(2),:)),'-o','Color',[0.5 0.5 0.5],'LineWidth',3.5)
  hold off
   datenow=datestr(now,'yymmddHHMMSS');
  saveas(gcf,['adjustGain' datenow '_' num2str(loopgaincnt) '.png'])
    saveas(gcf,['adjustGain' datenow '_' num2str(loopgaincnt) '.fig'])

find(marocmap(:,:,1)==refpixelxy(1) & marocmap(:,:,2)==refpixelxy(2));

phdref=squeeze(allima2(refpixelxy(1),refpixelxy(2),:));
%identify pe steps:
% find ind > 1pe
%mindac=min(find(dactab>189));


daczeropoint1=190;threshpeak=0.3;
peaksrefdac=findpelevel(phdref,dactab,daczeropoint1,threshpeak);


%%%
%%check example:
  iitest=3;jjtest=11;
  for ii=1:8
        for jj=9:16
         
  
   
testpixelxy=[jj ii];
%testpixelxy(1)=testpixelxy(1);
 if ii==iitest && jj==jjtest
        hold on
        plot(dactab,  squeeze(allima2(testpixelxy(1),testpixelxy(2),:)),'-d','Color',[0.2 0.2 0.2],'LineWidth',3.4)
      
        hold off
        
  end  

phdtest=squeeze(allima2(testpixelxy(1),testpixelxy(2),:));
peakstestdac=findpelevel(phdtest,dactab,daczeropoint1,threshpeak);


%find sep between pe and shift between pix
if numel(peakstestdac)>=3
peaksep=peakstestdac(1:3)-peaksrefdac(1:3);
%peaksep=peakstestdac(3)-peaksrefdac(3);
peakmove=sign(round(mean(peaksep)));


 disp(['pe levels REFpix found at dac: ' num2str(peaksrefdac)])
disp(['pe levels TestPix found at dac: ' num2str(peakstestdac)])

%get old gain and increment it
[ig,indexgain]=ismember(['GAIN' num2str(marocmap16(testpixelxy(1),testpixelxy(2),1)-1)] ,quaboconfig);
gainpixold=char(quaboconfig(indexgain,marocmap16(testpixelxy(1),testpixelxy(2),2)+1));
gainpixnew=dec2hex(hex2dec(gainpixold(3:4))-peakmove);
gainmap(testpixelxy(1),testpixelxy(2))=(hex2dec(gainpixold(3:4))-peakmove);
quaboconfig(indexgain,marocmap16(testpixelxy(1),testpixelxy(2),2)+1)={['0x' gainpixnew]};

  if ii==iitest && jj==jjtest
      disp(['pe levels REFpix found at dac: ' num2str(peaksrefdac)])
disp(['pe levels TestPix found at dac: ' num2str(peakstestdac)])
disp(['pe separation in dac: ' num2str(peaksep)])
disp(['pe suggested move in dac: ' num2str(peakmove)])
  disp(['New Gain (dec): ' num2str(gainmap(testpixelxy(1),testpixelxy(2)))])
disp(['gain old: ' num2str(hex2dec(gainpixold(3:4)))])
disp(['gain new: ' num2str(hex2dec(gainpixnew))])
  end

end 
     end
  end

    
    
   end
  
figure
hold on
plot(dactab,phdref,'g')
%plot(dactab,-d0,'b')
plot(dactab,d1,'r')
plot(dactab,d1r,'m')
hold off
set(gca,'YScale','log')





