function [dacQ0ref dacQ1ref dacQ2ref dacQ3ref]= findDACref(cpsref,IP)

%IP='192.168.3.248'
%IP='192.168.3.252'
%IP='192.168.0.0'
load('MarocMap.mat');
%quaboSN='13';%input('Enter quabo SN:','s');
%quaboSNstr=num2str(str2num(quaboSN),'%03d');
%disp(['You decided to use quabo SN' quaboSNstr])

boardnum=findboardnum(IP);

quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config.txt']);
disp('Starting HV...')
szq=size(quaboconfig,1);
quaboconfig(szq+1,1)={'IP'};quaboconfig(szq+1,3)={IP};
%szq=size(quaboconfig,1);
%quaboconfig(szq+1,1)={'QuaboSN'};quaboconfig(szq+1,3)={str2num(quaboSN)};

maskmode=0;
% maskpix1=[63, 4];
% %maskpix2=[12 2];
% marocmap(maskpix1(1),maskpix1(2),:)
maskpix1=marocmap16(7,9,:);

quaboconfig = changemask(maskmode,maskpix1,quaboconfig); %maskmode: unmask all pix (=0); mask all excepted some (=1)
 [ia,indexdac]=ismember('DAC1',quaboconfig);
if maskmode==0
    masklabel='no mask.';
else
    masklabel=['all-pix-masked-excepted pix#' num2str(maskpix1(1)-1) 'on Q' num2str(maskpix1(2)-1)]; % ' AND pix#' num2str(maskpix2(1)-1) 'on Q' num2str(maskpix2(2)-1)
end


gain=60;
quaboconfig=changegain(gain, quaboconfig,0); % third param is using an adjusted gain map (=1) or not (=0)


gaintab=60
dactabmax=round(190+0.325*gaintab*4)
dactab=[180:1:dactabmax ];

IntensmeanQ0=[];IntensmeanQ1=[];IntensmeanQ2=[];IntensmeanQ3=[];IntensmeanQ8=[];IntensmeanQ9=[];
%allima=zeros(16,16,numel(dactab),numel(indcol));

for qq=1:1
    indcol=qq;
    if qq == 1
        xc=9;yc=8;
        maskpix1=marocmap16(xc,yc,:);
    elseif qq == 2
        xc=7;yc=8;
        maskpix1=marocmap16(xc,yc,:);
    elseif qq == 3
        xc=7;yc=9;
        maskpix1=marocmap16(xc,yc,:);
    elseif qq == 4
        xc=9;yc=9;
        maskpix1=marocmap16(xc,yc,:);
    end
    
    
    quaboconfig = changemask(maskmode,maskpix1,quaboconfig); %maskmode: unmask all pix (=0); mask all excepted some (=1)
    pausetime=1;nim=100;
    for dd=1:numel(dactab)
        indcol=1:4;
        quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactab(dd))]};
        disp(['Sending Maroc comm...DAC1:' num2str(dactab(dd)) '/' num2str(dactab(end)) ' Gain' num2str(gaintab)   ])
        sendconfig2Maroc(quaboconfig)
        
        %timepause=10;
        %disp(['Q' num2str(indcol2) '  ' num2str( timepause*(numel(dactab)-dd)) 's left...'])
        pause(pausetime)
        %pause(pausetime)
        images=grabimagesG(nim,1,1,boardnum);
        
        meanimage=mean(images(:,:,:),[3])';
       % allima(:,:,dd,indcol2)=meanimage;
        figure
        imagesc(meanimage)
        colorbar
        axis image
        pause(0.5)
        close
        timenow=now;
        %             import matlab.io.*
        %             utcshift=7/24;
        %             filename = ['b_d0w0m0q0_' datestr(timenow+utcshift,'yyyymmdd_HHMMSS_FFF') ];
        %             fullfilename=[ getuserdir '\panoseti\DATA\' filename];
        %             fptr = fits.createFile([fullfilename '.fits']);
        %
        %             fits.createImg(fptr,'int32',[16 16]);
        %             %fitsmode='overwrite';
        %             img=int32(meanimage);
        %             fits.writeImg(fptr,img)
        %             fits.closeFile(fptr);
        %close
       %  IntensmaxQ1(nima)=max(ima(9:16,1:8),[],'all');
                IntensmeanQ0=[IntensmeanQ0 mean(meanimage(9:16,1:8),[1 2])];
                % IntensmaxQ2(nima)=max(ima(1:8,1:8),[],'all');
                IntensmeanQ1=[IntensmeanQ1 mean(meanimage(1:8,1:8),[1 2])];
                %   IntensmaxQ3(nima)=max(ima(1:8,9:16),[],'all');
                IntensmeanQ2=[IntensmeanQ2 mean(meanimage(1:8,9:16),[1 2])];
                %   IntensmaxQ4(nima)=max(ima(9:16,9:16),[],'all');
                IntensmeanQ3=[IntensmeanQ3 mean(meanimage(9:16,9:16),[1 2])];
     %     IntensmaxQ4(nima)=max(ima(9:16,9:16),[],'all');
    %    IntensmeanQ8=[IntensmeanQ8 (meanimage(xc,yc))];
        
    end
  %  find(abs(IntensmeanQ0))
  %cpsref=1e2;
  %find the right decreasing part of the cps
 [maxv, maxi ]= max(IntensmeanQ0);
 IntensmeanQ0R=IntensmeanQ0(maxi:end);
[minval, inddaccpsref]=min(abs(IntensmeanQ0R-cpsref));
 dacQ0ref=dactab(maxi+inddaccpsref-1);
 
 [maxv, maxi ]= max(IntensmeanQ1);
 IntensmeanQ1R=IntensmeanQ1(maxi:end);
[minval, inddaccpsref]=min(abs(IntensmeanQ1R-cpsref));
 dacQ1ref=dactab(maxi+inddaccpsref-1);
 
 [maxv, maxi ]= max(IntensmeanQ2);
 IntensmeanQ2R=IntensmeanQ2(maxi:end);
[minval, inddaccpsref]=min(abs(IntensmeanQ2R-cpsref));
 dacQ2ref=dactab(maxi+inddaccpsref-1);
 
 [maxv, maxi ]= max(IntensmeanQ3);
 IntensmeanQ3R=IntensmeanQ3(maxi:end);
[minval, inddaccpsref]=min(abs(IntensmeanQ3R-cpsref));
 dacQ3ref=dactab(maxi+inddaccpsref-1);
 
  quaboconfig(indexdac,1+1)={['0x' dec2hex(dacQ0ref)]};
  quaboconfig(indexdac,2+1)={['0x' dec2hex(dacQ1ref)]};
  quaboconfig(indexdac,3+1)={['0x' dec2hex(dacQ2ref)]};
  quaboconfig(indexdac,4+1)={['0x' dec2hex(dacQ3ref)]};
        disp(['Sending final calib Maroc comm...'  ])
        sendconfig2Maroc(quaboconfig)
        
        disp(['DACrefQ0:' num2str(dacQ0ref) 'DACrefQ1:' num2str(dacQ1ref) ...
            'DACrefQ2:' num2str(dacQ2ref) 'DACrefQ3:' num2str(dacQ3ref) ...
            ])
   figure;hold on; plot(dactab,IntensmeanQ0);plot(dactab,IntensmeanQ1);plot(dactab,IntensmeanQ2);plot(dactab,IntensmeanQ3);set(gca,'YScale','log')     
 title(IP)
end