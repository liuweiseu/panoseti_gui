clear all
close all
format 
%figini
tickns=3.2; %ns

%direc='/Users/jeromemaire/Documents/SETI/PANOSETI/detectors/coincid/';
%files = dir([direc 'p_d0w0m0q0_20190215_020025_57385' '*.fits']);
%files = dir([direc 'p_d0w0m0q0_20190215_184639_60566' '*.fits']);

%(init dataset) 1Hz only:
%files = dir([direc 'p_d0w0m0q0_20190217_011115_36685' '*.fits']);
%1Hz only:
%direc='C:\Users\jerome\Documents\panoseti\DATA\1Hzonly\';
%files = dir([direc 'p_d0w0m0q0_20190219_210419_151' '*.fits']);
%1Hz low thresh:
direc=[getuserdir '\panoseti\DATA\doublemobo7\'];
files = dir([direc 'p_d0w0m0q0_20191114' '*.fits']);

nbim=numel(files);
images=zeros(16,16,nbim);
packetno=zeros(1,nbim);
boarloc=zeros(1,nbim);
utc=zeros(1,nbim);
nanosec=zeros(1,nbim);
timecomp=zeros(1,nbim);

for nima=1:nbim
ima=fitsread([direc files(nima).name]);
info = fitsinfo([direc files(nima).name]);

%nbim=1 ;%size(info.Image,2);
%disp(['Opening fits file with ' num2str(nbim) ' image(s)'])

format long

     %for nima=1:nbim
         disp(['Reading image keywords #' num2str(nima) '/' num2str(nbim)])
        packetno(nima)=cell2mat(info.PrimaryData.Keywords(14,2));
        boarloc(nima)=cell2mat(info.PrimaryData.Keywords(15,2));
        utc(nima)=cell2mat(info.PrimaryData.Keywords(16,2));
        nanosec(nima)=cell2mat(info.PrimaryData.Keywords(17,2));
        timecomp(nima)=cell2mat(info.PrimaryData.Keywords(18,2));
        images(:,:,nima)=ima;%fitsread([direc files(i).name],'Image',nima);
    end
        format long
     indquabo1 = find(boarloc==4660);
        packetno1=packetno(indquabo1);
        boarloc1=boarloc(indquabo1);
        utc1=utc(indquabo1);
        nanosec1=3.2*nanosec(indquabo1);
        timecomp1=timecomp(indquabo1);
        
     indquabo2 = find(boarloc==4661);
        packetno2=packetno(indquabo2);
        boarloc2=boarloc(indquabo2);
        utc2=utc(indquabo2);
        nanosec2=3.2*nanosec(indquabo2);
        timecomp2=timecomp(indquabo2);
   
        
        
 %   find 1hz indices
 % if next timecomp < 1 go next
 t1=3600*24*(timecomp1- timecomp1(1));
 sz1=numel(t1);
 durat=t1(end)-t1(1);
%   t2=3600*24*(timecomp2- timecomp1(1));
%  tdiff=t1(2:end)-t1(1:end-1);
%  %%%FIRST
%  %ind1h=find((abs(tdiff-1)<0.35) & t1(1:end-1)<100);
%   ind1h=find((abs(tdiff-1)<0.35) & t1(1:end-1)>-1);
%  ind1h0=ind1h(1);
%  indcyc1=ind1h;
% % ind1hz=find((abs(tdiff-floor(tdiff))<0.25) & tdiff>0.5 & t1<220);
%  

figure
plot(t1,ones(1,sz1),'+')

% 
% [p,f]=plomb(t1,7,'normalized')
% figure
% plot(f,p)
% xlabel('Frequency [Hz]')

diffs=zeros(sz1,sz1);
diffsdecim=zeros(sz1,sz1);
for ii=1:sz1
    t1c=t1(ii);
    diffs(ii,:)=t1-t1c;
    diffsdecim(ii,:)=abs(t1-t1c)-floor(abs(t1-t1c));
end

diffs=triu(diffs);
indzeros=find(diffs==0);
diffs( indzeros)=NaN;
 
% diffsdecim=triu(diffsdecim);
% indzeros=find(diffsdecim==0);
% diffsdecim( indzeros)=NaN;

figure
histogram(diffs,'BinWidth',0.2)
xlabel('')

figure
imagesc(diffsdecim)
colorbar

figure
h=histogram(diffsdecim,'BinWidth',0.01)

histodec=h.BinCounts;
szh=numel(histodec);

interv=0:1/szh:1;
middleind=find((interv>0.2)&(interv<0.8));
meanmiddlehisto=mean(histodec(middleind));
SNR=max(histodec)/meanmiddlehisto


SNRrows=zeros(1,sz1);
for ii=1:sz1
    h=histogram(diffsdecim(ii,:),'BinWidth',0.01);
    histodec=h.BinCounts;
    szh=numel(histodec);
    interv=0:1/szh:1-1/szh;
    middleind=find((interv>0.2)&(interv<0.8));
    meanmiddlehisto=mean(histodec(middleind));
    extremind=find((interv<0.2)|(interv>0.8));
    maxhisto=max(histodec(extremind));
    SNRrows(ii)=maxhisto/meanmiddlehisto;
end

figure
plot(SNRrows)

indtrue=find(SNRrows>5);
amp=ones(1,sz1);
amp(indtrue)=2;
figure
plot(t1,amp,'+')
ylim([0 3])

disp(['Number of true positives: ' num2str(numel(indtrue)) ' / ' num2str(sz1) ' tot.frames'])
disp(['Number of true positives: ' num2str(numel(indtrue)) ' / ' num2str(floor(durat)) ' expected'])