%HVequaliz
%adjustparams
exper='illuminated dark box II '
convcps=400.;

%%light stuffs
RickLEDV=[0 1.7 1.8 1.9 2. 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0 3.5 4. 4.5 5. 6. 7.];
ThorlabsnW=[0 0.3 0.6 1. 1.4 1.9 2.4 3. 3.5 4.1 4.7 5.4 6.0 6.6 7.3 10.6 14.1 17.7 21.4 29.1 37.];

RickLEDV=[0   2.   2.5   3.0   4. 4.5 5. 6. 7.   10.   15. 20. 23.];
ThorlabsnW=[0  1.4   4.1  7.3   14.1 17.7 21.4 29.1 35. 57.3 96. 136. 160.];
ThorlabsnWND=0.01*ThorlabsnW;

ThorlabsnWNDpix=(1/((pi*(9.5/2)^2)/9.))*ThorlabsnWND;
h=6.62607e-34;c=2.998e8;lam=0.633e-6;
ThorlabsnWNDpixphot=(lam/h/c) *(1e-9)* ThorlabsnWNDpix;
qe=0.22;
ThorlabsnWNDpixcnt=qe*ThorlabsnWNDpixphot;

%Rick LED in CW continuous
quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config.txt']);
 %set gain
 gaintab=33;
   for pp=0:63 
        [ig,indexgain]=ismember(['GAIN' num2str(pp)] ,quaboconfig);

        quaboconfig(indexgain,indcol+1)={['0x' dec2hex(gaintab(1))]};
     end

IntensmeanQ0=[];IntensmeanQ1=[];IntensmeanQ2=[];IntensmeanQ3=[];IntensmeanQ8=[];

  realhvQ0=[];realhvQ1=[];realhvQ2=[];realhvQ3=[];
realcurQ0=[];realcurQ1=[];realcurQ2=[];realcurQ3=[];
temp1=[];temp2=[]; 
timecomp=[];

szT=numel(RickLEDV);
allima=zeros(16,16,szT);
for kk=1:szT
%disp(['Change led voltage to V:' num2str(HVThorNDnW(kk))])
 %     x=input(['Change led voltage to V:' num2str(HVThorNDnW(kk))])
 disp(['Set the LED HV to [V]:' num2str(RickLEDV(kk))])
 timepause=2;
 disp([num2str( timepause*(szT-kk)) 's left...'])
    pause(timepause)
    images=grabimages(10,1,1);
    figure
    meanimage=mean(images(:,:,:),[3])';
    allima(:,:,kk)=meanimage;
    
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
    
    % IntensmaxQ2(nima)=max(ima(1:8,1:8),[],'all');
    IntensmeanQ1=[IntensmeanQ1 median(meanimage(1:8,1:8),[1 2])];
    %   IntensmaxQ3(nima)=max(ima(1:8,9:16),[],'all');
    IntensmeanQ2=[IntensmeanQ2 median(meanimage(1:8,9:16),[1 2])];
    %  IntensmaxQ1(nima)=max(ima(9:16,1:8),[],'all');
    IntensmeanQ0=[IntensmeanQ0 median(meanimage(9:16,1:8),[1 2])];
    %   IntensmaxQ4(nima)=max(ima(9:16,9:16),[],'all');
    IntensmeanQ3=[IntensmeanQ3 median(meanimage(9:16,9:16),[1 2])];
      %   IntensmaxQ4(nima)=max(ima(9:16,9:16),[],'all');
    IntensmeanQ8=[IntensmeanQ8 meanimage(1,7)];
    
    try
        hk = getlastHK;
    catch
        pause(1)
        hk = getlastHK;
    end
    realhvQ0=[realhvQ0 hk.hvmon0];
    realhvQ1=[realhvQ1 hk.hvmon1];
    realhvQ2=[realhvQ2 hk.hvmon2];
    realhvQ3=[realhvQ3 hk.hvmon3];
    realcurQ0=[realcurQ0 hk.ihvmon0];
    realcurQ1=[realcurQ1 hk.ihvmon1];
    realcurQ2=[realcurQ2 hk.ihvmon2];
    realcurQ3=[realcurQ3 hk.ihvmon3];
  
temp1=[temp1 hk.temp1];temp2=[temp2 hk.temp2]; 
timecomp=[timecomp hk.timecomp];
    
close all

   figure('Position',[10 10 1200 800])
set(gcf,'Color','w')


subplot(2,3,1)
%title([exper ', Quabo SN009, ' datestr(timecomp(1),'yyyy-mm-dd HH:MM') ', Imaging DAC1:' num2str(dactabbest) ' Gain:'  num2str(gaintab)])
hold on
plot(24.*3600*(timecomp-timecomp(1)),realhvQ0,'b-+')
plot(24.*3600*(timecomp-timecomp(1)),realhvQ1,'r-+')
plot(24.*3600*(timecomp-timecomp(1)),realhvQ2,'g-+')
plot(24.*3600*(timecomp-timecomp(1)),realhvQ3,'m-+')
hold off
xlabel('Time in s')
ylabel('HV [V]')
legend(['Q0, (V_f-V_i=' num2str(realhvQ0(end)-realhvQ0(1),'%5.4f') 'V)'],...
    ['Q1, (V_f-V_i=' num2str(realhvQ1(end)-realhvQ1(1),'%5.4f') 'V)'],...
    ['Q2, (V_f-V_i=' num2str(realhvQ2(end)-realhvQ2(1),'%5.4f') 'V)'],...
    ['Q3, (V_f-V_i=' num2str(realhvQ3(end)-realhvQ3(1),'%5.4f') 'V)'])

subplot(2,3,2)
hold on
plot(24.*3600*(timecomp-timecomp(1)),realcurQ0,'b-+')
plot(24.*3600*(timecomp-timecomp(1)),realcurQ1,'r-+')
plot(24.*3600*(timecomp-timecomp(1)),realcurQ2,'g-+')
plot(24.*3600*(timecomp-timecomp(1)),realcurQ3,'m-+')
hold off
xlabel('Time in s')
ylabel('I [\muA]')
legend(['Q0, (I_f-I_i=' num2str(realcurQ0(end)-realcurQ0(1),'%5.2f') '\muA)'],...
    ['Q1, (I_f-I_i=' num2str(realcurQ1(end)-realcurQ1(1),'%5.2f') '\muA)'],...
    ['Q2, (I_f-I_i=' num2str(realcurQ2(end)-realcurQ2(1),'%5.2f') '\muA)'],...
    ['Q3, (I_f-I_i=' num2str(realcurQ3(end)-realcurQ3(1),'%5.2f') '\muA)'])

subplot(2,3,4)
hold on
plot(24.*3600*(timecomp-timecomp(1)),temp1,'b-+')
plot(24.*3600*(timecomp-timecomp(1)),temp2,'r-+')
hold off
xlabel('Time in s')
ylabel('Temperature [C]')
legend(['TMP125, (T_f-T_i=' num2str(temp1(end)-temp1(1),'%5.2f') '\circ C)'],...
    ['Temp. FPGA, (T_f-T_i=' num2str(temp2(end)-temp2(1),'%5.2f') '\circ C)'])

subplot(2,3,5)
hold on
plot(24.*3600*(timecomp-timecomp(1)),convcps*IntensmeanQ0,'b-+')
plot(24.*3600*(timecomp-timecomp(1)),convcps*IntensmeanQ1,'r-+')
plot(24.*3600*(timecomp-timecomp(1)),convcps*IntensmeanQ2,'g-+')
plot(24.*3600*(timecomp-timecomp(1)),convcps*IntensmeanQ3,'m-+')
plot(24.*3600*(timecomp-timecomp(1)),convcps*IntensmeanQ8,'k-+')
hold off
xlabel('Time in s')
ylabel('Median intensity [cps]')
legend(['Q0, (cps_f-cps_i=' num2str(convcps*IntensmeanQ0(end)-convcps*IntensmeanQ0(1),'%5.1f') 'cps)'],...
    ['Q1, (cps_f-cps_i=' num2str(convcps*IntensmeanQ1(end)-convcps*IntensmeanQ1(1),'%5.1f') 'cps)'],...
    ['Q2, (cps_f-cps_i=' num2str(convcps*IntensmeanQ2(end)-convcps*IntensmeanQ2(1),'%5.1f') 'cps)'],...
    ['Q3, (cps_f-cps_i=' num2str(convcps*IntensmeanQ3(end)-convcps*IntensmeanQ3(1),'%5.1f') 'cps)'])

subplot(2,3,3)
removedark=1
if removedark==0
GQ0=(1e-6/64/1.6e-19/convcps)*(realcurQ0.*(IntensmeanQ0.^-1));
GQ1=(1e-6/64/1.6e-19/convcps)*(realcurQ1.*(IntensmeanQ1.^-1));
GQ2=(1e-6/64/1.6e-19/convcps)*(realcurQ2.*(IntensmeanQ2.^-1));
GQ3=(1e-6/64/1.6e-19/convcps)*(realcurQ3.*(IntensmeanQ3.^-1));
else
   indm=1;% min(4,kk);
GQ0=(1e-6/64/1.6e-19/convcps)*((realcurQ0-mean(realcurQ0(1:indm))).*(IntensmeanQ0.^-1));
GQ1=(1e-6/64/1.6e-19/convcps)*((realcurQ1-mean(realcurQ1(1:indm))).*(IntensmeanQ1.^-1));
GQ2=(1e-6/64/1.6e-19/convcps)*((realcurQ2-mean(realcurQ2(1:indm))).*(IntensmeanQ2.^-1));
GQ3=(1e-6/64/1.6e-19/convcps)*((realcurQ3-mean(realcurQ3(1:indm))).*(IntensmeanQ3.^-1));
GQ8=(1e-6/64/1.6e-19/convcps)*((realcurQ1-mean(realcurQ1(1:indm))).*(IntensmeanQ8.^-1));
end
hold on
plot(24.*3600*(timecomp-timecomp(1)),GQ0,'b-+')
plot(24.*3600*(timecomp-timecomp(1)),GQ1,'r-+')
plot(24.*3600*(timecomp-timecomp(1)),GQ2,'g-+')
plot(24.*3600*(timecomp-timecomp(1)),GQ3,'m-+')
plot(24.*3600*(timecomp-timecomp(1)),GQ8,'k-+')
hold off
xlabel('Time in s')
ylabel(['Gain at DAC1'  ' [=I/nbpix/cps/q(e-)]'])
legend(['Q0, (G_f-G_i=' num2str(GQ0(end)-GQ0(1),'%5.1f') ')'],...
    ['Q1, (G_f-G_i=' num2str(GQ1(end)-GQ1(1),'%5.1f') ')'],...
    ['Q2, (G_f-G_i=' num2str(GQ2(end)-GQ2(1),'%5.1f') ')'],...
    ['Q3, (G_f-G_i=' num2str(GQ3(end)-GQ3(1),'%5.1f') ')'])

subplot(2,3,6)
% GQ0=(1e-6/64/1.6e-19/convcps)*(realcurQ0.*(IntensmeanQ0.^-1));
% GQ1=(1e-6/64/1.6e-19/convcps)*(realcurQ1.*(IntensmeanQ1.^-1));
% GQ2=(1e-6/64/1.6e-19/convcps)*(realcurQ2.*(IntensmeanQ2.^-1));
% GQ3=(1e-6/64/1.6e-19/convcps)*(realcurQ3.*(IntensmeanQ3.^-1));
% [sortedt, sortedind]=sort(temp1);
% sortedGQ0=GQ0(sortedind);
% hold on
% plot(temp1,GQ0(sortedind),'b-+')
% plot(temp1,GQ1(sortedind),'r-+')
% plot(temp1,GQ2(sortedind),'g-+')
% plot(temp1,GQ3(sortedind),'m-+')
% hold off
% xlabel('Temperature (TMP125) [\circ C]')
% ylabel(['Gain at DAC1' ' [I/nbpix/cps/q(e-)]'])
% legend(['Q0'],...
%     ['Q1'],...
%     ['Q2'],...
%     ['Q3'])


%figure
plot(ThorlabsnWNDpix(1:kk),convcps*IntensmeanQ8,'-+')
xlabel('Light Intensity [nW/pix]')
ylabel(['CPS'])
end



datenow=datestr(now,'yymmddHHMMSS');

%open txt file of temperature el-enviroPad-TC
%% Initialize variables.
filename = 'C:\Users\jerome\Documents\panoseti\DATA\temperature\LogFile_0009.txt';
LogFile =importTemperaturefile(filename);
tempbox=cell2mat(LogFile(:,3))
%tempbox=cell2mat(LogFile(1:2400,3))
%tempbox=cell2mat(LogFile(1000:end-900,3))
%get time
timebox=zeros(1,numel(tempbox));
for jj=1:numel(tempbox)
aa=LogFile{jj, 2};
ab=datenum(cell2mat(aa),'mm/dd/yyyy HH:MM:SS');
timebox(jj)=ab;

end
subplot(2,3,4)
cla
hold on
plot(24.*3600*(timecomp-timecomp(1)),temp1,'b-+')
plot(24.*3600*(timecomp-timecomp(1)),temp2,'r-+')
plot(24.*3600*(timebox-timebox(1)),tempbox,'g-+')
hold off
xlabel('Time in s')
ylabel('Temperature [C]')
%legend('TMP125','Temp. FPGA','Ambient temp inside dark box')
legend(['TMP125, (T_f-T_i=' num2str(temp1(end)-temp1(1),'%5.2f') '\circ C)'],...
    ['Temp. FPGA, (T_f-T_i=' num2str(temp2(end)-temp2(1),'%5.2f') '\circ C)'],...
    ['Ambient temp, (T_f-T_i=' num2str(tempbox(end)-tempbox(1),'%5.2f') '\circ C)'])



     saveas(gcf,['testTemperature' datenow '.png'])
   saveas(gcf,['testTemperature' datenow '.fig'])
   
   save(['testTemperature' datenow '.mat'])
   
%    IntensmeanQ1(end-10:end)=[];
%    IntensmeanQ2(end-10:end)=[];
%    IntensmeanQ3(end-10:end)=[];
%    IntensmeanQ0(end-10:end)=[];
%     realhvQ0(end-10:end)=[];realhvQ1(end-10:end)=[];realhvQ2(end-10:end)=[];realhvQ3(end-10:end)=[];
% realcurQ0(end-10:end)=[];realcurQ1(end-10:end)=[];realcurQ2(end-10:end)=[];realcurQ3(end-10:end)=[];
% temp1(end-10:end)=[];temp2(end-10:end)=[]; 
% timecomp(end-10:end)=[];
