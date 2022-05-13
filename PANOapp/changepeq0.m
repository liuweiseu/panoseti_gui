mode=2
changeacqmode=1
 
modestr=num2str(mode);
if mode==0
    modestr='';
end
%IP='192.168.3.248'
%IP='192.168.3.252'
%IP='192.168.0.0'
% load('MarocMap.mat');
 % boardSN=
quaboSN=num2str(IP2SN(IP));%input('Enter quabo SN:','s');
quaboSNstr=num2str(str2num(quaboSN),'%03d');
%disp(['You decided to use quabo SN' quaboSNstr])

if (mode==3) || (mode==7)
    quaboconfig=importquaboconfig([getuserdir filesep 'panoseti' filesep 'defaultconfig' filesep 'quabo_config_DUAL.txt']);
else
quaboconfig=importquaboconfig([getuserdir filesep 'panoseti' filesep 'defaultconfig' filesep 'quabo_config.txt']);
end
%
%quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config_PHdual.txt']);

%disp('Starting HV...')
szq=size(quaboconfig,1);
quaboconfig(szq+1,1)={'IP'};quaboconfig(szq+1,3)={IP};
szq=size(quaboconfig,1);
quaboconfig(szq+1,1)={'QuaboSN'};quaboconfig(szq+1,3)={str2num(quaboSN)};

% maskmode=0;
% % maskpix1=[63, 4];
% % %maskpix2=[12 2];
% % marocmap(maskpix1(1),maskpix1(2),:)
% maskpix1=marocmap16(7,9,:);
% 
%     quaboconfig = changemask(maskmode,maskpix1,quaboconfig); %maskmode: unmask all pix (=0); mask all excepted some (=1)
%  
% if maskmode==0
%     masklabel='no mask.';
% else
%     masklabel=['all-pix-masked-excepted pix#' num2str(maskpix1(1)-1) 'on Q' num2str(maskpix1(2)-1)]; % ' AND pix#' num2str(maskpix2(1)-1) 'on Q' num2str(maskpix2(2)-1)
% end




 
 gain=60;
 quaboconfig=changegain(gain, quaboconfig,0); % third param is using an adjusted gain map (=1) or not (=0)
% quaboconfig=changepe(30.,gain,quaboconfig);
%quaboconfig=changepedual(30,30.,gain,quaboconfig);

if changeacqmode==1
 [ig,indexacqmode]=ismember(['ACQMODE '] ,quaboconfig);
     quaboconfig(indexacqmode,2)={['0x0' modestr]};
if (mode==3) || (mode==7)
    quaboconfig=changepedual(30.,40.5,gain,quaboconfig);      
 else
     quaboconfig=changepe(30.,gain,quaboconfig); 
 end
  sentacqparams2board(quaboconfig)  
  end
    % init the board?
%         disp('Init Marocs...')
%         sendconfig2Maroc(quaboconfig)
%         disp('Waiting 3s...')
%         pause(1)
%         disp('Init Acq...')
%         sentacqparams2board(quaboconfig)
%         disp('Waiting 3s...')
%         pause(1)
%          sendHV(quaboconfig)
%          pause(1)

% subtractbaseline(quaboconfig)
         %       pause(3)
       %  gain=40.;
        if (mode==3) || (mode==7)
quaboconfig=changepedual(4.5,13.5,gain,quaboconfig);
        else
quaboconfig=changepe(4.5,gain,quaboconfig);
        end

%sendconfigCHANMASK(quaboconfig)

%  sendconfig2Maroc(quaboconfig)
%subtractbaseline(quaboconfig)  
