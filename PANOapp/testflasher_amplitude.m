%%start the boards first using "startmodules"
%%careful to not start flasher without fiber on 0.4/Sagan/West
clear all
close all
flashrate=1;
freq=flashrate*95.3;%52;%Hz
flashlevel0=15; %ADC starts to saturate at 15-20V


IPtab=["192.168.0.4","192.168.0.5","192.168.0.6","192.168.0.7",...
    "192.168.3.248","192.168.3.249","192.168.3.250","192.168.3.251" ]

%  IPtab=["192.168.0.4","192.168.0.5","192.168.0.6","192.168.0.7" ]

% IPtab=["192.168.0.4",...
%    "192.168.3.248" ]
% IPtab=["192.168.3.248" ]

%IPtab=[ "192.168.3.248","192.168.3.249","192.168.3.250","192.168.3.251" ]

%IP='192.168.0.4';
levtab=21:2:31%7:18
  
   lev=[5 7  10    15 20 25 30   31]
   nw=[0 1.2 9.2 24.5 40 55 69.2 72]
  h=6.63e-34;
c=3.e8;
lam=0.57e-6;
en1phot=h*c/lam
qe=1.
   rate=7
   freq0=(2^(rate-1))*95
   pow=0.1e-9  %W % in front of det (moy splitters) lev=31 rate=7
   ratiosurface =  (0.28^2)/ (pi*(0.95/2)^2);
   powpulsepix=pow*ratiosurface/freq0
   photpulsepix=powpulsepix*qe/en1phot
   usedlev=10;
   photpulsepixlev=photpulsepix*(3*usedlev -20.7)/72.3
   photpulsepixlevtab=(photpulsepix/72.3)*(3*levtab -20.7)
   


ADClevh1=zeros(1,numel(levtab));
ADClevh2=zeros(1,numel(levtab));
ADClevm1=zeros(1,numel(levtab));
ADClevm2=zeros(1,numel(levtab));
for ilev=1:numel(levtab)
    flashlev=levtab(ilev)
    
    
    
    gain=60;
    indcol=1;
    for IPn=1:size(IPtab,2)
        IP=IPtab(IPn);
        
        quaboSN=num2str(IP2SN(IP));%input('Enter quabo SN:','s');
        quaboSNstr=num2str(str2num(quaboSN),'%03d');
        
        quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config.txt']);
        szq=size(quaboconfig,1);
        quaboconfig(szq+1,1)={'IP'};quaboconfig(szq+1,3)={IP};
        szq=size(quaboconfig,1);
        quaboconfig(szq+1,1)={'QuaboSN'};quaboconfig(szq+1,3)={str2num(quaboSN)};
        
        
        maskmode=1;
        % maskpix1=[63, 4];
        % %maskpix2=[12 2];
        % marocmap(maskpix1(1),maskpix1(2),:)
        load('MarocMap.mat');
        maskpix1=marocmap16(7,9,:);
        
        quaboconfig = changemask(maskmode,maskpix1,quaboconfig); %maskmode: unmask all pix (=0); mask all excepted some (=1)
        
        
        [ig,indexflashrate]=ismember(['FLASH_RATE '] ,quaboconfig); %0 to 7, 0 = 1PPS, 1 = 76Hz, 2 = 152Hz, etc
        [ig,indexflashlevel]=ismember(['FLASH_LEVEL '] ,quaboconfig); % *0 to 31, 0 to 10v
        
        
        
        quaboconfig(indexflashrate,indcol+1)={[flashrate]};
        if IPn <5
            flashlevel=0;
        else
            flashlevel=flashlev;
        end
        quaboconfig(indexflashlevel,indcol+1)={[flashlevel]};
        
        
        [ig,indexacqmode]=ismember(['ACQMODE '] ,quaboconfig);
        quaboconfig(indexacqmode,2)={"0x01"};
        
        % quaboconfig=changepe(30.,gain,quaboconfig);
        
        % init the board?
        disp('Init Marocs...')
        sendconfig2Maroc(quaboconfig)
        disp('Waiting 3s...')
        pause(1)
        disp('Init Acq...')
        sentacqparams2board(quaboconfig)
        
        quaboconfig=changepe(30.,gain,quaboconfig);
        sendconfig2Maroc(quaboconfig)
    end
    
    
    
    
    
    
    %disp(['You decided to use quabo SN' quaboSNstr])
    
    %%make a loop to change pe sensitivity
    petab=[10. 20. 25. 30. 33. 36. 40. 50. 60.];
    for ipe=1:1%numel(petab)
        
        for IPn=1:size(IPtab,2)
            IP=IPtab(IPn);
            
            quaboSN=num2str(IP2SN(IP));%input('Enter quabo SN:','s');
            quaboSNstr=num2str(str2num(quaboSN),'%03d');
            
            quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config.txt']);
            szq=size(quaboconfig,1);
            quaboconfig(szq+1,1)={'IP'};quaboconfig(szq+1,3)={IP};
            szq=size(quaboconfig,1);
            quaboconfig(szq+1,1)={'QuaboSN'};quaboconfig(szq+1,3)={str2num(quaboSN)};
            
            
            [ig,indexflashrate]=ismember(['FLASH_RATE '] ,quaboconfig); %0 to 7, 0 = 1PPS, 1 = 76Hz, 2 = 152Hz, etc
            [ig,indexflashlevel]=ismember(['FLASH_LEVEL '] ,quaboconfig); % *0 to 31, 0 to 10v
            %flashrate=0;
            quaboconfig(indexflashrate,indcol+1)={[flashrate]};
            if IPn <5
                flashlevel=0;
            else
                flashlevel=31;
            end
            quaboconfig(indexflashlevel,indcol+1)={[flashlevel]};
            
            
            [ig,indexacqmode]=ismember(['ACQMODE '] ,quaboconfig);
            quaboconfig(indexacqmode,2)={"0x01"};
            
            
            
            
            
            quaboconfig=changepe(petab(ipe),gain,quaboconfig);
            sendconfig2Maroc(quaboconfig);
            
        end
        
        
        pause(3)
        %%record data
        nim=100;
        [images nbimafin nanosec timecomp boarloc]=grabimages2key(nim,2,1)   ;
        %%process data
        
        
        format long
        indquabo3248 = find(boarloc==1016);
        % packetno3248=packetno(indquabo3248);
        boarloc3248=boarloc(indquabo3248);
        %   utc3248=utc(indquabo3248);
        nanosec3248=nanosec(indquabo3248);
        timecomp3248=timecomp(indquabo3248);
        
        indquabo3249 = find(boarloc==1017);
        % packetno3249=packetno(indquabo3249);
        boarloc3249=boarloc(indquabo3249);
        %  utc3249=utc(indquabo3249);
        nanosec3249=nanosec(indquabo3249);
        timecomp3249=timecomp(indquabo3249);
        
        indquabo3250 = find(boarloc==1018);
        %  packetno3250=packetno(indquabo3250);
        boarloc3250=boarloc(indquabo3250);
        %  utc3250=utc(indquabo3250);
        nanosec3250=nanosec(indquabo3250);
        timecomp3250=timecomp(indquabo3250);
        
        indquabo3251 = find(boarloc==1019);
        %  packetno3251=packetno(indquabo3251);
        boarloc3251=boarloc(indquabo3251);
        %  utc3251=utc(indquabo3251);
        nanosec3251=nanosec(indquabo3251);
        timecomp3251=timecomp(indquabo3251);
        
        indquabo4 = find(boarloc==4);
        %  packetno4=packetno(indquabo4);
        boarloc4=boarloc(indquabo4);
        %   utc4=utc(indquabo4);
        nanosec4=nanosec(indquabo4);
        timecomp4=timecomp(indquabo4);
        
        indquabo5 = find(boarloc==5);
        %  packetno5=packetno(indquabo5);
        boarloc5=boarloc(indquabo5);
        %  utc5=utc(indquabo5);
        nanosec5=nanosec(indquabo5);
        timecomp5=timecomp(indquabo5);
        
        indquabo6 = find(boarloc==6);
        %  packetno6=packetno(indquabo6);
        boarloc6=boarloc(indquabo6);
        %  utc6=utc(indquabo6);
        nanosec6=nanosec(indquabo6);
        timecomp6=timecomp(indquabo6);
        
        indquabo7 = find(boarloc==7);
        %  packetno7=packetno(indquabo7);
        boarloc7=boarloc(indquabo7);
        %  utc7=utc(indquabo7);
        nanosec7=nanosec(indquabo7);
        timecomp7=timecomp(indquabo7);
        
        %unmaskcoor=marocmap(maskpix1(1),maskpix2(2),:);
        %unmask1=images(unmaskcoor(1),unmaskcoor(2),indquabo1);
        %unmask2=images(unmaskcoor(1),unmaskcoor(2),indquabo2);
        %     nanosec4G=[nanosec4G nanosec4];
        %       nanosec5G=[nanosec5G nanosec5];
        %         nanosec6G=[nanosec6G nanosec6];
        %           nanosec7G=[nanosec7G nanosec7];
        %     nanosec3248G=[nanosec3248G nanosec3248];
        %       nanosec3249G=[nanosec3249G nanosec3249];
        %         nanosec3250G=[nanosec3250G nanosec3250];
        %           nanosec3251G=[nanosec3251G nanosec3251];
        %   find 1hz indices
        % if next timecomp < 1 go next
        t4=3600*24*(timecomp4- timecomp4(1));
        t5=3600*24*(timecomp5- timecomp4(1));
        t6=3600*24*(timecomp6- timecomp4(1));
        t7=3600*24*(timecomp7- timecomp4(1));
        t3248=3600*24*(timecomp3248- timecomp4(1));
        t3249=3600*24*(timecomp3249 - timecomp4(1));
        t3250=3600*24*(timecomp3250- timecomp4(1));
        t3251=3600*24*(timecomp3251- timecomp4(1));
        
        nbcoin=0;expectednbcoins=0;
        nanodiff=[];
        coincidences=[];nanodiff_filtered=[];
        nbf=1;
        
        windowtimecomp=0.6;%s
        coincidencetime=30.;%ns
        nbcoinfile=nbcoin;
        [coincidence4 nbcoin4 nanodiff4] = findcoincidences(...
            windowtimecomp,coincidencetime,t4,nanosec4,...
            t5,nanosec5,t6,nanosec6,t7,nanosec7,...
            t3248,nanosec3248, t3249,nanosec3249, ...
            t3250,nanosec3250, t3251,nanosec3251 ) ;
        
        coincidences=[coincidences; coincidence4];
        nbcoin=nbcoin+nbcoin4;
        nanodiff=[nanodiff nanodiff4];
        
        [coincidence5 nbcoin5 nanodiff5] = findcoincidences(...
            windowtimecomp,coincidencetime,...
            t5,nanosec5,t6,nanosec6,t7,nanosec7,...
            t3248,nanosec3248, t3249,nanosec3249, ...
            t3250,nanosec3250, t3251,nanosec3251,[],[] ) ;
        coincidence5=cat(2, cell(size(coincidence5,1),1), coincidence5(:,1:end-1));
        coincidences=[coincidences; coincidence5];
        nbcoin=nbcoin+nbcoin5;
        nanodiff=[nanodiff nanodiff5];
        
        [coincidence6 nbcoin6 nanodiff6] = findcoincidences(...
            windowtimecomp,coincidencetime,...
            t6,nanosec6,t7,nanosec7,...
            t3248,nanosec3248, t3249,nanosec3249, ...
            t3250,nanosec3250, t3251,nanosec3251,[],[],[],[] ) ;
        coincidence6=cat(2, cell(size(coincidence6,1),2), coincidence6(:,1:end-2));
        coincidences=[coincidences; coincidence6];
        nbcoin=nbcoin+nbcoin6;
        nanodiff=[nanodiff nanodiff6];
        
        [coincidence7 nbcoin7 nanodiff7] = findcoincidences(...
            windowtimecomp,coincidencetime,...
            t7,nanosec7,...
            t3248,nanosec3248, t3249,nanosec3249, ...
            t3250,nanosec3250, t3251,nanosec3251,[],[],[],[],[],[] ) ;
        coincidence7=cat(2, cell(size(coincidence7,1),3), coincidence7(:,1:end-3));
        coincidences=[coincidences; coincidence7];
        nbcoin=nbcoin+nbcoin7;
        nanodiff=[nanodiff nanodiff7];
        
        [coincidence3248 nbcoin3248 nanodiff3248] = findcoincidences(...
            windowtimecomp,coincidencetime,...
            t3248,nanosec3248, t3249,nanosec3249, ...
            t3250,nanosec3250, t3251,nanosec3251,[],[],[],[],[],[],[],[] ) ;
        coincidence3248=cat(2, cell(size(coincidence3248,1),4), coincidence3248(:,1:end-4));
        coincidences=[coincidences; coincidence3248];
        nbcoin=nbcoin+nbcoin3248;
        nanodiff=[nanodiff nanodiff3248];
        
        [coincidence3249 nbcoin3249 nanodiff3249] = findcoincidences(...
            windowtimecomp,coincidencetime,...
            t3249,nanosec3249, ...
            t3250,nanosec3250, t3251,nanosec3251,[],[],[],[],[],[],[],[],[],[] ) ;
        coincidence3249=cat(2, cell(size(coincidence3249,1),5), coincidence3249(:,1:end-5));
        coincidences=[coincidences; coincidence3249];
        nbcoin=nbcoin+nbcoin3249;
        nanodiff=[nanodiff nanodiff3249];
        
        [coincidence3250 nbcoin3250 nanodiff3250] = findcoincidences(...
            windowtimecomp,coincidencetime,...
            t3250,nanosec3250, t3251,nanosec3251,[],[],[],[],[],[],[],[],[],[],[],[] ) ;
        coincidence3250=cat(2, cell(size(coincidence3250,1),6), coincidence3250(:,1:end-6));
        
        coincidences=[coincidences; coincidence3250];
        nbcoin=nbcoin+nbcoin3250;
        nanodiff=[nanodiff nanodiff3250];
        
        
        
        %
        %     figure
        %     histogram(nanodiff)
        %     drawnow
        
        
        durationcomp=max([t4(numel(t4)) t5(numel(t5)) t6(numel(t6)) t7(numel(t7))],[],'all') ...
            -min([t4(1) t5(1) t6(1) t7(1)],[],'all')
        duration=durationcomp;
        maxnanos= max([nanosec4(numel(nanosec4)) nanosec5(numel(nanosec5)) nanosec6(numel(nanosec6)) nanosec7(numel(nanosec7))],[],'all');
        minnanos=  min([nanosec4(1) nanosec5(1) nanosec6(1) nanosec7(1)],[],'all');
        if maxnanos<minnanos
            maxnanos=maxnanos+1e9;
        end
        duration=1e-9*( maxnanos-minnanos)
        expectednbcoins=expectednbcoins+round(duration* freq +1);
        expectednbcoinscomp=expectednbcoins+round(durationcomp* freq +1);
        
        %%%for longer seq:
        % duration=1e-9*(1e9-nanosec4(1)+1e9*(numel(find(nanosec4(1:end-1)-nanosec4(2:end)>1e8))-1)+nanosec4(numel(nanosec4)))
        
        
        %    nan4=nanosec4(cell2mat(coincidences(ind8coins(:),1)))
        %    measfreq4=1/(1e-9*min(nan4(2:end)-nan4(1:end-1)));
        %    disp(['Meas. freq b#4 [Hz]: ' num2str(measfreq4)])
        %      nan5=nanosec5(cell2mat(coincidences(ind8coins(:),2)))
        %       measfreq5=1/(1e-9*min(nan5(2:end)-nan5(1:end-1)));
        %    disp(['Meas. freq b#5 [Hz]: ' num2str(measfreq5)])
        %     nan6=nanosec6(cell2mat(coincidences(ind8coins(:),3)))
        %    measfreq6=1/(1e-9*min(nan6(2:end)-nan6(1:end-1)));
        %    disp(['Meas. freq b#6 [Hz]: ' num2str(measfreq6)])
        %     nan7=nanosec7(cell2mat(coincidences(ind8coins(:),4)))
        %       measfreq7=1/(1e-9*min(nan7(2:end)-nan7(1:end-1)));
        %    disp(['Meas. freq b#7 [Hz]: ' num2str(measfreq7)])
        disp(['Duration[s]: ' num2str(duration) ' Expected nb coins: '  num2str(round(duration* freq +1))])
        disp(['Nb coins board#4 :' num2str(nbcoin4)]);
        disp(['Nb coins board#5 :' num2str(nbcoin5)]);
        disp(['Nb coins board#6 :' num2str(nbcoin6)]);
        disp(['Nb coins board#7 :' num2str(nbcoin7)]);
        disp(['Nb coins board#248 :' num2str(nbcoin3248)]);
        disp(['Nb coins board#249 :' num2str(nbcoin3249)]);
        disp(['Nb coins board#250 :' num2str(nbcoin3250)]);
        disp(['Nb coins total all combi :' num2str(nbcoin-nbcoinfile)]);
        
        
        for board=1:8
            nbcointotboard=(numel(([coincidences{:,board}])));
            disp(['Nb coins with board #' num2str(board) ' :' num2str(nbcointotboard) ])
        end
        
        coinnbboards=zeros(1,size(coincidences,1));
        for cc=1:size(coincidences,1)
            coinnbboards(cc)=(numel(([coincidences{cc,:}])));
        end
        maxnbboardcoin=max(coinnbboards,[],'all')
        disp(['Max Nb boards per coin: ' num2str(maxnbboardcoin) ])
        coins2quabos=numel(find(coinnbboards==2));
        disp(['coins with 2 boards:' num2str(coins2quabos)])
        coins3quabos=numel(find(coinnbboards==3));
        disp(['coins with 3 boards:' num2str(coins3quabos)])
        coins4quabos=numel(find(coinnbboards==4));
        disp(['coins with 4 boards:' num2str(coins4quabos)])
        coins5quabos=numel(find(coinnbboards==5));
        disp(['coins with 5 boards:' num2str(coins5quabos)])
        coins6quabos=numel(find(coinnbboards==6));
        disp(['coins with 6 boards:' num2str(coins6quabos)])
        coins7quabos=numel(find(coinnbboards==7));
        disp(['coins with 7 boards:' num2str(coins7quabos)])
        coins8quabos=numel(find(coinnbboards==8));
        disp(['coins with 8 boards:' num2str(coins8quabos)])
        
        disp(['Expected nb coins: '  num2str(expectednbcoins)])
        
        ind8coins=find(coinnbboards==8);
        if numel(ind8coins)~=0
            coincidencefiltered8quabos=coincidences{ind8coins,:};
            
            
            nan4=nanosec4(cell2mat(coincidences(ind8coins(:),1)));
            measfreq4=1/(1e-9*median(nan4(2:end)-nan4(1:end-1)));
            disp(['Meas. freq b#4 [Hz]: ' num2str(measfreq4)])
            nan5=nanosec5(cell2mat(coincidences(ind8coins(:),2)));
            measfreq5=1/(1e-9*median(nan5(2:end)-nan5(1:end-1)));
            disp(['Meas. freq b#5 [Hz]: ' num2str(measfreq5)])
            nan6=nanosec6(cell2mat(coincidences(ind8coins(:),3)));
            measfreq6=1/(1e-9*median(nan6(2:end)-nan6(1:end-1)));
            disp(['Meas. freq b#6 [Hz]: ' num2str(measfreq6)])
            nan7=nanosec7(cell2mat(coincidences(ind8coins(:),4)));
            measfreq7=1/(1e-9*median(nan7(2:end)-nan7(1:end-1)));
            disp(['Meas. freq b#7 [Hz]: ' num2str(measfreq7)])
            nan248=nanosec3248(cell2mat(coincidences(ind8coins(:),5)));
            measfreq248=1/(1e-9*median(nan248(2:end)-nan248(1:end-1)));
            disp(['Meas. freq b#248 [Hz]: ' num2str(measfreq248)])
            nan249=nanosec3249(cell2mat(coincidences(ind8coins(:),6)));
            measfreq249=1/(1e-9*median(nan249(2:end)-nan249(1:end-1)));
            disp(['Meas. freq b#249 [Hz]: ' num2str(measfreq249)])
            nan250=nanosec3250(cell2mat(coincidences(ind8coins(:),7)));
            measfreq250=1/(1e-9*median(nan250(2:end)-nan250(1:end-1)));
            disp(['Meas. freq b#250 [Hz]: ' num2str(measfreq250)])
            nan251=nanosec3251(cell2mat(coincidences(ind8coins(:),8)));
            measfreq251=1/(1e-9*median(nan251(2:end)-nan251(1:end-1)));
            disp(['Meas. freq b#251 [Hz]: ' num2str(measfreq251)])
            disp(['Duration (based on nano) [s]: ' num2str(duration) ' Expected nb coins: '  num2str(round(duration* freq -1))])
            disp(['Duration (based on comp time)[s]: ' num2str(durationcomp) ' Expected nb coins: '  num2str(round(durationcomp* freq +1))])
            
            
            
            fnanosectab=zeros(numel(ind8coins),8);
            for ff=1:numel(ind8coins)
                fnanosectab(ff,1)=nanosec4(cell2mat(coincidences(ind8coins(ff),1)));
                fnanosectab(ff,2)=nanosec5(cell2mat(coincidences(ind8coins(ff),2)));
                fnanosectab(ff,3)=nanosec6(cell2mat(coincidences(ind8coins(ff),3)));
                fnanosectab(ff,4)=nanosec7(cell2mat(coincidences(ind8coins(ff),4)));
                fnanosectab(ff,5)=nanosec3248(cell2mat(coincidences(ind8coins(ff),5)));
                fnanosectab(ff,6)=nanosec3249(cell2mat(coincidences(ind8coins(ff),6)));
                fnanosectab(ff,7)=nanosec3250(cell2mat(coincidences(ind8coins(ff),7)));
                fnanosectab(ff,8)=nanosec3251(cell2mat(coincidences(ind8coins(ff),8)));
                for col=1:7
                    for colcol=col:8
                        nanodiff_filtered=[nanodiff_filtered ...
                            fnanosectab(ff,col)-fnanosectab(ff,colcol)];
                    end
                end
            end
            
            %%triggered images:
            disptrigima=1;
            if disptrigima==1
                trigima=zeros(32,64,numel(ind8coins));
                
                % nbima=20;%nbim;
                % for im=1:nbima
                %     disp(im)
                %  images(:,:,im)=fitsread([direc '\' file],'image',im);
                % end
                
                %             case 1
                %                     parentUIaxes=app.UIAxes2;
                %                     imadisp=fliplr(shapedima);
                %                 case 2
                %                     parentUIaxes=app.UIAxes3;
                %                     imadisp=flipud(fliplr((shapedima)'));
                %                 case 3
                %                     parentUIaxes=app.UIAxes4;
                %                     imadisp=flipud(shapedima);
                %                 case 4
                %                     parentUIaxes=app.UIAxes5;
                %                     imadisp=shapedima';
                for ff=1:1%numel(ind8coins)
                    trigima(1:16,1:16,ff)=fliplr(images(:,:,indquabo4(cell2mat(coincidences(ind8coins(ff),1)))));
                    trigima(1:16,17:32,ff)=flipud(fliplr((images(:,:,indquabo5(cell2mat(coincidences(ind8coins(ff),2)))))'));
                    trigima(17:32,17:32,ff)=flipud(images(:,:,indquabo6(cell2mat(coincidences(ind8coins(ff),3)))));
                    trigima(17:32,1:16,ff)=images(:,:,indquabo7(cell2mat(coincidences(ind8coins(ff),4))))';
                    trigima(1:16,32+(1:16),ff)=fliplr(images(:,:,indquabo3248(cell2mat(coincidences(ind8coins(ff),5)))));
                    trigima(1:16,32+(17:32),ff)=flipud(fliplr((images(:,:,indquabo3249(cell2mat(coincidences(ind8coins(ff),6)))))'));
                    trigima(17:32,32+(17:32),ff)=flipud(images(:,:,indquabo3250(cell2mat(coincidences(ind8coins(ff),7)))));
                    trigima(17:32,32+(1:16),ff)=images(:,:,indquabo3251(cell2mat(coincidences(ind8coins(ff),8))))';
                end
                figure
                imagesc(trigima(:,:,1))
                colorbar
                axis image
                
                figure
                subplot(2,1,1)
                h1=histogram( trigima(1:32,1:32,1))
                [maxval maxind]=max(h1.Values);
                ADClevh1(ilev)= h1.BinEdges(maxind);
                ADClevm1(ilev)=median( trigima(1:32,1:32,1),'all');
                xlabel('ADC values')
                ylabel('Occurrence')
                title('mobo#1')
                
                subplot(2,1,2)
                h2=histogram( trigima(1:32,33:64,1))
                [maxval maxind]=max(h2.Values);
                ADClevh2(ilev)= h2.BinEdges(maxind);
                ADClevm2(ilev)=median( trigima(1:32,33:64,1), 'all');
                xlabel('ADC values')
                ylabel('Occurrence')
                title('mobo#1')
                
            end
            
            figure('Color','w','Position',[100 100 900 600])
            histogram(nanodiff)
            xlabel('Nanosec time difference [ns]')
            ylabel('Occurrences')
            title(['Lick flasher  ' num2str(freq) 'Hz, ' num2str((10/31)*levtab(ilev))  'V, PH mode, ' num2str(petab(ipe)) 'pe, gains:60'])
            yl=ylim;
            text(-5.8,0.8*yl(2),['Meas. freq q#4 [Hz]: ' num2str(measfreq4)])
            text(-5.8,0.75*yl(2), ['Duration [s]: ' num2str(duration)])
            text(-5.8,0.7*yl(2), ['Expected nb coincidences: '  num2str(round(duration* freq -1))])
            text(-5.8,0.65*yl(2), ['Nb coincidences detected by 8 boards:' num2str(coins8quabos)])
            set(gca,'XLim',[-6 6])
            datenow=datestr(now,'yymmddHHMMSS');
            box on
            saveas(gcf,[getuserdir '\panoseti\DATA\coindiff_' num2str(petab(ipe)) 'pe' '_' datenow '.png'])
            saveas(gcf,[getuserdir '\panoseti\DATA\coindiff_' num2str(petab(ipe)) 'pe' '_' datenow '.fig'])
        end
        wantmore=0;
        if wantmore==1
            figure('Color','w')
            histogram(nanodiff_filtered)
            xlabel('Nanosec time difference [ns]')
            ylabel('Occurrences')
            title('Lick flasher, PH mode, 15pe, gains:60')
            
            
            figure('Color','w')
            histogram(fnanosectab)
            xlabel('Nanosec counter [ns]')
            ylabel('Occurrences')
            title('Lick flasher 1Hz, PH mode, 15pe, gains:60')
            
            
            figure('Color','w')
            hold on
            for cb=1:8
                histogram(fnanosectab(:,cb))
            end
            xlabel('Nanosec counter [ns]')
            ylabel('Occurrences')
            title('Lick flasher 1Hz, PH mode, 15pe, gains:60')
            
            minx=min(fnanosectab,[],'all');
            maxx=max(fnanosectab,[],'all');
            figure('Color','w')
            hold on
            for cb=1:8
                subplot(8,1,cb)
                histogram(fnanosectab(:,cb))
                set(gca,'XLim',[minx maxx])
            end
            xlabel('Nanosec counter [ns]')
            ylabel('Occurrences')
            title('Lick flasher 1Hz, PH mode, 15pe, gains:60')
            
            figure('Color','w')
            hold on
            mar={'b','r','g','m','-ob','-+r','-+g','-+m'};leg={};
            quabotab=[4 5 6 7 248 249 250 251];
            for cb=1:8
                leg=[leg {['Quabo IP: ' num2str(quabotab(cb))]}];
                plot(fnanosectab(:,cb), cell2mat(mar(cb)),'LineWidth',1.6,'MarkerSize',8.)
            end
            xlabel('coincidence event')
            ylabel('Nanosec counter')
            title('Lick flasher 1Hz, PH mode, 15pe, gains:60')
            legend(leg)
        end
    end
    
    
end

figini
figure('Color','w')
hold on
plot(levtab,ADClevh1,'b')
plot(levtab,ADClevm1,'b--')
plot(levtab,ADClevh2,'r')
plot(levtab,ADClevm2,'r--')
hold  off
 xlabel('Flasher level (0-31: 0-10V)')
ylabel('ADC')
           % title('Lick flasher 1Hz, PH mode, 15pe, gains:60')
           legend('mobo#1W (from  max hist.)', 'mobo#1W (ADC median over pix)', ...
              'mobo#2E (from  max hist.)', 'mobo#2E (ADC median over pix)' )
box on 
grid on


 
figini
figure('Color','w','Position',[100 100 900 600])
hold on
plot(levtab,photpulsepixlevtab,'b+-')
hold  off
 xlabel('Flasher LED level (0 to 31: 0 to 10V)')
ylabel('Nb of photons per pulse  per pixel')
            title(['Lick flasher (splitted), ' num2str(freq) 'Hz, PH mode, thresh:' num2str(petab(ipe)) 'pe, gains:60'])
 box on 
grid on
 saveas(gcf,[getuserdir '\panoseti\DATA\Photpulsepix_flasherLev.png'])
 saveas(gcf,[getuserdir '\panoseti\DATA\Photpulsepix_flasherLev.fig'])
    
 
 
 
figini
figure('Color','w','Position',[100 100 900 600])
hold on
plot(photpulsepixlevtab,ADClevh1,'b')
plot(photpulsepixlevtab,ADClevm1,'b--')
plot(photpulsepixlevtab,ADClevh2,'r')
plot(photpulsepixlevtab,ADClevm2,'r--')
hold  off
 xlabel('Nb of photons per pulse  per pixel ')
ylabel('ADC value')
            title(['Lick flasher ' num2str(freq) 'Hz, PH mode, thresh:' num2str(petab(ipe)) 'pe, gains:60'])
           legend('mobo#1W (from  max hist.)', 'mobo#1W (ADC median over pix)', ...
              'mobo#2E (from  max hist.)', 'mobo#2E (ADC median over pix)' )
box on 
grid on
 saveas(gcf,[getuserdir '\panoseti\DATA\coinADC_' num2str(petab(ipe)) 'pe' '_' datenow '.png'])
 saveas(gcf,[getuserdir '\panoseti\DATA\coinADC_' num2str(petab(ipe)) 'pe' '_' datenow '.fig'])