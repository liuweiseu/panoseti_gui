clear all
close all
format
%figini
tickns=1.; %ns

 startq5ph

%direc='/Users/jeromemaire/Documents/SETI/PANOSETI/detectors/coincid/';
%files = dir([direc 'p_d0w0m0q0_20190215_020025_57385' '*.fits']);
%files = dir([direc 'p_d0w0m0q0_20190215_184639_60566' '*.fits']);

%(init dataset) 1Hz only:
%files = dir([direc 'p_d0w0m0q0_20190217_011115_36685' '*.fits']);
%1Hz only:
%direc='C:\Users\jerome\Documents\panoseti\DATA\1Hzonly\';
%files = dir([direc 'p_d0w0m0q0_20190219_210419_151' '*.fits']);
%1Hz low thresh:
direc=[getuserdir '\panoseti\DATA\singlemobo\'];
files = dir([direc  '*.fits']);


[A,I]= max([files(:).datenum]);
if ~isempty(I)
    latestfiledatenum=dirc(I).datenum;
end

nbim=numel(files);
images=zeros(16,16,nbim);
packetno=zeros(1,nbim);
boarloc=zeros(1,nbim);
utc=zeros(1,nbim);
nanosec=zeros(1,nbim);
timecomp=zeros(1,nbim);

nim0=30;binw=7e-5;
petab=[10. 15. 20.];
gaintab=[40 60 80];
truedet=zeros(numel(petab),numel(gaintab));
totframes=zeros(numel(petab),numel(gaintab));
P=zeros(numel(petab),numel(gaintab));
N=zeros(numel(petab),numel(gaintab));
TP=zeros(numel(petab),numel(gaintab));
FP=zeros(numel(petab),numel(gaintab)); %si numel(indtruenano)>P
FNmissed=zeros(numel(petab),numel(gaintab));


for gaini=1:numel(gaintab)
    quaboconfig=changegain(gaintab(gaini), quaboconfig,1);
    for pei=1:numel(petab)
          disp(['Gain ' num2str(gaini) '/' num2str(numel(gaintab)) ' ' 'Pe ' num2str(pei) '/' num2str(numel(petab)) ])
  
        quaboconfig=changepe(petab(pei),gaintab(gaini),quaboconfig);
        pause(3)
        nim=nim0;
        [images nbimafin nanosec1 timecomp1]=grabimages2key(nim,2,1);
        durat=3600*24*(timecomp1(end)- timecomp1(1));
        if 3600*24*(timecomp1(end)- timecomp1(1)) <3
            nim=round(nim0*4/durat);
            [images nbimafin nanosec timecomp boardloc]=grabimages2key(nim,2,1);
        end
        
           indquabo1 = find(boarloc==4660);
       % packetno1=packetno(indquabo1);
       % boarloc1=boarloc(indquabo1);
       % utc1=utc(indquabo1);
        nanosec1=nanosec(indquabo1);
        timecomp1=timecomp(indquabo1);
        
     indquabo2 = find(boarloc==4661);
      %  packetno2=packetno(indquabo2);
      %  boarloc2=boarloc(indquabo2);
      %  utc2=utc(indquabo2);
        nanosec2=nanosec(indquabo2);
        timecomp2=timecomp(indquabo2);
   
        nanosec1=tickns*(1e-9)*nanosec1;
      
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
        
        %nano1=nanosec1-nanosec1(1);
        
        figure
        subplot(1,2,1)
        plot(t1,ones(1,sz1),'+')
        xlabel('Comp time [s]')
        ylabel('Frame event')
        subplot(1,2,2)
        plot(nanosec1,ones(1,sz1),'+r')
        xlabel('Nanosec counter [s]')
        ylabel('Frame event')
        %
        % [p,f]=plomb(t1,7,'normalized')
        % figure
        % plot(f,p)
        % xlabel('Frequency [Hz]')
        
        diffs=zeros(sz1,sz1);
        diffsdecim=zeros(sz1,sz1);
        nanodiffs=zeros(sz1,sz1);
        %nanodiffsdecim=zeros(sz1,sz1);
        for ii=1:sz1
            t1c=t1(ii);
            diffs(ii,:)=t1-t1c;
            diffsdecim(ii,:)=abs(t1-t1c)-floor(abs(t1-t1c));
            t1c=nanosec1(ii);
            nanodiffs(ii,:)=abs(nanosec1-t1c);
        end
        
        
        
nanodiffsnodiag=nanodiffs;
for ii = 1 :size(nanodiffs,1)
nanodiffsnodiag(ii,ii)=1e6;
end
postrue=mod(find(nanodiffsnodiag<binw),nim);
indz=find(postrue==0);
postrue(indz)=nim;
[C,ia,ic] =unique(postrue);




        diffs=triu(diffs);
        indzeros=find(diffs==0);
        diffs( indzeros)=NaN;
        
        
        nanodiffs0=triu(nanodiffs);
        indzeros0=find(nanodiffs0==0);
        nanodiffs0( indzeros0)=NaN;
        
        % diffsdecim=triu(diffsdecim);
        % indzeros=find(diffsdecim==0);
        % diffsdecim( indzeros)=NaN;
        
        figure
        subplot(1,2,1)
        histogram(diffs,'BinWidth',0.2)
        xlabel('computer time differences [s]')
        ylabel('counts')
        subplot(1,2,2)
        histogram(nanodiffs,'BinWidth',binw)
        xlabel('nanosec differences [s]')
        ylabel('counts')
        
        figure
        subplot(1,2,1)
        imagesc(diffsdecim)
        xlabel('Frame#')
        ylabel('Frame#')
        title('Diff time comp differences')
        colorbar
        subplot(1,2,2)
        imagesc(nanodiffs)
        xlabel('Frame#')
        ylabel('Frame#')
        title('Nanosec differences')
        colorbar
        
        figure
        subplot(1,2,1)
        h=histogram(diffsdecim,'BinWidth',0.01)
        xlabel('computer time differences [s]')
        ylabel('counts')
        subplot(1,2,2)
        hnano=histogram(nanodiffs0,'BinWidth',binw)
        xlabel('nanosec differences [s]')
        ylabel('counts')
        xlim([-0.1 1.1])
        
        histodec=h.BinCounts;
        szh=numel(histodec);
        
        histodecnano=hnano.BinCounts;
        szhnano=numel(histodecnano);
        
        interv=0:1/szh:1;
        middleind=find((interv>0.2)&(interv<0.8));
        meanmiddlehisto=mean(histodec(middleind));
        SNR=max(histodec)/meanmiddlehisto
        
        intervnano=0:1/szhnano:1;
        middleindnano=find((intervnano>binw));
        meanmiddlehistonano=mean(histodecnano(2:end));
        if ~isfinite(meanmiddlehistonano) ||  numel(meanmiddlehistonano)==0 || meanmiddlehistonano==0
            meanmiddlehistonano=binw;
        end
        SNRnano=max(histodecnano)/meanmiddlehistonano
        
        
        SNRrows=zeros(1,sz1);
        SNRrowsnano=zeros(1,sz1);
        figure
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
            
            hnano=histogram(nanodiffs(ii,:),'BinWidth',binw);
            histodecnano=hnano.BinCounts;
            szh=numel(histodecnano);
            intervnano=0:1/szhnano:1-1/szhnano;
            middleindnano=find((intervnano>binw));
            
            meanmiddlehistonano=mean(histodecnano(2:end));
            if ~isfinite(meanmiddlehistonano) || numel(meanmiddlehistonano)==0 || meanmiddlehistonano==0
                meanmiddlehistonano=binw;
            end
            %extremind=find((intervnano>0.0001));
            maxhistonano=max(histodecnano);
            SNRrowsnano(ii)=maxhistonano/meanmiddlehistonano;
        end
        
        figure
        subplot(1,2,1)
        plot(SNRrows,'+-')
        xlabel('Frame#')
        ylabel('SNR time comp')
        subplot(1,2,2)
        plot(SNRrowsnano,'+-')
        xlabel('Frame#')
        ylabel('SNR nanosec')
        
        indtrue=find(SNRrows>0.2*max(SNRrows));
        amp=ones(1,sz1);
        amp(indtrue)=2;
        
        indtruenano=find(SNRrowsnano>0.2*max(SNRrowsnano));
        ampnano=ones(1,sz1);
        ampnano(indtruenano)=2;
        
                ampnano2=ones(1,sz1)+0.1;
        ampnano2(C)=3;
        figure
        subplot(1,2,1)
        plot(t1,amp,'+')
        ylim([0 3])
        xlabel('computer time differences [s]')
        ylabel('events')
        subplot(1,2,2)
        hold on
        plot(t1,ampnano2,'+r')
        plot(t1,ampnano,'+')
        ylim([0 4])
        xlabel('nanosec counter differences [s]')
        ylabel('events')
        
        disp(['Number of positives (comp): ' num2str(numel(indtrue)) ' / ' num2str(sz1) ' tot.frames'])
        disp(['Number of true positives (comp): ' num2str(numel(indtrue)) ' / '  num2str(round(durat)+1) ' expected'])
        disp(['Number of positives (nanosec): ' num2str(numel(indtruenano)) ' / ' num2str(sz1) ' tot.frames'])
        disp(['Number of positives (nanosec): ' num2str(numel(indtruenano)) ' / '  num2str(round(durat)+1) ' expected'])
        disp(['nb of positives (nanosec2): ' num2str(numel(C)) ' / '  num2str(round(durat)+1) ' expected'])
        disp(['Duration[s]: ' num2str(durat)])
          
        truedet(pei,gaini)=numel(indtruenano);
        totframes(pei,gaini)=sz1;
        P(pei,gaini)=round(durat)+1;
        N(pei,gaini)=sz1-(round(durat)+1);
        TP(pei,gaini)=min([numel(indtruenano) round(durat)+1]);
        FP(pei,gaini)=max([numel(indtruenano)-(round(durat)+1) 0]); %si numel(indtruenano)>P
        FNmissed(pei,gaini)=max([(round(durat)+1)-numel(indtruenano) 0]);
        
    end
end


figure
subplot(1,2,1)
hold on
leg={};

for gaini = 1:numel(gaintab)
    hitrate= TP(:,gaini)./P(:,gaini);
    leg=[leg {['Gain: ' num2str(gaintab(gaini))]}]
    plot(petab,hitrate,'-+')
    
end



hold off
xlabel('pe#')
ylabel('True Positive Rate (TP/P)')
legend(leg)

subplot(1,2,2)
hold on
for gaini=1:numel(gaintab)
    falsepositiverate= FP(:,gaini)./N(:,gaini);
    plot(petab,falsepositiverate,'-+')
end
hold off
xlabel('pe#')
ylabel('False Positive Rate (FP/N)')

for ii =1 :4 
disp(numel(find(nanodiffs0(ii,:)<binw)))
end











