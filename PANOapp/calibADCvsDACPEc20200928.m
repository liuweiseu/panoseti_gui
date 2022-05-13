close all
%don't run panotv at the same time otherwise it will miss lot of frames at high
%threshold
tic
figini;

exposurestr='';
nbimperdac=500;

%makereport=
if makereport ==1
    import mlreportgen.report.*
    import mlreportgen.dom.*
    sec4 = Section;
    sec4.Title = 'ADC vs PE relationship';
end

%dactab=[235:2:265 ];  %works well for gain=33, Q1
%  dactab=[250:5:300 ]; %works well for gain=66

usegainmap=1;
gaintabtab=[60];%11:31 %1:10:121;
ADCDACtab=zeros(16,16,4,numel(gaintabtab));
ADCDACtabQ=zeros(numel(gaintabtab),4,4);
%gaintab=gaintabtab;%11:31 %1:10:121;
%load(['pethresh_gain' num2str(gaintabtab) '.mat'])
filenmadcvsdacQ=cell(numel(gaintabtab),4);
filenmmeanstdQ=cell(numel(gaintabtab),4);
filenmmeanmedQ=cell(numel(gaintabtab),4);


indcoldac=1; %%% 1...4 attention!
%load(['gainmap_gain' num2str(gaintabtab) '.mat'])

resultdir=calibdir;

%currtabExp=[0. round(logspace(0,log10(4000),10))];
currtabExp=[0.];
exptext=' Dark. ' %' Light ON (400uA) '
%currtabExp=[0. ];
maxtesttime = 60;

expstr='Dark.';
shaperstr='Bipolar fs; ';
maskstr='All-pixels-masked-excepted-one; ';
%IntensmeanQ9G=zeros(numel(dactab0),numel(gaintabtab),numel(currtabExp));

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
for  gainkk=1:numel(gaintabtab)
    gaintab=gaintabtab(gainkk);
   %UNCOMMENT to use gain map 
   quaboconfig=changegain(gaintab(1),quaboconfig,usegainmap)
    %quaboconfig=changegain(gaintab(1),quaboconfig,0)
    if makereport==1
        sec40 = Section;
        sec40.Title = ['Gain ini:' num2str(gaintab)];
    end
    
    load(([getuserdir '\panoseti\Calibrations\' 'CalibrationDB.mat']))
    [ig,indexquabosn]=ismember(['QuaboSN'] ,quaboconfig);
    inddetrow=find(quaboDETtable(:,1)==str2num(cell2mat(quaboconfig(indexquabosn,3))));
   % inddetrow=find(quaboDETtable(:,1)==str2num(quaboSN))
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
    petab=3.2:0.3:6.4;
    
    dactab0=round(A0*petab+B0);
    dactab1=round(A1*petab+B1);
    dactab2=round(A2*petab+B2);
    dactab3=round(A3*petab+B3);
    
    for mx=3:3 %64
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
            %     figure
            
            
            %put high thresh on all 4 quads
            % dactabH0=500;
            %  quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactabH0)]};
            %  pause(pausetime)
            
            IntensmeanQ0=[];IntensmeanQ1=[];IntensmeanQ2=[];IntensmeanQ3=[];IntensmeanQ8=[];IntensmeanQ9=[];
            allima=zeros(16,16,numel(dactab),numel(indcol));
            indcol2=1;
            timetested=0;
           % timetestedzero=tic;
            
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
                Intenspix=[];Intenspixmed=[];
                IntenspixSTD=[];
                IntenspixB=[];
                IntenspixSTDB=[];
                
                IntenspixC=[];
                IntenspixSTDC=[];
                IntensmeanQ8G=[];
              %  tic;
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
                        saveas(gcf,[calibdir 'meanpix_vs_timeacq' '_DAC' num2str(dactab(dd)) '_' 'Gain' num2str(gaintab(1))  '_' datenow '_nomask.png'])
                        saveas(gcf,[calibdir 'meanpix_vs_timeacq' '_DAC' num2str(dactab(dd)) '_' 'Gain' num2str(gaintab(1)) '_' datenow '_nomask.fig'])
                        close(gcf)
                        % end
                        spatialmeanvstime=squeeze(mean(images(:,:,:),[1 2]));
                        spatialmedianvstime=squeeze(median(images(:,:,:),[1 2]));
                        
                        
                        
                        figure
                        % subplot(2,2,3)
                        set(gcf,'Color','w')
                        hold on
                        plot(squeeze(spatialmeanvstime),'-+b','LineWidth',1)
                        plot(squeeze(spatialmedianvstime),'--r','LineWidth',1)
                        hold off
                        legend('Mean over all pixels', 'Median')
                        xlabel('Time [frame#]')
                        ylabel('mean ADC value (over pixels)')
                        yl=ylim
                        ti=title(['Q' num2str(my) ', '  exptext 'Bipolar fs; All-masked-except-one-pix. ' num2str(nbimperdac) ' frames'])
                        set(gca,'FontSize',12)
                        set(ti,'FontSize',10)
                        box on; grid on
                        text(10,yl(1)+0.75*(yl(2)-yl(1)),['DAC:' num2str(dactab(dd))],'FontSize',16)
                        %  text(100,yl(1)+0.5*(yl(2)-yl(1)),['HOLD [ns]:' num2str(hh*5)],'FontSize',18)
                        %ylim([2090 2110])
                        datenow=datestr(now,'yymmddHHMMSS');
                        filenmmeanmed=[calibdir 'meanimage_vs_timeacq' 'Q' num2str(my) '_DAC' num2str(dactab(dd)) '_' 'Gain' num2str(gaintab(1))  '_' datenow '_nomask.png'];
                        filenmmeanmedQ(gainkk,my)={filenmmeanmed};
                        saveas(gcf,filenmmeanmed)
                        saveas(gcf,[calibdir 'meanimage_vs_timeacq' 'Q' num2str(my) '_DAC' num2str(dactab(dd)) '_' 'Gain' num2str(gaintab(1)) '_' datenow '_nomask.fig'])
                        close(gcf)
                        %what about outlier images?
                        
                        
                        meanimage=mean(images(:,:,:),[3])';
                        medianimage=median(images(:,:,:),[3])';
                        stdimage=std(images(:,:,:),0,[3])';
                        figure
                        set(gcf,'Color','w','Position',[100 100 700 300])
                        subplot(1,2,1)
                        imagesc(meanimage')
                        axis image
                        colorbar
                        ti=title('mean image')
                        set(gca,'FontSize',12)
                        set(ti,'FontSize',10)
                        text(1,-2,['Q' num2str(my) ', ' exptext 'Bipolar fs; All-trigmasked-except-one. ' num2str(nbimperdac) ' images'],'FontSize',12)
                        
                        text(1,-4,['DAC:' num2str(dactab(dd))],'FontSize',12)
                        %   text(1,-6,['HOLD [ns]:' num2str(hh*5)],'FontSize',12)
                        
                        subplot(1,2,2)
                        imagesc(stdimage')
                        axis image
                        colorbar
                        ti=title('STD image')
                        
                        set(gca,'FontSize',12)
                        set(ti,'FontSize',10)
                        
                        datenow=datestr(now,'yymmddHHMMSS');
                        filenmmeanstd=[calibdir 'mean2dimage_STD2dimage' 'Q' num2str(my) '_DAC' num2str(dactab(dd)) '_' 'Gain' num2str(gaintab(1))  '_' datenow '_nomask.png'];
                        filenmmeanstdQ(gainkk,my)={filenmmeanstd};
                        saveas(gcf,filenmmeanstd)
                        saveas(gcf,[calibdir 'mean2dimage_STD2dimage' 'Q' num2str(my) '_DAC' num2str(dactab(dd)) '_' 'Gain' num2str(gaintab(1)) '_' datenow '_nomask.fig'])
                        close(gcf)
                        
                        
                        
                      %  toctoc=toc;
                      %  timetested=toctoc;
                        if sum(images,'all')>0
                            Intenspix=[Intenspix; meanimage(xt1,yt1)];
                            Intenspixmed=[Intenspixmed; medianimage(xt1,yt1)];
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
                    plot(dactab,Intenspixmed,'g--')
                    %   errorbar(dactab,IntenspixB,0.5*IntenspixSTDB)
                    %   errorbar(dactab,IntenspixC,0.5*IntenspixSTDC)
                    box on
                    
                    %  hold off
                    %nbimperdac
                    xlabel('DAC1 value')
                    ylabel(' mean ADC value')
                    title(['Q' num2str(my) ', Gain ini:' num2str(gaintab(1)) exptext ' All-pix-masked-exc.-one. Errorbar = STD( ' num2str(nbimperdac) ' images)'],'FontSize',12)
                    %  legend('Max intensity in trig. images (diff. pixel#)','Triggering pix', 'other pixel')
                    
                    
                    set(gca, 'YScale','lin')
                    box on; grid on
                    set(gca,'FontSize',18)
                    yl=ylim
                    %%pe levels
                    Aquad=gaintab*quaboDETtable(inddetrow,6+my);
                    Bquad=quaboDETtable(inddetrow,10+my);
                    peaksdac3=zeros(1,ceil(petab(1))-1);
                    for pp=ceil(petab(1)):floor(petab(end))
                        [minval minind] =  min(abs(dactab-(Bquad+Aquad*pp)));
                        peaksdac3=[peaksdac3 dactab(minind(1))];
                        pepplot=plot([peaksdac3(end) peaksdac3(end)] , yl,'--')
                        pepplot.Annotation.LegendInformation.IconDisplayStyle = 'off';
                        text(peaksdac3(end) ,-3+yl(2),[num2str(pp) 'pe'],'FontSize',18)
                    end
                    
                    
                    %best fit
                    [countfit, gof] = fit(dactab',IntensmeanQ8G, 'poly1')
                    ADCDACfit=plot(dactab,(countfit.p1*dactab + countfit.p2),'--','LineWidth',2.)
                    leg= [{'Max intensity in mean images'} {['pix[' num2str(xt1) ',' num2str(yt1) '] mean']}  {['pix[' num2str(xt1) ',' num2str(yt1) '] median']}...
                        {['ADC = ' num2str(countfit.p1) ' DAC + ' num2str(countfit.p2) ' OR ' 'ADC = ' num2str(Aquad*countfit.p1) ' PE + ' num2str(Bquad*countfit.p1+countfit.p2)]}]
                    %                      {['pix[' num2str(xt2) ',' num2str(yt2) ']']} ...
                    %                         {['pix[' num2str(xt3) ',' num2str(yt3) ']']} ...
                    
                    legend(leg,'Location','SouthEast')
                    
                    ADCDACtab(xt1,yt1,1,gainkk)=countfit.p1;
                    ADCDACtab(xt1,yt1,2,gainkk)=countfit.p2;
                    ADCDACtab(xt1,yt1,3,gainkk)=Aquad*countfit.p1;
                    ADCDACtab(xt1,yt1,4,gainkk)=Bquad*countfit.p1+countfit.p2;
                    
                    ADCDACtabQ(gainkk,my,1)=countfit.p1;
                    ADCDACtabQ(gainkk,my,2)=countfit.p2;
                    ADCDACtabQ(gainkk,my,3)=Aquad*countfit.p1;
                    ADCDACtabQ(gainkk,my,4)=Bquad*countfit.p1+countfit.p2;
                    
                    % text(dactab(2),yl(2)-5,['HOLD [ns]:' num2str(hhh*5)],'FontSize',18)
                    hold off
                    datenow=datestr(now,'yymmddHHMMSS');
                    filenmadcvsdac=[calibdir 'ADC_DACQ' num2str(my) '_' 'Gain' num2str(gaintab(1))  '_' datenow '_nomask.png'];
                    filenmadcvsdacQ(gainkk,my)={filenmadcvsdac};
                    saveas(gcf,filenmadcvsdac)
                    saveas(gcf,[calibdir 'ADC_DACQ' num2str(my) '_' 'Gain' num2str(gaintab(1)) '_' datenow '_nomask.fig'])
                    close(gcf)
                    
                    IntensmeanQ8GH=[IntensmeanQ8GH IntensmeanQ8G];
                    % IntensmeanQ8GSTDH=[IntensmeanQ8GSTDH; IntensmeanQ8GSTD];;
                    IntenspixH=[IntenspixH Intenspix];
                    IntenspixSTDH=[IntenspixSTDH IntenspixSTD];
                    IntenspixHB=[IntenspixHB IntenspixB];
                    IntenspixSTDHB=[IntenspixSTDHB IntenspixSTDB];
                end
            end
            
            
            
            
        end
        
        
        % makereport=0
        if makereport==1
            
            %   sec41 = Section;
            %  sec41.Title = ['Quadrant ' num2str(my)];
            
            add(sec40,Paragraph(['The following figures shows ADC vs DAC and fitted curve (darks, pixel-all-masked-excepted-one) at an initial gain of '  num2str(gaintab(1)) ' for Q0.Q1,Q2,Q3:' ]));
            %    plot1=Image(filenmadcvsdac);
            
            
            imgStyle = {ScaleToFit(true)};
            img1 = Image(cell2mat(filenmadcvsdacQ(gainkk,1)));
            img1.Style = imgStyle;
            img2=Image(cell2mat(filenmadcvsdacQ(gainkk,2)));
            img2.Style = imgStyle;
            img3 = Image(cell2mat(filenmadcvsdacQ(gainkk,3)));
            img3.Style = imgStyle;
            img4=Image(cell2mat(filenmadcvsdacQ(gainkk,4)));
            img4.Style = imgStyle;
            %Insert images in the row of a 1x3, invisible layout table (lot).
            
            lot = Table({img1, ' ', img2; img3, ' ', img4});
            %The images will be sized to fit the table entries only if their height and width is specified.
            
            lot.entry(1,1).Style = {Width('3.2in'), Height('3in')};
            lot.entry(1,2).Style = {Width('.2in'), Height('3in')};
            lot.entry(1,3).Style = {Width('3.2in'), Height('3in')};
            lot.entry(2,1).Style = {Width('3.2in'), Height('3in')};
            lot.entry(2,2).Style = {Width('.2in'), Height('3in')};
            lot.entry(2,3).Style = {Width('3.2in'), Height('3in')};
            %Make the table span the width of the page between the margins. Tell the table layout manager to not resize the table columns to fit the images.
            
            lot.Style = {ResizeToFitContents(false), Width('100%')};
            %Generate and display the report.
            
            add(sec40, lot);
            
            
            %                 widthch=plot1.Width;
            %                 widthima=str2num(widthch(1:strfind(widthch,'px')-1));
            %                 heightch=plot1.Height;
            %                 heightima=str2num(heightch(1:strfind(heightch,'px')-1));
            %                 plot1.Width='450px';
            %                 plot1.Height=[ num2str(floor(450/widthima*heightima)) 'px'];
            %                 add(sec41,plot1);
            
            add(sec40,Paragraph(['For sanity check, the following figures represent the mean and std deviation of pixel intensities over ' num2str(nbimperdac) ' frames at a given DAC (PH mode, darks, Initial Gain: '  num2str(gaintab(1)) ') for Q0,Q1,Q2,Q3 where the unmasked pixel should be brighter than the other ones. ' ]));
            %  plot1=Image(filenmmeanstd);
            
            imgStyle = {ScaleToFit(true)};
            img1 = Image(cell2mat(filenmmeanstdQ(gainkk,1)));
            img1.Style = imgStyle;
            img2=Image(cell2mat(filenmmeanstdQ(gainkk,2)));
            img2.Style = imgStyle;
            img3 = Image(cell2mat(filenmmeanstdQ(gainkk,3)));
            img3.Style = imgStyle;
            img4=Image(cell2mat(filenmmeanstdQ(gainkk,4)));
            img4.Style = imgStyle;
            %Insert images in the row of a 1x3, invisible layout table (lot).
            
            lot = Table({img1, ' ', img2; img3, ' ', img4});
            %The images will be sized to fit the table entries only if their height and width is specified.
            
            lot.entry(1,1).Style = {Width('3.2in'), Height('1.5in')};
            lot.entry(1,2).Style = {Width('.2in'), Height('1.5in')};
            lot.entry(1,3).Style = {Width('3.2in'), Height('1.5in')};
            lot.entry(2,1).Style = {Width('3.2in'), Height('1.5in')};
            lot.entry(2,2).Style = {Width('.2in'), Height('1.5in')};
            lot.entry(2,3).Style = {Width('3.2in'), Height('1.5in')};
            %Make the table span the width of the page between the margins. Tell the table layout manager to not resize the table columns to fit the images.
            
            lot.Style = {ResizeToFitContents(false), Width('100%')};
            %Generate and display the report.
            
            add(sec40, lot);
            
            
            %                 widthch=plot1.Width;
            %                 widthima=str2num(widthch(1:strfind(widthch,'px')-1));
            %                 heightch=plot1.Height;
            %                 heightima=str2num(heightch(1:strfind(heightch,'px')-1));
            %                 plot1.Width='400px';
            %                 plot1.Height=[ num2str(floor(450/widthima*heightima)) 'px'];
            %                 add(sec41,plot1);
            
            add(sec40,Paragraph(['Another sanity check, the following figures shows the mean and median of frame intensities vs time at a given DAC at an initial gain of '  num2str(gaintab(1)) ' for Q0,Q1,Q2,Q3 (the ADC std should only be a few ADC values for both mean and median):' ]));
            plot1=Image(filenmmeanmed);
            imgStyle = {ScaleToFit(true)};
            img1 = Image(cell2mat(filenmmeanmedQ(gainkk,1)));
            img1.Style = imgStyle;
            img2=Image(cell2mat(filenmmeanmedQ(gainkk,2)));
            img2.Style = imgStyle;
            img3 = Image(cell2mat(filenmmeanmedQ(gainkk,3)));
            img3.Style = imgStyle;
            img4=Image(cell2mat(filenmmeanmedQ(gainkk,4)));
            img4.Style = imgStyle;
            %Insert images in the row of a 1x3, invisible layout table (lot).
            
            lot = Table({img1, ' ', img2; img3, ' ', img4});
            %The images will be sized to fit the table entries only if their height and width is specified.
            
            lot.entry(1,1).Style = {Width('3.2in'), Height('3in')};
            lot.entry(1,2).Style = {Width('.2in'), Height('3in')};
            lot.entry(1,3).Style = {Width('3.2in'), Height('3in')};
            lot.entry(2,1).Style = {Width('3.2in'), Height('3in')};
            lot.entry(2,2).Style = {Width('.2in'), Height('3in')};
            lot.entry(2,3).Style = {Width('3.2in'), Height('3in')};
            %Make the table span the width of the page between the margins. Tell the table layout manager to not resize the table columns to fit the images.
            
            lot.Style = {ResizeToFitContents(false), Width('100%')};
            %Generate and display the report.
            
            add(sec40, lot);
            %                 widthch=plot1.Width;
            %                 widthima=str2num(widthch(1:strfind(widthch,'px')-1));
            %                 heightch=plot1.Height;
            %                 heightima=str2num(heightch(1:strfind(heightch,'px')-1));
            %                 plot1.Width='400px';
            %                 plot1.Height=[ num2str(floor(450/widthima*heightima)) 'px'];
            %                 add(sec41,plot1);
            
            
            
            add(sec4,sec40);
            
            %  add(sec40,sec41);
            %  add(sec4,sec42);
            
            
        end
        
        
        
    end
    
end

if makereport==1
%%add DAC vs pe coeffs table
sec42 = Section;
sec42.Title = ['ADC = M pe# + N'];
add(sec42,Paragraph(['Coefficients of the linear function ADC = C DAC + D and ADC = M pe# + N are given in the following table.' ]));
add(sec42,Paragraph(['C, D coefficients are deduced from PH-mode dark ADC data using a specific pixel on each quadrant.' ]));
add(sec42,Paragraph(['M, N coefficients are deduced from A,B,C,D coeffcients such as' ]));
add(sec42,Paragraph(['M = A C g' ]));
add(sec42,Paragraph(['and' ]));
add(sec42,Paragraph(['N = BC + D' ]));
add(sec42,Paragraph(['For the relationship to be scalable to any gain, the coefficient M'' is recorded as' ]));
add(sec42,Paragraph(['M'' = A C' ]));

add(sec42,Paragraph(['The following table gives C, D, M, N coefficients for Quadrants#0,1,2,3.']));
tableStyle = ...
    { ...
    Width("100%"), ...
    Border("solid"), ...
    RowSep("solid"), ...
    ColSep("solid") ...
    };

tableEntriesStyle = ...
    { ...
    HAlign("center"), ...
    VAlign("middle") ...
    };

headerRowStyle = ...
    { ...
    InnerMargin("2pt","2pt","2pt","2pt"), ...
    BackgroundColor("gray"), ...
    Bold(true) ...
    };
grps(1) = TableColSpecGroup;
grps(1).Span = 11;

%specs=[];
specs2(1) = TableColSpec;
specs2(1).Span = 1;
specs2(1).Style = {Width("8%")};

specs2(2) = TableColSpec;
specs2(2).Span = 1;
specs2(2).Style = {Width("12%")};

specs2(3) = TableColSpec;
specs2(3).Span = 1;
specs2(3).Style = {Width("16%")};

specs2(4) = TableColSpec;
specs2(4).Span = 1;
specs2(4).Style = {Width("16%")};

specs2(5) = TableColSpec;
specs2(5).Span = 1;
specs2(5).Style = {Width("16%")};

specs2(6) = TableColSpec;
specs2(6).Span = 1;
specs2(6).Style = {Width("16%")};

specs2(7) = TableColSpec;
specs2(7).Span = 1;
specs2(7).Style = {Width("16%")};


grps(1).ColSpecs = specs2;
headerContent = ...
    { ...
    ' ', ['Gain ini'], ['C'], ['D' ], ['M'], ['M'''], ['N'] ...
    };

bodyContent = ...
    { ...
    'Q0', [num2str( gaintabtab(1))], ...
    [num2str( ADCDACtabQ(1,1,1))], ...
    [num2str( ADCDACtabQ(1,1,2))], ...
    [num2str( ADCDACtabQ(1,1,3))], ...
    [num2str( ADCDACtabQ(1,1,3)/gaintabtab(1))], ...
    [num2str( ADCDACtabQ(1,1,4))] ...
    ; ...
    'Q0', [num2str( gaintabtab(2))], ...
    [num2str( ADCDACtabQ(2,1,1))], ...
    [num2str( ADCDACtabQ(2,1,2))], ...
    [num2str( ADCDACtabQ(2,1,3))], ...
    [num2str( ADCDACtabQ(2,1,3)/gaintabtab(2))], ...
    [num2str( ADCDACtabQ(2,1,4))] ...
    ; ...
    'Q1', [num2str(  gaintabtab(1))], ...
    [num2str( ADCDACtabQ(1,2,1))], ...
    [num2str( ADCDACtabQ(1,2,2))], ...
    [num2str( ADCDACtabQ(1,2,3))], ...
    [num2str( ADCDACtabQ(1,2,3)/gaintabtab(1))], ...
    [num2str( ADCDACtabQ(1,2,4))] ...
    ; ...
    'Q1', [num2str(  gaintabtab(2))], ...
    [num2str( ADCDACtabQ(2,2,1))], ...
    [num2str( ADCDACtabQ(2,2,2))], ...
    [num2str( ADCDACtabQ(2,2,3))], ...
    [num2str( ADCDACtabQ(2,2,3)/gaintabtab(2))], ...
    [num2str( ADCDACtabQ(2,2,4))] ...
    ; ...
    'Q2', [num2str(  gaintabtab(1))], ...
    [num2str( ADCDACtabQ(1,3,1))], ...
    [num2str( ADCDACtabQ(1,3,2))], ...
    [num2str( ADCDACtabQ(1,3,3))], ...
    [num2str( ADCDACtabQ(1,3,3)/gaintabtab(1))], ...
    [num2str( ADCDACtabQ(1,3,4))] ...
    ; ...
    'Q2', [num2str(  gaintabtab(2))], ...
    [num2str( ADCDACtabQ(2,3,1))], ...
    [num2str( ADCDACtabQ(2,3,2))], ...
    [num2str( ADCDACtabQ(2,3,3))], ...
    [num2str( ADCDACtabQ(2,3,3)/gaintabtab(2))], ...
    [num2str( ADCDACtabQ(2,3,4))] ...
    ; ...
    'Q3', [num2str(  gaintabtab(1))], ...
    [num2str( ADCDACtabQ(1,4,1))], ...
    [num2str( ADCDACtabQ(1,4,2))], ...
    [num2str( ADCDACtabQ(1,4,3))], ...
    [num2str( ADCDACtabQ(1,4,3)/gaintabtab(1))], ...
    [num2str( ADCDACtabQ(1,4,4))] ...
    ; ...
    'Q3', [num2str(  gaintabtab(2))], ...
    [num2str( ADCDACtabQ(2,4,1))], ...
    [num2str( ADCDACtabQ(2,4,2))], ...
    [num2str( ADCDACtabQ(2,4,3))], ...
    [num2str( ADCDACtabQ(2,4,3)/gaintabtab(2))], ...
    [num2str( ADCDACtabQ(2,4,4))] ...
    };
tableContent = [headerContent; bodyContent];

table = Table(tableContent);
table.ColSpecGroups = grps;

table.Style = tableStyle;
table.TableEntriesStyle = tableEntriesStyle;

firstRow = table.Children(1);
firstRow.Style = headerRowStyle;

add(sec42,table);

%                 tableADCvsDAC=BaseTable({' ' ['Gain ini'] ['C'] ['D' ] ['G'] ['G'''] ['H'] ...
%                     ; ...
%
%                     });
%                 add(sec42,tableADCvsDAC);
add(sec4,sec42);

end

%save([getuserdir '\panoseti\Calibrations\' 'ADCDACmap_gain' num2str(gaintab(1)) '.mat'],'ADCDACtab')
% ADCDACtabG=zeros(20,4,4);
load([getuserdir '\panoseti\Calibrations\' 'ADCDACcoeffs_gain' num2str(gaintab(1)) '.mat'],'ADCDACtabG')
ADCDACtabG(inddetrow,:,:)=ADCDACtabQ; %only one gain valueotherwise it will bug
save([getuserdir '\panoseti\Calibrations\' 'ADCDACcoeffs_gain' num2str(gaintab(1)) '.mat'],'ADCDACtabG')

%%%%%%%%%%


if makereport==1
    
    add(rpt,sec4);
    %  sec4 = Section;
end

tadc=toc;
%%%%%%%%%%
%%%%%%%%%%
%%%%%
%%%%%%%%%%