
thresh=10.
gain=60;
maskmode=1;
maskpix1=[12 2];
maskpix2=[12 2];
if maskmode==0
    masklabel='no mask.';
else
    masklabel=['all-pix-masked-excepted pix#' num2str(maskpix1(1)-1) 'on Q' num2str(maskpix1(2)-1) ' AND pix#' num2str(maskpix2(1)-1) 'on Q' num2str(maskpix2(2)-1)];
end



IP1='192.168.1.10'

quaboSN1='5';%input('Enter quabo SN:','s');
quaboSNstr1=num2str(str2num(quaboSN1),'%03d');
disp(['You decided to use quabo SN' quaboSNstr1])


quaboconfig1=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config.txt']);
disp('Starting HV...')
szq1=size(quaboconfig1,1);
quaboconfig1(szq1+1,1)={'IP'};quaboconfig1(szq1+1,3)={IP1};
szq1=size(quaboconfig1,1);
quaboconfig1(szq1+1,1)={'QuaboSN'};quaboconfig1(szq1+1,3)={str2num(quaboSN1)};


    quaboconfig1 = changemask(maskmode,maskpix1,quaboconfig1); %maskmode: unmask all pix (=0); mask all excepted some (=1)
 


quaboconfig1=changegain(gain, quaboconfig1,0); % third param is using an adjusted gain map (=1) or not (=0)
[ig1,indexgain1]=ismember(['GAIN' num2str(maskpix1(1)-1)] ,quaboconfig1);
realgainpix1tmp=char(quaboconfig1(indexgain1,maskpix1(2)+1))
realgainpix1=hex2dec(realgainpix1tmp(3:4))

quaboconfig1=changepe(thresh,gain,quaboconfig1);

[ig,indexacqmode]=ismember(['ACQMODE '] ,quaboconfig1);
    quaboconfig1(indexacqmode,2)={"0x01"};
   
    
        
        % init the board?
        disp('Init Marocs...')
        sendconfig2Maroc(quaboconfig1)
        disp('Waiting 3s...')
        pause(1)
        disp('Init Acq...')
        sentacqparams2board(quaboconfig1)
        disp('Waiting 3s...')
        pause(1)
         sendHV(quaboconfig1)
         pause(1)

  subtractbaseline(quaboconfig1)
                pause(3)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% Quabo#2
IP2='192.168.1.11'

quaboSN2='8';%input('Enter quabo SN:','s');
quaboSNstr2=num2str(str2num(quaboSN2),'%03d');
disp(['You decided to use quabo SN' quaboSNstr2])


quaboconfig2=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config.txt']);
disp('Starting HV...')
szq2=size(quaboconfig2,1);
quaboconfig2(szq1+1,1)={'IP'};quaboconfig2(szq1+1,3)={IP2};
szq2=size(quaboconfig2,1);
quaboconfig2(szq2+1,1)={'QuaboSN'};quaboconfig2(szq2+1,3)={str2num(quaboSN2)};


    quaboconfig2 = changemask(maskmode,maskpix2,quaboconfig2); %maskmode: unmask all pix (=0); mask all excepted some (=1)
 

%gain=60;
quaboconfig2=changegain(gain, quaboconfig2,0); % third param is using an adjusted gain map (=1) or not (=0)


    [ig2,indexgain2]=ismember(['GAIN' num2str(maskpix2(1)-1)] ,quaboconfig2);
realgainpix2tmp2=char(quaboconfig2(indexgain2,maskpix2(2)+1))
realgainpix2=hex2dec(realgainpix2tmp2(3:4))


quaboconfig2=changepe(thresh,gain,quaboconfig2);

[ig,indexacqmode]=ismember(['ACQMODE '] ,quaboconfig2);
    quaboconfig2(indexacqmode,2)={"0x01"};
   
    
        
        % init the board?
        disp('Init Marocs...')
        sendconfig2Maroc(quaboconfig2)
        disp('Waiting 3s...')
        pause(1)
        disp('Init Acq...')
        sentacqparams2board(quaboconfig2)
        disp('Waiting 3s...')
        pause(1)
         sendHV(quaboconfig2)
         pause(1)

  subtractbaseline(quaboconfig2)
                pause(3)

