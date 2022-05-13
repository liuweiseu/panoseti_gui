% instrreset 
% clear all
close all
images=grabimages(100,1,1);
 
 meanimage=mean(images(:,:,:),[3])
 figure
 imagesc(meanimage)
  timenow=now;
   import matlab.io.*
            utcshift=7/24;
         filename = ['b_d0w0m0q0_' datestr(timenow+utcshift,'yyyymmdd_HHMMSS') ];
         fullfilename=[ getuserdir '\' filename];
   fptr = fits.createFile([fullfilename '.fits']);
                                
                                fits.createImg(fptr,'double',[16 16]);
                                %fitsmode='overwrite';
                                img=double(meanimage);
                            fits.writeImg(fptr,img)
                                fits.closeFile(fptr);
 