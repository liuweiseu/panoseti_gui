close all
%meth: 0 tend to HV Hamamatsu
%      1 tend to given nb cnts
meth=0
optimalHV0=54.2;optimalHV1=54.2;optimalHV2=54.2;optimalHV3=54.2;
maxhv=60.1;
resQ=0.02;%resQ=5;
costQ0=10*resQ;costQ1=10*resQ;costQ2=10*resQ;costQ3=10*resQ;
optimalcnt=10;%for meth=1
HVinc=0.02;
IntensmeanQ0=[];IntensmeanQ1=[];IntensmeanQ2=[];IntensmeanQ3=[];
realhvQ0=[];realhvQ1=[];realhvQ2=[];realhvQ3=[];
realcurQ0=[];realcurQ1=[];realcurQ2=[];realcurQ3=[];

init=0
if init==1
quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config.txt']);

% init the board?
disp('Init Marocs...')
sendconfig2Maroc(quaboconfig)
disp('Waiting 3s...')
pause(3)
disp('Init Acq...')
sentacqparams2board(quaboconfig)
disp('Waiting 3s...')
pause(3)
end
disp('Init HV...')
sendHV(quaboconfig)
disp('Waiting 3s...')
pause(3)

hk = getlastHK


figure
while (abs(costQ0)>resQ) || (abs(costQ1)>resQ) || (abs(costQ2)>resQ) || (abs(costQ3)>resQ)
    pause(6)
    
    images=grabimages(10,1,1);
    
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
    
    Vref=1250.;
    [ia,index]=ismember('HV_0 ',quaboconfig);
    HV_0=str2num(quaboconfig(index,2)) ;
    HVrV_0=  (Vref*(10/(65536*158)))*HV_0;
    
    [ia,index]=ismember('HV_1 ',quaboconfig);
    HV_1=str2num(quaboconfig(index,2)) ;
    HVrV_1=  (Vref*(10/(65536*158)))*HV_1;
    
    [ia,index]=ismember('HV_2 ',quaboconfig);
    HV_2=str2num(quaboconfig(index,2)) ;
    HVrV_2=  (Vref*(10/(65536*158)))*HV_2;
    
    [ia,index]=ismember('HV_3 ',quaboconfig);
    HV_3=str2num(quaboconfig(index,2)) ;
    HVrV_3=  (Vref*(10/(65536*158)))*HV_3;
    
    tabnames={'HV_0 ','HV_1 ','HV_2 ',...
        'HV_3 '};
    
    hk = getlastHK;
    realhvQ0=[realhvQ0 hk.hvmon0];
    realhvQ1=[realhvQ1 hk.hvmon1];
    realhvQ2=[realhvQ2 hk.hvmon2];
    realhvQ3=[realhvQ3 hk.hvmon3];
    realcurQ0=[realcurQ0 hk.ihvmon0];
    realcurQ1=[realcurQ1 hk.ihvmon1];
    realcurQ2=[realcurQ2 hk.ihvmon2];
    realcurQ3=[realcurQ3 hk.ihvmon3];
    
    if meth==0
        
        costQ0=(realhvQ0(end)-optimalHV0);
        costQ1=(realhvQ1(end)-optimalHV1);
        costQ2=(realhvQ2(end)-optimalHV2);
        costQ3=(realhvQ3(end)-optimalHV3);
    elseif meth==1
        costQ0=(IntensmeanQ0(end)-optimalcnt);
        costQ1=(IntensmeanQ1(end)-optimalcnt);
        costQ2=(IntensmeanQ2(end)-optimalcnt);
        costQ3=(IntensmeanQ3(end)-optimalcnt);
    end
    
    if (hk.hvmon0< maxhv) || (hk.hvmon1< maxhv) || (hk.hvmon2< maxhv) || (hk.hvmon3< maxhv)
        
        
        
        changeHV0=0;
        if (abs(costQ0)>resQ)
            newHV0=HVrV_0-sign(costQ0)*HVinc;
            changeHV0=1;
        end
        changeHV1=0;
        if (abs(costQ1)>resQ)
            newHV1=HVrV_1-sign(costQ1)*HVinc;
            changeHV1=1;
        end
        changeHV2=0;
        if (abs(costQ2)>resQ)
            newHV2=HVrV_2-sign(costQ2)*HVinc;
            changeHV2=1;
        end
        changeHV3=0;
        if (abs(costQ3)>resQ)
            newHV3=HVrV_3-sign(costQ3)*HVinc;
            changeHV3=1;
        end
        
        disp(['Req. HV0:' num2str(HVrV_0) '(' num2str(HV_0) ')' ...
            ' HV1:' num2str(HVrV_1) '(' num2str(HV_1) ')' ...
            ' HV2:' num2str(HVrV_2) '(' num2str(HV_2) ')' ...
            ' HV3:' num2str(HVrV_3) '(' num2str(HV_3) ')'])
        disp(['Real HV0:' num2str(hk.hvmon0) ' HV1:' num2str(hk.hvmon1) ' HV2:' num2str(hk.hvmon2) ' HV3:' num2str(hk.hvmon3)])
        disp(['Cnts Q0:' num2str(IntensmeanQ0(end))...
            ' Q1:' num2str(IntensmeanQ1(end))  ' Q2:' num2str(IntensmeanQ2(end))  ' Q3:' num2str(IntensmeanQ3(end))])
        
        %oldvalue=quaboconfig(index,2);
        if isnumeric(newHV0) && (newHV0>0) && (newHV0<maxhv) && ...
                isnumeric(newHV1) && (newHV1>1) && (newHV1<maxhv) && ...
                isnumeric(newHV2) && (newHV0>2) && (newHV2<maxhv) && ...
                isnumeric(newHV3) && (newHV0>3) && (newHV3<maxhv)
            % (1/(Vref*(10/(65536*158))))*
            [ia,index]=ismember('HV_0 ',quaboconfig);
            quaboconfig(index,2)=string(floor(    (1/(Vref*(10/(65536*158))))*newHV0     ));
            [ia,index]=ismember('HV_1 ',quaboconfig);
            quaboconfig(index,2)=string(floor(    (1/(Vref*(10/(65536*158))))*newHV1     ));
            [ia,index]=ismember('HV_2 ',quaboconfig);
            quaboconfig(index,2)=string(floor(    (1/(Vref*(10/(65536*158))))*newHV2     ));
            [ia,index]=ismember('HV_3 ',quaboconfig);
            quaboconfig(index,2)=string(floor(    (1/(Vref*(10/(65536*158))))*newHV3     ));
            %quaboconfig(index,2)=string(floor(    (65536/75)*newData     ));
            
            disp(['Sign Q0:' num2str(-changeHV0*sign(costQ0)) ...
                'Sign Q1:'  num2str(-changeHV1*sign(costQ1)) ...
                'Sign Q2:'  num2str(-changeHV2*sign(costQ2)) ...
                'Sign Q3:'  num2str(-changeHV3*sign(costQ3))])
            disp(['Send new HV0:' num2str(newHV0) ' (' num2str(floor(    (1/(Vref*(10/(65536*158))))*newHV0     )) ')' ...
                ' new HV1:' num2str(newHV1) ' (' num2str(floor(    (1/(Vref*(10/(65536*158))))*newHV1     )) ')' ...
                ' new HV2:' num2str(newHV2) ' (' num2str(floor(    (1/(Vref*(10/(65536*158))))*newHV2     )) ')' ...
                ' new HV3:' num2str(newHV3) ' (' num2str(floor(    (1/(Vref*(10/(65536*158))))*newHV3     )) ')' ...
                ])
            if (changeHV0+changeHV1+changeHV2+changeHV3>0)
                sendHV(quaboconfig)
            end
        end
        
    end
    
end

%plot HVs, current, cnts
figure
set(gcf, 'Color','w')
subplot(1,3,1)
hold on
plot(IntensmeanQ0,'b')
plot(IntensmeanQ1,'r')
plot(IntensmeanQ2,'g')
plot(IntensmeanQ3,'m')
hold off
xlabel('iter#')
ylabel('Mean intensity')
legend('Q0','Q1','Q2','Q3')

subplot(1,3,2)
hold on
plot(realhvQ0,'b')
plot(realhvQ1,'r')
plot(realhvQ2,'g')
plot(realhvQ3,'m')
hold off
xlabel('iter#')
ylabel('HV [V]')
legend('Q0','Q1','Q2','Q3')

subplot(1,3,3)
hold on
plot(realcurQ0,'b')
plot(realcurQ1,'r')
plot(realcurQ2,'g')
plot(realcurQ3,'m')
hold off
xlabel('iter#')
ylabel('I [\muA]')
legend('Q0','Q1','Q2','Q3')

datenow=datestr(now,'yymmdd_HHMMSS');
   saveas(gcf,['HVinitVop' datenow '.png'])
   saveas(gcf,['HVinitVop' datenow '.fig'])
%Real HV0:54.9956 HV1:54.7687 HV2:54.9582 HV3:54.59
