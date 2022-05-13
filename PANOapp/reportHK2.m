%reportHK
%load .mat first
load('C:\Users\jerome\Documents\panoseti\panoHK\HK4660MtLaguna20190410.mat')
C:\Users\jerome\Documents\panoseti\panoHK\
close all
nbacq=numel(hvmon0tab);
ind1=nbacq-4000;
ind2=nbacq-2500;
figure
subplot(2,1,1)
hold on
plot(  hvmon0tab(ind1:ind2),'b');
plot(  hvmon1tab(ind1:ind2),'r');
plot(  hvmon2tab(ind1:ind2),'g');
plot(  hvmon3tab(ind1:ind2),'m');
plot(  rawhvmontab(ind1:ind2),'k');
xlabel('Time [acq.# or 2.64s units]')
ylabel('HV [V]')
legend('HV1','HV2','HV3','HV4','HVraw')
hold off
subplot(2,1,2)
hold on
plot(  ihvmon0tab(ind1:ind2),'b');
plot(  ihvmon1tab(ind1:ind2),'r');
plot(  ihvmon2tab(ind1:ind2),'g');
plot(  ihvmon3tab(ind1:ind2),'m');
hold off
xlabel('Time [acq.# or 2.64s units]')
ylabel('I [\mu A]')
legend('I1','I2','I3','I4')


                       


