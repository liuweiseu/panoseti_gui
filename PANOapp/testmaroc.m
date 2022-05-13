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
