tic

figini;
close all
load('MarocMap.mat');
nim=100;
peval=2.5;

%makereport=0;

    if makereport==1
        import mlreportgen.report.*
        import mlreportgen.dom.*
        sec3 = Section;
                sec3.Title = 'Gain calibration';
                  logm12 = {Color('black'),FontFamily(),FontSize('12pt'),WhiteSpace('preserve')};
        
                  para = Paragraph(['In this section, the gain between pixels are adjusted ' ...
                      'such as the pe steps between pixels get aligned. The procedure starts with ' ...
                      'the same initial gain value on all pixels. Cps curves for all pixels are measured with darks, which are then used to detect pe steps in terms of ' ...
                      'their DAC values. The 2-pe step DAC value is compared to the reference pixel 2-pe step DAC to determine if the gain ' ...
                          'on that pixel should be incremented or decremented.']);para.Style=logm12; add(sec3,para)
                                        para = Paragraph(['This section shows initial cps curves before gain adjustment ' ...
                          '(same Maroc gain value on each pixel) and final adjusted cps curves. ' ...
                          '']); para.Style=logm12; add(sec3,para)
  
                    secB = Section;
    secB.Title = ['DAC vs PE relationship'];
    end

datenow1=datestr(now,'yymmddHHMMSS');

quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config.txt']);
quaboconfig(szq+1,1)={'IP'};quaboconfig(szq+1,3)={IP};

[ig,indexstimon]=ismember(['STIMON '] ,quaboconfig);
quaboconfig(indexstimon,2)={"0"};

[ig,indexacqint]=ismember(['ACQINT '] ,quaboconfig);
acqint=(1e-5)*str2num(quaboconfig(indexacqint,2));
exposurestr=['Exposure time [ms]:' num2str(1000*acqint,'%3.3g')];
normcps=1/acqint;

[ig,indexacqmode]=ismember(['ACQMODE '] ,quaboconfig);
quaboconfig(indexacqmode,2)={"0x02"};

gaintaballg=[40 60];
coeffsallg=[];gainmapallg=[];pestepfigcell=cell(numel(gaintaballg),4);cpsfinalfigcell=cell(numel(gaintaballg));
cpsfitA=zeros(16,16,numel(gaintaballg)); cpsfitB=zeros(16,16,numel(gaintaballg));
 pestepImadac=zeros(4,numel(gaintaballg),3); pestepImacps=zeros(4,numel(gaintaballg),3);  
for igg=1:numel(gaintaballg)
    pausetime=1.;
    indcol=1:4;
    %set gain
    gaintab=gaintaballg(igg);%33;
    quaboconfig = changegain(gaintab(1), quaboconfig,0); % third param is using an adjusted gain map (=1) or not (=0)
    
    
    %set masks MASKOR1&2
    maskmode=0;
    quaboconfig = changemask(maskmode,[],quaboconfig); %maskmode: unmask all pix (=0); mask all excepted some (=1)
    %quaboconfig = changemask(1,[2 1;2 2; 2 3 ; 2 4],quaboconfig); %maskmode: unmask all pix (=0); mask all excepted some (=1)
    
    masklabel='No mask.'
    % wakeup the board
    disp('Init Marocs...')
    %put high thresh on all 4 quads
    [ia,indexdac]=ismember('DAC1',quaboconfig);
    dactabH0=500;
    quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactabH0)]};
    sendconfig2Maroc(quaboconfig)
    disp('Waiting 3s...')
    pause(3)
    disp('Init Acq...')
    sentacqparams2board(quaboconfig)
    disp('Waiting 3s...')
    pause(3)
    
    gainmap=zeros(16,16);
    gainmap(:,:)=gaintab;
    
    loopgain=1;
    loopgaincnt=0;
    
    dactabmax=round(190+0.325*gaintab(1)*4)
    dactab=[180:1:dactabmax ];
    
    
    residuQ0=[]; residuQ1=[]; residuQ2=[]; residuQ3=[];
    
    while loopgain==1
        loopgaincnt=loopgaincnt+1;
        loopgaincnt1=loopgaincnt;
        
        figure
        [ia,indexdac]=ismember('DAC1',quaboconfig);
        
        %put high thresh on all 4 quads
        %     dactabH0=500;
        %     quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactabH0)]};
        %    % pause(pausetime)
        
        IntensmeanQ0=[];IntensmeanQ1=[];IntensmeanQ2=[];IntensmeanQ3=[];IntensmeanQ8=[];IntensmeanQ9=[];
        allima=zeros(16,16,numel(dactab),numel(indcol));
        indcol2=1;
        for dd=1:numel(dactab)
            quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactab(dd))]};
            disp(['Sending Maroc comm...DAC1:' num2str(dactab(dd)) '/' num2str(dactab(end)) ' Gain' num2str(gaintab) ' iter' num2str(loopgaincnt)  ])
            sendconfig2Maroc(quaboconfig)
            
            %timepause=10;
            %disp(['Q' num2str(indcol2) '  ' num2str( timepause*(numel(dactab)-dd)) 's left...'])
            pause(pausetime)
            %pause(pausetime)
            images=grabimages(nim,1,1);
            
            meanimage=mean(images(:,:,:),[3])';
            allima(:,:,dd,indcol2)=meanimage;
            
            imagesc(meanimage)
            colorbar
            pause(0.5)
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
            close
            %  IntensmaxQ1(nima)=max(ima(9:16,1:8),[],'all');
            %         IntensmeanQ0=[IntensmeanQ0 mean(meanimage(9:16,1:8),[1 2])];
            %         % IntensmaxQ2(nima)=max(ima(1:8,1:8),[],'all');
            %         IntensmeanQ1=[IntensmeanQ1 mean(meanimage(1:8,1:8),[1 2])];
            %         %   IntensmaxQ3(nima)=max(ima(1:8,9:16),[],'all');
            %         IntensmeanQ2=[IntensmeanQ2 mean(meanimage(1:8,9:16),[1 2])];
            %         %   IntensmaxQ4(nima)=max(ima(9:16,9:16),[],'all');
            %         IntensmeanQ3=[IntensmeanQ3 mean(meanimage(9:16,9:16),[1 2])];
            %   IntensmaxQ4(nima)=max(ima(9:16,9:16),[],'all');
            IntensmeanQ8=[IntensmeanQ8 (meanimage(1,7))];
            
            
        end
        %  %put high thresh on all 4 quads
        % dactabH0=500;
        %  quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactabH0)]};
        %  pause(pausetime)
        % indcol2=2;
        % for dd=1:numel(dactab)
        %  quaboconfig(indexdac,indcol2+1)={['0x' dec2hex(dactab(dd))]};
        %  disp(['Sending Maroc comm...DAC1:' num2str(dactab(dd))])
        % sendconfig2Maroc(quaboconfig)
        % % disp(['Q' num2str(indcol2) '  ' num2str( timepause*(numel(dactab)-dd)) 's left...'])
        %
        % pause(pausetime)
        % %timepause=10;
        %    % pause(timepause)
        %     images=grabimages(10,1,1);
        %     figure
        %     meanimage=mean(images(:,:,:),[3])';
        %     allima(:,:,dd,indcol2)=meanimage;
        %
        %     imagesc(meanimage)
        %     colorbar
        %     timenow=now;
        %     import matlab.io.*
        %     utcshift=7/24;
        %     filename = ['b_d0w0m0q0_' datestr(timenow+utcshift,'yyyymmdd_HHMMSS_FFF') ];
        %     fullfilename=[ getuserdir '\panoseti\DATA\' filename];
        %     fptr = fits.createFile([fullfilename '.fits']);
        %
        %     fits.createImg(fptr,'int32',[16 16]);
        %     %fitsmode='overwrite';
        %     img=int32(meanimage);
        %     fits.writeImg(fptr,img)
        %     fits.closeFile(fptr);
        %
        %         %  IntensmaxQ1(nima)=max(ima(9:16,1:8),[],'all');
        %    % IntensmeanQ0=[IntensmeanQ0 mean(meanimage(9:16,1:8),[1 2])];
        %     % IntensmaxQ2(nima)=max(ima(1:8,1:8),[],'all');
        %     IntensmeanQ1=[IntensmeanQ1 mean(meanimage(1:8,1:8),[1 2])];
        %     %   IntensmaxQ3(nima)=max(ima(1:8,9:16),[],'all');
        %     %IntensmeanQ2=[IntensmeanQ2 mean(meanimage(1:8,9:16),[1 2])];
        %     %   IntensmaxQ4(nima)=max(ima(9:16,9:16),[],'all');
        %     %IntensmeanQ3=[IntensmeanQ3 mean(meanimage(9:16,9:16),[1 2])];
        %
        %
        % end
        %  %put high thresh on all 4 quads
        % dactabH0=500;
        %  quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactabH0)]};
        %  pause(pausetime)
        % indcol2=3;
        % for dd=1:numel(dactab)
        %  quaboconfig(indexdac,indcol2+1)={['0x' dec2hex(dactab(dd))]};
        %  disp('Sending Maroc comm...')
        % sendconfig2Maroc(quaboconfig)
        %  disp(['Q' num2str(indcol2) '  ' num2str( timepause*(numel(dactab)-dd)) 's left...'])
        %
        % pause(pausetime)
        % %timepause=10;
        %     %pause(pausetime)
        %     images=grabimages(10,1,1);
        %     figure
        %     meanimage=mean(images(:,:,:),[3])';
        %     allima(:,:,dd,indcol2)=meanimage;
        %
        %     imagesc(meanimage)
        %     colorbar
        %     timenow=now;
        %     import matlab.io.*
        %     utcshift=7/24;
        %     filename = ['b_d0w0m0q0_' datestr(timenow+utcshift,'yyyymmdd_HHMMSS_FFF') ];
        %     fullfilename=[ getuserdir '\panoseti\DATA\' filename];
        %     fptr = fits.createFile([fullfilename '.fits']);
        %
        %     fits.createImg(fptr,'int32',[16 16]);
        %     %fitsmode='overwrite';
        %     img=int32(meanimage);
        %     fits.writeImg(fptr,img)
        %     fits.closeFile(fptr);
        %
        %         %  IntensmaxQ1(nima)=max(ima(9:16,1:8),[],'all');
        %    % IntensmeanQ0=[IntensmeanQ0 mean(meanimage(9:16,1:8),[1 2])];
        %     % IntensmaxQ2(nima)=max(ima(1:8,1:8),[],'all');
        %     %IntensmeanQ1=[IntensmeanQ1 mean(meanimage(1:8,1:8),[1 2])];
        %     %   IntensmaxQ3(nima)=max(ima(1:8,9:16),[],'all');
        %     IntensmeanQ2=[IntensmeanQ2 mean(meanimage(1:8,9:16),[1 2])];
        %     %   IntensmaxQ4(nima)=max(ima(9:16,9:16),[],'all');
        %    % IntensmeanQ3=[IntensmeanQ3 mean(meanimage(9:16,9:16),[1 2])];
        %
        %
        % end
        %  %put high thresh on all 4 quads
        % dactabH0=500;
        %  quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactabH0)]};
        %  pause(pausetime)
        % indcol2=4;
        % for dd=1:numel(dactab)
        %  quaboconfig(indexdac,indcol2+1)={['0x' dec2hex(dactab(dd))]};
        %  disp('Sending Maroc comm...')
        % sendconfig2Maroc(quaboconfig)
        %  disp(['Q' num2str(indcol2) '  ' num2str( timepause*(numel(dactab)-dd)) 's left...'])
        %
        % pause(pausetime)
        % %timepause=10;
        %    % pause(timepause)
        %     images=grabimages(10,1,1);
        %     figure
        %     meanimage=mean(images(:,:,:),[3])';
        %     allima(:,:,dd,indcol2)=meanimage;
        %
        %     imagesc(meanimage)
        %     colorbar
        %     timenow=now;
        %     import matlab.io.*
        %     utcshift=7/24;
        %     filename = ['b_d0w0m0q0_' datestr(timenow+utcshift,'yyyymmdd_HHMMSS_FFF') ];
        %     fullfilename=[ getuserdir '\panoseti\DATA\' filename];
        %     fptr = fits.createFile([fullfilename '.fits']);
        %
        %     fits.createImg(fptr,'int32',[16 16]);
        %     %fitsmode='overwrite';
        %     img=int32(meanimage);
        %     fits.writeImg(fptr,img)
        %     fits.closeFile(fptr);
        %
        %         %  IntensmaxQ1(nima)=max(ima(9:16,1:8),[],'all');
        %     %IntensmeanQ0=[IntensmeanQ0 mean(meanimage(9:16,1:8),[1 2])];
        %     % IntensmaxQ2(nima)=max(ima(1:8,1:8),[],'all');
        %     %IntensmeanQ1=[IntensmeanQ1 mean(meanimage(1:8,1:8),[1 2])];
        %     %   IntensmaxQ3(nima)=max(ima(1:8,9:16),[],'all');
        %     %IntensmeanQ2=[IntensmeanQ2 mean(meanimage(1:8,9:16),[1 2])];
        %     %   IntensmaxQ4(nima)=max(ima(9:16,9:16),[],'all');
        %     IntensmeanQ3=[IntensmeanQ3 mean(meanimage(9:16,9:16),[1 2])];
        %
        
        %end
        
        allima2=allima(:,:,:,1);
        %%fitting cps curves
        %remove left part
        
        
        for ii=1:16
            for jj=1:16
                curv= normcps*squeeze(allima2(jj,ii,:))';
                intenmax0pt=5e3;
                darkref =find(fliplr(curv)>intenmax0pt);
                if numel(darkref)>0
                daczeropointleft=fliplr(dactab(darkref(1)));
                curv=curv(end-darkref(1)+1:end);
                %put Nan instead of zeros at high dacs
                
                indzeroright=find(curv==0);
                if numel(indzeroright)>0
                    indcutright=indzeroright(1)-1;
                    curv=curv(1:indcutright);
                else
                    indcutright=numel(curv);
                end
                if numel(curv)>1
                    [countfit, gof] = fit(transpose(squeeze(dactab(end-darkref(1)+1:end-darkref(1)+1+indcutright-1))),log10(curv)', 'poly1')
                    cpsfitA(jj,ii,igg)=countfit.p1;
                    cpsfitB(jj,ii,igg)=countfit.p2;
                end
                end
            end
        end
        
        
        
        mainfig=figure('Position',[50 50 1600 900])
        hold on
        figquad=0;
        if figquad==1
            % plot(dactab, IntensmeanQ0,'-+b')
            %  plot(dactab, IntensmeanQ1,'-+r')
            %  plot(dactab, IntensmeanQ2,'-+g')
            %  plot(dactab, IntensmeanQ3,'-+m')
            plot(dactab, IntensmeanQ8,'-+k')
        else
            
            subplot(2,2,1)
            hold on
            for ii=1:8
                for jj=9:16
                    plot(dactab, normcps * squeeze(allima2(jj,ii,:)),'-+','Color',[0.5 ii/8 jj/16])
                end
            end
            hold off
            title(['Q0 Bipolar fs; Gain:' num2str(gaintab) 'd(' dec2hex(gaintab) 'h); ' masklabel])
            
            %legend('Q0')
            xlabel('Threshold DAC1 ')
            ylabel('Mean intensity [counts per second]')
            hold off
            set(gca, 'YScale','log')
            %legend('Q0','Q1','Q2','Q3','Single pix: [1,1]')
            box on
            grid on
            
            subplot(2,2,2)
            hold on
            for ii=1:8
                for jj=1:8
                    
                    plot(dactab, normcps *  squeeze(allima2(jj,ii,:)),'-+','Color',[0.5 ii/8 jj/8])
                end
            end
            hold off
            title('Q1 all pix')
            xlabel('Threshold DAC1 ')
            ylabel('Mean intensity [counts per second]')
            hold off
            set(gca, 'YScale','log')
            %legend('Q0','Q1','Q2','Q3','Single pix: [1,1]')
            box on
            grid on
            
            subplot(2,2,3)
            hold on
            for ii=9:16
                for jj=1:8
                    plot(dactab, normcps *  squeeze(allima2(jj,ii,:)),'-+','Color',[0.5 ii/16 jj/8])
                end
            end
            hold off
            title('Q2 all pix')
            xlabel('Threshold DAC1 ')
            ylabel('Mean intensity [counts per second]')
            hold off
            set(gca, 'YScale','log')
            %legend('Q0','Q1','Q2','Q3','Single pix: [1,1]')
            box on
            grid on
            
            subplot(2,2,4)
            hold on
            for ii=9:16
                for jj=9:16
                    plot(dactab, normcps *  squeeze(allima2(jj,ii,:)),'-+','Color',[0.5 ii/16 jj/16])
                end
            end
            hold off
            title('Q3 all pix')
        end
        xlabel('Threshold DAC1 ')
        ylabel('Mean intensity [counts per second]')
        hold off
        set(gca, 'YScale','log')
        %legend('Q0','Q1','Q2','Q3','Single pix: [1,1]')
        box on
        grid on
        set(gcf,'Color','w')
        xlim([dactab(1) dactab(end)])
        
        %
        % gain adjustement
        yl=[1 1e8];
        
        refpixelxyQ0=[14 7];
        refpixelxyQ1=[3 6];
        refpixelxyQ2=[3 13];
        refpixelxyQ3=[10 14];
        subplot(2,2,1)
        hold on
        plot(dactab, normcps * squeeze(allima2(refpixelxyQ0(1),refpixelxyQ0(2),:)),'-o','Color',[0.5 0.5 0.5],'LineWidth',3.5)
        hold off
        title(['Q0 all pix, Gain ini:' num2str(gaintab) ' ITER#:' num2str(loopgaincnt) ' Ref. pt: 2 pe,' ' no mask' ])
        
        % title([' ITER#' num2str(loopgaincnt)])
        ylim(yl)
        subplot(2,2,2)
        hold on
        plot(dactab, normcps * squeeze(allima2(refpixelxyQ1(1),refpixelxyQ1(2),:)),'-o','Color',[0.5 0.5 0.5],'LineWidth',3.5)
        hold off
        ylim(yl)
        subplot(2,2,3)
        hold on
        plot(dactab,normcps * squeeze(allima2(refpixelxyQ2(1),refpixelxyQ2(2),:)),'-o','Color',[0.5 0.5 0.5],'LineWidth',3.5)
        hold off
        ylim(yl)
        subplot(2,2,4)
        hold on
        plot(dactab, normcps * squeeze(allima2(refpixelxyQ3(1),refpixelxyQ3(2),:)),'-o','Color',[0.5 0.5 0.5],'LineWidth',3.5)
        hold off
        ylim(yl)
        
        
        % find(marocmap(:,:,1)==refpixelxyQ0(1) & marocmap(:,:,2)==refpixelxyQ0(2));
        % find(marocmap(:,:,1)==refpixelxyQ1(1) & marocmap(:,:,2)==refpixelxyQ1(2));
        % find(marocmap(:,:,1)==refpixelxyQ2(1) & marocmap(:,:,2)==refpixelxyQ2(2));
        % find(marocmap(:,:,1)==refpixelxyQ3(1) & marocmap(:,:,2)==refpixelxyQ3(2));
        
        phdrefQ0=squeeze(allima2(refpixelxyQ0(1),refpixelxyQ0(2),:));
        phdrefQ1=squeeze(allima2(refpixelxyQ1(1),refpixelxyQ1(2),:));
        phdrefQ2=squeeze(allima2(refpixelxyQ2(1),refpixelxyQ2(2),:));
        phdrefQ3=squeeze(allima2(refpixelxyQ3(1),refpixelxyQ3(2),:));
        %identify pe steps:
        % find ind > 1pe
        %mindac=min(find(dactab>189));
        
        
        daczeropoint1=0;threshpeak=0.25;intenexpo05pe=3.0e2;startpe=2;
        if loopgaincnt==1
            darkref =find(fliplr(phdrefQ0')>intenexpo05pe);
            flipdactab=fliplr(dactab);
            daczeropoint1g0=flipdactab(darkref(1));
            steplen=floor(0.16*gaintab(1));
            peaksrefdacQ0=findpelevel(phdrefQ0,dactab,daczeropoint1g0,threshpeak,-steplen+6);
            darkref =find(fliplr(phdrefQ1')>intenexpo05pe);
            daczeropoint1g1=flipdactab(darkref(1));
            peaksrefdacQ1=findpelevel(phdrefQ1,dactab,daczeropoint1g1,threshpeak,-steplen+6);
            darkref =find(fliplr(phdrefQ2')>intenexpo05pe);
            daczeropoint1g2=flipdactab(darkref(1));
            peaksrefdacQ2=findpelevel(phdrefQ2,dactab,daczeropoint1g2,threshpeak,-steplen+6);
            darkref =find(fliplr(phdrefQ3')>intenexpo05pe);
            daczeropoint1g3=flipdactab(darkref(1));
            peaksrefdacQ3=findpelevel(phdrefQ3,dactab,daczeropoint1g3,threshpeak,-steplen+6);
        end
        
        
        %%%final image dacoffset
        % offdac=-round(0.5*(peaksrefdacQ0(2)-peaksrefdacQ0(1)));
        offdac=0;
        
        figure(mainfig)
        subplot(2,2,1)
        hold on
        plot([peaksrefdacQ0(1) peaksrefdacQ0(1)] , yl,'r--')
        plot([peaksrefdacQ0(2) peaksrefdacQ0(2)] , yl,'b--')
        plot([peaksrefdacQ0(3) peaksrefdacQ0(3)] , yl,'g--')
        tex=text(peaksrefdacQ0(1)+1 , 0.8*yl(2),[num2str(startpe) 'pe'],'Color','r','FontSize',9)
        tex=text(peaksrefdacQ0(2)+1 , 0.8*yl(2),[num2str(startpe+1) 'pe'],'Color','b','FontSize',9)
        tex=text(peaksrefdacQ0(3)+1 , 0.8*yl(2),[num2str(startpe+2) 'pe'],'Color','g','FontSize',9)
        if loopgaincnt>1
            plot([Q0refdac] , ctconvergence,'mo')
            plot([Q0refdac+offdac] , imaconvergence,'go')
        end
        hold off
        
        subplot(2,2,2)
        hold on
        plot([peaksrefdacQ1(1) peaksrefdacQ1(1)] , yl,'r--')
        plot([peaksrefdacQ1(2) peaksrefdacQ1(2)] , yl,'b--')
        plot([peaksrefdacQ1(3) peaksrefdacQ1(3)] , yl,'g--')
                tex=text(peaksrefdacQ1(1)+1 , 0.8*yl(2),[num2str(startpe) 'pe'],'Color','r','FontSize',9)
        tex=text(peaksrefdacQ1(2)+1 , 0.8*yl(2),[num2str(startpe+1) 'pe'],'Color','b','FontSize',9)
        tex=text(peaksrefdacQ1(3)+1 , 0.8*yl(2),[num2str(startpe+2) 'pe'],'Color','g','FontSize',9)
        %      plot([peaksrefdacQ0(1)+(peaksrefdacQ1(1)-peaksrefdacQ0(1)) peaksrefdacQ0(1)+(peaksrefdacQ1(1)-peaksrefdacQ0(1))] , yl,'r--')
        %      plot([peaksrefdacQ0(2)+(peaksrefdacQ1(1)-peaksrefdacQ0(1)) peaksrefdacQ0(2)+(peaksrefdacQ1(1)-peaksrefdacQ0(1))] , yl,'b--')
        %      plot([peaksrefdacQ0(3)+(peaksrefdacQ1(1)-peaksrefdacQ0(1)) peaksrefdacQ0(3)+(peaksrefdacQ1(1)-peaksrefdacQ0(1))] , yl,'g--')
        if loopgaincnt>1
            %            plot([Q0refdac+(peaksrefdacQ1(1)-peaksrefdacQ0(1))] , ctconvergence,'mo')
            %              plot([Q0refdac+(peaksrefdacQ1(1)-peaksrefdacQ0(1))+offdac] , imaconvergence,'go')
            %       plot([peaksrefdacQ1(1)-(Q0refdac-peaksrefdacQ0(1))] , ctconvergence,'mo')
            %       plot([peaksrefdacQ1(1)-(Q0refdac-peaksrefdacQ0(1))+offdac] , imaconvergence,'go')
            
        end
        hold off
        subplot(2,2,3)
        hold on
        plot([peaksrefdacQ2(1) peaksrefdacQ2(1)] , yl,'r--')
        plot([peaksrefdacQ2(2) peaksrefdacQ2(2)] , yl,'b--')
        plot([peaksrefdacQ2(3) peaksrefdacQ2(3)] , yl,'g--')
        tex=text(peaksrefdacQ2(1)+1 , 0.8*yl(2),[num2str(startpe) 'pe'],'Color','r','FontSize',9)
        tex=text(peaksrefdacQ2(2)+1 , 0.8*yl(2),[num2str(startpe+1) 'pe'],'Color','b','FontSize',9)
        tex=text(peaksrefdacQ2(3)+1 , 0.8*yl(2),[num2str(startpe+2) 'pe'],'Color','g','FontSize',9)        
        %       plot([peaksrefdacQ0(1)+(peaksrefdacQ2(1)-peaksrefdacQ0(1)) peaksrefdacQ0(1)+(peaksrefdacQ2(1)-peaksrefdacQ0(1))] , yl,'r--')
        %      plot([peaksrefdacQ0(2)+(peaksrefdacQ2(1)-peaksrefdacQ0(1)) peaksrefdacQ0(2)+(peaksrefdacQ2(1)-peaksrefdacQ0(1))] , yl,'b--')
        %      plot([peaksrefdacQ0(3)+(peaksrefdacQ2(1)-peaksrefdacQ0(1)) peaksrefdacQ0(3)+(peaksrefdacQ2(1)-peaksrefdacQ0(1))] , yl,'g--')
        %
        if loopgaincnt>1
            %            plot([Q0refdac+(peaksrefdacQ2(1)-peaksrefdacQ0(1))] , ctconvergence,'mo')
            %              plot([Q0refdac+(peaksrefdacQ2(1)-peaksrefdacQ0(1))+offdac] , imaconvergence,'go')
            %    plot([peaksrefdacQ2(1)-(Q0refdac-peaksrefdacQ0(1))] , ctconvergence,'mo')
            %      plot([peaksrefdacQ2(1)-(Q0refdac-peaksrefdacQ0(1))+offdac] , imaconvergence,'go')
            
        end
        hold off
        subplot(2,2,4)
        hold on
        plot([peaksrefdacQ3(1) peaksrefdacQ3(1)] , yl,'r--')
        plot([peaksrefdacQ3(2) peaksrefdacQ3(2)] , yl,'b--')
        plot([peaksrefdacQ3(3) peaksrefdacQ3(3)] , yl,'g--')
                tex=text(peaksrefdacQ3(1)+1 , 0.8*yl(2),[num2str(startpe) 'pe'],'Color','r','FontSize',9)
        tex=text(peaksrefdacQ3(2)+1 , 0.8*yl(2),[num2str(startpe+1) 'pe'],'Color','b','FontSize',9)
        tex=text(peaksrefdacQ3(3)+1 , 0.8*yl(2),[num2str(startpe+2) 'pe'],'Color','g','FontSize',9)
        %      plot([peaksrefdacQ0(1)+(peaksrefdacQ3(1)-peaksrefdacQ0(1)) peaksrefdacQ0(1)+(peaksrefdacQ3(1)-peaksrefdacQ0(1))] , yl,'r--')
        %      plot([peaksrefdacQ0(2)+(peaksrefdacQ3(1)-peaksrefdacQ0(1)) peaksrefdacQ0(2)+(peaksrefdacQ3(1)-peaksrefdacQ0(1))] , yl,'b--')
        %      plot([peaksrefdacQ0(3)+(peaksrefdacQ3(1)-peaksrefdacQ0(1)) peaksrefdacQ0(3)+(peaksrefdacQ3(1)-peaksrefdacQ0(1))] , yl,'g--')
        if loopgaincnt>1
            %            plot([Q0refdac+(peaksrefdacQ3(1)-peaksrefdacQ0(1))] , ctconvergence,'mo')
            %             plot([Q0refdac+(peaksrefdacQ3(1)-peaksrefdacQ0(1))+offdac] , imaconvergence,'go')
            %    plot([peaksrefdacQ3(1)-(Q0refdac-peaksrefdacQ0(1))] , ctconvergence,'mo')
            %     plot([peaksrefdacQ3(1)-(Q0refdac-peaksrefdacQ0(1))+offdac] , imaconvergence,'go')
            
        end
        hold off
        
        
        
        
        saveas(gcf,[calibdir 'cpsadjustGain' num2str(gaintab) '_' datenow1 '_' num2str(loopgaincnt) '.png'])
        saveas(gcf,[calibdir 'cpsadjustGain' num2str(gaintab) '_' datenow1 '_' num2str(loopgaincnt) '.fig'])
        
        
        frame = getframe(gcf);
        im = frame2im(frame); %,
        [imind,cm] = rgb2ind(im,256);
        delay=0.5;
        if loopgaincnt == 1;
            cpsname=[calibdir 'cpsGain' num2str(gaintab) '_' num2str(loopgaincnt) '_' datenow1 '.gif'];
            imwrite(imind,cm,cpsname,'gif', 'Loopcount',inf,'DelayTime',delay);%,'ScreenSize',[640 640]
        else
            imwrite(imind,cm,cpsname,'gif','WriteMode','append','DelayTime',delay);
        end
        close
        %%%QUAD# 0 
        %%check example:
        residu0=0;
        iitest=3;jjtest=11;
        for ii=1:8
            for jj=9:16
                %if (jj~= refpixelxyQ0(1)) || (ii~= refpixelxyQ0(2))
                testpixelxy=[jj ii];
                %testpixelxy(1)=testpixelxy(1);
                if 1==0 && ii==iitest && jj==jjtest
                    subplot(2,2,1)
                    hold on
                    plot(dactab,  squeeze(allima2(testpixelxy(1),testpixelxy(2),:)),'-d','Color',[0.2 0.2 0.2],'LineWidth',3.4)
                    
                    hold off
                    
                end
                
                phdtestQ0=squeeze(allima2(testpixelxy(1),testpixelxy(2),:));
                % peakstestdacQ0=findpelevel(phdtestQ0,dactab,daczeropoint1,threshpeak);
                [minval minindr1]= min( abs(peaksrefdacQ0(1) - dactab));
                heightdacref=peaksrefdacQ0(4-startpe);
                [minval minindr3]= min( abs(heightdacref - dactab));
                if loopgaincnt==1
                    ctconvergence= phdrefQ0(minindr3);
                    imaconvergence= phdrefQ0(minindr3+offdac)
                    %  Q0refdac=peakstestdacQ0;
                end
                [minval minind]= min( abs(phdtestQ0(minindr1:end)-ctconvergence)) ;
                
                peakstestdacQ0=minindr1-1+minind;
                
                %metric residu
                residu0=residu0+(phdtestQ0(minindr3)-ctconvergence)^2;
                
                if loopgaincnt==1
                    % ctconvergence= phdrefQ0(minindr3);
                    Q0refdac=heightdacref;%dactab(1)-1+peakstestdacQ0;
                end
                
                %find sep between pe and shift between pix
                if numel(peakstestdacQ0)>=1
                    peaksepQ0=dactab(1)-1+peakstestdacQ0(1)-Q0refdac;
                    %peaksepQ0=peakstestdacQ0(1:3)-peaksrefdacQ0(1:3);
                    %peaksep=peakstestdac(3)-peaksrefdac(3);
                    peakmoveQ0=sign(round(mean(peaksepQ0)));
                    
                    
                    % disp(['pe levels REFpix found at dac: ' num2str(peaksrefdacQ0)])
                    %disp(['pe levels TestPix found at dac: ' num2str(peakstestdacQ0)])
                    
                    %get old gain and increment it
                    [ig,indexgain]=ismember(['GAIN' num2str(marocmap16(testpixelxy(1),testpixelxy(2),1)-1)] ,quaboconfig);
                    gainpixold=char(quaboconfig(indexgain,marocmap16(testpixelxy(1),testpixelxy(2),2)+1));
                    gainpixnew=dec2hex(hex2dec(gainpixold(3:4))-peakmoveQ0);
                    gainmap(testpixelxy(1),testpixelxy(2))=(hex2dec(gainpixold(3:4))-peakmoveQ0);
                    quaboconfig(indexgain,marocmap16(testpixelxy(1),testpixelxy(2),2)+1)={['0x' gainpixnew]};
                    
                    if ii==iitest && jj==jjtest
                        disp(['pe levels REFpix found at dac: ' num2str(peaksrefdacQ0)])
                        disp(['pe levels TestPix found at dac: ' num2str(peakstestdacQ0)])
                        disp(['pe separation in dac: ' num2str(peaksepQ0)])
                        disp(['pe suggested move in dac: ' num2str(peakmoveQ0)])
                        disp(['New Gain (dec): ' num2str(gainmap(testpixelxy(1),testpixelxy(2)))])
                        disp(['gain old: ' num2str(hex2dec(gainpixold(3:4)))])
                        disp(['gain new: ' num2str(hex2dec(gainpixnew))])
                    end
                    
                end
                % end
            end
        end
        residuQ0=[residuQ0 residu0];
        
        
        %%%QUAD# 1
        %%check example:  
        iitest=2;jjtest=6;
        residu1=0;
        for ii=1:8
            for jj=1:8
                %   if (jj~= refpixelxyQ1(1)) || (ii~= refpixelxyQ1(2))
                testpixelxy=[jj ii];
                %testpixelxy(1)=testpixelxy(1);
                if 1==0 && ii==iitest && jj==jjtest
                    subplot(2,2,2)
                    hold on
                    
                    plot(dactab,  squeeze(allima2(testpixelxy(1),testpixelxy(2),:)),'-d','Color',[0.2 0.2 0.2],'LineWidth',3.4)
                    
                    hold off
                    
                end
                
                phdtestQ1=squeeze(allima2(testpixelxy(1),testpixelxy(2),:));
                % peakstestdacQ1=findpelevel(phdtestQ1,dactab,daczeropoint1,threshpeak);
                [minval minindr1]= min( abs(peaksrefdacQ1(1) - dactab));
                [minval minindr3]= min( abs(peaksrefdacQ1(4-startpe) - dactab));
                %              [minval minind]= min( abs(phdtestQ1(minindr1:end)-phdrefQ1(minindr3))) ;
                %             peakstestdacQ1=peaksrefdacQ1(1)-1+minind;
                %
                [minval minind]= min( abs(phdtestQ1(minindr1:end)-ctconvergence)) ;
                peakstestdacQ1=minindr1-1+minind;
                
                %metric residu
                residu1=residu1+(phdtestQ1(minindr3)-ctconvergence)^2;
                
                %find sep between pe and shift between pix
                if numel(peakstestdacQ1)>=1
                    peaksepQ1=dactab(1)-1+peakstestdacQ1(1)-peaksrefdacQ1(1)-(Q0refdac-peaksrefdacQ0(1));
                    %peaksepQ1=peakstestdacQ1(1:3)-peaksrefdacQ1(1:3);
                    %peaksep=peakstestdac(3)-peaksrefdac(3);
                    peakmoveQ1=sign(round(mean(peaksepQ1)));
                    
                    
                    %disp(['pe levels REFpix found at dac: ' num2str(peaksrefdacQ1)])
                    %disp(['pe levels TestPix found at dac: ' num2str(peakstestdacQ1)])
                    
                    %get old gain and increment it
                    [ig,indexgain]=ismember(['GAIN' num2str(marocmap16(testpixelxy(1),testpixelxy(2),1)-1)] ,quaboconfig);
                    gainpixold=char(quaboconfig(indexgain,marocmap16(testpixelxy(1),testpixelxy(2),2)+1));
                    gainpixnew=dec2hex(hex2dec(gainpixold(3:4))-peakmoveQ1);
                    gainmap(testpixelxy(1),testpixelxy(2))=(hex2dec(gainpixold(3:4))-peakmoveQ1);
                    quaboconfig(indexgain,marocmap16(testpixelxy(1),testpixelxy(2),2)+1)={['0x' gainpixnew]};
                    
                    if ii==iitest && jj==jjtest
                        disp(['pe levels REFpix Q1 found at dac: ' num2str(peaksrefdacQ1)])
                        disp(['pe levels TestPix Q1 found at dac: ' num2str(peakstestdacQ1)])
                        disp(['pe separation Q1 in dac: ' num2str(peaksepQ1)])
                        disp(['pe suggested move in dac: ' num2str(peakmoveQ1)])
                        disp(['New Gain (dec): ' num2str(gainmap(testpixelxy(1),testpixelxy(2)))])
                        disp(['gain old: ' num2str(hex2dec(gainpixold(3:4)))])
                        disp(['gain new: ' num2str(hex2dec(gainpixnew))])
                    end
                    
                    %  end
                end
            end
        end
        residuQ1=[residuQ1 residu1];
        
        %%%QUAD# 2
        %%check example:
        iitest=11;jjtest=6;
        residu2=0; 
        for ii=9:16
            for jj=1:8
                %  if (jj~= refpixelxyQ2(1)) || (ii~= refpixelxyQ2(2))
                testpixelxy=[jj ii];
                %testpixelxy(1)=testpixelxy(1);
                if 1==0 && ii==iitest && jj==jjtest
                    subplot(2,2,3)
                    hold on
                    plot(dactab,  squeeze(allima2(testpixelxy(1),testpixelxy(2),:)),'-d','Color',[0.2 0.2 0.2],'LineWidth',3.4)
                    
                    hold off
                    
                end
                
                phdtestQ2=squeeze(allima2(testpixelxy(1),testpixelxy(2),:));
                % peakstestdacQ2=findpelevel(phdtestQ2,dactab,daczeropoint1,threshpeak);
                [minval minindr1]= min( abs(peaksrefdacQ2(1) - dactab));
                [minval minindr3]= min( abs(peaksrefdacQ2(4-startpe) - dactab));
                %              [minval minind]= min( abs(phdtestQ2(minindr1:end)-phdrefQ2(minindr3))) ;
                %             peakstestdacQ2=peaksrefdacQ2(1)-1+minind;
                [minval minind]= min( abs(phdtestQ2(minindr1:end)-ctconvergence)) ;
                peakstestdacQ2=minindr1-1+minind;
                
                %metric residu
                residu2=residu2+(phdtestQ2(minindr3)-ctconvergence)^2;
                
                
                %find sep between pe and shift between pix
                if numel(peakstestdacQ2)>=1
                    peaksepQ2=dactab(1)-1+peakstestdacQ2(1)-peaksrefdacQ2(1)-(Q0refdac-peaksrefdacQ0(1));
                    % peaksepQ2=peakstestdacQ2(1)-peaksrefdacQ0(3)+(peaksrefdacQ2(3)-peaksrefdacQ0(3));
                    %peaksepQ2=peakstestdacQ2(1:3)-peaksrefdacQ2(1:3);
                    %peaksep=peakstestdac(3)-peaksrefdac(3);
                    peakmoveQ2=sign(round(mean(peaksepQ2)));
                    
                    
                    % disp(['pe levels REFpix Q2 found at dac: ' num2str(peaksrefdacQ2)])
                    %disp(['pe levels TestPix Q2 found at dac: ' num2str(peakstestdacQ2)])
                    
                    %get old gain and increment it
                    [ig,indexgain]=ismember(['GAIN' num2str(marocmap16(testpixelxy(1),testpixelxy(2),1)-1)] ,quaboconfig);
                    gainpixold=char(quaboconfig(indexgain,marocmap16(testpixelxy(1),testpixelxy(2),2)+1));
                    gainpixnew=dec2hex(hex2dec(gainpixold(3:4))-peakmoveQ2);
                    gainmap(testpixelxy(1),testpixelxy(2))=(hex2dec(gainpixold(3:4))-peakmoveQ2);
                    quaboconfig(indexgain,marocmap16(testpixelxy(1),testpixelxy(2),2)+1)={['0x' gainpixnew]};
                    
                    if ii==iitest && jj==jjtest
                        disp(['pe levels Q2 REFpix found at dac: ' num2str(peaksrefdacQ2)])
                        disp(['pe levels Q2 TestPix found at dac: ' num2str(peakstestdacQ2)])
                        disp(['pe separation Q2 in dac: ' num2str(peaksepQ2)])
                        disp(['pe suggested Q2 move in dac: ' num2str(peakmoveQ2)])
                        disp(['New Gain Q2(dec): ' num2str(gainmap(testpixelxy(1),testpixelxy(2)))])
                        disp(['gain old Q2: ' num2str(hex2dec(gainpixold(3:4)))])
                        disp(['gain new: ' num2str(hex2dec(gainpixnew))])
                    end
                    
                    % end
                end
            end
        end
        residuQ2=[residuQ2 residu2];
        
        
        %%%QUAD# 3 
        %%check example:
        iitest=11;jjtest=14;
        residu3=0;
        for ii=9:16
            for jj=9:16
                %  if (jj~= refpixelxyQ3(1)) || (ii~= refpixelxyQ3(2))
                testpixelxy=[jj ii];
                %testpixelxy(1)=testpixelxy(1);
                if 1==0 && ii==iitest && jj==jjtest
                    subplot(2,2,4)
                    hold on
                    plot(dactab,  squeeze(allima2(testpixelxy(1),testpixelxy(2),:)),'-d','Color',[0.2 0.2 0.2],'LineWidth',3.4)
                    
                    hold off
                    
                end
                
                phdtestQ3=squeeze(allima2(testpixelxy(1),testpixelxy(2),:));
                % peakstestdacQ3=findpelevel(phdtestQ3,dactab,daczeropoint1,threshpeak);
                [minval minindr1]= min( abs(peaksrefdacQ3(1) - dactab));
                [minval minindr3]= min( abs(peaksrefdacQ3(4-startpe) - dactab));
                %              [minval minind]= min( abs(phdtestQ3(minindr1:end)-phdrefQ3(minindr3))) ;
                %             peakstestdacQ3=peaksrefdacQ3(1)-1+minind;
                [minval minind]= min( abs(phdtestQ3(minindr1:end)-ctconvergence)) ;
                peakstestdacQ3=minindr1-1+minind;
                
                %metric residu
                residu3=residu3+(phdtestQ3(minindr3)-ctconvergence)^2;
                %find sep between pe and shift between pix
                if numel(peakstestdacQ3)>=1
                    peaksepQ3=dactab(1)-1+peakstestdacQ3(1)-peaksrefdacQ3(1)-(Q0refdac-peaksrefdacQ0(1));
                    %peaksepQ3=peakstestdacQ3(1)-peaksrefdacQ0(3)+(peaksrefdacQ3(3)-peaksrefdacQ0(3));
                    %peaksepQ3=peakstestdacQ3(1:3)-peaksrefdacQ3(1:3);
                    %peaksep=peakstestdac(3)-peaksrefdac(3);
                    peakmoveQ3=sign(round(mean(peaksepQ3)));
                    
                    
                    %disp(['pe levels REFpix Q3 found at dac: ' num2str(peaksrefdacQ3)])
                    %disp(['pe levels TestPix Q3 found at dac: ' num2str(peakstestdacQ3)])
                    
                    %get old gain and increment it
                    [ig,indexgain]=ismember(['GAIN' num2str(marocmap16(testpixelxy(1),testpixelxy(2),1)-1)] ,quaboconfig);
                    gainpixold=char(quaboconfig(indexgain,marocmap16(testpixelxy(1),testpixelxy(2),2)+1));
                    gainpixnew=dec2hex(hex2dec(gainpixold(3:4))-peakmoveQ3);
                    gainmap(testpixelxy(1),testpixelxy(2))=(hex2dec(gainpixold(3:4))-peakmoveQ3);
                    quaboconfig(indexgain,marocmap16(testpixelxy(1),testpixelxy(2),2)+1)={['0x' gainpixnew]};
                    
                    if ii==iitest && jj==jjtest
                        disp(['pe levels REFpix Q3 found at dac: ' num2str(peaksrefdacQ3)])
                        disp(['pe levels TestPix Q3 found at dac: ' num2str(peakstestdacQ3)])
                        disp(['pe separation Q3 in dac: ' num2str(peaksepQ3)])
                        disp(['pe suggestedQ3  move in dac: ' num2str(peakmoveQ3)])
                        disp(['New Gain (dec)Q3: ' num2str(gainmap(testpixelxy(1),testpixelxy(2)))])
                        disp(['gain oldQ3: ' num2str(hex2dec(gainpixold(3:4)))])
                        disp(['gain newQ3: ' num2str(hex2dec(gainpixnew))])
                    end
                end
                %  end
            end
        end
        residuQ3=[residuQ3 residu3];
        
        figure
        hold on
        plot(residuQ0,'-b')
        plot(residuQ1,'-r')
        plot(residuQ2,'-g')
        plot(residuQ3,'-m')
        hold off
        xlabel('Iteration #')
        %  ylabel('\sum_{pix} ( phd_{pix}(dacref) - ctref(dacref))^2')
        ylabel(['( cnt_{pix}(' num2str(peval) 'pe) - cnt_{ref}(' num2str(peval) 'pe))^{2}'])
        title(['Gain initial:' num2str(gaintab) ])
        legend('Q0','Q1','Q2','Q3')
        saveas(gcf,[calibdir 'ResiduImaGain' num2str(gaintab) '_' num2str(loopgaincnt) '_' datenow1 '.png'])
        saveas(gcf,[calibdir 'ResiduImaGain' num2str(gaintab) '_' num2str(loopgaincnt) '_' datenow1 '.fig'])
        
        
        %%stop the loop if : enough iterations AND in a minimum in the
        %%oscillations
        itermax=ceil(0.25*gaintab);
        if (loopgaincnt>itermax)
            increa= sign((residuQ0(end)-residuQ0(end-1))+(residuQ1(end)-residuQ1(end-1))+(residuQ2(end)-residuQ2(end-1))+(residuQ3(end)-residuQ3(end-1)));
            if (loopgaincnt>itermax) && (increa<0)
                loopgain=0;
                disp('******  stopping iterations *******')
            end
        end
        
        %%%%put quad at right DAC 1pe and take screenshot of image and gain map
        
        %%do a final measurement of pe step location:
        darkref =find(fliplr(phdrefQ0')>intenexpo05pe);
        flipdactab=fliplr(dactab);
        daczeropoint1g0=flipdactab(darkref(1));
        steplen=floor(0.16*gaintab(1));
        [peaksrefdacQ0 filenm0]=findpelevelopt(phdrefQ0,dactab,daczeropoint1g0,threshpeak,-steplen+6,'Q0',startpe);
        darkref =find(fliplr(phdrefQ1')>intenexpo05pe);
        daczeropoint1g1=flipdactab(darkref(1));
        [peaksrefdacQ1 filenm1]=findpelevelopt(phdrefQ1,dactab,daczeropoint1g1,threshpeak,-steplen+6,'Q1',startpe);
        darkref =find(fliplr(phdrefQ2')>intenexpo05pe);
        daczeropoint1g2=flipdactab(darkref(1));
        [peaksrefdacQ2 filenm2]=findpelevelopt(phdrefQ2,dactab,daczeropoint1g2,threshpeak,-steplen+6,'Q2',startpe);
        darkref =find(fliplr(phdrefQ3')>intenexpo05pe);
        daczeropoint1g3=flipdactab(darkref(1));
        [peaksrefdacQ3 filenm3]=findpelevelopt(phdrefQ3,dactab,daczeropoint1g3,threshpeak,-steplen+6,'Q3',startpe);
        %%%do a final cps figure with final pe steps
        
        pestepfigcell(igg,1)={filenm0};pestepfigcell(igg,2)={filenm1};pestepfigcell(igg,3)={filenm2};pestepfigcell(igg,4)={filenm3};
        
        pestepImadac(1,igg,:)=peaksrefdacQ0(1:3);
        pestepImadac(2,igg,:)=peaksrefdacQ1(1:3);
        pestepImadac(3,igg,:)=peaksrefdacQ2(1:3);
        pestepImadac(4,igg,:)=peaksrefdacQ3(1:3);
        
      %  normcps*=1/(2.5e-3);
        for ida=1:3
            dacofpe=find(dactab==peaksrefdacQ0(ida));
            pestepImacps(1,igg,ida)=normcps*phdrefQ0(dacofpe);
            dacofpe=find(dactab==peaksrefdacQ1(ida));
            pestepImacps(2,igg,ida)=normcps*phdrefQ1(dacofpe);
            dacofpe=find(dactab==peaksrefdacQ2(ida));
            pestepImacps(3,igg,ida)=normcps*phdrefQ2(dacofpe);
            dacofpe=find(dactab==peaksrefdacQ3(ida));
            pestepImacps(4,igg,ida)=normcps*phdrefQ3(dacofpe);
        end
        
        
        close all
        figure('Position',[50 50 1600 900])
        hold on
        
        
        subplot(2,2,1)
        hold on
        for ii=1:8
            for jj=9:16
                plot(dactab,  normcps*squeeze(allima2(jj,ii,:)),'-+','Color',[0.5 ii/8 jj/16])
            end
        end
        plot([peaksrefdacQ0(1) peaksrefdacQ0(1)] , yl,'r--')
        plot([peaksrefdacQ0(2) peaksrefdacQ0(2)] , yl,'b--')
        plot([peaksrefdacQ0(3) peaksrefdacQ0(3)] , yl,'g--')
        hold off
        title(['Q0 Bipolar fs; Gain:' num2str(gaintab) 'd(' dec2hex(gaintab) 'h); ' masklabel])
        
        xlabel('Threshold DAC1 ')
        ylabel('Mean intensity [counts per second]')
        hold off
        set(gca, 'YScale','log')
        box on
        grid on
        
        subplot(2,2,2)
        hold on
        for ii=1:8
            for jj=1:8
                
                plot(dactab,  normcps*squeeze(allima2(jj,ii,:)),'-+','Color',[0.5 ii/8 jj/8])
            end
        end
        plot([peaksrefdacQ1(1) peaksrefdacQ1(1)] , yl,'r--')
        plot([peaksrefdacQ1(2) peaksrefdacQ1(2)] , yl,'b--')
        plot([peaksrefdacQ1(3) peaksrefdacQ1(3)] , yl,'g--')
        hold off
        title('Q1 all pix')
        xlabel('Threshold DAC1 ')
        ylabel('Mean intensity [counts per second]')
        hold off
        set(gca, 'YScale','log')
        box on
        grid on
        
        subplot(2,2,3)
        hold on
        for ii=9:16
            for jj=1:8
                plot(dactab,  normcps*squeeze(allima2(jj,ii,:)),'-+','Color',[0.5 ii/16 jj/8])
            end
        end
        plot([peaksrefdacQ2(1) peaksrefdacQ2(1)] , yl,'r--')
        plot([peaksrefdacQ2(2) peaksrefdacQ2(2)] , yl,'b--')
        plot([peaksrefdacQ2(3) peaksrefdacQ2(3)] , yl,'g--')
        hold off
        title('Q2 all pix')
        xlabel('Threshold DAC1 ')
        ylabel('Mean intensity [counts per second]')
        hold off
        set(gca, 'YScale','log')
        box on
        grid on
        
        subplot(2,2,4)
        hold on
        for ii=9:16
            for jj=9:16
                plot(dactab,  normcps*squeeze(allima2(jj,ii,:)),'-+','Color',[0.5 ii/16 jj/16])
            end
        end
        plot([peaksrefdacQ3(1) peaksrefdacQ3(1)] , yl,'r--')
        plot([peaksrefdacQ3(2) peaksrefdacQ3(2)] , yl,'b--')
        plot([peaksrefdacQ3(3) peaksrefdacQ3(3)] , yl,'g--')
        hold off
        title('Q3 all pix')
        set(gca, 'YScale','log')
         xlabel('Threshold DAC1 ')
        ylabel('Mean intensity [counts per second]')
        box on
        grid on
        
        filenm=[calibdir 'cpsFinaladjustGain' num2str(gaintab) '_' datenow1 '_' num2str(loopgaincnt) '.png'];
        cpsfinalfigcell(igg)={filenm};
        saveas(gcf,filenm)
        saveas(gcf,[calibdir 'cpsFinaladjustGain' num2str(gaintab) '_' datenow1 '_' num2str(loopgaincnt) '.fig'])
        close
        
        
        
        
        %petab=(1/8)*(-182 + dactab);
        %petab=(1/A)*(-B + dactab);
        % A0=mean([peaksrefdacQ0(2)-peaksrefdacQ0(1) peaksrefdacQ0(3)-peaksrefdacQ0(2) ]);
        % A1=mean([peaksrefdacQ1(2)-peaksrefdacQ1(1) peaksrefdacQ1(3)-peaksrefdacQ1(2) ]);
        % A2=mean([peaksrefdacQ2(2)-peaksrefdacQ2(1) peaksrefdacQ2(3)-peaksrefdacQ2(2) ]); %peaksrefdacQ2(4)-peaksrefdacQ2(3)
        % A3=mean([peaksrefdacQ3(2)-peaksrefdacQ3(1) peaksrefdacQ3(3)-peaksrefdacQ3(2) ]);
        A0=mean([peaksrefdacQ0(2)-peaksrefdacQ0(1)]);
        A1=mean([peaksrefdacQ1(2)-peaksrefdacQ1(1)]);
        A2=mean([peaksrefdacQ2(2)-peaksrefdacQ2(1)]); %peaksrefdacQ2(4)-peaksrefdacQ2(3)
        A3=mean([peaksrefdacQ3(2)-peaksrefdacQ3(1)]);
        disp(['A0:' num2str(A0) ' A1:' num2str(A1) ' A2:' num2str(A2) ' A3:' num2str(A3)])
        
        % %% ! !! HIGH GAINS: A*2 because starts at 2pe
        % B0=peaksrefdacQ0(1)-A0*2;
        % B1=peaksrefdacQ1(1)-A1*2;
        % B2=peaksrefdacQ2(1)-A2*2;
        % B3=peaksrefdacQ3(1)-A3*2;
        %%
        B0=peaksrefdacQ0(1)-A0*startpe;
        B1=peaksrefdacQ1(1)-A1*startpe;
        B2=peaksrefdacQ2(1)-A2*startpe;
        B3=peaksrefdacQ3(1)-A3*startpe;
        disp(['B0:' num2str(B0) ' B1:' num2str(B1) ' B2:' num2str(B2) ' B3:' num2str(B3)])
        
        if loopgain==0;
            save([getuserdir '\panoseti\Calibrations\' 'pethresh_gain' num2str(gaintab) '.mat'],'A0','A1','A2','A3','B0','B1','B2','B3')
            coeffsallg=cat(1, coeffsallg,[ gaintab A0 A1 A2 A3 B0 B1 B2 B3 ]);
        end
        %quaboconfig=changepe(3,33,quaboconfig)
        
        
        dactab0=round(A0*peval+B0);
        dactab1=round(A1*peval+B1);
        dactab2=round(A2*peval+B2);
        dactab3=round(A3*peval+B3);
        
        quaboconfig(indexdac,1+1)={['0x' dec2hex(dactab0)]};
        quaboconfig(indexdac,2+1)={['0x' dec2hex(dactab1)]};
        quaboconfig(indexdac,3+1)={['0x' dec2hex(dactab2)]};
        quaboconfig(indexdac,4+1)={['0x' dec2hex(dactab3)]};
        
        disp(['Sending Maroc comm...DAC1 Q0:' num2str(dactab0)])
        disp(['Sending Maroc comm...DAC1 Q1:' num2str(dactab1)])
        disp(['Sending Maroc comm...DAC1 Q2:' num2str(dactab2)])
        disp(['Sending Maroc comm...DAC1 Q3:' num2str(dactab3)])
        sendconfig2Maroc(quaboconfig)
        pause(2)
        images=grabimages(nim,1,1);
        
        meanimage=mean(images(:,:,:),[3])';
        
        close
        figure
        hold on
        histogram(meanimage,64,'BinWidth',4)
        
        if loopgaincnt==1
            histylim=ylim;
            histylim(2)=3*histylim(2);
            ylim(histylim)
            histxlim=xlim;
            histylim=ylim;
            
        else
            xlim(histxlim)
            ylim(histylim)
        end
        % plot([imaconvergence imaconvergence] , histylim,'k--')
        % plot([ctconvergence ctconvergence] , histylim,'k--')
        hold off
        set(gcf,'Color','w')
        ti= title(['Pixel cnts, Gain ini:' num2str(gaintab) ' ITER#:' num2str(loopgaincnt) ' Thresh:' num2str(peval) 'pe' ])
        set(ti,'FontSize',12)
        xlabel('Pixel intensity [cnts per exposure]')
        ylabel('Occurrence')
        saveas(gcf,[calibdir 'FinalHistImaGain' num2str(gaintab) '_' num2str(loopgaincnt) '_' datenow1 '.png'])
        saveas(gcf,[calibdir 'FinalHistImaGain' num2str(gaintab) '_' num2str(loopgaincnt) '_' datenow1 '.fig'])
        frame = getframe(gcf);
        im = frame2im(frame); %,
        [imind,cm] = rgb2ind(im,256);
        delay=0.5;
        if loopgaincnt == 1;
            histimagename=[calibdir 'HistIma_' num2str(loopgaincnt) '_' datenow1 '.gif'];
            imwrite(imind,cm,histimagename,'gif', 'Loopcount',inf,'DelayTime',delay);%,'ScreenSize',[640 640]
        else
            imwrite(imind,cm,histimagename,'gif','WriteMode','append','DelayTime',delay);
        end
        close
        figure
        if loopgaincnt==1
            imamax=max(meanimage,[],'all');
        end
        imagesc(meanimage',[0 imamax])
        %title('Image')
        cb=colorbar
        cb.Label.String='Counts per exposure';
        set(gcf,'Color','w')
        ti= title(['Image, Gain ini:' num2str(gaintab) ' ITER#:' num2str(loopgaincnt) ' Thresh:' num2str(peval) 'pe' ])
        set(ti,'FontSize',14)
        saveas(gcf,[calibdir 'ImaGain' num2str(gaintab) '_' num2str(loopgaincnt) '_' datenow1 '.png'])
        saveas(gcf,[calibdir 'ImaGain' num2str(gaintab) '_' num2str(loopgaincnt) '_' datenow1 '.fig'])
        
        frame = getframe(gcf);
        im = frame2im(frame); %,
        [imind,cm] = rgb2ind(im,256);
        delay=0.5;
        if loopgaincnt == 1;
            imagename=[calibdir 'ImaGain' num2str(gaintab) '_' num2str(loopgaincnt) '_' datenow1 '.gif'];
            imwrite(imind,cm,imagename,'gif', 'Loopcount',inf,'DelayTime',delay);%,'ScreenSize',[640 640]
        else
            imwrite(imind,cm,imagename,'gif','WriteMode','append','DelayTime',delay);
        end
        
        figure
        imagesc(gainmap',[gaintab-15 gaintab+15])
        %title('Gain map')
        
                cb=colorbar
        cb.Label.String='Gain value';
        set(gcf,'Color','w')
        %  ti= title(['Gain map ITER#' num2str(loopgaincnt) ' DAC1 Q0:' num2str(Q0refdac) ' Q1:' num2str(peaksrefdacQ1(3)) ' Q2:' num2str(peaksrefdacQ2(3)) ' Q3:' num2str(peaksrefdacQ3(3))])
        ti= title(['Gain initial:' num2str(gaintab) ' ITER#' num2str(loopgaincnt) ])
        set(ti,'FontSize',12)
        saveas(gcf,[calibdir 'Gain' num2str(gaintab) 'map_' num2str(loopgaincnt) '_' datenow1 '.png'])
        saveas(gcf,[calibdir 'Gain' num2str(gaintab) 'map_' num2str(loopgaincnt) '_' datenow1 '.fig'])
        frame = getframe(gcf);
        im = frame2im(frame); %,
        [imind,cm] = rgb2ind(im,256);
        delay=0.5;
        if loopgaincnt == 1;
            gainname=[calibdir 'Gain' num2str(gaintab) 'map_' num2str(loopgaincnt) '_' datenow1 '.gif'];
            imwrite(imind,cm,gainname,'gif', 'Loopcount',inf,'DelayTime',delay);%,'ScreenSize',[640 640]
        else
            imwrite(imind,cm,gainname,'gif','WriteMode','append','DelayTime',delay);
        end
        close
    end
    
    % figure
    % hold on
    % plot(dactab,phdref,'g')
    % %plot(dactab,-d0,'b')
    % plot(dactab,d1,'r')
    % plot(dactab,d1r,'m')
    % hold off
    % set(gca,'YScale','log')
    
    %%%record thresh ve pe relations
    %   daczeropoint1=0;threshpeak=0.25;
    %
    %     peaksrefdacQ0=findpelevel(phdrefQ0,dactab,daczeropoint1,threshpeak,-12);
    %      peaksrefdacQ1=findpelevel(phdrefQ1,dactab,daczeropoint1,threshpeak,-12);
    %       peaksrefdacQ2=findpelevel(phdrefQ2,dactab,daczeropoint1,threshpeak,-12);
    %        peaksrefdacQ3=findpelevel(phdrefQ3,dactab,daczeropoint1,threshpeak,-12);
    
    
    
    %%% save gain map values
    quaboconfig_gain=quaboconfig;
    save([calibdir 'gainmap_gain' num2str(gaintab) '.mat'],'gainmap','quaboconfig_gain')
    gainmapallg=cat(3,gainmapallg, gainmap-gaintab);
    
    
    if makereport==1
%         import mlreportgen.report.*
%         import mlreportgen.dom.*
%         sec3 = Section;

        sec3a = Section;
        sec3a.Title = ['Gain adjustment. Gain initial:' num2str(gaintab)];
        %add cps curves (ini):
       para=Paragraph('Dark frames were recorded in imaging mode to measure cps curves on eack pixel (no mask). '); para.Style=logm12; 
              add(sec3a,para);
              para=Paragraph(['Without gain adjustment, i.e. using the same Maroc gain value on each pixel (initial gains were set to ' num2str(gaintab) '), initial cps curves shows pixel-to-pixel variations of pe steps locations:']);
         para.Style=logm12;add(sec3a,para);
        
        plot1=Image([calibdir 'cpsadjustGain' num2str(gaintab) '_' datenow1 '_' num2str(1) '.png']);
        widthch=plot1.Width;
        widthima=str2num(widthch(1:strfind(widthch,'px')-1));
        heightch=plot1.Height;
        heightima=str2num(heightch(1:strfind(heightch,'px')-1));
        plot1.Width='600px';
        plot1.Height=[ num2str(floor(600/widthima*heightima)) 'px'];
        add(sec3a,plot1);
        %add cps final
        para=Paragraph(['After ' num2str(loopgaincnt) ' iterations of gain adjustment (with initial gains set to ' num2str(gaintab) '), final cps curves are represented in the following figure. ']);
        para.Style=logm12;
        add(sec3a,para);
        plot1=Image([calibdir  'cpsadjustGain' num2str(gaintab) '_' datenow1 '_' num2str(loopgaincnt) '.png']);
        widthch=plot1.Width;
        widthima=str2num(widthch(1:strfind(widthch,'px')-1));
        heightch=plot1.Height;
        heightima=str2num(heightch(1:strfind(heightch,'px')-1));
        plot1.Width='600px';
        plot1.Height=[ num2str(floor(600/widthima*heightima)) 'px'];
        add(sec3a,plot1);
         para=Paragraph(['If the gain adjustment routine worked properly, the pixel-to-pixel variations of pe-step DAC values should be smaller than the initial one.']);
         para.Style=logm12;
         add(sec3a,para);
        %Ima ini/finale
          para= Paragraph(['A comparison of the initial and final frames in imaging mode (darks at 2.5pe) is given by the next two figures before and after gain adjustment. The pixel intensities in the second figure should be more uniform spatially over all pixels.']);
             para.Style=logm12;
          add(sec3a,para);
           imgStyle = {ScaleToFit(true)};
img1 = Image([calibdir 'ImaGain' num2str(gaintab) '_' num2str(1) '_' datenow1 '.png']);
img1.Style = imgStyle;
img2 = Image([calibdir 'ImaGain' num2str(gaintab) '_' num2str(loopgaincnt) '_' datenow1 '.png']);
img2.Style = imgStyle;
%Insert images in the row of a 1x3, invisible layout table (lot).

lot = Table({img1, ' ', img2});
%The images will be sized to fit the table entries only if their height and width is specified.

lot.entry(1,1).Style = {Width('3.2in'), Height('3in')};
lot.entry(1,2).Style = {Width('.2in'), Height('3in')};
lot.entry(1,3).Style = {Width('3.2in'), Height('3in')};
%Make the table span the width of the page between the margins. Tell the table layout manager to not resize the table columns to fit the images.

lot.Style = {ResizeToFitContents(false), Width('100%')};
%Generate and display the report.

add(sec3a, lot);
%         add(sec3a,Paragraph(['Image at ' num2str(peval) 'pe without gain adjustment (all gains set to ' num2str(gaintab) ', imaging mode):']));
%         plot1=Image([calibdir 'ImaGain' num2str(gaintab) '_' num2str(1) '_' datenow1 '.png']);
%         widthch=plot1.Width;
%         widthima=str2num(widthch(1:strfind(widthch,'px')-1));
%         heightch=plot1.Height;
%         heightima=str2num(heightch(1:strfind(heightch,'px')-1));
%         plot1.Width='350px';
%         plot1.Height=[ num2str(floor(350/widthima*heightima)) 'px'];
%         add(sec3a,plot1);
%         add(sec3a,Paragraph(['Image at ' num2str(peval) 'pe after ' num2str(loopgaincnt) ' iterations of gain adjustment (initial gains set to ' num2str(gaintab) '):']));
%         plot1=Image([calibdir 'ImaGain' num2str(gaintab) '_' num2str(loopgaincnt) '_' datenow1 '.png']);
%         widthch=plot1.Width;
%         widthima=str2num(widthch(1:strfind(widthch,'px')-1));
%         heightch=plot1.Height;
%         heightima=str2num(heightch(1:strfind(heightch,'px')-1));
%         plot1.Width='350px';
%         plot1.Height=[ num2str(floor(350/widthima*heightima)) 'px'];
%         add(sec3a,plot1);
%         
        %save hist ini/fin
          para=Paragraph(['A comparison of the initial and final histograms of pixel intensities in imaging mode at 2.5pe is given by the next two figures before and after gain adjustment. The pixel intensity distribution in the second figure should be narrower than the first one.']);
   para.Style=logm12;
          add(sec3a,para);
          imgStyle = {ScaleToFit(true)};
img1 = Image([calibdir 'FinalHistImaGain' num2str(gaintab) '_' num2str(1) '_' datenow1 '.png']);
img1.Style = imgStyle;
 img2=Image([calibdir 'FinalHistImaGain' num2str(gaintab) '_' num2str(loopgaincnt) '_' datenow1 '.png']);
img2.Style = imgStyle;
%Insert images in the row of a 1x3, invisible layout table (lot).

lot = Table({img1, ' ', img2});
%The images will be sized to fit the table entries only if their height and width is specified.

lot.entry(1,1).Style = {Width('3.2in'), Height('3in')};
lot.entry(1,2).Style = {Width('.2in'), Height('3in')};
lot.entry(1,3).Style = {Width('3.2in'), Height('3in')};
%Make the table span the width of the page between the margins. Tell the table layout manager to not resize the table columns to fit the images.

lot.Style = {ResizeToFitContents(false), Width('100%')};
%Generate and display the report.

add(sec3a, lot);   
%         add(sec3a,Paragraph(['Histogram of pixel values at ' num2str(peval) 'pe without gain adjustment (all gains set to ' num2str(gaintab) ', imaging mode):']));
%         plot1=Image([calibdir 'FinalHistImaGain' num2str(gaintab) '_' num2str(1) '_' datenow1 '.png']);
%         widthch=plot1.Width;
%         widthima=str2num(widthch(1:strfind(widthch,'px')-1));
%         heightch=plot1.Height;
%         heightima=str2num(heightch(1:strfind(heightch,'px')-1));
%         plot1.Width='450px';
%         plot1.Height=[ num2str(floor(450/widthima*heightima)) 'px'];
%         add(sec3a,plot1);
%         add(sec3a,Paragraph(['Histogram of pixel values at ' num2str(peval) 'pe after ' num2str(loopgaincnt) ' iterations of gain adjustment (initial gains set to ' num2str(gaintab) '):']));
%         plot1=Image([calibdir 'FinalHistImaGain' num2str(gaintab) '_' num2str(loopgaincnt) '_' datenow1 '.png']);
%         widthch=plot1.Width;
%         widthima=str2num(widthch(1:strfind(widthch,'px')-1));
%         heightch=plot1.Height;
%         heightima=str2num(heightch(1:strfind(heightch,'px')-1));
%         plot1.Width='450px';
%         plot1.Height=[ num2str(floor(450/widthima*heightima)) 'px'];
%         add(sec3a,plot1);

        %add gain map final
        para=Paragraph([' Final gain map after ' num2str(loopgaincnt) ' iterations of gain adjustment (initial gains set to ' num2str(gaintab) '):']);
         para.Style=logm12;
         add(sec3a,para);
        plot1=Image([calibdir 'Gain' num2str(gaintab) 'map_' num2str(loopgaincnt) '_' datenow1 '.png']);
        widthch=plot1.Width;
        widthima=str2num(widthch(1:strfind(widthch,'px')-1));
        heightch=plot1.Height;
        heightima=str2num(heightch(1:strfind(heightch,'px')-1));
        plot1.Width='350px';
        plot1.Height=[ num2str(floor(350/widthima*heightima)) 'px'];
        add(sec3a,plot1);
        %residus final
           para=Paragraph(['To stop automatically the gain adjustment iterations, the residual is calculated as  the sum of squared differences ' ... 
               'of counts between  pixels and the reference one at 2-pe. ' ...
               ' Iterations are stopped when the residual (next figure) does not decrease anymore.']);
   para.Style=logm12;
           add(sec3a,para);
        para=Paragraph(['The following figure shows the residual at ' num2str(peval) 'pe after ' num2str(loopgaincnt) ' iterations of gain adjustment (initial gains set to ' num2str(gaintab) '):']);
      para.Style=logm12;
        add(sec3a,para);
        plot1=Image([calibdir 'ResiduImaGain' num2str(gaintab) '_' num2str(loopgaincnt) '_' datenow1 '.png']);
        widthch=plot1.Width;
        widthima=str2num(widthch(1:strfind(widthch,'px')-1));
        heightch=plot1.Height;
        heightima=str2num(heightch(1:strfind(heightch,'px')-1));
        plot1.Width='500px';
        plot1.Height=[ num2str(floor(500/widthima*heightima)) 'px'];
        add(sec3a,plot1);
        add(sec3,sec3a);
        
        
    end
    
    
end

%%put final results in calib table
% divide each A coeffs by corresponding gain
if exist('quaboDETtable','var')
    quaboDETtable(inddetrow,7)=mean([coeffsallg(1,2)/coeffsallg(1,1) coeffsallg(2,2)/coeffsallg(2,1)]);
    quaboDETtable(inddetrow,8)=mean([coeffsallg(1,3)/coeffsallg(1,1) coeffsallg(2,3)/coeffsallg(2,1)]);
    quaboDETtable(inddetrow,9)=mean([coeffsallg(1,4)/coeffsallg(1,1) coeffsallg(2,4)/coeffsallg(2,1)]);
    quaboDETtable(inddetrow,10)=mean([coeffsallg(1,5)/coeffsallg(1,1) coeffsallg(2,5)/coeffsallg(2,1)]);
    quaboDETtable(inddetrow,11)=mean([coeffsallg(1,6) coeffsallg(2,6)]);
    quaboDETtable(inddetrow,12)=mean([coeffsallg(1,7) coeffsallg(2,7)]);
    quaboDETtable(inddetrow,13)=mean([coeffsallg(1,8) coeffsallg(2,8)]);
    quaboDETtable(inddetrow,14)=mean([coeffsallg(1,9) coeffsallg(2,9)]);
    
    
    save([getuserdir '\panoseti\Calibrations\' 'CalibrationDB.mat'],'quaboDETtable')
end


if makereport==1

    
    for ig=1:numel(gaintaballg)
        %add cps curves (finales):
        secB1 = Section;
        secB1.Title = ['PE step detection (Gain initial ' num2str(gaintaballg(ig)) ')'];
         para=   Paragraph(['To deduce the DAC vs pe# relationship for each quadrant, dark acquisitions are recorded and pe steps detected.']);
 add(secB1,para);
        para=Paragraph(['To detect pe step locations (as a function of DAC), we used final cps curves after ' num2str(loopgaincnt) ' iterations of gain adjustment (initial gains set to ' num2str(gaintaballg(ig)) ') as shown in the previous section.']);
add(secB1,para);
        %         plot1=Image(cell2mat(cpsfinalfigcell(ig)));
%         widthch=plot1.Width;
%         widthima=str2num(widthch(1:strfind(widthch,'px')-1));
%         heightch=plot1.Height;
%         heightima=str2num(heightch(1:strfind(heightch,'px')-1));
%         plot1.Width='650px';
%         plot1.Height=[ num2str(floor(650/widthima*heightima)) 'px'];
%         add(secB1,plot1);
%         
        %%add pe step figures
          add(secB1,Paragraph(['To detect pe steps, the cps derivative over DAC is calculated and it is divided by the cps vs dac curve itself to give more weight to the lower cps values at high DAC. Then, a peak detection is performed on the derivative to determine pe step locations (using a threshold and a minimal distance between peaks that depend on the gain). The following figures are showing the chosen cps curves as well as their derivatives and detected peaks. ']));

        for qq=1:4
            filenm=cell2mat(pestepfigcell(ig,qq))
            add(secB1,Paragraph(['The following figure shows the pe-step detection on quadrant ' num2str(qq-1) ' (initial gains set to ' num2str(gaintaballg(ig)) '):']));
            plot1=Image(filenm);
            widthch=plot1.Width;
            widthima=str2num(widthch(1:strfind(widthch,'px')-1));
            heightch=plot1.Height;
            heightima=str2num(heightch(1:strfind(heightch,'px')-1));
            plot1.Width='500px';
            plot1.Height=[ num2str(floor(500/widthima*heightima)) 'px'];
            add(secB1,plot1);
            
            
        end
        add(secB,secB1);
    end
    
    
    
    %save mean gain map
    gaindiff1=(1/gaintaballg(1))*(gainmapallg(:,:,1));
    gaindiff2=(1/gaintaballg(2))*(gainmapallg(:,:,2));
    gainmapallg2=cat(3,gaindiff1,gaindiff2);
    gainmapallgmean=mean(gainmapallg2,3);
    load([getuserdir '\panoseti\Calibrations\' 'gainmap_inc.mat'],'gainmapallgmeanSN')
    gainmapallgmeanSN(:,:,inddetrow)=gainmapallgmean;
    save([getuserdir '\panoseti\Calibrations\' 'gainmap_inc.mat'],'gainmapallgmeanSN')
    
    %compare first two gain map
    gg=(gainmapallg(:,:,2)-gaintaballg(2))./(gainmapallg(:,:,1)-gaintaballg(1));
    figure;  imagesc(gg,[1 2]);colorbar
    ti= title(['Ratio of (gain map - gain initial) at gains of ' num2str(gaintaballg(2)) ' and ' num2str(gaintaballg(1))])
    ti.FontSize=10
    saveas(gcf,[calibdir 'RatioGain' 'map_'  datenow1 '.png'])
    saveas(gcf,[calibdir 'RatioGain'  'map_' datenow1 '.fig'])
    
    sec3c = Section;
    sec3c.Title = ['Gain adjusment map'];
    para=Paragraph(['It could be shown from the gain adjustment maps above that the adjusted-gain map difference (adjusted-gain map - initial gain g) scales with the initial gain g such that ' ]);
     para.Style=logm12; 
     add(sec3c,para);
    para=Paragraph([' Adjusted_Gain_map(g) = g (1 + G) ' ]);
       para.Style=logm12;
       add(sec3c,para);
    para=Paragraph([' where G is a 16x16 matrix deduced from the previous gain map measurements which can be used to adjust the pixel gains to any user-defined gain value. The use of the above equation to adjust the gain ensures pe steps stays aligned at any gain and it minimizes pixel-to-pixel intensity variations.']);
     para.Style=logm12; 
     add(sec3c,para);
    para=Paragraph(['For sanity check, the ratio of gain map differences at initial gains of 40 to 60 is represented in the following figure and should be equal or close to 60/40 = 1.5 on each pixel.' ]);
     para.Style=logm12;
     add(sec3c,para);
    % 'the gain map difference is divided by the initial gain before being recorded.']));
    para=Paragraph(['The following figure shows the ratio of (gain map - gain initial) at gains of ' num2str(gaintaballg(2)) ' and ' num2str(gaintaballg(1))]);
    para.Style=logm12;
     add(sec3c,para);
    plot1=Image([calibdir 'RatioGain' 'map_'  datenow1 '.png']);
    widthch=plot1.Width;
    widthima=str2num(widthch(1:strfind(widthch,'px')-1));
    heightch=plot1.Height;
    heightima=str2num(heightch(1:strfind(heightch,'px')-1));
    plot1.Width='450px';
    plot1.Height=[ num2str(floor(450/widthima*heightima)) 'px'];
    add(sec3c,plot1);
    add(sec3,sec3c);
    
    %%add DAC vs pe coeffs table
    secB2 = Section;
   
    secB2.Title = ['DAC = A gain pe# + B (Imaging mode only)'];
       para=Paragraph(['From all these previous measurements in imaging mode (dark), we can deduce an initial set of A and B coefficients that will be refined with PH mode measurements in the following sections.']);
   para.Style=logm12; 
       add(secB2,para);
    tableDACvsPE=BaseTable({['Gain ini'] ['A Q0'] ...
        ['B Q0' ] ...
        ['A Q1' ] ...
        ['B Q1' ] ...
        ['A Q2' ] ...
        ['B Q2'] ...
        ['A Q3'] ...
        ['B Q3'] ...
        ; ...
        [num2str(gaintaballg(1))] ...
        [num2str(coeffsallg(1,2)/coeffsallg(1,1))] ...
        [num2str(coeffsallg(1,6))] ...
        [num2str(coeffsallg(1,3)/coeffsallg(1,1))] ...
        [num2str(coeffsallg(1,7))] ...
        [num2str(coeffsallg(1,4)/coeffsallg(1,1))] ...
        [num2str(coeffsallg(1,8))] ...
        [num2str(coeffsallg(1,5)/coeffsallg(1,1))] ...
        [num2str(coeffsallg(1,9))] ...
                ; ...
        [num2str(gaintaballg(2))] ...
        [num2str(coeffsallg(2,2)/coeffsallg(2,1))] ...
        [num2str(coeffsallg(2,6))] ...
        [num2str(coeffsallg(2,3)/coeffsallg(2,1))] ...
        [num2str(coeffsallg(2,7))] ...
        [num2str(coeffsallg(2,4)/coeffsallg(2,1))] ...
        [num2str(coeffsallg(2,8))] ...
        [num2str(coeffsallg(2,5)/coeffsallg(2,1))] ...
        [num2str(coeffsallg(2,9))] ...
                ; ...
        ['Mean'] ...
        [num2str(quaboDETtable(inddetrow,7))] ...
        [num2str(quaboDETtable(inddetrow,11))] ...
        [num2str(quaboDETtable(inddetrow,8))] ...
        [num2str(quaboDETtable(inddetrow,12))] ...
        [num2str(quaboDETtable(inddetrow,9))] ...
        [num2str(quaboDETtable(inddetrow,13))] ...
        [num2str(quaboDETtable(inddetrow,10))] ...
        [num2str(quaboDETtable(inddetrow,14))] ...
        });
    add(secB2,tableDACvsPE);
  %  add(secB,secB2);
    
    %%%%%%%%% add cps vs dac coefs
    %To be added
%        secD = Section;
%         secD.Title = ['CPS vs DAC relationship'];
%       
%     for ig=1:numel(gaintaballg)
%           secD1 = Section;
%         secD1.Title = ['CPS vs DAC relationship (Gain initial ' num2str(gaintaballg(ig)) ')'];
%         
%      
%         figure
%         imagesc(cpsfitA(:,:,2)',[-0.2 0])
%         colorbar
%         title(['CPS fit Coeffs C in 10^{(C DAC + D)} at gain ini: '  num2str(gaintaballg(ig))])
%         filenm=[calibdir 'cpsvsdacC_gain' num2str(gaintaballg(ig)) '_' datenow1 '.png'];
%         saveas(gcf,filenm)
%         saveas(gcf,[calibdir 'cpsvsdacC_gain' num2str(gaintaballg(ig)) '_' datenow1 '.fig'])
%         
%            add(secD1,Paragraph(['CPS cuves were fitted using 10^(C DAC + D). Coeffs C are reported below:']));
%         plot1=Image(filenm);
%         widthch=plot1.Width;
%         widthima=str2num(widthch(1:strfind(widthch,'px')-1));
%         heightch=plot1.Height;
%         heightima=str2num(heightch(1:strfind(heightch,'px')-1));
%         plot1.Width='550px';
%         plot1.Height=[ num2str(floor(550/widthima*heightima)) 'px'];
%         add(secD1,plot1);
%         
%         
%         figure
%         imagesc(cpsfitB(:,:,ig)',[20 25])
%         colorbar
%         ti=title(['CPS fit Coeffs C in 10^{(C DAC + D)} at gain ini: '  num2str(gaintaballg(ig))])
%         ti.FontSize=10
%         filenm=[calibdir 'cpsvsdacC_gain' num2str(gaintaballg(ig)) '_' datenow1 '.png'];
%         saveas(gcf,filenm)
%         saveas(gcf,[calibdir 'cpsvsdacC_gain' num2str(gaintaballg(ig)) '_' datenow1 '.fig'])
% 
%                add(secD1,Paragraph(['CPS cuves were fitted using 10^(C DAC + D). Coeffs D are reported below:']));
%         plot1=Image(filenm);
%         widthch=plot1.Width;
%         widthima=str2num(widthch(1:strfind(widthch,'px')-1));
%         heightch=plot1.Height;
%         heightima=str2num(heightch(1:strfind(heightch,'px')-1));
%         plot1.Width='550px';
%         plot1.Height=[ num2str(floor(550/widthima*heightima)) 'px'];
%         add(secD1,plot1);
% 
%      add(secD,secD1);
%     end
    
end



if makereport==1
    
    add(rpt,sec3);
    %keep secB for next routine
 %   add(rpt,secB);
 
  %  add(rpt,secD);
%     sec4 = Section;
%     sec4.Title = 'DAC vs ADC calibration';
end

 %datenow=datestr(now,'yymmddHHMMSS');
save([calibdir 'calibima' datenow '.mat'], 'pestepImadac','pestepImacps','cpsfitA','cpsfitB')
tima=toc