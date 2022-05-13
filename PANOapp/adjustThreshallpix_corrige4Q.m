figini;
close all
nim=10;
quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config.txt']);
[ig,indexstimon]=ismember(['STIMON '] ,quaboconfig);
quaboconfig(indexstimon,2)={"0"};
pausetime=0.5;
indcol=1:4;
%set gain
gaintab=33;
for pp=0:63
    [ig,indexgain]=ismember(['GAIN' num2str(pp)] ,quaboconfig);
    
    quaboconfig(indexgain,indcol+1)={['0x' dec2hex(gaintab(1))]};
end

gainmap=zeros(16,16);
gainmap(:,:)=gaintab;

loopgain=1;
loopgaincnt=0;

while loopgain==1
    loopgaincnt=loopgaincnt+1;
    %set masks MASKOR1_
    mask=0;
    if mask==0
        masklabel='no mask, ';
        for pp=0:63
            [ig,indexmask]=ismember(['MASKOR1_' num2str(pp)] ,quaboconfig);
            [ig,indexmask2]=ismember(['MASKOR2_' num2str(pp)] ,quaboconfig);
            quaboconfig(indexmask,indcol+1)={['0']};
            quaboconfig(indexmask2,indcol+1)={['0']};
        end
        
    else
        masklabel='all-pixel-masked-excepted-one, ';
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
    dactab=[180:1:230 ];
    %dactab=[185:5:305  ];
    figure
    [ia,indexdac]=ismember('DAC1',quaboconfig);
    
    %put high thresh on all 4 quads
    dactabH0=500;
    quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactabH0)]};
    pause(pausetime)
    
    IntensmeanQ0=[];IntensmeanQ1=[];IntensmeanQ2=[];IntensmeanQ3=[];IntensmeanQ8=[];IntensmeanQ9=[];
    allima=zeros(16,16,numel(dactab),numel(indcol));
    indcol2=1;
    for dd=1:numel(dactab)
        quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactab(dd))]};
        disp(['Sending Maroc comm...DAC1:' num2str(dactab(dd))])
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
        
        %  IntensmaxQ1(nima)=max(ima(9:16,1:8),[],'all');
        IntensmeanQ0=[IntensmeanQ0 mean(meanimage(9:16,1:8),[1 2])];
        % IntensmaxQ2(nima)=max(ima(1:8,1:8),[],'all');
        IntensmeanQ1=[IntensmeanQ1 mean(meanimage(1:8,1:8),[1 2])];
        %   IntensmaxQ3(nima)=max(ima(1:8,9:16),[],'all');
        IntensmeanQ2=[IntensmeanQ2 mean(meanimage(1:8,9:16),[1 2])];
        %   IntensmaxQ4(nima)=max(ima(9:16,9:16),[],'all');
        IntensmeanQ3=[IntensmeanQ3 mean(meanimage(9:16,9:16),[1 2])];
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
    
    figure('Position',[50 50 1600 900])
    hold on
    figquad=0;
    if figquad==1
        % plot(dactab, IntensmeanQ0,'-+b')
        %  plot(dactab, IntensmeanQ1,'-+r')
        %  plot(dactab, IntensmeanQ2,'-+g')
        %  plot(dactab, IntensmeanQ3,'-+m')
        plot(dactab, IntensmeanQ8,'-+k')
    else
        allima2=allima(:,:,:,1);
        subplot(2,2,1)
        hold on
        for ii=1:8
            for jj=9:16
                plot(dactab,  squeeze(allima2(jj,ii,:)),'-+','Color',[0.5 ii/8 jj/16])
            end
        end
        hold off
        legend('Q0')
         xlabel('Threshold DAC1 ')
    ylabel('Mean intensity [counts per exposure]')
    hold off
    set(gca, 'YScale','log')
    %legend('Q0','Q1','Q2','Q3','Single pix: [1,1]')
    box on
    grid on
    
        subplot(2,2,2)
        hold on
        for ii=1:8
            for jj=1:8
                
                plot(dactab,  squeeze(allima2(jj,ii,:)),'-+','Color',[0.5 ii/8 jj/8])
            end
        end
        hold off
        legend('Q1')
         xlabel('Threshold DAC1 ')
    ylabel('Mean intensity [counts per exposure]')
    hold off
    set(gca, 'YScale','log')
    %legend('Q0','Q1','Q2','Q3','Single pix: [1,1]')
    box on
    grid on
    
        subplot(2,2,3)
        hold on
        for ii=9:16
            for jj=1:8
                plot(dactab,  squeeze(allima2(jj,ii,:)),'-+','Color',[0.5 ii/16 jj/8])
            end
        end
        hold off
        legend('Q2')
         xlabel('Threshold DAC1 ')
    ylabel('Mean intensity [counts per exposure]')
    hold off
    set(gca, 'YScale','log')
    %legend('Q0','Q1','Q2','Q3','Single pix: [1,1]')
    box on
    grid on
    
        subplot(2,2,4)
        hold on
        for ii=9:16
            for jj=9:16
                plot(dactab,  squeeze(allima2(jj,ii,:)),'-+','Color',[0.5 ii/16 jj/16])
            end
        end
        hold off
        legend('Q3')
    end
    xlabel('Threshold DAC1 ')
    ylabel('Mean intensity [counts per exposure]')
    hold off
    set(gca, 'YScale','log')
    %legend('Q0','Q1','Q2','Q3','Single pix: [1,1]')
    box on
    grid on
    set(gcf,'Color','w')
    title(['Bipolar fs; Gain:' num2str(gaintab) 'd(' dec2hex(gaintab) 'h); ' masklabel])
    xlim([dactab(1) dactab(end)])
    
    %
    % gain adjustement
    load('MarocMap.mat');
    
    refpixelxyQ0=[10 3];
    refpixelxyQ1=[3 6];
    refpixelxyQ2=[3 13];
    refpixelxyQ3=[10 14];
    subplot(2,2,1)
    hold on
    plot(dactab,  squeeze(allima2(refpixelxyQ0(1),refpixelxyQ0(2),:)),'-o','Color',[0.5 0.5 0.5],'LineWidth',3.5)
    hold off
    title([' ITER#' num2str(loopgaincnt)])
         
    subplot(2,2,2)
    hold on
    plot(dactab,  squeeze(allima2(refpixelxyQ1(1),refpixelxyQ1(2),:)),'-o','Color',[0.5 0.5 0.5],'LineWidth',3.5)
    hold off
    subplot(2,2,3)
    hold on
    plot(dactab,  squeeze(allima2(refpixelxyQ2(1),refpixelxyQ2(2),:)),'-o','Color',[0.5 0.5 0.5],'LineWidth',3.5)
    hold off
    subplot(2,2,4)
    hold on
    plot(dactab,  squeeze(allima2(refpixelxyQ3(1),refpixelxyQ3(2),:)),'-o','Color',[0.5 0.5 0.5],'LineWidth',3.5)
    hold off
    
    
    
    datenow=datestr(now,'yymmddHHMMSS');
    saveas(gcf,['adjustGain' datenow '_' num2str(loopgaincnt) '.png'])
    saveas(gcf,['adjustGain' datenow '_' num2str(loopgaincnt) '.fig'])
                    frame = getframe(gcf);
                          im = frame2im(frame); %,
                         [imind,cm] = rgb2ind(im,256);
                         delay=0.5;
                        if loopgaincnt == 1;
                             cpsname=['cps_' num2str(loopgaincnt) '_' datenow '.gif'];
                            imwrite(imind,cm,cpsname,'gif', 'Loopcount',inf,'DelayTime',delay);%,'ScreenSize',[640 640]
                        else
                             imwrite(imind,cm,cpsname,'gif','WriteMode','append','DelayTime',delay);
                        end
    
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
    
    
    daczeropoint1=0;threshpeak=0.3;
    peaksrefdacQ0=findpelevel(phdrefQ0,dactab,daczeropoint1,threshpeak);
     peaksrefdacQ1=findpelevel(phdrefQ1,dactab,daczeropoint1,threshpeak);
      peaksrefdacQ2=findpelevel(phdrefQ2,dactab,daczeropoint1,threshpeak);
       peaksrefdacQ3=findpelevel(phdrefQ3,dactab,daczeropoint1,threshpeak);
    
    %%%QUAD# 0
    %%check example:
    iitest=3;jjtest=11;
    for ii=1:8
        for jj=9:16
            if (jj~= refpixelxyQ0(1)) || (ii~= refpixelxyQ0(2))
              testpixelxy=[jj ii];
            %testpixelxy(1)=testpixelxy(1);
            if ii==iitest && jj==jjtest
                subplot(2,2,1)
                hold on
                plot(dactab,  squeeze(allima2(testpixelxy(1),testpixelxy(2),:)),'-d','Color',[0.2 0.2 0.2],'LineWidth',3.4)
                
                hold off
                
            end
            
            phdtestQ0=squeeze(allima2(testpixelxy(1),testpixelxy(2),:));
           % peakstestdacQ0=findpelevel(phdtestQ0,dactab,daczeropoint1,threshpeak);
               [minval minindr1]= min( abs(peaksrefdacQ0(1) - dactab)); 
             [minval minindr0]= min( abs(peaksrefdacQ0(3) - dactab)); 
             [minval minind]= min( abs(phdtestQ0(minindr1:end)-phdrefQ0(minindr3))) ;
            peakstestdacQ0=peaksrefdacQ0(1)-1+minind;
            
            %find sep between pe and shift between pix
            if numel(peakstestdacQ0)>=1
                peaksepQ0=peakstestdacQ0(1)-peaksrefdacQ0(3);
                %peaksepQ0=peakstestdacQ0(1:3)-peaksrefdacQ0(1:3);
                %peaksep=peakstestdac(3)-peaksrefdac(3);
                peakmoveQ0=sign(round(mean(peaksepQ0)));
                
                
                disp(['pe levels REFpix found at dac: ' num2str(peaksrefdacQ0)])
                disp(['pe levels TestPix found at dac: ' num2str(peakstestdacQ0)])
                
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
            end
        end
    end
    
    
    %%%QUAD# 1
    %%check example:
    iitest=2;jjtest=6;
    for ii=1:8
        for jj=1:8
            if (jj~= refpixelxyQ1(1)) || (ii~= refpixelxyQ1(2))
              testpixelxy=[jj ii];
            %testpixelxy(1)=testpixelxy(1);
            if ii==iitest && jj==jjtest
                 subplot(2,2,2)
                hold on
                
                plot(dactab,  squeeze(allima2(testpixelxy(1),testpixelxy(2),:)),'-d','Color',[0.2 0.2 0.2],'LineWidth',3.4)
                
                hold off
                
            end
            
            phdtestQ1=squeeze(allima2(testpixelxy(1),testpixelxy(2),:));
           % peakstestdacQ1=findpelevel(phdtestQ1,dactab,daczeropoint1,threshpeak);
             [minval minindr1]= min( abs(peaksrefdacQ1(1) - dactab)); 
             [minval minindr3]= min( abs(peaksrefdacQ1(3) - dactab)); 
             [minval minind]= min( abs(phdtestQ1(minindr1:end)-phdrefQ1(minindr3))) ;
            peakstestdacQ1=peaksrefdacQ1(1)-1+minind;
            
            %find sep between pe and shift between pix
            if numel(peakstestdacQ1)>=1
                peaksepQ1=peakstestdacQ1(1)-peaksrefdacQ1(3);
                %peaksepQ1=peakstestdacQ1(1:3)-peaksrefdacQ1(1:3);
                %peaksep=peakstestdac(3)-peaksrefdac(3);
                peakmoveQ1=sign(round(mean(peaksepQ1)));
                
                
                disp(['pe levels REFpix found at dac: ' num2str(peaksrefdacQ1)])
                disp(['pe levels TestPix found at dac: ' num2str(peakstestdacQ1)])
                
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
                
            end
            end
        end
    end
    
    %%%QUAD# 2
    %%check example:
    iitest=11;jjtest=6;
    for ii=9:16
        for jj=1:8
            if (jj~= refpixelxyQ2(1)) || (ii~= refpixelxyQ2(2))
              testpixelxy=[jj ii];
            %testpixelxy(1)=testpixelxy(1);
            if ii==iitest && jj==jjtest
                 subplot(2,2,3)
                hold on
                plot(dactab,  squeeze(allima2(testpixelxy(1),testpixelxy(2),:)),'-d','Color',[0.2 0.2 0.2],'LineWidth',3.4)
                
                hold off
                
            end
            
            phdtestQ2=squeeze(allima2(testpixelxy(1),testpixelxy(2),:));
           % peakstestdacQ2=findpelevel(phdtestQ2,dactab,daczeropoint1,threshpeak);
             [minval minindr1]= min( abs(peaksrefdacQ2(1) - dactab)); 
             [minval minindr3]= min( abs(peaksrefdacQ2(3) - dactab)); 
             [minval minind]= min( abs(phdtestQ2(minindr1:end)-phdrefQ2(minindr3))) ;
            peakstestdacQ2=peaksrefdacQ2(1)-1+minind;
            
            %find sep between pe and shift between pix
            if numel(peakstestdacQ2)>=1
                peaksepQ2=peakstestdacQ2(1)-peaksrefdacQ2(3);
                %peaksepQ2=peakstestdacQ2(1:3)-peaksrefdacQ2(1:3);
                %peaksep=peakstestdac(3)-peaksrefdac(3);
                peakmoveQ2=sign(round(mean(peaksepQ2)));
                
                
                disp(['pe levels REFpix Q2 found at dac: ' num2str(peaksrefdacQ2)])
                disp(['pe levels TestPix Q2 found at dac: ' num2str(peakstestdacQ2)])
                
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
                
            end
            end
        end
    end
    
    
    
    %%%QUAD# 3
    %%check example:
    iitest=11;jjtest=14;
    for ii=9:16
        for jj=9:16
            if (jj~= refpixelxyQ3(1)) || (ii~= refpixelxyQ3(2))
              testpixelxy=[jj ii];
            %testpixelxy(1)=testpixelxy(1);
            if ii==iitest && jj==jjtest
                 subplot(2,2,4)
                hold on
                plot(dactab,  squeeze(allima2(testpixelxy(1),testpixelxy(2),:)),'-d','Color',[0.2 0.2 0.2],'LineWidth',3.4)
                
                hold off
                
            end
            
            phdtestQ3=squeeze(allima2(testpixelxy(1),testpixelxy(2),:));
           % peakstestdacQ3=findpelevel(phdtestQ3,dactab,daczeropoint1,threshpeak);
            [minval minindr1]= min( abs(peaksrefdacQ3(1) - dactab)); 
             [minval minindr3]= min( abs(peaksrefdacQ3(3) - dactab)); 
             [minval minind]= min( abs(phdtestQ3(minindr1:end)-phdrefQ3(minindr3))) ;
            peakstestdacQ3=peaksrefdacQ3(1)-1+minind;
            
            %find sep between pe and shift between pix
            if numel(peakstestdacQ3)>=1
                peaksepQ3=peakstestdacQ3(1)-peaksrefdacQ3(3);
                %peaksepQ3=peakstestdacQ3(1:3)-peaksrefdacQ3(1:3);
                %peaksep=peakstestdac(3)-peaksrefdac(3);
                peakmoveQ3=sign(round(mean(peaksepQ3)));
                
                
                disp(['pe levels REFpix Q3 found at dac: ' num2str(peaksrefdacQ3)])
                disp(['pe levels TestPix Q3 found at dac: ' num2str(peakstestdacQ3)])
                
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
            end
        end
    end
    
    %%%%put quad at right DAC 1pe and take screenshot of image and gain map
     quaboconfig(indexdac,1+1)={['0x' dec2hex(peaksrefdacQ0(3))]};
      quaboconfig(indexdac,2+1)={['0x' dec2hex(peaksrefdacQ1(3))]};
      quaboconfig(indexdac,3+1)={['0x' dec2hex(peaksrefdacQ2(3))]};
       quaboconfig(indexdac,4+1)={['0x' dec2hex(peaksrefdacQ3(3))]};
    
        disp(['Sending Maroc comm...DAC1 Q0:' num2str(peaksrefdacQ0(3))])
         disp(['Sending Maroc comm...DAC1 Q1:' num2str(peaksrefdacQ1(3))])
          disp(['Sending Maroc comm...DAC1 Q2:' num2str(peaksrefdacQ2(3))])
           disp(['Sending Maroc comm...DAC1 Q3:' num2str(peaksrefdacQ3(3))])
        sendconfig2Maroc(quaboconfig)
        pause(2)
           images=grabimages(nim,1,1);
        
        meanimage=mean(images(:,:,:),[3])';
        
        figure
         imagesc(meanimage)
        %title('Image')
        colorbar
          set(gcf,'Color','w')
         ti= title(['Image ITER#' num2str(loopgaincnt) ' DAC1 Q0:' num2str(peaksrefdacQ0(3)) ' Q1:' num2str(peaksrefdacQ1(3)) ' Q2:' num2str(peaksrefdacQ2(3)) ' Q3:' num2str(peaksrefdacQ3(3))])
         set(ti,'FontSize',14)
         saveas(gcf,['Ima_' num2str(loopgaincnt) '_' datenow '.png'])
         saveas(gcf,['Ima_' num2str(loopgaincnt) '_' datenow '.fig'])
          
                    frame = getframe(gcf);
                          im = frame2im(frame); %,
                         [imind,cm] = rgb2ind(im,256);
                         delay=0.5;
                        if loopgaincnt == 1;
                             imagename=['Ima_' num2str(loopgaincnt) '_' datenow '.gif'];
                            imwrite(imind,cm,imagename,'gif', 'Loopcount',inf,'DelayTime',delay);%,'ScreenSize',[640 640]
                        else
                             imwrite(imind,cm,imagename,'gif','WriteMode','append','DelayTime',delay);
                        end
 
        figure
        imagesc(gainmap)
           %title('Gain map')
        colorbar
        set(gcf,'Color','w')
       ti= title(['Gain map ITER#' num2str(loopgaincnt) ' DAC1 Q0:' num2str(peaksrefdacQ0(3)) ' Q1:' num2str(peaksrefdacQ1(3)) ' Q2:' num2str(peaksrefdacQ2(3)) ' Q3:' num2str(peaksrefdacQ3(3))])
          set(ti,'FontSize',14)
            saveas(gcf,['Gainmap_' num2str(loopgaincnt) '_' datenow '.png'])
         saveas(gcf,['Gainmap_' num2str(loopgaincnt) '_' datenow '.fig'])
                        frame = getframe(gcf);
                          im = frame2im(frame); %,
                         [imind,cm] = rgb2ind(im,256);
                         delay=0.5;
                        if loopgaincnt == 1;
                             gainname=['Gainmap_' num2str(loopgaincnt) '_' datenow '.gif'];
                            imwrite(imind,cm,gainname,'gif', 'Loopcount',inf,'DelayTime',delay);%,'ScreenSize',[640 640]
                        else
                             imwrite(imind,cm,gainname,'gif','WriteMode','append','DelayTime',delay);
                        end
        
end

figure
hold on
plot(dactab,phdref,'g')
%plot(dactab,-d0,'b')
plot(dactab,d1,'r')
plot(dactab,d1r,'m')
hold off
set(gca,'YScale','log')





