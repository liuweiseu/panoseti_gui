%comparison baselines taken 5min apart
im1=fitsread('C:\Users\jerome\Documentspanoseti\baselines\b_d0w0m0q0_20190725_180240.fits');
im2=fitsread('C:\Users\jerome\Documentspanoseti\baselines\b_d0w0m0q0_20190725_181102.fits');
im3=fitsread('C:\Users\jerome\Documentspanoseti\baselines\b_d0w0m0q0_20190725_181124.fits');
im4=fitsread('C:\Users\jerome\Documentspanoseti\baselines\b_d0w0m0q0_20190725_181644.fits');
im5=fitsread('C:\Users\jerome\Documentspanoseti\baselines\b_d0w0m0q0_20190725_181656.fits');
im6=fitsread('C:\Users\jerome\Documentspanoseti\baselines\b_d0w0m0q0_20190725_181705.fits');
im7=fitsread('C:\Users\jerome\Documentspanoseti\baselines\b_d0w0m0q0_20190725_181711.fits');
im8=fitsread('C:\Users\jerome\Documentspanoseti\baselines\b_d0w0m0q0_20190725_181728.fits');
im9=fitsread('C:\Users\jerome\Documentspanoseti\baselines\b_d0w0m0q0_20190725_181737.fits');
im10=fitsread('C:\Users\jerome\Documentspanoseti\baselines\b_d0w0m0q0_20190725_181743.fits');
im11=fitsread('C:\Users\jerome\Documentspanoseti\baselines\b_d0w0m0q0_20190725_181747.fits');

% b_d0w0m0q0_20190725_180731
% b_d0w0m0q0_20190725_181102
% b_d0w0m0q0_20190725_181124
% b_d0w0m0q0_20190725_181644
% b_d0w0m0q0_20190725_181656
% b_d0w0m0q0_20190725_181705
% b_d0w0m0q0_20190725_181711
% b_d0w0m0q0_20190725_181728
% b_d0w0m0q0_20190725_181737
% b_d0w0m0q0_20190725_181743
% b_d0w0m0q0_20190725_181747

figure
imagesc(im10-im11)
title('Difference between two baselines taken 5min apart.')
colorbar

     datenow=datestr(now,'yymmddHHMMSS');
        saveas(gcf,['BaselineDiff'  '_' datenow '.png'])
        saveas(gcf,['BaselineDiff'  '_' datenow '.fig'])
        
        imtot=cat(3,im1, im2, im3, im4, im5, im6, im7, im8, im9, im10, im11);
   stdimage=std(imtot(:,:,:),0,[3])';
   figure
imagesc(stdimage)
title('Standard deviation of 11 baselines taken within 5mins.')
colorbar
  datenow=datestr(now,'yymmddHHMMSS');
        saveas(gcf,['BaselineSTD'  '_' datenow '.png'])
        saveas(gcf,['BaselineSTD'  '_' datenow '.fig'])
        