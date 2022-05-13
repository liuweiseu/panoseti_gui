clear all
close all
format long
%figini
tickns=1.; %ns
freq=152;%Hz
%direc='/Users/jeromemaire/Documents/SETI/PANOSETI/detectors/coincid/';
%files = dir([direc 'p_d0w0m0q0_20190215_020025_57385' '*.fits']);
%files = dir([direc 'p_d0w0m0q0_20190215_184639_60566' '*.fits']);

%(init dataset) 1Hz only:
%files = dir([direc 'p_d0w0m0q0_20190217_011115_36685' '*.fits']);
%1Hz only:
%direc='C:\Users\jerome\Documents\panoseti\DATA\1Hzonly\';
%files = dir([direc 'p_d0w0m0q0_20190219_210419_151' '*.fits']);
%1Hz low thresh:
datenow=datestr(now,'yymmddHHMMSS');
% datenow='191125114516';
% newd=  [getuserdir '\panoseti\DATA\testpulser\' datenow '\']
% mkdir(newd)
direc=[getuserdir '\panoseti\DATA\testpulser5\'];
% maskpix1=[11 2];
% maskpix2=[11 2];
%
% maskmode=1
% if maskmode==0
%     masklabel='no mask.';
% else
%     masklabel=['all-pix-masked-excepted pix#' num2str(maskpix1(1)-1) 'on Q' num2str(maskpix1(2)-1) ' AND pix#' num2str(maskpix2(1)-1) 'on Q' num2str(maskpix2(2)-1)];
% end
 load('MarocMap.mat');
files = dir([direc 'p_d0w0m0q0_202003' '*.fits']);

nbfiles=numel(files);
 nbcoin=0;expectednbcoins=0;
 nanodiff=[];
 coincidences=[];nanodiff_filtered=[];
for nbf=1:1%numel(files)
    
    file = files(nbf).name;
   
    info = fitsinfo([direc file]);
   nbim= size(info.Image,2);
%     ima=fitsread([direc '\' file]);
%     nbim=size(ima,3);
    images=zeros(16,16,nbim);
    packetno=zeros(1,nbim);
    boarloc=zeros(1,nbim);
    utc=zeros(1,nbim);
    nanosec=zeros(1,nbim);
    timecomp=zeros(1,nbim);
    %unmask1=zeros(1,nbim);
    %unmask2=zeros(1,nbim);
    format long
    for nima=1:nbim
        %nbim=1 ;%size(info.Image,2);
        %disp(['Opening fits file with ' num2str(nbim) ' image(s)'])
        %for nima=1:nbim
        ima=fitsread([direc '\' file],'image',nima);
         
       % info = fitsinfo(file);
        disp(['Reading image keywords #' num2str(nima) '/' num2str(nbim)])
        packetno(nima)=cell2mat(info.Image(nima).Keywords(13,2));
        boarloc(nima)=cell2mat(info.Image(nima).Keywords(14,2));
        utc(nima)=cell2mat(info.Image(nima).Keywords(15,2));
        nanosec(nima)=cell2mat(info.Image(nima).Keywords(16,2));
        timecomp(nima)=cell2mat(info.Image(nima).Keywords(17,2));
        images(:,:,nima)=ima;%fitsread([direc files(i).name],'Image',nima);
        
        
    end
    
    format long
    indquabo3248 = find(boarloc==1016);
    packetno3248=packetno(indquabo3248);
    boarloc3248=boarloc(indquabo3248);
    utc3248=utc(indquabo3248);
    nanosec3248=nanosec(indquabo3248);
    timecomp3248=timecomp(indquabo3248);
    
    indquabo3249 = find(boarloc==1017);
    packetno3249=packetno(indquabo3249);
    boarloc3249=boarloc(indquabo3249);
    utc3249=utc(indquabo3249);
    nanosec3249=nanosec(indquabo3249);
    timecomp3249=timecomp(indquabo3249);
    
    indquabo3250 = find(boarloc==1018);
    packetno3250=packetno(indquabo3250);
    boarloc3250=boarloc(indquabo3250);
    utc3250=utc(indquabo3250);
    nanosec3250=nanosec(indquabo3250);
    timecomp3250=timecomp(indquabo3250);
    
    indquabo3251 = find(boarloc==1019);
    packetno3251=packetno(indquabo3251);
    boarloc3251=boarloc(indquabo3251);
    utc3251=utc(indquabo3251);
    nanosec3251=nanosec(indquabo3251);
    timecomp3251=timecomp(indquabo3251);
    
    indquabo4 = find(boarloc==4);
    packetno4=packetno(indquabo4);
    boarloc4=boarloc(indquabo4);
    utc4=utc(indquabo4);
    nanosec4=nanosec(indquabo4);
    timecomp4=timecomp(indquabo4);
    
    indquabo5 = find(boarloc==5);
    packetno5=packetno(indquabo5);
    boarloc5=boarloc(indquabo5);
    utc5=utc(indquabo5);
    nanosec5=nanosec(indquabo5);
    timecomp5=timecomp(indquabo5);
    
    indquabo6 = find(boarloc==6);
    packetno6=packetno(indquabo6);
    boarloc6=boarloc(indquabo6);
    utc6=utc(indquabo6);
    nanosec6=nanosec(indquabo6);
    timecomp6=timecomp(indquabo6);
    
    indquabo7 = find(boarloc==7);
    packetno7=packetno(indquabo7);
    boarloc7=boarloc(indquabo7);
    utc7=utc(indquabo7);
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
    
    windowtimecomp=0.6;%s
    coincidencetime=5.;%ns
    nbcoinfile=nbcoin;
     [coincidence4 nbcoin4 nanodiff4] = findcoincidences(...
         windowtimecomp,coincidencetime,timecomp4,nanosec4,...
     timecomp5,nanosec5,timecomp6,nanosec6,timecomp7,nanosec7,...
     timecomp3248,nanosec3248, timecomp3249,nanosec3249, ...
     timecomp3250,nanosec3250, timecomp3251,nanosec3251 ) ;  
     
     coincidences=[coincidences; coincidence4];
     nbcoin=nbcoin+nbcoin4;
     nanodiff=[nanodiff nanodiff4];
     
  [coincidence5 nbcoin5 nanodiff5] = findcoincidences(...
         windowtimecomp,coincidencetime,...
     timecomp5,nanosec5,timecomp6,nanosec6,timecomp7,nanosec7,...
     timecomp3248,nanosec3248, timecomp3249,nanosec3249, ...
     timecomp3250,nanosec3250, timecomp3251,nanosec3251,[],[] ) ;  
     coincidence5=cat(2, cell(size(coincidence5,1),1), coincidence5(:,1:end-1));
     coincidences=[coincidences; coincidence5];
     nbcoin=nbcoin+nbcoin5;
     nanodiff=[nanodiff nanodiff5];   
     
     [coincidence6 nbcoin6 nanodiff6] = findcoincidences(...
         windowtimecomp,coincidencetime,...
     timecomp6,nanosec6,timecomp7,nanosec7,...
     timecomp3248,nanosec3248, timecomp3249,nanosec3249, ...
     timecomp3250,nanosec3250, timecomp3251,nanosec3251,[],[],[],[] ) ;  
      coincidence6=cat(2, cell(size(coincidence6,1),2), coincidence6(:,1:end-2));
     coincidences=[coincidences; coincidence6];
     nbcoin=nbcoin+nbcoin6;
     nanodiff=[nanodiff nanodiff6];   
     
     [coincidence7 nbcoin7 nanodiff7] = findcoincidences(...
         windowtimecomp,coincidencetime,...
     timecomp7,nanosec7,...
     timecomp3248,nanosec3248, timecomp3249,nanosec3249, ...
     timecomp3250,nanosec3250, timecomp3251,nanosec3251,[],[],[],[],[],[] ) ;  
      coincidence7=cat(2, cell(size(coincidence7,1),3), coincidence7(:,1:end-3));
     coincidences=[coincidences; coincidence7];
     nbcoin=nbcoin+nbcoin7;
     nanodiff=[nanodiff nanodiff7];   
     
     [coincidence3248 nbcoin3248 nanodiff3248] = findcoincidences(...
         windowtimecomp,coincidencetime,...
     timecomp3248,nanosec3248, timecomp3249,nanosec3249, ...
     timecomp3250,nanosec3250, timecomp3251,nanosec3251,[],[],[],[],[],[],[],[] ) ;  
      coincidence3248=cat(2, cell(size(coincidence3248,1),4), coincidence3248(:,1:end-4));
     coincidences=[coincidences; coincidence3248];
     nbcoin=nbcoin+nbcoin3248;
     nanodiff=[nanodiff nanodiff3248];    
     
     [coincidence3249 nbcoin3249 nanodiff3249] = findcoincidences(...
         windowtimecomp,coincidencetime,...
      timecomp3249,nanosec3249, ...
     timecomp3250,nanosec3250, timecomp3251,nanosec3251,[],[],[],[],[],[],[],[],[],[] ) ;  
      coincidence3249=cat(2, cell(size(coincidence3249,1),5), coincidence3249(:,1:end-5));
     coincidences=[coincidences; coincidence3249];
     nbcoin=nbcoin+nbcoin3249;
     nanodiff=[nanodiff nanodiff3249];
     
     [coincidence3250 nbcoin3250 nanodiff3250] = findcoincidences(...
         windowtimecomp,coincidencetime,...
     timecomp3250,nanosec3250, timecomp3251,nanosec3251,[],[],[],[],[],[],[],[],[],[],[],[] ) ;  
       coincidence3250=cat(2, cell(size(coincidence3250,1),6), coincidence3250(:,1:end-6));
    
     coincidences=[coincidences; coincidence3250];
     nbcoin=nbcoin+nbcoin3250;
     nanodiff=[nanodiff nanodiff3250];
     
        
   
    
    figure
    histogram(nanodiff)
    drawnow
   
    
   durationcomp=max([t4(numel(t4)) t5(numel(t5)) t6(numel(t6)) t7(numel(t7))],[],'all') ...
       -min([t4(1) t5(1) t6(1) t7(1)],[],'all')
  maxnanos= max([nanosec4(numel(nanosec4)) nanosec5(numel(nanosec5)) nanosec6(numel(nanosec6)) nanosec7(numel(nanosec7))],[],'all');
  minnanos=  min([nanosec4(1) nanosec5(1) nanosec6(1) nanosec7(1)],[],'all'); 
  if maxnanos<minnanos
      maxnanos=maxnanos+1e9;
  end
  duration=1e-9*( maxnanos...
       -minnanos)
   expectednbcoins=expectednbcoins+round(duration* freq +1);
     
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
coincidencefiltered8quabos=coincidences{ind8coins,:};
 
 
   nan4=nanosec4(cell2mat(coincidences(ind8coins(:),1)))
   measfreq4=1/(1e-9*min(nan4(2:end)-nan4(1:end-1)));
   disp(['Meas. freq b#4 [Hz]: ' num2str(measfreq4)])
     nan5=nanosec5(cell2mat(coincidences(ind8coins(:),2)));
      measfreq5=1/(1e-9*min(nan5(2:end)-nan5(1:end-1)));
   disp(['Meas. freq b#5 [Hz]: ' num2str(measfreq5)])
    nan6=nanosec6(cell2mat(coincidences(ind8coins(:),3)));
   measfreq6=1/(1e-9*min(nan6(2:end)-nan6(1:end-1)));
   disp(['Meas. freq b#6 [Hz]: ' num2str(measfreq6)])
    nan7=nanosec7(cell2mat(coincidences(ind8coins(:),4)));
      measfreq7=1/(1e-9*min(nan7(2:end)-nan7(1:end-1)));
   disp(['Meas. freq b#7 [Hz]: ' num2str(measfreq7)])  
   nan248=nanosec3248(cell2mat(coincidences(ind8coins(:),5)));
      measfreq248=1/(1e-9*min(nan248(2:end)-nan248(1:end-1)));
   disp(['Meas. freq b#248 [Hz]: ' num2str(measfreq248)])
    disp(['Duration[s]: ' num2str(duration) ' Expected nb coins: '  num2str(round(duration* freq +1))])
 


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

    figure('Color','w')
    histogram(nanodiff)
    xlabel('Nanosec time difference [ns]')
    ylabel('Occurrences')
    title('Lick flasher, PH mode, 15pe, gains:60')

 figure('Color','w')
    histogram(nanodiff_filtered)
    xlabel('Nanosec time difference [ns]')
    ylabel('Occurrences')
    title('Lick flasher, PH mode, 15pe, gains:60')
end
