function reportlastHK(sincesec)
%reportHK
%load .mat first
%load('C:\Users\jerome\Documents\panoseti\panoHK\HK4660MtLaguna20190410.mat')
load(['C:\Users\jerome\Documents\panoseti\panoHK\' getlatestfile('C:\Users\jerome\Documents\panoseti\panoHK\')])
%close all
nbacq=numel(hvmon0tab);
ind1=nbacq-sincesec/2.64;
ind2=nbacq-sincesec/2.64;
timevec=2.64*(0:(ind2-ind1));
figure('Position',[50 50 1200 900],'Color','w')
subplot(3,1,1)
hold on
plot(timevec,  hvmon0tab(ind1:ind2),'b');
plot(timevec,   hvmon1tab(ind1:ind2),'r');
plot(timevec,   hvmon2tab(ind1:ind2),'g');
plot(timevec,   hvmon3tab(ind1:ind2),'m');
plot( timevec,  rawhvmontab(ind1:ind2),'k');
xlabel('Time [s]')
ylabel('HV [V]')
legend('HV1','HV2','HV3','HV4','HVraw')
hold off
box on
subplot(3,1,2)
hold on
plot(timevec,   ihvmon0tab(ind1:ind2),'b');
plot(timevec,   ihvmon1tab(ind1:ind2),'r');
plot(timevec,   ihvmon2tab(ind1:ind2),'g');
plot(timevec,   ihvmon3tab(ind1:ind2),'m');
hold off
xlabel('Time [s]')
ylabel('I [\mu A]')
legend('I1','I2','I3','I4')
box on

subplot(3,1,3)
hold on
plot(  temp1tab(ind1:ind2),'b');
plot(  temp2tab(ind1:ind2),'r');
hold off
xlabel('Time [s]')
ylabel('Temperature [\circ C]')
legend('I1','I2','I3','I4')
box on
  datenow=datestr(now,'yymmddHHMMSS');
        saveas(gcf,['HK_' datenow '.png'])
        saveas(gcf,[ 'HK_' datenow '.fig'])
end           


