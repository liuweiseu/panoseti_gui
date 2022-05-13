close all


exposurestr='';
nbimperdac=1000;

makereport=0
if makereport==1
    import mlreportgen.report.* 
import mlreportgen.dom.* 
    sec4 = Section;
    sec4.Title = 'DAC vs ADC calibration';
end

%dactab=[235:2:265 ];  %works well for gain=33, Q1
%  dactab=[250:5:300 ]; %works well for gain=66
ADCDACtab=zeros(16,16,2);
usegainmap=1;
gaintabtab=[40];%11:31 %1:10:121;
gaintab=gaintabtab;%11:31 %1:10:121;
%load(['pethresh_gain' num2str(gaintabtab) '.mat'])
load(([getuserdir '\panoseti\Calibrations\' 'CalibrationDB.mat']))
[ig,indexquabosn]=ismember(['QuaboSN'] ,quaboconfig);
inddetrow=find(quaboDETtable(:,1)==str2num(cell2mat(quaboconfig(indexquabosn,3))));
A0=gaintab*quaboDETtable(inddetrow,7);
A1=gaintab*quaboDETtable(inddetrow,8);
A2=gaintab*quaboDETtable(inddetrow,9);
A3=gaintab*quaboDETtable(inddetrow,10);
B0=quaboDETtable(inddetrow,11);
B1=quaboDETtable(inddetrow,12);
B2=quaboDETtable(inddetrow,13);
B3=quaboDETtable(inddetrow,14);

%dactab=[205:2:230 ];
%petab=(1/A0)*(-B0 + dactab); % A0...A3
petab=3.2:0.3:7.5;

dactab0=round(A0*petab+B0);
dactab1=round(A1*petab+B1);
dactab2=round(A2*petab+B2);
dactab3=round(A3*petab+B3);

indcoldac=1; %%% 1...4 attention!
%load(['gainmap_gain' num2str(gaintabtab) '.mat'])

resultdir=[getuserdir '\panoseti\PANOapp\results'];

%currtabExp=[0. round(logspace(0,log10(4000),10))];
currtabExp=[0.];
exptext=' Dark. ' %' Light ON (400uA) '
%currtabExp=[0. ];
maxtesttime = 60;

expstr='Dark.';
shaperstr='Bipolar fs; ';
maskstr='All-pixels-masked-excepted-one [7,1]; ';
IntensmeanQ9G=zeros(numel(dactab0),numel(gaintabtab),numel(currtabExp));

realhvQ0=[];realhvQ1=[];realhvQ2=[];realhvQ3=[];
realcurQ0=[];realcurQ1=[];realcurQ2=[];realcurQ3=[];
temp1=[];temp2=[];
timecomp=[];

cc=1;
%for cc=1:numel(currtabExp)
%disp(['Testing Curr:' num2str(currtabExp(cc))])
%disp(['Setting: U' num2str(currtabExp(cc),'%05g') ';'])
%setADU(['WR' num2str(currtab(ii),'%05g')]);
% setJimPS(s,currtabExp(cc))
%disp('Changing Light intensity. Waiting 15s for HV to be adjusted...')

%     if cc>1
%     pause(15)
%     end

%%%%%%%%%%quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config.txt']);
[ig,indexstimon]=ismember(['STIMON '] ,quaboconfig);
quaboconfig(indexstimon,2)={"0"};
pausetime=0.5;
indcol=1:4;

[ig,indexacqmode]=ismember(['ACQMODE '] ,quaboconfig);
quaboconfig(indexacqmode,2)={"0x01"};

%[ig,indexhold1]=ismember(['HOLD1 '] ,quaboconfig);
%[ig,indexhold2]=ismember(['HOLD2 '] ,quaboconfig);


for mx=1:1 %64
    for my=1:4
        disp(['Characterizing pixel #' num2str(mx) ' on Q' num2str(my)])
        %
        if my==1
            dactab=dactab0;
        elseif my==2
            dactab=dactab1;
        elseif my==3
            dactab=dactab2;
        elseif my==4
            dactab=dactab3;
        end
        % [ig,indexacqint]=ismember(['ACQINT '] ,quaboconfig);
        % acqint=(1e-5)*str2num(quaboconfig(indexacqint,2));
        % exposurestr=['Exposure time [ms]:' num2str(1000*acqint,'%3.3g')];
        normcps=1; %/acqint;
        %set gain
        
        
        for  gainkk=1:numel(gaintabtab)
            gaintab=gaintabtab(gainkk);
            quaboconfig=changegain(gaintab(1),quaboconfig,usegainmap)
            %             if usegainmap==0
            %                 gaintab=gaintabtab(gainkk);
            %                 for pp=0:63
            %                     [ig,indexgain]=ismember(['GAIN' num2str(pp)] ,quaboconfig);
            %
            %                     quaboconfig(indexgain,indcol+1)={['0x' dec2hex(gaintab(1))]};
            %                 end
            %             else
            %                 load(['gainmap_gain' num2str(gaintab(1)) '.mat'])
            %                 for pp=0:63
            %                     [ig,indexgainmap]=ismember(['GAIN' num2str(pp)] ,quaboconfig_gain);
            %                     [ig,indexgain]=ismember(['GAIN' num2str(pp)] ,quaboconfig);
            %
            %                     quaboconfig(indexgain,indcol+1)=quaboconfig_gain(indexgainmap,indcol+1);
            %                 end
            %             end
            %set masks MASKOR1_
            
            load('Marocmap.mat')
            xt1=squeeze(marocmap(mx,my,1));
            yt1=squeeze(marocmap(mx,my,2));
            xt2=squeeze(marocmap(32,1,1));
            yt2=squeeze(marocmap(32,1,2));
            xt3=squeeze(marocmap(8,4,1));
            yt3=squeeze(marocmap(8,4,2));
            
            mask=1;
            quaboconfig=changemask(mask,[mx my],quaboconfig)
            %             if mask==0
            %                 for pp=0:63
            %                     [ig,indexmask]=ismember(['MASKOR1_' num2str(pp)] ,quaboconfig);
            %                     quaboconfig(indexmask,indcol+1)={['0']};
            %                 end
            %             else
            %                 indcols=1
            %                 for pp=0:63
            %                     [ig,indexmask]=ismember(['MASKOR1_' num2str(pp)] ,quaboconfig);
            %                     quaboconfig(indexmask,indcol+1)={['1']};
            %                     [ig,indexmask2]=ismember(['MASKOR2_' num2str(pp)] ,quaboconfig);
            %                     quaboconfig(indexmask2,indcol+1)={['1']};
            %                 end
            %                 %         [ig,indexmask]=ismember(['MASKOR1_63'] ,quaboconfig);
            %                 %         quad=1;
            %                 %         quaboconfig(indexmask,quad+1)={['0']};
            %                 %         [ig,indexmask2]=ismember(['MASKOR2_63'] ,quaboconfig);
            %                 %         quaboconfig(indexmask2,quad+1)={['0']};
            %
            %                 %marocmap(32,1,:)
            %                 [ig,indexmask]=ismember(['MASKOR1_' num2str(mx-1)] ,quaboconfig);
            %                 quad=my;
            %                 quaboconfig(indexmask,quad+1)={['0']};
            %                 [ig,indexmask2]=ismember(['MASKOR2_'  num2str(mx-1)] ,quaboconfig);
            %                 quaboconfig(indexmask2,quad+1)={['0']};
            %                 %         [ig,indexmask]=ismember(['MASKOR1_53'] ,quaboconfig);
            %                 %       quaboconfig(indexmask,quad+1)={['0']};
            %                 %         [ig,indexmask2]=ismember(['MASKOR2_53'] ,quaboconfig);
            %                 %         quaboconfig(indexmask2,quad+1)={['0']};
            %
            %                 %                         quaboconfig(indexmask,quad+1+1)={['0']};
            %                 %         [ig,indexmask2]=ismember(['MASKOR2_63'] ,quaboconfig);
            %                 %         quaboconfig(indexmask2,quad+1+1)={['0']};
            %                 %                 [ig,indexmask]=ismember(['MASKOR1_63'] ,quaboconfig);
            %             end
            
            
            %set masks CHANMASK_
            %             maskph=0;
            %             if maskph==0
            %                 for pp=0:7
            %                     [ig,indexmask]=ismember(['CHANMASK_' num2str(pp) ' '] ,quaboconfig);
            %                     quaboconfig(indexmask,1+1)={['0x0']};
            %                 end
            %             else
            %                 for pp=0:7
            %                     [ig,indexmask]=ismember(['CHANMASK_' num2str(pp) ' '] ,quaboconfig);
            %                     quaboconfig(indexmask,1+1)={['0xFFFFFFFF']};
            %                 end
            %                 [ig,indexmask]=ismember(['CHANMASK_8 '] ,quaboconfig);
            %                 quaboconfig(indexmask,1+1)={['0x1FF']};
            %                 [ig,indexmask]=ismember(['CHANMASK_0 '] ,quaboconfig);
            %                 % quad=2;
            %                 quaboconfig(indexmask,1+1)={['0xEFFFFFFF']};
            %                 sendPHmasks(quaboconfig)
            %             end
            %
            
            %put high thresh on all 4 quads
            [ia,indexdac]=ismember('DAC1',quaboconfig);
            dactabH0=1000;indcol=1:4;
            quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactabH0)]};
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
            
            %dactab=[185:5:305  ];
            figure
            
            
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
            for hh=0:0
                % quaboconfig(indexhold1,2)={num2str(hh)};
                %quaboconfig(indexhold2,2)={num2str(hh)};
                % quaboconfig(indexacqmode,2)={"0x01"};
                %  sentacqparams2board(quaboconfig)
                %  disp('Waiting 1s...')
                %   pause(1)
                %%SUBTRACT BASELINE EACH TIME
                subtractbaseline(quaboconfig)
                pause(3)
                %%%testing the crap PH change bizarro thing
                %         bizarro=1
                %         while bizarro==1
                %             bizarro=0;
                %               imagephtest=grabimagesnofits(100,1,1);
                %               spatialmeantest=(mean(imagephtest(:,:,:),[3]));
                %               timestdtest=std(mean(imagephtest(:,:,:),[1 2]));
                %                if max(spatialmeantest,[],'all')>3*mean(spatialmeantest,[1 2])
                %                   bizarro=1
                %                    disp(['Bizarre mode detected (peaks detected). Retrying...'])
                %                end
                % %               if timestdtest>1.5
                % %                   figure
                % %                  plot(squeeze( mean(imagephtest(:,:,:),[1 2])))
                % %                  clf
                % %                    bizarro=1
                % %                    disp(['Bizarre mode detected (large std ' num2str(timestdtest) '). Retrying...'])
                % %                end
                % %               if max(imagephtest,[],'all')>3000-2000
                % %                   bizarro=1
                % %               end
                % %               if mean(imagephtest(1:8,9:16),'all')> mean(imagephtest(9:16,1:8),'all')
                % %                   bizarro=1
                % %               end
                %               if bizarro==1
                %                   sentacqparams2board(quaboconfig)
                %                   pause(1)
                %               end
                %           end
                
                
                
                
                %          sentacqparams2board(quaboconfig)
                %          disp('Waiting 1s...')
                %          pause(1)
                %          sentacqparams2board(quaboconfig)
                %          disp('Waiting 1s...')
                %          pause(1)
                %          sentacqparams2board(quaboconfig)
                %          disp('Waiting 1s...')
                %          pause(1)
                %          sentacqparams2board(quaboconfig)
                %          disp('Waiting 1s...')
                %   load gong.mat; gong = audioplayer(y, Fs); play(gong);
                %       pause(1)
                % IntensmeanQ9G(dd,gainkk,cc)=measframerate(10,1,1);
                nbtrig=0;
                Intenspix=[];
                IntenspixSTD=[];
                IntenspixB=[];
                IntenspixSTDB=[];
                
                IntenspixC=[];
                IntenspixSTDC=[];
                IntensmeanQ8G=[];
                tic;
                %    while timetested<maxtesttime
                dd=1
                while dd<=numel(dactab)
                    quaboconfig(indexdac,my+1)={['0x' dec2hex(dactab(dd))]};
                    disp(['Sending Maroc comm...DAC1:' num2str(dactab(dd)) ' Gain:' num2str((gaintabtab(gainkk))) ' (' num2str(gainkk) '/' num2str(numel(gaintabtab)) ')' ...
                        'Light I [step]: ' num2str(cc) '/' num2str(numel(currtabExp)) ' PixM/Quad: ' num2str(mx) '/' num2str(my)])
                    sendconfig2Maroc(quaboconfig)
                    pause(3)
                    
                    %  images=grabimages(nbimperdac,1,1);
                    nbtot=0;imageszeros=[];
                    nbimafin=1;%will stop if no image
                    while (nbtot<nbimperdac) && (nbimafin~=0)
                        [imageszerostmp nbimafin]=grabimages2(nbimperdac,1,1);
                        imageszerostmp=imageszerostmp(:,:,1:nbimafin-1);
                        nbtot=nbtot+nbimafin-1;
                        
                        imageszeros2=cat(3,imageszeros,imageszerostmp );
                        imageszeros=imageszeros2;
                    end
                    if (nbimafin~=0)
                        %  images=imageszeros(:,:,1:nbimafin-1);
                        images=imageszeros(:,:,1:nbimperdac);
                        imagesNZ=[];
                        %double-check no zeros image
                        imagesNZind=[];
                        for zz=1:size(images,3)
                            if sum(images(:,:,zz))~=0
                                imagesNZind=[imagesNZind zz];
                            end
                        end
                        imagesNZ=images(:,:,imagesNZind);
                        images=imagesNZ;
                        
                        % if dd==1
                        figure('Position',[10 10 1400 900])
                        subplot(2,1,1)
                        hold on
                        
                        [histsinglepix1 cent1]=hist(squeeze(images(xt1,yt1,:)))
                        plot(cent1, histsinglepix1)
                        [histsinglepix2 cent2]=hist(squeeze(images(xt2,yt2,:)))
                        plot(cent2, histsinglepix2)
                        [histsinglepix3 cent3]=hist(squeeze(images(xt3,yt3,:)))
                        plot(cent3, histsinglepix3)
                        hold off
                        legend(['pix[' num2str(xt1) ',' num2str(yt1) ']'],...
                            ['pix[' num2str(xt2) ',' num2str(yt2) ']'],...
                            ['pix[' num2str(xt3) ',' num2str(yt3) ']'])
                        xlabel('ADC value')
                        
                        subplot(2,1,2)
                        hold on
                        plot(squeeze(images(xt1,yt1,:)),'+')
                        %  plot(squeeze(images(3,7,:)),'+')
                        % plot(squeeze(images(10,7,:)),'+')
                        hold off
                        xlabel('Time [frame#]')
                        ylabel('ADC value (triggered pix)')
                        legend(['pix[' num2str(xt1) ',' num2str(yt1) ']'])
                        datenow=datestr(now,'yymmddHHMMSS');
                        saveas(gcf,[resultdir '\png\ ' 'meanpix_vs_timeacq' '_DAC' num2str(dactab(dd)) '_' 'Gain' num2str(gaintab(1))  '_' datenow '_nomask.png'])
                        saveas(gcf,[resultdir '\fig\' 'meanpix_vs_timeacq' '_DAC' num2str(dactab(dd)) '_' 'Gain' num2str(gaintab(1)) '_' datenow '_nomask.fig'])
                        close(gcf)
                        % end
                        spatialmeanvstime=squeeze(mean(images(:,:,:),[1 2]));
                        spatialmedianvstime=squeeze(median(images(:,:,:),[1 2]));
                        
                        
                        
                        figure
                        % subplot(2,2,3)
                        set(gcf,'Color','w')
                        hold on
                        plot(squeeze(spatialmeanvstime),'-+b','LineWidth',2)
                        plot(squeeze(spatialmedianvstime),'--r','LineWidth',1)
                        hold off
                        legend('Mean over all pixels', 'Median')
                        xlabel('Time [frame#]')
                        ylabel('mean ADC value (over pixels)')
                        yl=ylim
                        ti=title([exptext 'Bipolar fs; All-trigmasked-except-one. STD: ' num2str(nbimperdac) ' images/dac'])
                        set(gca,'FontSize',12)
                        set(ti,'FontSize',10)
                        box on; grid on
                        text(10,yl(1)+0.75*(yl(2)-yl(1)),['DAC:' num2str(dactab(dd))],'FontSize',16)
                        %  text(100,yl(1)+0.5*(yl(2)-yl(1)),['HOLD [ns]:' num2str(hh*5)],'FontSize',18)
                        %ylim([2090 2110])
                        datenow=datestr(now,'yymmddHHMMSS');
                        filenmmeanmed=[resultdir '\png\' 'meanimage_vs_timeacq' '_DAC' num2str(dactab(dd)) '_' 'Gain' num2str(gaintab(1))  '_' datenow '_nomask.png'];
                        saveas(gcf,filenmmeanmed)
                        saveas(gcf,[resultdir '\fig\' 'meanimage_vs_timeacq' '_DAC' num2str(dactab(dd)) '_' 'Gain' num2str(gaintab(1)) '_' datenow '_nomask.fig'])
                        close(gcf)
                        %what about outlier images?
                        
                        
                        meanimage=mean(images(:,:,:),[3])';
                        stdimage=std(images(:,:,:),0,[3])';
                        figure
                        set(gcf,'Color','w')
                        subplot(1,2,1)
                        imagesc(meanimage')
                        axis image
                        colorbar
                        ti=title('mean image')
                        set(gca,'FontSize',12)
                        text(1,-2,[exptext 'Bipolar fs; All-trigmasked-except-one. STD: ' num2str(nbimperdac) ' images/dac'])
                        
                        text(1,-4,['DAC:' num2str(dactab(dd))],'FontSize',12)
                        %   text(1,-6,['HOLD [ns]:' num2str(hh*5)],'FontSize',12)
                        
                        subplot(1,2,2)
                        imagesc(stdimage')
                        axis image
                        colorbar
                        title('STD image')
                        set(gca,'FontSize',12)
                        
                        datenow=datestr(now,'yymmddHHMMSS');
                        filenmmeanstd=[resultdir '\png\' 'mean2dimage_STD2dimage' '_DAC' num2str(dactab(dd)) '_' 'Gain' num2str(gaintab(1))  '_' datenow '_nomask.png'];
                        saveas(gcf,filenmmeanstd)
                        saveas(gcf,[resultdir '\fig\' 'mean2dimage_STD2dimage' '_DAC' num2str(dactab(dd)) '_' 'Gain' num2str(gaintab(1)) '_' datenow '_nomask.fig'])
                        close(gcf)
                        
                        
                        
                        toctoc=toc;
                        timetested=toctoc;
                        if sum(images,'all')>0
                            Intenspix=[Intenspix; meanimage(xt1,yt1)];
                            IntenspixSTD=[IntenspixSTD; stdimage(xt1,yt1)];
                            IntenspixB=[IntenspixB; meanimage(xt2,yt2)];
                            IntenspixSTDB=[IntenspixSTDB; stdimage(xt3,yt3)];
                            IntenspixC=[IntenspixC; meanimage(xt3,yt3)];
                            IntenspixSTDC=[IntenspixSTDC; stdimage(xt3,yt3)];
                            [Ma, indmlin] =max(meanimage);
                            [Ma2, indmcol] =max(Ma);
                            
                            disp(['pix ' num2str(indmlin(indmcol)) ' ' num2str(indmcol)])
                            IntensmeanQ8G=[IntensmeanQ8G; Ma2];
                            
                            nbtrig=nbtrig+1
                            if Ma2<meanimage(1,7)
                                disp('Stop')
                            end
                        end
                    else
                        dd=numel(dactab);
                    end
                    dd=dd+1;
                end
                
                
                if (nbimafin~=0)
                    
                    figure('Position',[10 10 1400 900],'Color','w')
                    hold on
                    plot(dactab,IntensmeanQ8G,'ro-')
                    errorbar(dactab,Intenspix,0.5*IntenspixSTD)
                    %   errorbar(dactab,IntenspixB,0.5*IntenspixSTDB)
                    %   errorbar(dactab,IntenspixC,0.5*IntenspixSTDC)
                    box on
                    
                    %  hold off
                    %nbimperdac
                    xlabel('DAC1 value')
                    ylabel(' mean ADC value')
                    title([' Gain ini:' num2str(gaintab(1)) exptext ' All-pix-masked-exc.-one. Errorbar STD ' num2str(nbimperdac) ' images/DAC1pts'],'FontSize',12)
                    %  legend('Max intensity in trig. images (diff. pixel#)','Triggering pix', 'other pixel')
                    
                    
                    set(gca, 'YScale','lin')
                    box on; grid on
                    set(gca,'FontSize',12)
                    yl=ylim
                    %%pe levels
                    peaksdac3=zeros(1,ceil(petab(1))-1);
                    for pp=ceil(petab(1)):floor(petab(end))
                        [minval minind] =  min(abs(dactab-(B0+A0*pp)));
                        peaksdac3=[peaksdac3 dactab(minind(1))];
                        pepplot=plot([peaksdac3(end) peaksdac3(end)] , yl,'--')
                        pepplot.Annotation.LegendInformation.IconDisplayStyle = 'off';
                        text(peaksdac3(end) ,-3+yl(2),[num2str(pp) 'pe'],'FontSize',16)
                    end
                    
                    
                    %best fit
                    [countfit, gof] = fit(dactab',IntensmeanQ8G, 'poly1')
                    ADCDACfit=plot(dactab,(countfit.p1*dactab + countfit.p2),'--','LineWidth',2.)
                    leg= [{'Max intensity in trig. images (diff. pixel#)'} {['pix[' num2str(xt1) ',' num2str(yt1) ']']} ...
                        {['ADC = ' num2str(countfit.p1) ' DAC + ' num2str(countfit.p2) ' OR ' 'ADC = ' num2str(A0*countfit.p1) ' PE + ' num2str(B0*countfit.p1+countfit.p2)]}]
                    %                      {['pix[' num2str(xt2) ',' num2str(yt2) ']']} ...
                    %                         {['pix[' num2str(xt3) ',' num2str(yt3) ']']} ...
                    
                    legend(leg,'Location','SouthEast')
                    
                    ADCDACtab(xt1,yt1,1)=countfit.p1;
                    ADCDACtab(xt1,yt1,2)=countfit.p2;
                    
                    % text(dactab(2),yl(2)-5,['HOLD [ns]:' num2str(hhh*5)],'FontSize',18)
                    hold off
                    datenow=datestr(now,'yymmddHHMMSS');
                    filenmadcvsdac=[resultdir '\png\' 'ADC_DACHOLD' num2str(hh) '_' 'Gain' num2str(gaintab(1))  '_' datenow '_nomask.png'];
                    saveas(gcf,filenmadcvsdac)
                    saveas(gcf,[resultdir '\fig\' 'ADC_DACHOLD' num2str(hh) '_' 'Gain' num2str(gaintab(1)) '_' datenow '_nomask.fig'])
                    close(gcf)
                    
                    IntensmeanQ8GH=[IntensmeanQ8GH IntensmeanQ8G];
                    % IntensmeanQ8GSTDH=[IntensmeanQ8GSTDH; IntensmeanQ8GSTD];;
                    IntenspixH=[IntenspixH Intenspix];
                    IntenspixSTDH=[IntenspixSTDH IntenspixSTD];
                    IntenspixHB=[IntenspixHB IntenspixB];
                    IntenspixSTDHB=[IntenspixSTDHB IntenspixSTDB];
                end
            end
            
            
           % makereport=0
            if makereport==1
                
                sec41 = Section;
                sec41.Title = ['Quadrant ' num2str(my)];
                
                add(sec41,Paragraph(['ADC values vs DAC and fitted curve (dark, all pixelmasked excpt-one):' ]));
                plot1=Image(filenmadcvsdac);
                widthch=plot1.Width;
                widthima=str2num(widthch(1:strfind(widthch,'px')-1));
                heightch=plot1.Height;
                heightima=str2num(heightch(1:strfind(heightch,'px')-1));
                plot1.Width='450px';
                plot1.Height=[ num2str(floor(450/widthima*heightima)) 'px'];
                add(sec41,plot1);
                
                add(sec41,Paragraph(['Mean and std deviation of pixel over ' num2str(nbimperdac) ' frames at a given DAC:' ]));
                plot1=Image(filenmmeanstd);
                widthch=plot1.Width;
                widthima=str2num(widthch(1:strfind(widthch,'px')-1));
                heightch=plot1.Height;
                heightima=str2num(heightch(1:strfind(heightch,'px')-1));
                plot1.Width='400px';
                plot1.Height=[ num2str(floor(450/widthima*heightima)) 'px'];
                add(sec41,plot1);
                
                add(sec41,Paragraph(['Mean and median of frame intensities vs time at a given DAC:' ]));
                plot1=Image(filenmmeanmed);
                widthch=plot1.Width;
                widthima=str2num(widthch(1:strfind(widthch,'px')-1));
                heightch=plot1.Height;
                heightima=str2num(heightch(1:strfind(heightch,'px')-1));
                plot1.Width='400px';
                plot1.Height=[ num2str(floor(450/widthima*heightima)) 'px'];
                add(sec41,plot1);
                
                
                %%add DAC vs pe coeffs table
                sec42 = Section;
                sec42.Title = ['ADC = E DAC + F'];
                tableADCvsDAC=BaseTable({['Gain ini'] ['E'] ['F' ] ...
                    ; ...
                    [num2str( gaintab)] ...
                    [num2str( ADCDACtab(xt1,yt1,1))] ...
                    [num2str( ADCDACtab(xt1,yt1,2))] ...
                    });
                add(sec42,tableADCvsDAC);
                
                
                
                
                add(sec4,sec41);
                add(sec4,sec42);
                
                
            end
            
            
        end
        
        
        
        
        
    end
end

save(['ADCDACmap_gain' num2str(gaintab(1)) '.mat'],'ADCDACtab')
%%%%%%%%%%


if makereport==1
    
    add(rpt,sec4);
    sec4 = Section;
end
%%%%%%%%%%
%%%%%%%%%%
%%%%%
%%%%%%%%%%