close all
% if ~exist('s','var')
%     s = serial('COM6','BaudRate',9600);
%     fopen(s)
% end
exposurestr='';
nbimperdac=1000;
dactab=[215:2:235 ];
%  dactab=[250:5:290 ];
gaintabtab=[66];%11:31 %1:10:121;
%currtabExp=[0. round(logspace(0,log10(4000),10))];
currtabExp=[0.];
%currtabExp=[0. ];
maxtesttime = 60;

expstr='';
shaperstr='Bipolar fs; ';
maskstr='All-pixels-masked-excepted-one [7,1]; ';
IntensmeanQ9G=zeros(numel(dactab),numel(gaintabtab),numel(currtabExp));

realhvQ0=[];realhvQ1=[];realhvQ2=[];realhvQ3=[];
realcurQ0=[];realcurQ1=[];realcurQ2=[];realcurQ3=[];
temp1=[];temp2=[];
timecomp=[];

cc=1;
%for cc=1:numel(currtabExp)
disp(['Testing Curr:' num2str(currtabExp(cc))])
disp(['Setting: U' num2str(currtabExp(cc),'%05g') ';'])
%setADU(['WR' num2str(currtab(ii),'%05g')]);
% setJimPS(s,currtabExp(cc))
disp('Changing Light intensity. Waiting 15s for HV to be adjusted...')

%     if cc>1
%     pause(15)
%     end

quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config.txt']);
[ig,indexstimon]=ismember(['STIMON '] ,quaboconfig);
quaboconfig(indexstimon,2)={"0"};
pausetime=0.5;
indcol=1:4;

[ig,indexacqmode]=ismember(['ACQMODE '] ,quaboconfig);
quaboconfig(indexacqmode,2)={"0x01"};

[ig,indexhold1]=ismember(['HOLD1 '] ,quaboconfig);
[ig,indexhold2]=ismember(['HOLD2 '] ,quaboconfig);



%

% [ig,indexacqint]=ismember(['ACQINT '] ,quaboconfig);
% acqint=(1e-5)*str2num(quaboconfig(indexacqint,2));
% exposurestr=['Exposure time [ms]:' num2str(1000*acqint,'%3.3g')];
normcps=1; %/acqint;
%set gain


for  gainkk=1:numel(gaintabtab)
    gaintab=gaintabtab(gainkk);
    for pp=0:63
        [ig,indexgain]=ismember(['GAIN' num2str(pp)] ,quaboconfig);
        
        quaboconfig(indexgain,indcol+1)={['0x' dec2hex(gaintab(1))]};
    end
    
    
    %set masks MASKOR1_
    mask=0;
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
    
    
    %set masks CHANMASK_
    maskph=0;
    if maskph==0
        for pp=0:7
            [ig,indexmask]=ismember(['CHANMASK_' num2str(pp) ' '] ,quaboconfig);
            quaboconfig(indexmask,1+1)={['0x0']};
        end
    else
        for pp=0:7
            [ig,indexmask]=ismember(['CHANMASK_' num2str(pp) ' '] ,quaboconfig);
            quaboconfig(indexmask,1+1)={['0xFFFFFFFF']};
        end
        [ig,indexmask]=ismember(['CHANMASK_0 '] ,quaboconfig);
        % quad=2;
        quaboconfig(indexmask,1+1)={['0xEFFFFFFF']};
        
    end
    
    
    % init the board?
    disp('Init Marocs...')
    sendconfig2Maroc(quaboconfig)
    disp('Waiting 3s...')
    pause(3)
    disp('Init Acq...')
    %  sentacqparams2board(quaboconfig)
    disp('Waiting 3s...')
    pause(3)
    
    %dactab=[ 240 250 260 270 280 290 300 305 310 320 350 400 450 500];
    %dactab=[288 290 292 294 296 298 300 305 310 320 350 400 450 500];
    %dactab=[550:1:650 ];
    
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
    timetested=0;
    timetestedzero=tic;
    
    IntensmeanQ8GH=[];
    % IntensmeanQ8GSTDH=[IntensmeanQ8GSTDH; IntensmeanQ8GSTD];;
    IntenspixH=[];
    IntenspixSTDH=[];
     IntenspixHB=[];
    IntenspixSTDHB=[];
    
    pause(3)
    for hh=0:15 %0:15
        quaboconfig(indexhold1,2)={num2str(hh)};
        quaboconfig(indexhold2,2)={num2str(hh)};
        sentacqparams2board(quaboconfig)
        disp('Waiting 1s...')
         pause(1)
         sentacqparams2board(quaboconfig)
         disp('Waiting 1s...')
         pause(1)
         sentacqparams2board(quaboconfig)
         disp('Waiting 1s...')
         pause(1)
         sentacqparams2board(quaboconfig)
         disp('Waiting 1s...')
         pause(1)
         sentacqparams2board(quaboconfig)
         disp('Waiting 1s...')
         load gong.mat; gong = audioplayer(y, Fs); play(gong);
         pause(1)
        % IntensmeanQ9G(dd,gainkk,cc)=measframerate(10,1,1);
        nbtrig=0;
        Intenspix=[];
        IntenspixSTD=[];
          IntenspixB=[];
        IntenspixSTDB=[];
        IntensmeanQ8G=[];
        tic;
        %    while timetested<maxtesttime
        for dd=1:numel(dactab)
            quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactab(dd))]};
            disp(['Sending Maroc comm...DAC1:' num2str(dactab(dd)) ' Gain:' num2str((gaintabtab(gainkk))) ' (' num2str(gainkk) '/' num2str(numel(gaintabtab)) ')' ...
                'Light I [step]: ' num2str(cc) '/' num2str(numel(currtabExp))])
            sendconfig2Maroc(quaboconfig)
            pause(3)
            
            images=grabimages(nbimperdac,1,1);
        
            meanimage=mean(images(:,:,:),[3])';
            stdimage=std(images(:,:,:),0,[3])';
            toctoc=toc;
            timetested=toctoc;
            if sum(images,'all')>0
                Intenspix=[Intenspix; meanimage(1,7)];
                IntenspixSTD=[IntenspixSTD; stdimage(1,7)];
                IntenspixB=[IntenspixB; meanimage(3,7)];
                IntenspixSTDB=[IntenspixSTDB; stdimage(3,7)];
                [Ma, indmlin] =max(meanimage);
                [Ma2, indmcol] =max(Ma);
                disp(['pix ' num2str(indmlin(indmcol)) ' ' num2str(indmcol)])
                IntensmeanQ8G=[IntensmeanQ8G; Ma2];
                
                nbtrig=nbtrig+1
                if Ma2<meanimage(1,7)
                    disp('Stop')
                end
            end
        end
        
        
        
        
        figure
        hold on
        plot(dactab,IntensmeanQ8G,'ro-')
        errorbar(dactab,Intenspix,IntenspixSTD)
         errorbar(dactab,IntenspixB,IntenspixSTDB)
        box on
        
        hold off
        %nbimperdac
        xlabel('DAC1 value')
        ylabel(' mean ADC value')
        title(['Gain:' num2str(gaintab(1)) ' Dark. All-pix-masked-exc.-one. Errorbar STD ' num2str(nbimperdac) ' images/DAC1pts'])
        legend('Max intensity in trig. images (diff. pixel#)','Triggering pix', 'other pixel')
        set(gca, 'YScale','log')
        datenow=datestr(now,'yymmddHHMMSS');
        saveas(gcf,['ADC_DACHOLD' num2str(hh) '_' 'Gain' num2str(gaintab(1))  '_' datenow '_nomask.png'])
        saveas(gcf,['ADC_DACHOLD' num2str(hh) '_' 'Gain' num2str(gaintab(1)) '_' datenow '_nomask.fig'])
        
   
    IntensmeanQ8GH=[IntensmeanQ8GH IntensmeanQ8G];
    % IntensmeanQ8GSTDH=[IntensmeanQ8GSTDH; IntensmeanQ8GSTD];;
    IntenspixH=[IntenspixH Intenspix];
    IntenspixSTDH=[IntenspixSTDH IntenspixSTD];
     IntenspixHB=[IntenspixHB IntenspixB];
    IntenspixSTDHB=[IntenspixSTDHB IntenspixSTDB];
     end
end

figure
hold on
leg={};
for hhh=0:15
    %plot(dactab,IntensmeanQ8G,'r+-')
    hhh
    errorbar(dactab,IntenspixH(:,hhh+1),IntenspixSTDH(:,hhh+1))
    leg(hhh+1)={ ['Hold [ns]: ' num2str(5*hhh)  ]};
end
box on

hold off
%nbimperdac
xlabel('DAC1 value')
ylabel(' mean ADC value')
title(['Gain:' num2str(gaintab(1)) ' Dark. No mask. Errorbar STD ' num2str(nbimperdac) ' images/DAC1pts'])
legend(leg)
set(gca, 'YScale','log')
datenow=datestr(now,'yymmddHHMMSS');
saveas(gcf,['ADC_DACHOLDAll'  '_' 'Gain' num2str(gaintab(1))  '_' datenow '_nomask.png'])
saveas(gcf,['ADC_DACHOLDAll'  '_' 'Gain' num2str(gaintab(1)) '_' datenow '_nomask.fig'])

save(['ADC_DACHOLDAll'  '_' 'Gain' num2str(gaintab(1)) '_' datenow '_nomask.mat'])

%end
for hhh=0:15
 figure('Position',[10 10 1400 900])
 set(gcf,'Color','w')
 
        hold on
        plot(dactab,IntensmeanQ8GH(:,hhh+1),'ro-')
        errorbar(dactab,IntenspixH(:,hhh+1),IntenspixSTDH(:,hhh+1))
        errorbar(dactab,IntenspixHB(:,hhh+1),IntenspixSTDHB(:,hhh+1))
        box on
        yl=ylim
        text(dactab(2),yl(2)-3,['HOLD [ns]:' num2str(hhh*5)],'FontSize',18)
        hold off
        set(gca,'FontSize',16) 
        %nbimperdac
        xlabel('DAC1 value')
        ylabel(' mean ADC value')
        title(['Gain:' num2str(gaintab(1)) ' Dark. All-pix-masked-excepted-one. Errorbar STD ' num2str(nbimperdac) ' images/DAC1pts'])
        legend('Max intensity in trig. images (may be different pixel#)','triggering pixel','one other pix')
        %set(gca, 'YScale','log')
        datenow=datestr(now,'yymmddHHMMSS');
        saveas(gcf,['ADC_DACHOLD' num2str(hhh) '_' 'Gain' num2str(gaintab(1))  '_' datenow '_nomask.png'])
        saveas(gcf,['ADC_DACHOLD' num2str(hhh) '_' 'Gain' num2str(gaintab(1)) '_' datenow '_nomask.fig'])
end       