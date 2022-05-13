quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config.txt']);
[ig,indexstimon]=ismember(['STIMON '] ,quaboconfig);
  quaboconfig(indexstimon,2)={"0"};
pausetime=0.5;
indcol=1:4;
 %set gain
 IntensmeanQ8G=[];
 gaintabtab=11:31 %1:10:121;
for  gainkk=1:numel(gaintabtab);
    gaintab=gaintabtab(gainkk);
   for pp=0:63 
        [ig,indexgain]=ismember(['GAIN' num2str(pp)] ,quaboconfig);

        quaboconfig(indexgain,indcol+1)={['0x' dec2hex(gaintab(1))]};
   end
  
   
     %set masks MASKOR1_
     mask=1;
     if mask==0
       for pp=0:63 
        [ig,indexmask]=ismember(['MASKOR1_' num2str(pp)] ,quaboconfig);
        quaboconfig(indexmask,indcol+1)={['0']};
       end
     else
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
% dactabH0=500;
%  quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactabH0)]};
%  pause(pausetime)
 
IntensmeanQ0=[];IntensmeanQ1=[];IntensmeanQ2=[];IntensmeanQ3=[];IntensmeanQ8=[];IntensmeanQ9=[];
allima=zeros(16,16,numel(dactab),numel(indcol));
indcol2=1;
for dd=1:numel(dactab)
 quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactab(dd))]};
 disp(['Sending Maroc comm...DAC1:' num2str(dactab(dd)) ' Gain:' num2str(numel(gaintabtab(gainkk))) ' (' num2str(gainkk) '/' num2str(numel(gaintabtab)) ')' ])
sendconfig2Maroc(quaboconfig)

%timepause=10;
 %disp(['Q' num2str(indcol2) '  ' num2str( timepause*(numel(dactab)-dd)) 's left...'])
 pause(pausetime) 
 %pause(pausetime)
    images=grabimages(10,1,1);

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
IntensmeanQ8G=[IntensmeanQ8G; IntensmeanQ8];
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

% figure
% hold on
% figquad=0;
% if figquad==1
% % plot(dactab, IntensmeanQ0,'-+b')
% %  plot(dactab, IntensmeanQ1,'-+r')
% %  plot(dactab, IntensmeanQ2,'-+g')
% %  plot(dactab, IntensmeanQ3,'-+m')
%  plot(dactab, IntensmeanQ8,'-+k')
% else
%     allima2=allima(:,:,:,1);
%     for ii=1:8
%         for jj=9:16
%             plot(dactab,  squeeze(allima2(jj,ii,:)),'-+','Color',[0.5 ii/8 jj/16])
%         end
%     end
% end
% xlabel('Threshold DAC1 ')
% ylabel('Mean intensity [counts per exposure]')
% hold off
% set(gca, 'YScale','log')
% legend('Q0','Q1','Q2','Q3','Single pix: [1,1]')
% box on 
% grid on
% set(gcf,'Color','w')
% title(['Bipolar fs; Gain:' num2str(gaintab) 'd(' dec2hex(gaintab) 'h); all-pixels-masked-excepted-one '])
%  datenow=datestr(now,'yymmddHHMMSS');
%   saveas(gcf,['threshImaDAC' datenow 'allpix_masked.png'])
%     saveas(gcf,['threshImaDAC' datenow 'allpix_masked.fig'])
%    
%    %%DEDUCE OPTIMAL VALUES AT MAX CNTS
%    [mv,mind0]=max(IntensmeanQ0);
%     [mv,mind1]=max(IntensmeanQ1);
%      [mv,mind2]=max(IntensmeanQ2);
%       [mv,mind3]=max(IntensmeanQ3);
%       %find first zeros after bump
%     indz0=  find(IntensmeanQ0(mind0+1:end)==2)
%     indz1=  find(IntensmeanQ1(mind1+1:end)==2)
%     indz2=  find(IntensmeanQ2(mind2+1:end)==2)
%     indz3=  find(IntensmeanQ3(mind3+1:end)==2)
%     shifttab=1
%    quaboconfig(indexdac,indcol(1)+1)={['0x' dec2hex(dactab(mind0)+indz0(1)+shifttab+2)]};
%    quaboconfig(indexdac,indcol(2)+1)={['0x' dec2hex(dactab(mind1)+indz1(1)+shifttab)]};
%    quaboconfig(indexdac,indcol(3)+1)={['0x' dec2hex(dactab(mind2)+indz2(1)+shifttab)]};
%    quaboconfig(indexdac,indcol(4)+1)={['0x' dec2hex(dactab(mind3)+indz3(1)+shifttab+2)]};
%    sendconfig2Maroc(quaboconfig)
%    
%    dactabbest=[dactab(mind0)+indz0(1)+3 (dactab(mind1)+indz1(1)+3) (dactab(mind2)+6) (dactab(mind3)+indz3(1)+3)]
%    save(['adjustthresh' datenow '.mat'])
%     quaboconfig(indexstimon,2)={"0"};

% RickLEDV=[1.7 1.8 1.9 2. 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0 3.5 4. 4.5 5. 6. 7. 10. 15. 20. 23.];
% ThorlabsnW=[0.3 0.6 1. 1.4 1.9 2.4 3. 3.5 4.1 4.7 5.4 6.0 6.6 7.3 10.6 14.1 17.7 21.4 29.1 37. 57.3 96. 136. 160.];
% ThorlabsnWND=0.01*ThorlabsnW;
% 
% ThorlabsnWNDpix=(1/((pi*(9.5/2)^2)/9.))*ThorlabsnWND;
% h=6.62607e-34;c=2.998e8;lam=0.633e-6;
% ThorlabsnWNDpixphot=(lam/h/c) *(1e-9)* ThorlabsnWNDpix;
% qe=0.22;
% ThorlabsnWNDpixcnt=qe*ThorlabsnWNDpixphot;
% 
% leg={};
% for ii=1:numel(ThorlabsnWNDpixphot)
%     leg(ii)={ ['LED [Mph/s/pix]:' num2str(1e-6*ThorlabsnWNDpixphot(ii),'%6.1f') ' [nW/pix]:' num2str(ThorlabsnWNDpix(ii),'%6.4f')]};
% end
%  leg(ii+1)={ ['Dark, Q1 pix [7,1]']};
% 
% legend(leg)
end

figure

for ii=1:size(IntensmeanQ8G,1)
    hold on
 plot(dactab, IntensmeanQ8G(ii,:),'-+','Color',rand(1,3),'Linewidth',1.5) %[ii/size(IntensmeanQ8G,1) (1-ii/size(IntensmeanQ8G,1)) ii/size(IntensmeanQ8G,1)]
 hold off
end

xlabel('Threshold DAC1 ')
ylabel('Mean intensity [counts per exposure]')
hold off
set(gca, 'YScale','log')

leg={};
for ii=1:numel(gaintabtab)
    leg(ii)={ ['Gain:' num2str(gaintabtab(ii)) ' (0x' dec2hex(gaintabtab(ii)) ')']};
end
legend(leg)
box on 
grid on
set(gcf,'Color','w')
title(['dark, Bipolar fs; all-pixels-masked-excepted-one [7,1]'])
 datenow=datestr(now,'yymmddHHMMSS');
  saveas(gcf,['threshImaDACGAIN' datenow '_masked.png'])
    saveas(gcf,['threshImaDACGAIN' datenow '_masked.fig'])
    save(['threshImaDACGAIN' datenow '_masked.mat'])