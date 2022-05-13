quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config.txt']);
[ig,indexstimon]=ismember(['STIMON '] ,quaboconfig);
  quaboconfig(indexstimon,2)={"1"};
  [ig,indexstimrate]=ismember(['STIM_RATE '] ,quaboconfig);
   quaboconfig(indexstimrate,2)={"4"};
  
pausetime=3;
indcol=1:4;
 %set gain
 gaintab=33;
   for pp=0:63 
        [ig,indexgain]=ismember(['GAIN' num2str(pp)] ,quaboconfig);

        quaboconfig(indexgain,indcol+1)={['0x' dec2hex(gaintab(1))]};
   end
   
    %set ctest_
   for pp=0:63 
        [ig,indexgain]=ismember(['CTEST_' num2str(pp)] ,quaboconfig);

        quaboconfig(indexgain,indcol+1)={['1']};
   end
     %set masks
     for pp=0:63 
        [ig,indexmask]=ismember(['MASKOR1_' num2str(pp)] ,quaboconfig);
         [ig,indexmask2]=ismember(['MASKOR2_' num2str(pp)] ,quaboconfig);
        quaboconfig(indexmask,indcol+1)={['0']};
        quaboconfig(indexmask2,indcol+1)={['0']};
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
%dactab=[180:206 ];
dactab=150:5:250;
%dactab=[185:5:305  ];
 
   [ia,indexdac]=ismember('DAC1',quaboconfig);
   
     %put high thresh on all 4 quads
dactabH0=500;
 quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactabH0)]};
 pause(pausetime)
 
IntensmeanQ0=[];IntensmeanQ1=[];IntensmeanQ2=[];IntensmeanQ3=[];
allima=zeros(16,16,numel(dactab),numel(indcol));
indcol2=1;
for dd=1:numel(dactab)
 quaboconfig(indexdac,indcol2+1)={['0x' dec2hex(dactab(dd))]};
 disp('Sending Maroc comm...')
sendconfig2Maroc(quaboconfig)

%timepause=10;
 %disp(['Q' num2str(indcol2) '  ' num2str( timepause*(numel(dactab)-dd)) 's left...'])
 pause(pausetime) 
 %pause(pausetime)
    images=grabimages(10,1,1);
    figure
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
    %IntensmeanQ1=[IntensmeanQ1 mean(meanimage(1:8,1:8),[1 2])];
    %   IntensmaxQ3(nima)=max(ima(1:8,9:16),[],'all');
    %IntensmeanQ2=[IntensmeanQ2 mean(meanimage(1:8,9:16),[1 2])];
    %   IntensmaxQ4(nima)=max(ima(9:16,9:16),[],'all');
    %IntensmeanQ3=[IntensmeanQ3 mean(meanimage(9:16,9:16),[1 2])];
    

end
 %put high thresh on all 4 quads
dactabH0=500;
 quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactabH0)]};
 pause(pausetime)
indcol2=2;
for dd=1:numel(dactab)
 quaboconfig(indexdac,indcol2+1)={['0x' dec2hex(dactab(dd))]};
 disp('Sending Maroc comm...')
sendconfig2Maroc(quaboconfig)
 disp(['Q' num2str(indcol2) '  ' num2str( timepause*(numel(dactab)-dd)) 's left...'])

pause(pausetime)
%timepause=10;
   % pause(timepause)
    images=grabimages(10,1,1);
    figure
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
   % IntensmeanQ0=[IntensmeanQ0 mean(meanimage(9:16,1:8),[1 2])];
    % IntensmaxQ2(nima)=max(ima(1:8,1:8),[],'all');
    IntensmeanQ1=[IntensmeanQ1 mean(meanimage(1:8,1:8),[1 2])];
    %   IntensmaxQ3(nima)=max(ima(1:8,9:16),[],'all');
    %IntensmeanQ2=[IntensmeanQ2 mean(meanimage(1:8,9:16),[1 2])];
    %   IntensmaxQ4(nima)=max(ima(9:16,9:16),[],'all');
    %IntensmeanQ3=[IntensmeanQ3 mean(meanimage(9:16,9:16),[1 2])];
    

end
 %put high thresh on all 4 quads
dactabH0=500;
 quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactabH0)]};
 pause(pausetime)
indcol2=3;
for dd=1:numel(dactab)
 quaboconfig(indexdac,indcol2+1)={['0x' dec2hex(dactab(dd))]};
 disp('Sending Maroc comm...')
sendconfig2Maroc(quaboconfig)
 disp(['Q' num2str(indcol2) '  ' num2str( timepause*(numel(dactab)-dd)) 's left...'])

pause(pausetime)
%timepause=10;
    %pause(pausetime)
    images=grabimages(10,1,1);
    figure
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
   % IntensmeanQ0=[IntensmeanQ0 mean(meanimage(9:16,1:8),[1 2])];
    % IntensmaxQ2(nima)=max(ima(1:8,1:8),[],'all');
    %IntensmeanQ1=[IntensmeanQ1 mean(meanimage(1:8,1:8),[1 2])];
    %   IntensmaxQ3(nima)=max(ima(1:8,9:16),[],'all');
    IntensmeanQ2=[IntensmeanQ2 mean(meanimage(1:8,9:16),[1 2])];
    %   IntensmaxQ4(nima)=max(ima(9:16,9:16),[],'all');
   % IntensmeanQ3=[IntensmeanQ3 mean(meanimage(9:16,9:16),[1 2])];
    

end
 %put high thresh on all 4 quads
dactabH0=500;
 quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactabH0)]};
 pause(pausetime)
indcol2=4;
for dd=1:numel(dactab)
 quaboconfig(indexdac,indcol2+1)={['0x' dec2hex(dactab(dd))]};
 disp('Sending Maroc comm...')
sendconfig2Maroc(quaboconfig)
 disp(['Q' num2str(indcol2) '  ' num2str( timepause*(numel(dactab)-dd)) 's left...'])

pause(pausetime)
%timepause=10;
   % pause(timepause)
    images=grabimages(10,1,1);
    figure
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
    %IntensmeanQ0=[IntensmeanQ0 mean(meanimage(9:16,1:8),[1 2])];
    % IntensmaxQ2(nima)=max(ima(1:8,1:8),[],'all');
    %IntensmeanQ1=[IntensmeanQ1 mean(meanimage(1:8,1:8),[1 2])];
    %   IntensmaxQ3(nima)=max(ima(1:8,9:16),[],'all');
    %IntensmeanQ2=[IntensmeanQ2 mean(meanimage(1:8,9:16),[1 2])];
    %   IntensmaxQ4(nima)=max(ima(9:16,9:16),[],'all');
    IntensmeanQ3=[IntensmeanQ3 mean(meanimage(9:16,9:16),[1 2])];
    

end

figure
hold on
plot(dactab, IntensmeanQ0,'-+b')
plot(dactab, IntensmeanQ1,'-+r')
plot(dactab, IntensmeanQ2,'-+g')
plot(dactab, IntensmeanQ3,'-+m')
xlabel('Threshold DAC1')
ylabel('Mean intensity [counts per exposure]')
hold off
legend('Q0','Q1','Q2','Q3')

datenow=datestr(now,'yymmddHHMMSS');
 saveas(gcf,['threshImaDAC' datenow '.png'])
   saveas(gcf,['threshImaDAC' datenow '.fig'])
   
   %%DEDUCE OPTIMAL VALUES AT MAX CNTS
   [mv,mind0]=max(IntensmeanQ0);
    [mv,mind1]=max(IntensmeanQ1);
     [mv,mind2]=max(IntensmeanQ2);
      [mv,mind3]=max(IntensmeanQ3);
      %find first zeros after bump
%     indz0=  find(IntensmeanQ0(mind0+1:end)>=2)
%     indz1=  find(IntensmeanQ1(mind1+1:end)>=2)
%     indz2=  find(IntensmeanQ2(mind2+1:end)>=2)
%     indz3=  find(IntensmeanQ3(mind3+1:end)>=2)
    shifttab=10;
   quaboconfig(indexdac,indcol(1)+1)={['0x' dec2hex(dactab(mind0)+shifttab)]};
   quaboconfig(indexdac,indcol(2)+1)={['0x' dec2hex(dactab(mind1)+shifttab)]};
   quaboconfig(indexdac,indcol(3)+1)={['0x' dec2hex(dactab(mind2)+shifttab)]};
   quaboconfig(indexdac,indcol(4)+1)={['0x' dec2hex(dactab(mind3)+shifttab)]};
   sendconfig2Maroc(quaboconfig)
   
   dactabbest=[dactab(mind0)+shifttab (dactab(mind1)+shifttab) (dactab(mind2)+shifttab) (dactab(mind3)+shifttab)]
   %save(['adjustthresh' datenow '.mat'])
   
%%%%%%%%MAP MAROC PIX
     for pp=0:63 
        [ig,indexmask]=ismember(['MASKOR1_' num2str(pp)] ,quaboconfig);
         [ig,indexmask2]=ismember(['MASKOR2_' num2str(pp)] ,quaboconfig);
        quaboconfig(indexmask,indcol+1)={['1']};
        quaboconfig(indexmask2,indcol+1)={['1']};
     end
       
     marocmap=zeros(64,4,2);
      marocmap16=zeros(16,16,2);
for qq=1:4
for qp=1:64
    
     %set masks MASKOR1_

        [ig,indexmask1]=ismember(['MASKOR1_' num2str(qp-1)] ,quaboconfig);
        [ig,indexmask2]=ismember(['MASKOR2_' num2str(qp-1)] ,quaboconfig);
        quaboconfig(indexmask1,qq+1)={['0']};
        quaboconfig(indexmask2,qq+1)={['0']};
      
    
       
%  quaboconfig(indexdac,indcol2+1)={['0x' dec2hex(dactab(dd))]};
%  disp('Sending Maroc comm...')
 sendconfig2Maroc(quaboconfig)
 pause(0.2)
% 
% %timepause=10;
%  %disp(['Q' num2str(indcol2) '  ' num2str( timepause*(numel(dactab)-dd)) 's left...'])
%  pause(pausetime) 
 %pause(pausetime)
    images=grabimages(10,1,1);
    %figure
    meanimage=mean(images(:,:,:),[3])';
    allima(:,:,dd,indcol2)=meanimage;
    
    imagesc(meanimage)
    colorbar
    timenow=now;
    import matlab.io.*
    utcshift=7/24;
    
    [row,column,value] = max_matrix(meanimage);
     marocmap(qp,qq,:)=[row column];
      marocmap16(row,column,:)=[qp qq];
     disp(['MarocPix:' num2str(qp) ' Q' num2str(qq) ' maps to PANOtv: ' num2str(row) ',' num2str(column)])
%     filename = ['b_d0w0m0q0_' datestr(timenow+utcshift,'yyyymmdd_HHMMSS_FFF') ];
%     fullfilename=[ getuserdir '\panoseti\DATA\' filename];
%     fptr = fits.createFile([fullfilename '.fits']);
%     
%     fits.createImg(fptr,'int32',[16 16]);
%     %fitsmode='overwrite';
%     img=int32(meanimage);
%     fits.writeImg(fptr,img)
%     fits.closeFile(fptr);
    
        %  IntensmaxQ1(nima)=max(ima(9:16,1:8),[],'all');
 %   IntensmeanQ0=[IntensmeanQ0 mean(meanimage(9:16,1:8),[1 2])];
    % IntensmaxQ2(nima)=max(ima(1:8,1:8),[],'all');
    %IntensmeanQ1=[IntensmeanQ1 mean(meanimage(1:8,1:8),[1 2])];
    %   IntensmaxQ3(nima)=max(ima(1:8,9:16),[],'all');
    %IntensmeanQ2=[IntensmeanQ2 mean(meanimage(1:8,9:16),[1 2])];
    %   IntensmaxQ4(nima)=max(ima(9:16,9:16),[],'all');
    %IntensmeanQ3=[IntensmeanQ3 mean(meanimage(9:16,9:16),[1 2])];
    
     quaboconfig(indexmask1,qq+1)={['1']};
        quaboconfig(indexmask2,qq+1)={['1']};

end
end

%check map sanity:
checkmap=zeros(16,16);
for qq=1:4
for qp=1:64
checkmap(marocmap(qp,qq,1),marocmap(qp,qq,2))=1;
end
end
figure
imagesc(checkmap)
colorbar

%%
save('MarocMap.mat','marocmap','marocmap16')

    quaboconfig(indexstimon,2)={"0"};