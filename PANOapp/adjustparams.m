dactab=[196];
gaintab=[21];
IntensmeanQ0=[];IntensmeanQ1=[];IntensmeanQ2=[];IntensmeanQ3=[];

%set DAC1
    [ia,indexdac]=ismember('DAC1',quaboconfig);
          
 indcol=1:4;

 quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactab(1))]};
 
 %set gain
   for pp=0:63 
        [ig,indexgain]=ismember(['GAIN' num2str(pp)] ,quaboconfig);

        quaboconfig(indexgain,indcol+1)={['0x' num2str(gaintab(1))]};
     end
         sendconfig2Maroc(quaboconfig)
         
         
           pause(6)
    
    images=grabimages(10,1,1);
    figure
    meanimage=mean(images(:,:,:),[3])';
    
    imagesc(meanimage)
    colorbar
    timenow=now;
    import matlab.io.*
    utcshift=7/24;
    filename = ['b_d0w0m0q0_' datestr(timenow+utcshift,'yyyymmdd_HHMMSS') ];
    fullfilename=[ getuserdir filename];
    fptr = fits.createFile([fullfilename '.fits']);
    
    fits.createImg(fptr,'int32',[16 16]);
    %fitsmode='overwrite';
    img=int32(meanimage);
    fits.writeImg(fptr,img)
    fits.closeFile(fptr);
    
    % IntensmaxQ2(nima)=max(ima(1:8,1:8),[],'all');
    IntensmeanQ1=[IntensmeanQ1 mean(meanimage(1:8,1:8),[1 2])];
    %   IntensmaxQ3(nima)=max(ima(1:8,9:16),[],'all');
    IntensmeanQ2=[IntensmeanQ2 mean(meanimage(1:8,9:16),[1 2])];
    %  IntensmaxQ1(nima)=max(ima(9:16,1:8),[],'all');
    IntensmeanQ0=[IntensmeanQ0 mean(meanimage(9:16,1:8),[1 2])];
    %   IntensmaxQ4(nima)=max(ima(9:16,9:16),[],'all');
    IntensmeanQ3=[IntensmeanQ3 mean(meanimage(9:16,9:16),[1 2])];
    