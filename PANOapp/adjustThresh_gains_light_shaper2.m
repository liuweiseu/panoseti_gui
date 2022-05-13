%close all
if ~exist('s','var')
    s = serial('COM6','BaudRate',9600);
    fopen(s)
end
datarep=[getuserdir '\panoseti\DATA\Calibrations\']
  dactab=[160:1:350 ];
%gaintabtab=[21 33 70];%11:31 %1:10:121;
gaintabtab=[33 66 99 132 165 198 231];%11:31 %1:10:121;
%currtabExp=[0. round(logspace(0,log10(4000),10))];
%currtabExp=[0. 2.^(2:11)];
currtabExp=[0. 2.^(2:11)];
%currtabExp=[0.];
    expstr='Half-bipolar;';
    shaperstr='Half-Bipolar fs; ';
    maskstr='All-pixels-masked-excepted-one [7,1]; ';
IntensmeanQ9G=zeros(numel(dactab),numel(gaintabtab),numel(currtabExp));
%%let's do 16 possibility for Bfs
BfsRCt=[0.5 1.75 3 4.25 0.66 2.31 3.96 5.61 1 3.5 6 8.5 2 7 12 17];
BfsR=1e3*[25 25 25 25 33 33 33 33 50 50 50 50 100 100 100 100];
BfsC=[20 70 120 170 20 70 120 170 20 70 120 170 20 70 120 170];
Bfschoice=[12 ]; 

  IntensmeanQ9GS=zeros(numel(dactab),numel(gaintabtab),numel(currtabExp),numel(Bfschoice)) ;
   dactabselectindS=zeros(3,3,numel(Bfschoice));

for bb=1:numel(Bfschoice)
   %for bb=2:numel(Bfschoice)
  realhvQ0=[];realhvQ1=[];realhvQ2=[];realhvQ3=[];
realcurQ0=[];realcurQ1=[];realcurQ2=[];realcurQ3=[];
temp1=[];temp2=[]; 
timecomp=[];

for cc=1:numel(currtabExp)
    disp(['Testing Curr:' num2str(currtabExp(cc))])
    disp(['Setting: U' num2str(currtabExp(cc),'%05g') ';'])
    %setADU(['WR' num2str(currtab(ii),'%05g')]);
    setJimPS(s,currtabExp(cc))
    disp('Changing Light intensity. Waiting 15s for HV to be adjusted...')
   if cc>1
    pause(15)
   end 
    quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config.txt']);
    [ig,indexstimon]=ismember(['STIMON '] ,quaboconfig);
    quaboconfig(indexstimon,2)={"0"};
    pausetime=0.5;
    indcol=1:4;
    %shaper
         [ig,indexCmdfsb]=ismember(['CMD_FSB'] ,quaboconfig);   
     [ig,indexCmdfsbfsu]=ismember(['CMD_FSB_FSU'] ,quaboconfig);  
     [ig,indexCmdfsu]=ismember(['CMD_FSU'] ,quaboconfig);
     %bipolar should be cmdfsb=1 cmdfsbfsu=0 cmdfsu=0
     %wrong:half bipolar should be cmdfsb=1 cmdfsbfsu=1 cmdfsu=0
     quaboconfig(indexCmdfsb,indcol+1)={"1"};
     quaboconfig(indexCmdfsbfsu,indcol+1)={"1"};
     quaboconfig(indexCmdfsu,indcol+1)={"0"};
     [ig,indexd1d2]=ismember(['D1_D2'] ,quaboconfig);
    quaboconfig(indexd1d2,indcol+1)={"1"};
     %exposure
    [ig,indexacqint]=ismember(['ACQINT '] ,quaboconfig);
    acqint=(1e-5)*str2num(quaboconfig(indexacqint,2));
    exposurestr=['Exposure time [ms]:' num2str(1000*acqint,'%3.3g')];
    normcps=1/acqint;
    %set gain
    IntensmeanQ8G=[];
    
    for  gainkk=1:numel(gaintabtab);
        gaintab=gaintabtab(gainkk);
        for pp=0:63
            [ig,indexgain]=ismember(['GAIN' num2str(pp)] ,quaboconfig);
            
            quaboconfig(indexgain,indcol+1)={['0x' dec2hex(gaintab(1))]};
        end
        
        
        %set masks MASKOR1_
        mask=1;
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
        

     
       shaperstr=['Half-Bipolar fs (' num2str(BfsRCt(Bfschoice(bb))) 'ns;'] ;
     [ig,indexBFS50F]=ismember(['SW_FSB2_50F'] ,quaboconfig);
     [ig,indexBFS100F]=ismember(['SW_FSB2_100F'] ,quaboconfig);
     [ig,indexBFS100K]=ismember(['SW_FSB2_100K'] ,quaboconfig);
     [ig,indexBFS50k]=ismember(['SW_FSB2_50K'] ,quaboconfig);
    %quaboconfig(indexsBFS50F,2)={"0"};
    BfsCind=mod(Bfschoice(bb),4);
    BfsRind=ceil(Bfschoice(bb)/4);
    %caps:
    if BfsCind==1
        quaboconfig(indexBFS100F,indcol+1)={"0"};
        quaboconfig(indexBFS50F,indcol+1)={"0"};
    elseif BfsCind==2
        quaboconfig(indexBFS100F,indcol+1)={"0"};
        quaboconfig(indexBFS50F,indcol+1)={"1"};
     elseif BfsCind==3
        quaboconfig(indexBFS100F,indcol+1)={"1"};
        quaboconfig(indexBFS50F,indcol+1)={"0"};
    elseif BfsCind==0
        quaboconfig(indexBFS100F,indcol+1)={"1"};
        quaboconfig(indexBFS50F,indcol+1)={"1"};    
    end
    %resistors:
     if BfsRind==1
        quaboconfig(indexBFS100K,indcol+1)={"1"};
        quaboconfig(indexBFS50k,indcol+1)={"1"};
    elseif BfsRind==2
        quaboconfig(indexBFS100K,indcol+1)={"0"};
        quaboconfig(indexBFS50k,indcol+1)={"1"};
     elseif BfsRind==3
        quaboconfig(indexBFS100K,indcol+1)={"1"};
        quaboconfig(indexBFS50k,indcol+1)={"0"};
    elseif BfsRind==4
        quaboconfig(indexBFS100K,indcol+1)={"0"};
        quaboconfig(indexBFS50k,indcol+1)={"0"};    
    end
% SW_FSB1_50F=1,1,1,1
% SW_FSB1_100F=1,1,1,1
% SW_FSB1_100K=1,1,1,1
% SW_FSB1_50k=0,0,0,0
  
        
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
        %figure
        [ia,indexdac]=ismember('DAC2',quaboconfig);
         [ia,indexdac1]=ismember('DAC1',quaboconfig);
          quaboconfig(indexdac1,indcol+1)={['0x' dec2hex(1023)]};
        %put high thresh on all 4 quads
        % dactabH0=500;
        %  quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactabH0)]};
        %  pause(pausetime)
        
        IntensmeanQ0=[];IntensmeanQ1=[];IntensmeanQ2=[];IntensmeanQ3=[];IntensmeanQ8=[];IntensmeanQ9=[];
        allima=zeros(16,16,numel(dactab),numel(indcol));
        indcol2=1;
        for dd=1:numel(dactab)
            quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactab(dd))]};
            disp(['Sending Maroc comm...DAC2:' num2str(dactab(dd)) ' Gain:' num2str((gaintabtab(gainkk))) ' (' num2str(gainkk) '/' num2str(numel(gaintabtab)) ')' ...
                'Light I [step]: ' num2str(cc) '/' num2str(numel(currtabExp))])
            sendconfig2Maroc(quaboconfig)
            
            %timepause=10;
            %disp(['Q' num2str(indcol2) '  ' num2str( timepause*(numel(dactab)-dd)) 's left...'])
            pause(pausetime)
            %pause(pausetime)
            images=grabimages(10,1,1);
            
            meanimage=mean(images(:,:,:),[3])';
            allima(:,:,dd,indcol2)=meanimage;
            
            %imagesc(meanimage)
           % colorbar
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
            
               IntensmeanQ9G(dd,gainkk,cc)=(meanimage(1,7));
            
        end
        IntensmeanQ8G=[IntensmeanQ8G; IntensmeanQ8];
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
        
        % figure
        % hold on
        % figquad=0;
        % if figquad==1
        % % plot(dactab, IntensmeanQ0,'-+b')
        % %  plot(dactab, IntensmeanQ1,'-+r')
        % %  plot(dactab, IntensmeanQ2,'-+g')
        % %  plot(dactab, IntensmeanQ3,'-+m')
        %  plot(dactab, IntensmeanQ8,'-+k')
        % else
        %     allima2=allima(:,:,:,1);
        %     for ii=1:8
        %         for jj=9:16
        %             plot(dactab,  squeeze(allima2(jj,ii,:)),'-+','Color',[0.5 ii/8 jj/16])
        %         end
        %     end
        % end
        % xlabel('Threshold DAC1 ')
        % ylabel('Mean intensity [counts per exposure]')
        % hold off
        % set(gca, 'YScale','log')
        % legend('Q0','Q1','Q2','Q3','Single pix: [1,1]')
        % box on
        % grid on
        % set(gcf,'Color','w')
        % title(['Bipolar fs; Gain:' num2str(gaintab) 'd(' dec2hex(gaintab) 'h); all-pixels-masked-excepted-one '])
        %  datenow=datestr(now,'yymmddHHMMSS');
        %   saveas(gcf,['threshImaDAC' datenow 'allpix_masked.png'])
        %     saveas(gcf,['threshImaDAC' datenow 'allpix_masked.fig'])
        %
        %    %%DEDUCE OPTIMAL VALUES AT MAX CNTS
        %    [mv,mind0]=max(IntensmeanQ0);
        %     [mv,mind1]=max(IntensmeanQ1);
        %      [mv,mind2]=max(IntensmeanQ2);
        %       [mv,mind3]=max(IntensmeanQ3);
        %       %find first zeros after bump
        %     indz0=  find(IntensmeanQ0(mind0+1:end)==2)
        %     indz1=  find(IntensmeanQ1(mind1+1:end)==2)
        %     indz2=  find(IntensmeanQ2(mind2+1:end)==2)
        %     indz3=  find(IntensmeanQ3(mind3+1:end)==2)
        %     shifttab=1
        %    quaboconfig(indexdac,indcol(1)+1)={['0x' dec2hex(dactab(mind0)+indz0(1)+shifttab+2)]};
        %    quaboconfig(indexdac,indcol(2)+1)={['0x' dec2hex(dactab(mind1)+indz1(1)+shifttab)]};
        %    quaboconfig(indexdac,indcol(3)+1)={['0x' dec2hex(dactab(mind2)+indz2(1)+shifttab)]};
        %    quaboconfig(indexdac,indcol(4)+1)={['0x' dec2hex(dactab(mind3)+indz3(1)+shifttab+2)]};
        %    sendconfig2Maroc(quaboconfig)
        %
        %    dactabbest=[dactab(mind0)+indz0(1)+3 (dactab(mind1)+indz1(1)+3) (dactab(mind2)+6) (dactab(mind3)+indz3(1)+3)]
        %    save(['adjustthresh' datenow '.mat'])
        %     quaboconfig(indexstimon,2)={"0"};
        
        % RickLEDV=[1.7 1.8 1.9 2. 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0 3.5 4. 4.5 5. 6. 7. 10. 15. 20. 23.];
        % ThorlabsnW=[0.3 0.6 1. 1.4 1.9 2.4 3. 3.5 4.1 4.7 5.4 6.0 6.6 7.3 10.6 14.1 17.7 21.4 29.1 37. 57.3 96. 136. 160.];
        % ThorlabsnWND=0.01*ThorlabsnW;
        %
        % ThorlabsnWNDpix=(1/((pi*(9.5/2)^2)/9.))*ThorlabsnWND;
        % h=6.62607e-34;c=2.998e8;lam=0.633e-6;
        % ThorlabsnWNDpixphot=(lam/h/c) *(1e-9)* ThorlabsnWNDpix;
        % qe=0.22;
        % ThorlabsnWNDpixcnt=qe*ThorlabsnWNDpixphot;
        %
        % leg={};
        % for ii=1:numel(ThorlabsnWNDpixphot)
        %     leg(ii)={ ['LED [Mph/s/pix]:' num2str(1e-6*ThorlabsnWNDpixphot(ii),'%6.1f') ' [nW/pix]:' num2str(ThorlabsnWNDpix(ii),'%6.4f')]};
        % end
        %  leg(ii+1)={ ['Dark, Q1 pix [7,1]']};
        %
        % legend(leg)
    end
    clf
    figure
    
    for ii=1:size(IntensmeanQ8G,1)
        hold on
        plot(dactab,normcps* IntensmeanQ8G(ii,:),'-+','Color',rand(1,3),'Linewidth',1.5) %[ii/size(IntensmeanQ8G,1) (1-ii/size(IntensmeanQ8G,1)) ii/size(IntensmeanQ8G,1)]
        hold off
    end
    
    xlabel('Threshold DAC2 ')
    ylabel('Mean intensity [counts per second]')
    hold off
    set(gca, 'YScale','log')
    
    leg={};
    for ii=1:numel(gaintabtab)
        leg(ii)={ ['Gain: ' num2str(gaintabtab(ii)) ' (0x' dec2hex(gaintabtab(ii)) ')']};
    end
    legend(leg)
    box on
    grid on
    set(gcf,'Color','w')
    title([expstr shaperstr maskstr exposurestr])
    datenow=datestr(now,'yymmddHHMMSS');
    %saveas(gcf,[datarep 'threshImaDACGAIN' datenow '_masked.png'])
    %saveas(gcf,[datarep 'threshImaDACGAIN' datenow '_masked.fig'])
    %save([datarep 'threshImaDACGAIN' datenow '_masked.mat'])
    clf;
    
    %save hk
    
    try
        hk = getlastHK;
    catch
        pause(0.11)
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
    
end
setJimPS(s,0)

%%use calibration light
% LEDND_Brightness_current_190531105316
load(['LEDND_Brightness_current_' '190531105316' '.mat'])
powerdet=zeros(1,numel(currtabExp));
for ii=2:numel(currtabExp)
    [ d, ix ] = min( abs( currtab-currtabExp(ii) ) );
    powerdet(ii)=ThorlabsnWNDpixfit(ix);
end

intensselect=[1 11];

% FIG: Light Intens. vs dactab for gains
    figure('Position',[10 10 1400 900])
     hold on
    % colortable=['b','r','g','m'];
    colortable=[0 0 1; 1 0 1;0 1 1;1 0 0;0 1 0;0 0 0;1 1 0;...
        0 0 0.5; 0.5 0 0.5;0 0.5 0.5;0.5 0 0;0 0.5 0;0 0 0;0.5 0.5 0];
%          [1 1 0]	%y	yellow
%      [1 0 1]	%m	magenta
% 	[0 1 1]	%c	cyan
% 	[1 0 0]	%r	red
% 	[0 1 0]	%g	green
% 	[0 0 1]	%b	blue
% 	[0 0 0]	%k	black 


     symg=['+','o','d','s','*','^','v','>','<','+','o','d','s','*','^','v','>','<'];
  for iiL=1:size(intensselect,2)
    for iig=1:size(IntensmeanQ9G,2)    
        plot(dactab, normcps*IntensmeanQ9G(:,iig,intensselect(iiL)),['-' symg(iig)],'Color',colortable(iiL,:),'Linewidth',1.5) %[ii/size(IntensmeanQ8G,1) (1-ii/size(IntensmeanQ8G,1)) ii/size(IntensmeanQ8G,1)]     
    end
  end
  hold off
set(gca,'FontSize',16)    
    xlabel('Threshold DAC2 ')
    ylabel('Mean intensity [counts per second]')
    hold off
    set(gca, 'YScale','log')
    
    leg={};
%     for ii=1:numel(gaintabtab)
%         leg(ii)={ ['Gain:' num2str(gaintabtab(ii)) ' (0x' dec2hex(gaintabtab(ii)) ')']};
%     end

iicc=1;
  for iiL=1:size(intensselect,2)
    for iig=1:size(IntensmeanQ9G,2)    
          leg(iicc)={ ['Gain:' num2str(gaintabtab(iig)) ' (0x' dec2hex(gaintabtab(iig)) '); Light [nW/pix]:' num2str(powerdet(intensselect(iiL)))]};
       iicc=iicc+1;   
    end
  end
    legend(leg,'Location','SouthWest')
    box on
    grid on 
    set(gcf,'Color','w')
    title([expstr shaperstr maskstr exposurestr])
    datenow=datestr(now,'yymmddHHMMSS');
    saveas(gcf,[datarep 'threshImaDACGAINLight_' datenow 'bp' num2str(Bfschoice(bb)) '_masked.png'])
    saveas(gcf,[datarep 'threshImaDACGAINLight_' datenow 'bp' num2str(Bfschoice(bb)) '_masked.fig'])
  %  save(['threshImaDACGAINLight_' datenow '_masked.mat'])
    
    %%%% FIG: Cnts vs Light_Intens
dactabselect=[190 198 206];
dactabselectind=zeros(1,numel(dactabselect));
for ii=1:numel(dactabselect)
    [ d, ixdac ] = min( abs( dactab-dactabselect(ii) ) );
    dactabselectind(ii)=ixdac;
end
    figure('Position',[10 10 1400 900])
     hold on
  for iid=1:size(dactabselect,2)
    for iig=1:size(IntensmeanQ9G,2)    
        plot(powerdet,normcps* squeeze(IntensmeanQ9G(dactabselectind(iid),iig,:)),['-' symg(iig)],'Color',colortable(iid,:),'Linewidth',1.5) %[ii/size(IntensmeanQ8G,1) (1-ii/size(IntensmeanQ8G,1)) ii/size(IntensmeanQ8G,1)]     
    end
  end
  hold off
  xlabel('Light power [nW/pix] ')
    ylabel('Mean counts # [counts per second]')
    hold off
    set(gca,'FontSize',16) 
    
    leg={};
%     for ii=1:numel(gaintabtab)
%         leg(ii)={ ['Gain:' num2str(gaintabtab(ii)) ' (0x' dec2hex(gaintabtab(ii)) ')']};
%     end
  for iid=1:size(dactabselect,2)
    for iig=1:size(IntensmeanQ9G,2)    
          leg(iig+(iid-1)*size(IntensmeanQ9G,2))={ ['Gain: ' num2str(gaintabtab(iig)) ' (0x' dec2hex(gaintabtab(iig)) ')' ' DAC: ' num2str(dactabselect(iid)) ]};
       end
  end
    legend(leg,'Location','northwest')
    box on
    grid on
    set(gcf,'Color','w')

    title([expstr shaperstr maskstr exposurestr])
    datenow=datestr(now,'yymmddHHMMSS');
   
   % save(['Light_threshImaDACGAIN' datenow '_masked.mat'])
     saveas(gcf,[datarep 'Light_threshImaDACGAIN' datenow  'bp' num2str(Bfschoice(bb)) '_masked.png'])
    saveas(gcf,[datarep 'Light_threshImaDACGAIN' datenow  'bp' num2str(Bfschoice(bb)) '_masked.fig'])
    set(gca, 'YScale','log', 'XScale','log')
      saveas(gcf,[datarep 'Light_threshImaDACGAIN' datenow  'bp' num2str(Bfschoice(bb)) '_maskedLOGLOG.png'])
    saveas(gcf,[datarep 'Light_threshImaDACGAIN' datenow  'bp' num2str(Bfschoice(bb)) '_maskedLOGLOG.fig'])
    
    
    %%%% FIG: Cnts vs Light_Intens PEs
      daczeropoint1=185;threshpeak=0.3;
       dactabselectind=zeros(1,numel(dactabselect));
       smaller=[1 0 0];
    for iig=1 :size(IntensmeanQ9G,2)
        %special settings for high gain
        if iig==1
            daczeropoint1=180;threshpeak=0.3;
        else 
             daczeropoint1=185;threshpeak=0.3;
        end
        if iig>4
            daczeropoint1=195;threshpeak=0.22;
        end
          peakstestdac=findpelevel(squeeze(IntensmeanQ9G(:,iig,1)),dactab,daczeropoint1,threshpeak,smaller);
      %    dactabselect=peakstestdac(1:3)  %[192 201 206];

            %do it on 0.5 pe, 1.5pe, 2.5pe
            %%first find number of dacs per pe
           dacperpe= round(0.5*(peakstestdac(3)-peakstestdac(1))-0.01);
            
           dactabselect=peakstestdac(1:3) -0.5*dacperpe;
            dactabselect(1)=max([dactabselect(1) daczeropoint1]);
                      %do it on 1pe,2pe,3pe
        for ii=1:numel(dactabselect)
            [ d, ixdac ] = min( abs( dactab-dactabselect(ii) ) );
            dactabselectind(ii,iig)=ixdac
        end
        %
    end
    
    figure('Position',[10 10 1400 900])
     hold on
  for iid=1:size(dactabselect,2)
    for iig=1:size(IntensmeanQ9G,2) 
        plot(powerdet,normcps* squeeze(IntensmeanQ9G(dactabselectind(iid,iig),iig,:)),['-' symg(iig)],'Color',colortable(iid,:),'Linewidth',1.5) %[ii/size(IntensmeanQ8G,1) (1-ii/size(IntensmeanQ8G,1)) ii/size(IntensmeanQ8G,1)]     
    end
  end
  hold off
  xlabel('Light power [nW/pix] ')
    ylabel('Mean counts # [counts per second]')
    hold off
    set(gca,'FontSize',16) 
   % title(['DAC:'  shaperstr maskstr exposurestr])
    
    leg={};
%     for ii=1:numel(gaintabtab)
%         leg(ii)={ ['Gain:' num2str(gaintabtab(ii)) ' (0x' dec2hex(gaintabtab(ii)) ')']};
%     end
iicc=1;
  for iid=1:size(dactabselect,2)
    for iig=1:size(IntensmeanQ9G,2)   
          leg(iicc)={ ['Gain: ' num2str(gaintabtab(iig)) ' (0x' dec2hex(gaintabtab(iig)) ') ' num2str(iid-0.5) 'pe)']};
       iicc=iicc+1;
    end
  end
    legend(leg,'Location','northwest')
    box on
    grid on
    set(gcf,'Color','w')

    title([expstr shaperstr maskstr exposurestr])
    datenow=datestr(now,'yymmddHHMMSS');
   
   % save(['Light_threshImaDACGAIN' datenow '_masked.mat'])
     saveas(gcf,[datarep 'Light_threshImaDACGAIN' datenow  'bp' num2str(Bfschoice(bb)) '_masked.png'])
    saveas(gcf,[datarep 'Light_threshImaDACGAIN' datenow  'bp' num2str(Bfschoice(bb)) '_masked.fig'])
    set(gca, 'YScale','log', 'XScale','log')
      saveas(gcf,[datarep 'Light_threshImaDACGAIN' datenow  'bp' num2str(Bfschoice(bb)) '_maskedLOGLOG.png'])
    saveas(gcf,[datarep 'Light_threshImaDACGAIN' datenow  'bp' num2str(Bfschoice(bb)) '_maskedLOGLOG.fig'])
    
    
%%%%% FIG: HK
   figure('Position',[10 10 1400 900])
set(gcf,'Color','w')
subplot(2,3,1)
%title([exper ', Quabo SN009, ' datestr(timecomp(1),'yyyy-mm-dd HH:MM') ', Imaging DAC1:' num2str(dactabbest) ' Gain:'  num2str(gaintab)])
hold on
%plot(powerdet,realhvQ0,'b-+')
plot(powerdet,realhvQ1,'r-+')
% plot(powerdet,realhvQ2,'g-+')
% plot(24.*3600*(timecomp-timecomp(1)),realhvQ3,'m-+')
hold off
xlabel('Light power [nW/pix] ')
ylabel('HV [V]')
legend(['Q1, (V_f-V_i=' num2str(realhvQ1(end)-realhvQ1(1),'%5.4f') 'V)'])

subplot(2,3,2)
hold on
%plot(24.*3600*(timecomp-timecomp(1)),realcurQ0,'b-+')
plot(powerdet,realcurQ1,'r-+')
%plot(24.*3600*(timecomp-timecomp(1)),realcurQ2,'g-+')
%plot(24.*3600*(timecomp-timecomp(1)),realcurQ3,'m-+')
hold off
xlabel('Light power [nW/pix] ')
ylabel('I [\muA]')
legend(['Q1, (I_f-I_i=' num2str(realcurQ1(end)-realcurQ1(1),'%5.2f') '\muA)'] )

subplot(2,3,4)
hold on
plot(powerdet,temp1,'b-+')
plot(powerdet,temp2,'r-+')
hold off
xlabel('Light power [nW/pix] ')
ylabel('Temperature [C]')
legend(['TMP125, (T_f-T_i=' num2str(temp1(end)-temp1(1),'%5.2f') '\circ C)'],...
    ['Temp. FPGA, (T_f-T_i=' num2str(temp2(end)-temp2(1),'%5.2f') '\circ C)'])

subplot(2,3,5)
hold on
showpe=1;showgain=1;
%plot(powerdet,convcps*IntensmeanQ0,'b-+')
plot(powerdet,normcps*squeeze(IntensmeanQ9G(dactabselectind(showpe),(showgain),:)),'r-+')
% plot(24.*3600*(timecomp-timecomp(1)),convcps*IntensmeanQ2,'g-+')
% plot(24.*3600*(timecomp-timecomp(1)),convcps*IntensmeanQ3,'m-+')
% plot(24.*3600*(timecomp-timecomp(1)),convcps*IntensmeanQ8,'k-+')
hold off
xlabel('Light Power  [nW/pix] ')
ylabel('Median intensity [cps]')
legend(['Single pix, (cps_f-cps_i=' num2str(normcps*IntensmeanQ9G(dactabselectind(showpe),(showgain),end)-normcps*IntensmeanQ9G(dactabselectind(showpe),(showgain),1),'%5.1f') 'cps)' ])

subplot(2,3,3)
removedark=1
if removedark==0
% GQ0=(1e-6/64/1.6e-19/normcps)*(realcurQ0.*(IntensmeanQ0.^-1));
% GQ1=(1e-6/64/1.6e-19/normcps)*(realcurQ1.*(IntensmeanQ1.^-1));
% GQ2=(1e-6/64/1.6e-19/normcps)*(realcurQ2.*(IntensmeanQ2.^-1));
% GQ3=(1e-6/64/1.6e-19/normcps)*(realcurQ3.*(IntensmeanQ3.^-1));
else
   indm=1;% min(4,kk);
% GQ0=(1e-6/64/1.6e-19/normcps)*((realcurQ0-mean(realcurQ0(1:indm))).*(IntensmeanQ0.^-1));
% GQ1=(1e-6/64/1.6e-19/normcps)*((realcurQ1-mean(realcurQ1(1:indm))).*(IntensmeanQ1.^-1));
% GQ2=(1e-6/64/1.6e-19/normcps)*((realcurQ2-mean(realcurQ2(1:indm))).*(IntensmeanQ2.^-1));
% GQ3=(1e-6/64/1.6e-19/normcps)*((realcurQ3-mean(realcurQ3(1:indm))).*(IntensmeanQ3.^-1));
%GQ8=(1e-6/64/1.6e-19/normcps)*((realcurQ1-mean(realcurQ8(1:indm))).*(IntensmeanQ8.^-1));
GQ9=(1e-6/64/1.6e-19/normcps)*((realcurQ1-mean(realcurQ1(1:indm))).*(squeeze(IntensmeanQ9G(dactabselectind(showpe),(showgain),:)).^-1)');
end
hold on
%plot(24.*3600*(timecomp-timecomp(1)),GQ0,'b-+')
plot(powerdet,GQ9,'r-+')
% plot(24.*3600*(timecomp-timecomp(1)),GQ2,'g-+')
% plot(24.*3600*(timecomp-timecomp(1)),GQ3,'m-+')
% plot(24.*3600*(timecomp-timecomp(1)),GQ8,'k-+')
hold off
xlabel('Light Intensity [nW/pix]')
ylabel(['Gain at DAC2'  ' [=I/nbpix/cps/q(e-)]'])
legend( ['Q1, (G_f-G_i=' num2str(GQ9(end)-GQ9(1),'%5.1f') ')'] )

subplot(2,3,6)
%GQ0=(1e-6/64/1.6e-19/convcps)*(realcurQ0.*(IntensmeanQ0.^-1));
GQ9b=(1e-6/64/1.6e-19/normcps)*(realcurQ1.*(IntensmeanQ9G(dactabselectind(showpe),(showgain),:).^-1));
%GQ2=(1e-6/64/1.6e-19/convcps)*(realcurQ2.*(IntensmeanQ2.^-1));
%GQ3=(1e-6/64/1.6e-19/convcps)*(realcurQ3.*(IntensmeanQ3.^-1));
[sortedt, sortedind]=sort(temp1);
sortedGQ9b=GQ9b(sortedind);
hold on
%plot(temp1,GQ0(sortedind),'b-+')
plot(temp1,GQ9b(sortedind),'r-+')
%plot(temp1,GQ2(sortedind),'g-+')
%plot(temp1,GQ3(sortedind),'m-+')
hold off
xlabel('Temperature (TMP125) [\circ C]')
ylabel(['Gain at DAC2' ' [I/nbpix/cps/q(e-)]'])
legend( ['Single pix.'] )
 



datenow=datestr(now,'yymmddHHMMSS');
  saveas(gcf,[datarep 'currDACGAINLight_' datenow  'bp' num2str(Bfschoice(bb)) '_masked.png'])
    saveas(gcf,[datarep 'currDACGAINLight_' datenow  'bp' num2str(Bfschoice(bb)) '_masked.fig'])
    save([datarep 'currDACGAINLight_' datenow  'bp' num2str(Bfschoice(bb)) '_masked.mat'])
    
 
 IntensmeanQ9GS(:,:,:,bb)=IntensmeanQ9G;
 dactabselectindS(:,:,bb) =  dactabselectind;
end
    


%%FIGURE SHAPERS

%intensselect=[1 7 11];
intensselect=[1 2];
% FIG: Light Intens. vs dactab for gains
    figure('Position',[10 10 1400 900])
     hold on
    % colortable=['b','r','g','m'];
    colortable=[0 0 1; 1 0 1;0 1 1;1 0 0;0 1 0;0 0 0;1 1 0;...
        0 0 0.5; 0.5 0 0.5;0 0.5 0.5;0.5 0 0;0 0.5 0;0 0 0;0.5 0.5 0];
     symg=['+','o','d','s','*','^','v','>','<','+','o','d','s','*','^','v','>','<'];
for bb=1:numel(Bfschoice) 
     for iiL=1:size(intensselect,2)
    for iig=1:size(IntensmeanQ9G,2)   
        plot(dactab, normcps*IntensmeanQ9GS(:,iig,intensselect(iiL),bb),['-' symg(bb)],'Color',colortable(size(intensselect,2)*iiL+iig,:),'Linewidth',1.5) %[ii/size(IntensmeanQ8G,1) (1-ii/size(IntensmeanQ8G,1)) ii/size(IntensmeanQ8G,1)]     
    end
     end
end
  hold off
set(gca,'FontSize',16)    
    xlabel('Threshold DAC2 ')
    ylabel('Mean intensity [counts per second]')
    hold off
    set(gca, 'YScale','log')
    
    leg={};
%     for ii=1:numel(gaintabtab)
%         leg(ii)={ ['Gain:' num2str(gaintabtab(ii)) ' (0x' dec2hex(gaintabtab(ii)) ')']};
%     end

iicc=1;
for bb=1:numel(Bfschoice) 
  for iiL=1:size(intensselect,2)
    for iig=1:size(IntensmeanQ9G,2)    
          leg(iicc)={ ['Half-Bipolar fs (' num2str(BfsRCt(Bfschoice(bb))) 'ns;' 'Gain:' num2str(gaintabtab(iig)) ' (0x' dec2hex(gaintabtab(iig)) '); Light [nW/pix]:' num2str(powerdet(intensselect(iiL)))]};
       iicc=iicc+1;   
    end
  end
end
    legend(leg,'Location','SouthWest')
    box on
    grid on 
    set(gcf,'Color','w')
    title([expstr  maskstr exposurestr])
    datenow=datestr(now,'yymmddHHMMSS');
    saveas(gcf,[datarep 'Shaper_threshImaDACGAINLight_' datenow 'bp' num2str(Bfschoice(bb)) '_masked.png'])
    saveas(gcf,[datarep 'Shaper_threshImaDACGAINLight_' datenow 'bp' num2str(Bfschoice(bb)) '_masked.fig'])
  %  save(['threshImaDACGAINLight_' datenow '_masked.mat'])
    
    %%%% FIG: Cnts vs Light_Intens
dactabselect=[190 198 206];
dactabselectind=zeros(1,numel(dactabselect));
for ii=1:numel(dactabselect)
    [ d, ixdac ] = min( abs( dactab-dactabselect(ii) ) );
    dactabselectind(ii)=ixdac;
end
    figure('Position',[10 10 1400 900])
     hold on
      for bb=1:numel(Bfschoice)
  for iid=1:size(dactabselect,2)
    for iig=size(IntensmeanQ9G,2)    
        plot(powerdet,normcps* squeeze(IntensmeanQ9GS(dactabselectind(iid),iig,:,bb)),['-' symg(bb)],'Color',colortable(iid,:),'Linewidth',1.5) %[ii/size(IntensmeanQ8G,1) (1-ii/size(IntensmeanQ8G,1)) ii/size(IntensmeanQ8G,1)]     
    end
  end
      end
  hold off
  xlabel('Light power [nW/pix] ')
    ylabel('Mean counts # [counts per second]')
    hold off
    set(gca,'FontSize',16) 
    
    leg={};
%     for ii=1:numel(gaintabtab)
%         leg(ii)={ ['Gain:' num2str(gaintabtab(ii)) ' (0x' dec2hex(gaintabtab(ii)) ')']};
%     end
iicc=1;
 for bb=1:numel(Bfschoice)
  for iid=1:size(dactabselect,2)
    for iig=size(IntensmeanQ9G,2)    
          leg(iicc)={ ['Bipolar fs (' num2str(BfsRCt(Bfschoice(bb))) 'ns;' 'Gain: ' num2str(gaintabtab(iig)) ' (0x' dec2hex(gaintabtab(iig)) ')' ' DAC: ' num2str(dactabselect(iid)) ]};
        iicc=iicc+1;  
    end
  end
 end
    legend(leg,'Location','northwest')
    box on
    grid on
    set(gcf,'Color','w')

    title([expstr shaperstr maskstr exposurestr])
    datenow=datestr(now,'yymmddHHMMSS');
   
   % save(['Light_threshImaDACGAIN' datenow '_masked.mat'])
     saveas(gcf,[datarep 'ShaperDAC_Light_threshImaDACGAIN' datenow  'bp' num2str(Bfschoice(bb)) '_masked.png'])
    saveas(gcf,[datarep 'ShaperDAC_Light_threshImaDACGAIN' datenow  'bp' num2str(Bfschoice(bb)) '_masked.fig'])
    set(gca, 'YScale','log', 'XScale','log')
      saveas(gcf,[datarep 'ShaperDAC_Light_threshImaDACGAIN' datenow  'bp' num2str(Bfschoice(bb)) '_maskedLOGLOG.png'])
    saveas(gcf,[datarep 'ShaperDAC_Light_threshImaDACGAIN' datenow  'bp' num2str(Bfschoice(bb)) '_maskedLOGLOG.fig'])
    
    
   %%%% FIG: Cnts vs Light_Intens PEs
    
    figure('Position',[10 10 1400 900])
     hold on
     for bb=1:numel(Bfschoice)
  for iid=1:size(dactabselect,2)
    for iig=1:size(IntensmeanQ9G,2)   
        plot(powerdet,normcps* squeeze(IntensmeanQ9GS(dactabselectindS(iid,iig,bb),iig,:,bb)),['-' symg(bb)],'Color',colortable(iid,:),'Linewidth',1.5) %[ii/size(IntensmeanQ8G,1) (1-ii/size(IntensmeanQ8G,1)) ii/size(IntensmeanQ8G,1)]     
    end
  end
     end
  hold off
  xlabel('Light power [nW/pix] ')
    ylabel('Mean counts # [counts per second]')
    hold off
    set(gca,'FontSize',16) 
   % title(['DAC:'  shaperstr maskstr exposurestr])
    
    leg={};
%     for ii=1:numel(gaintabtab)
%         leg(ii)={ ['Gain:' num2str(gaintabtab(ii)) ' (0x' dec2hex(gaintabtab(ii)) ')']};
%     end
iicc=1;
 for bb=1:numel(Bfschoice)
  for iid=1:size(dactabselect,2)
    for iig=1:size(IntensmeanQ9G,2)    
          leg(iicc)={ ['Bipolar fs (' num2str(BfsRCt(Bfschoice(bb))) 'ns;' 'Gain: ' num2str(gaintabtab(iig)) ' (0x' dec2hex(gaintabtab(iig)) ') ' num2str(iid) 'pe)']};
       iicc=iicc+1;
    end
  end
  end
    legend(leg,'Location','northwest')
    box on
    grid on
    set(gcf,'Color','w')

    title([expstr maskstr exposurestr])
    datenow=datestr(now,'yymmddHHMMSS');
   
   % save(['Light_threshImaDACGAIN' datenow '_masked.mat'])
     saveas(gcf,[datarep 'Shaper_Light_threshImaDACGAIN2' datenow  'bp' num2str(Bfschoice(bb)) '_masked.png'])
    saveas(gcf,[datarep 'Shaper_Light_threshImaDACGAIN2' datenow  'bp' num2str(Bfschoice(bb)) '_masked.fig'])
    set(gca, 'YScale','log', 'XScale','log')
      saveas(gcf,[datarep 'Shaper_Light_threshImaDACGAIN2' datenow  'bp' num2str(Bfschoice(bb)) '_maskedLOGLOG.png'])
    saveas(gcf,[datarep 'Shaper_Light_threshImaDACGAIN2' datenow  'bp' num2str(Bfschoice(bb)) '_maskedLOGLOG.fig'])
        