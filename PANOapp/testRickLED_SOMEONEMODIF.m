
%Rick LED in CW continuous
HVThorNDnW=[1.4 1.5 1.6 1.7 1.8 1.9 2.0];
ThorNDnW=[0.1 0.6 7 25.8 55 91.5 132.];
IntensmeanQ0=[];IntensmeanQ1=[];IntensmeanQ2=[];IntensmeanQ3=[];

szT=numel(ThorNDnW);
allima=zeros(16,16,szT);
for kk=1:szT
disp(['Change led voltage to V:' num2str(HVThorNDnW(kk))])
      x=input(['Change led voltage to V:' num2str(HVThorNDnW(kk))])
    
    images=grabimages(10,1,1);
    
    figure
    meanimage=mean(images(:,:,:),[3])';
    allima(:,:,kk)=meanimage;
    
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
    IntensmeanQ1=[IntensmeanQ1 median(meanimage(1:8,1:8),[1 2])];
    %   IntensmaxQ3(nima)=max(ima(1:8,9:16),[],'all');
    IntensmeanQ2=[IntensmeanQ2 median(meanimage(1:8,9:16),[1 2])];
    %  IntensmaxQ1(nima)=max(ima(9:16,1:8),[],'all');
    IntensmeanQ0=[IntensmeanQ0 median(meanimage(9:16,1:8),[1 2])];
    %   IntensmaxQ4(nima)=max(ima(9:16,9:16),[],'all');
    IntensmeanQ3=[IntensmeanQ3 median(meanimage(9:16,9:16),[1 2])];
end


convcps=400.;
figure
set(gcf,'Color','w')
subplot(1,2,1)
hold on
plot(ThorNDnW,convcps*IntensmeanQ0,'b-+')
plot(ThorNDnW,convcps*IntensmeanQ1,'r-+')
plot(ThorNDnW,convcps*IntensmeanQ2,'g-+')
plot(ThorNDnW,convcps*IntensmeanQ3,'m-+')
hold off
xlabel('LED brightness before ND filter, as meas. by Thorlabs powermeter [nW]')
ylabel('Median intensity [cps]')
legend('Q0','Q1','Q2','Q3')

subplot(1,2,2)
hold on
for ppx=1:16
    for ppy=1:16
    plot(ThorNDnW,convcps*squeeze(allima(ppx,ppy,:)),'-')
    end
end
hold off
xlabel('LED brightness before ND filter, as meas. by Thorlabs powermeter [nW]')
ylabel('Mean intensity [cps]')

ND=0.01;
ratiosurf=(3.^2)/(pi*(4.5)^2)

lam=562e-9 %nm
enerlam=6.626e-34 * 3e8/lam
conv2phs=(1e-9)*ND*ratiosurf/(enerlam)

figure
set(gcf,'Color','w')
subplot(1,2,1)
hold on
plot(conv2phs*ThorNDnW,convcps*IntensmeanQ0,'b-+')
plot(conv2phs*ThorNDnW,convcps*IntensmeanQ1,'r-+')
plot(conv2phs*ThorNDnW,convcps*IntensmeanQ2,'g-+')
plot(conv2phs*ThorNDnW,convcps*IntensmeanQ3,'m-+')
hold off
xlabel('LED brightness after ND filter, detector area-corrected [Nb photons/s]')
ylabel('Median intensity [cps]')
legend('Q0','Q1','Q2','Q3')

subplot(1,2,2)
hold on
for ppx=1:16
    for ppy=1:16
    plot(conv2phs*ThorNDnW,convcps*squeeze(allima(ppx,ppy,:)),'-')
    end
end
hold off
xlabel('LED brightness after ND filter, detector area-corrected [Nb photons/s]')
ylabel('Mean intensity [cps]')

%save('testrickled.mat')