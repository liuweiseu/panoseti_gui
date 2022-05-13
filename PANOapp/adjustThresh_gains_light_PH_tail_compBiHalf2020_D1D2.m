close all
datarep=[getuserdir '\panoseti\DATA\testshapers\']

exposurestr='';
  dactab=[200:1:234]; %242 ];
  dactab1=dactab;
gaintabtab=[66];%11:31 %1:10:121;
%currtabExp=[0. round(logspace(0,log10(4000),10))];
%currtabExp=[0. 2.^(5:2:11)];
currtabExp=[0. ];

    expstr='';
    shaperstr='Bipolar fs; ';
    maskstr='All-pixels-masked-excepted-one [7,1]; ';
IntensmeanQ9G1=zeros(numel(dactab),numel(gaintabtab),numel(currtabExp));


  realhvQ0=[];realhvQ1=[];realhvQ2=[];realhvQ3=[];
realcurQ0=[];realcurQ1=[];realcurQ2=[];realcurQ3=[];
temp1=[];temp2=[]; 
timecomp=[];
  datenow=datestr(now,'yymmddHHMMSS');

  gainkk=1;
  cc=1;
%for cc=1:numel(currtabExp)
   
  %  quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config.txt']);
 % [ia,indexdac]=ismember('DAC1',quaboconfig);
  quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config_PHdual.txt']);
 [ia,indexdac]=ismember('DAC2',quaboconfig);

   szq=size(quaboconfig,1);
quaboconfig(szq+1,1)={'IP'};quaboconfig(szq+1,3)={IP};
szq=size(quaboconfig,1);
quaboconfig(szq+1,1)={'QuaboSN'};quaboconfig(szq+1,3)={str2num(quaboSN)};
 
    
    
    pausetime=0.5;
    indcol=1:4;
    
    [ig,indexacqmode]=ismember(['ACQMODE '] ,quaboconfig);
    quaboconfig(indexacqmode,2)={"0x01"};
   
    
   % [ig,indexacqint]=ismember(['ACQINT '] ,quaboconfig);
   % acqint=(1e-5)*str2num(quaboconfig(indexacqint,2));
   % exposurestr=['Exposure time [ms]:' num2str(1000*acqint,'%3.3g')];
    normcps=1; %/acqint;
    %set gain
    IntensmeanQ8G=[];
    
 %   for  gainkk=1:numel(gaintabtab)
        gaintab=gaintabtab(1);
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
      %  figure
       
        
        %put high thresh on all 4 quads
        % dactabH0=500;
        %  quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactabH0)]};
        %  pause(pausetime)
        
        IntensmeanQ0=[];IntensmeanQ1=[];IntensmeanQ2=[];IntensmeanQ3=[];IntensmeanQ8=[];IntensmeanQ9=[];
        allima=zeros(16,16,numel(dactab),numel(indcol));
        indcol2=1;
        for dd=1:numel(dactab)
            quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactab(dd))]};
            disp(['Sending Maroc comm...DAC1:' num2str(dactab(dd)) ' Gain:' num2str((gaintabtab(1)))])
            sendconfig2Maroc(quaboconfig)
            
            %timepause=10;
            %disp(['Q' num2str(indcol2) '  ' num2str( timepause*(numel(dactab)-dd)) 's left...'])
            pause(pausetime)
            %pause(pausetime)
        disp(['Timeout[ms]:' num2str(timeout)])
%            else
               timeout=2000;
%           end
           pac1=[];
           while numel(pac1)==0
           [pac1 ti1]=measframeratec(timeout);
           end
           pacdiff=0;
           statnbpts=100;
           while pacdiff<statnbpts
            disp('Waiting for a new event at this threshold...')
            if timeout<3000
                disp(['pausing ' num2str(2+timeout/1000) 's'])
                pause(2+timeout/1000)
            end
            
            [pac2 ti2]=measframeratec(timeout);
            if (numel(pac1)==1) && (numel(pac2)==1)
                pacdiff=double(pac2)-double(pac1);
            elseif (numel(pac1)==0) || (numel(pac2)==0)
                pacdiff=0;
            end
            if pacdiff<0
                pacdiff=2^16-double(pac1)+double(pac2)
            end
           end
            timediff=3600*24*(ti2-ti1);
            if numel(timediff)>0
            IntensmeanQ9G1(dd,gainkk,cc)= double(pacdiff) / timediff;
            disp(['Nb cnts/s:' num2str(IntensmeanQ9G1(dd,gainkk,cc))])
            end
             
    save([datarep 'variablesExp' num2str(cc) '_dac' num2str(dd) '_' datenow '.mat'])
        end
        IntensmeanQ8G=[IntensmeanQ8G; IntensmeanQ8];

        
       %%%%%%%%%%%%%%%%%%%%%%
       
      % second pass
       
       %%%%%%%%%%%%%%%%%%%%%%%%
         dactab=[180:1:207]; %242 ];
         IntensmeanQ9G2=zeros(numel(dactab),numel(gaintabtab),numel(currtabExp));
          dactab2=dactab;
gaintabtab2=0.5*gaintabtab;%11:31 %1:10:121;
%currtabExp=[0. round(logspace(0,log10(4000),10))];
%currtabExp=[0. 2.^(5:2:11)];
currtabExp=[0. ];

    expstr='';
    shaperstr='Bipolar fs; ';
    maskstr='All-pixels-masked-excepted-one [7,1]; ';
%IntensmeanQ9G=zeros(numel(dactab),numel(gaintabtab),numel(currtabExp));

  realhvQ0=[];realhvQ1=[];realhvQ2=[];realhvQ3=[];
realcurQ0=[];realcurQ1=[];realcurQ2=[];realcurQ3=[];
temp1=[];temp2=[]; 
timecomp=[];
  datenow=datestr(now,'yymmddHHMMSS');

  gainkk=1;
  cc=1;
%for cc=1:numel(currtabExp)
   
  %  quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config.txt']);
 % [ia,indexdac]=ismember('DAC1',quaboconfig);
  quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config_PHdual.txt']);
 [ia,indexdac]=ismember('DAC2',quaboconfig);

   szq=size(quaboconfig,1);
quaboconfig(szq+1,1)={'IP'};quaboconfig(szq+1,3)={IP};
szq=size(quaboconfig,1);
quaboconfig(szq+1,1)={'QuaboSN'};quaboconfig(szq+1,3)={str2num(quaboSN)};
 
    
    
    pausetime=0.5;
    indcol=1:4;
    
    [ig,indexacqmode]=ismember(['ACQMODE '] ,quaboconfig);
    quaboconfig(indexacqmode,2)={"0x01"};
   
    
   % [ig,indexacqint]=ismember(['ACQINT '] ,quaboconfig);
   % acqint=(1e-5)*str2num(quaboconfig(indexacqint,2));
   % exposurestr=['Exposure time [ms]:' num2str(1000*acqint,'%3.3g')];
    normcps=1; %/acqint;
    %set gain
    IntensmeanQ8G=[];
    
 %   for  gainkk=1:numel(gaintabtab)
        gaintab=gaintabtab2(1);
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
      %  figure
       
        
        %put high thresh on all 4 quads
        % dactabH0=500;
        %  quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactabH0)]};
        %  pause(pausetime)
        
        IntensmeanQ0=[];IntensmeanQ1=[];IntensmeanQ2=[];IntensmeanQ3=[];IntensmeanQ8=[];IntensmeanQ9=[];
        allima=zeros(16,16,numel(dactab),numel(indcol));
        indcol2=1;
        for dd=1:numel(dactab)
            quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactab(dd))]};
            disp(['Sending Maroc comm...DAC1:' num2str(dactab(dd)) ' Gain:' num2str((gaintabtab2(1)))])
            sendconfig2Maroc(quaboconfig)
            
            %timepause=10;
            %disp(['Q' num2str(indcol2) '  ' num2str( timepause*(numel(dactab)-dd)) 's left...'])
            pause(pausetime)
            %pause(pausetime)
        disp(['Timeout[ms]:' num2str(timeout)])
%            else
               timeout=2000;
%           end
           pac1=[];
           while numel(pac1)==0
           [pac1 ti1]=measframeratec(timeout);
           end
           pacdiff=0;
           statnbpts=100;
           while pacdiff<statnbpts
            disp('Waiting for a new event at this threshold...')
            if timeout<3000
                disp(['pausing ' num2str(2+timeout/1000) 's'])
                pause(2+timeout/1000)
            end
            
            [pac2 ti2]=measframeratec(timeout);
            if (numel(pac1)==1) && (numel(pac2)==1)
                pacdiff=double(pac2)-double(pac1);
            elseif (numel(pac1)==0) || (numel(pac2)==0)
                pacdiff=0;
            end
            if pacdiff<0
                pacdiff=2^16-double(pac1)+double(pac2)
            end
           end
            timediff=3600*24*(ti2-ti1);
            if numel(timediff)>0
            IntensmeanQ9G2(dd,gainkk,cc)= double(pacdiff) / timediff;
            disp(['Nb cnts/s:' num2str(IntensmeanQ9G2(dd,gainkk,cc))])
            end
             
    save([datarep 'variablesExp' num2str(cc) '_dac' num2str(dd) '_' datenow '.mat'])
        end
        IntensmeanQ8G=[IntensmeanQ8G; IntensmeanQ8];

      
     %%%%%%%%%%%%%%%%%%%%%%
       
      % third pass
       
       %%%%%%%%%%%%%%%%%%%%%%%%
         dactab=[200:1:234]; %242 ];
         dactab3=dactab;
         IntensmeanQ9G3=zeros(numel(dactab),numel(gaintabtab),numel(currtabExp));

gaintabtab3=gaintabtab2;%11:31 %1:10:121;
%currtabExp=[0. round(logspace(0,log10(4000),10))];
%currtabExp=[0. 2.^(5:2:11)];
currtabExp=[0. ];

    expstr='';
    shaperstr='Bipolar fs; ';
    maskstr='All-pixels-masked-excepted-one [7,1]; ';
%IntensmeanQ9G=zeros(numel(dactab),numel(gaintabtab),numel(currtabExp));

  realhvQ0=[];realhvQ1=[];realhvQ2=[];realhvQ3=[];
realcurQ0=[];realcurQ1=[];realcurQ2=[];realcurQ3=[];
temp1=[];temp2=[]; 
timecomp=[];
  datenow=datestr(now,'yymmddHHMMSS');

  gainkk=1;
  cc=1;
%for cc=1:numel(currtabExp)
   
    quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config.txt']);
  [ia,indexdac]=ismember('DAC1',quaboconfig);
%  quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config_PHdual.txt']);
% [ia,indexdac]=ismember('DAC2',quaboconfig);

   szq=size(quaboconfig,1);
quaboconfig(szq+1,1)={'IP'};quaboconfig(szq+1,3)={IP};
szq=size(quaboconfig,1);
quaboconfig(szq+1,1)={'QuaboSN'};quaboconfig(szq+1,3)={str2num(quaboSN)};
 
    
    
    pausetime=0.5;
    indcol=1:4;
    
    [ig,indexacqmode]=ismember(['ACQMODE '] ,quaboconfig);
    quaboconfig(indexacqmode,2)={"0x01"};
   
    
   % [ig,indexacqint]=ismember(['ACQINT '] ,quaboconfig);
   % acqint=(1e-5)*str2num(quaboconfig(indexacqint,2));
   % exposurestr=['Exposure time [ms]:' num2str(1000*acqint,'%3.3g')];
    normcps=1; %/acqint;
    %set gain
    IntensmeanQ8G=[];
    
 %   for  gainkk=1:numel(gaintabtab)
        gaintab=gaintabtab3(1);
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
      %  figure
       
        
        %put high thresh on all 4 quads
        % dactabH0=500;
        %  quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactabH0)]};
        %  pause(pausetime)
        
        IntensmeanQ0=[];IntensmeanQ1=[];IntensmeanQ2=[];IntensmeanQ3=[];IntensmeanQ8=[];IntensmeanQ9=[];
        allima=zeros(16,16,numel(dactab),numel(indcol));
        indcol2=1;
        for dd=1:numel(dactab)
            quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactab(dd))]};
            disp(['Sending Maroc comm...DAC1:' num2str(dactab(dd)) ' Gain:' num2str((gaintabtab3(1)))])
            sendconfig2Maroc(quaboconfig)
            
            %timepause=10;
            %disp(['Q' num2str(indcol2) '  ' num2str( timepause*(numel(dactab)-dd)) 's left...'])
            pause(pausetime)
            %pause(pausetime)
        disp(['Timeout[ms]:' num2str(timeout)])
%            else
               timeout=2000;
%           end
           pac1=[];
           while numel(pac1)==0
           [pac1 ti1]=measframeratec(timeout);
           end
           pacdiff=0;
           statnbpts=100;
           while pacdiff<statnbpts
            disp('Waiting for a new event at this threshold...')
            if timeout<3000
                disp(['pausing ' num2str(2+timeout/1000) 's'])
                pause(2+timeout/1000)
            end
            
            [pac2 ti2]=measframeratec(timeout);
            if (numel(pac1)==1) && (numel(pac2)==1)
                pacdiff=double(pac2)-double(pac1);
            elseif (numel(pac1)==0) || (numel(pac2)==0)
                pacdiff=0;
            end
            if pacdiff<0
                pacdiff=2^16-double(pac1)+double(pac2)
            end
           end
            timediff=3600*24*(ti2-ti1);
            if numel(timediff)>0
            IntensmeanQ9G3(dd,gainkk,cc)= double(pacdiff) / timediff;
            disp(['Nb cnts/s:' num2str(IntensmeanQ9G3(dd,gainkk,cc))])
            end
             
    save([datarep 'variablesExp' num2str(cc) '_dac' num2str(dd) '_' datenow '.mat'])
        end
        IntensmeanQ8G=[IntensmeanQ8G; IntensmeanQ8];

            
        
   %%%%%%%%%%%%%%%%%%%%%%%
   
   %% fig
   
   %%%%%%%%%%%%%%%%%%%%%%
    figure
    
    %for ii=1:size(IntensmeanQ8G,1)
        hold on
           plot(dactab1, normcps*IntensmeanQ9G1(:,1,1),['b-+'],'Linewidth',1.5) %[ii/size(IntensmeanQ8G,1) (1-ii/size(IntensmeanQ8G,1)) ii/size(IntensmeanQ8G,1)]     
 plot(dactab2, normcps*IntensmeanQ9G2(1:numel(dactab2),1,1),['r-+'],'Linewidth',1.5) %[ii/size(IntensmeanQ8G,1) (1-ii/size(IntensmeanQ8G,1)) ii/size(IntensmeanQ8G,1)]     
 plot(dactab3, normcps*IntensmeanQ9G3(:,1,1),['g-+'],'Linewidth',1.5) %[ii/size(IntensmeanQ8G,1) (1-ii/size(IntensmeanQ8G,1)) ii/size(IntensmeanQ8G,1)]     
  
       % plot(dactab,normcps* IntensmeanQ8G(ii,:),'-+','Color',rand(1,3),'Linewidth',1.5) %[ii/size(IntensmeanQ8G,1) (1-ii/size(IntensmeanQ8G,1)) ii/size(IntensmeanQ8G,1)]
        hold off
   % end
    
    xlabel('Threshold DAC1 (bipol) or DAC2(half-bipol) ')
    ylabel(' [# triggers per second]')
    hold off
    set(gca, 'YScale','log')
    
%     leg={};
%     for ii=1:numel(gaintabtab)
%         leg(ii)={ ['Gain: ' num2str(gaintabtab(ii)) ' (0x' dec2hex(gaintabtab(ii)) ')']};
%     end

    legend(['Gain:' num2str(gaintabtab(1)) ', Half-bipolar'],...
        ['Gain:' num2str(gaintabtab2(1)) ', Half-bipolar'],...
        ['Gain:' num2str(gaintabtab3(1)) ', Bipolar'])
    box on
    grid on
    set(gcf,'Color','w')
    title([expstr shaperstr maskstr ])
    datenow=datestr(now,'yymmddHHMMSS');
    saveas(gcf,['threshImaDACGAIN' datenow '_masked.png'])
    saveas(gcf,['threshImaDACGAIN' datenow '_masked.fig'])
    save(['threshImaDACGAIN' datenow '_masked.mat'])
    
    