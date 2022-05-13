
IP='192.168.1.11'
 load('MarocMap.mat');
quaboSN='8';%input('Enter quabo SN:','s');
quaboSNstr=num2str(str2num(quaboSN),'%03d');
disp(['You decided to use quabo SN' quaboSNstr])


quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config.txt']);
disp('Starting HV...')
szq=size(quaboconfig,1);
quaboconfig(szq+1,1)={'IP'};quaboconfig(szq+1,3)={IP};
szq=size(quaboconfig,1);
quaboconfig(szq+1,1)={'QuaboSN'};quaboconfig(szq+1,3)={str2num(quaboSN)};

maskmode=1;
maskpix=[10, 2];
%maskpix2=[11 1];
marocmap(maskpix(1),maskpix(2),:)
    quaboconfig = changemask(maskmode,maskpix,quaboconfig); %maskmode: unmask all pix (=0); mask all excepted some (=1)
 
if maskmode==0
    masklabel='no mask.';
else
    masklabel=['all-pix-masked-excepted pix#' num2str(maskpix(1)-1) 'on Q' num2str(maskpix(2)-1) ];%' AND pix#' num2str(maskpix2(1)-1) 'on Q' num2str(maskpix2(2)-1)
end




 
gain=60;
quaboconfig=changegain(gain, quaboconfig,1); % third param is using an adjusted gain map (=1) or not (=0)
quaboconfig=changepe(20.,gain,quaboconfig);

[ig,indexacqmode]=ismember(['ACQMODE '] ,quaboconfig);
    quaboconfig(indexacqmode,2)={"0x01"};
   
    
        
        % init the board?
        disp('Init Marocs...')
        sendconfig2Maroc(quaboconfig)
        disp('Waiting 3s...')
        pause(1)
        disp('Init Acq...')
        sentacqparams2board(quaboconfig)
        disp('Waiting 3s...')
        pause(1)
         sendHV(quaboconfig)
         pause(1)

  subtractbaseline(quaboconfig)
                pause(3)


