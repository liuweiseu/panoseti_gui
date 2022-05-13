tic

figini;
close all
load('MarocMap.mat');
nim=100;
peval=2.5;
IP='192.168.3.248';
makereport=0;

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

gaintaballg=[60];
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
    
   % while loopgain==1
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
        
     %   allima2=allima(:,:,:,1);
        %%fitting cps curves
        %remove left part
        