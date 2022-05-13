
IP='192.168.1.10'

quaboSN='9';%input('Enter quabo SN:','s');
quaboSNstr=num2str(str2num(quaboSN),'%03d');
disp(['You decided to use quabo SN' quaboSNstr])


quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config.txt']);
disp('Starting HV...')
szq=size(quaboconfig,1);
quaboconfig(szq+1,1)={'IP'};quaboconfig(szq+1,3)={IP};
szq=size(quaboconfig,1);
quaboconfig(szq+1,1)={'QuaboSN'};quaboconfig(szq+1,3)={str2num(quaboSN)};

maskmode=1;
maskpix1=[63, 4];
%maskpix2=[12 2];
marocmap(maskpix1(1),maskpix1(2),:)
    quaboconfig = changemask(maskmode,maskpix1,quaboconfig); %maskmode: unmask all pix (=0); mask all excepted some (=1)
 
if maskmode==0
    masklabel='no mask.';
else
    masklabel=['all-pix-masked-excepted pix#' num2str(maskpix1(1)-1) 'on Q' num2str(maskpix1(2)-1)]; % ' AND pix#' num2str(maskpix2(1)-1) 'on Q' num2str(maskpix2(2)-1)
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


