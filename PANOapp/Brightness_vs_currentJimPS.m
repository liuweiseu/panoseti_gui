% needs thorlabs powermeter soft logging...
%
% meas. Thorlb power vs current LED
NDfilter=1.;
fsstr='Source at ~20cm from Thorlabs det. No ND filter. ';
maskstr='No Mask. ';

if NDfilter==1
    NDstr='No ND filter. ';
else
    NDstr=[num2str(100*NDfilter) '% ND Filter'];
end

  if ~exist('s','var')
        s = serial('COM6','BaudRate',9600);
        fopen(s)
  end

currtab=round(logspace(0,log10(10000),100));
power=zeros(1,numel(currtab));
for ii=1:numel(currtab)
    disp(['Testing Curr:' num2str(currtab(ii))])
    disp(['Setting: U' num2str(currtab(ii),'%05g') ';'])
   %setADU(['WR' num2str(currtab(ii),'%05g')]);
   setJimPS(s,currtab(ii))
   pause(1.5)
   C=readPowermeter;
   disp(['Power:' cell2mat(C(4))])
   power(ii)=str2num(cell2mat(C(4)));
   
    
end


ThorlabsnW=1e9*power;

ThorlabsnWpix=(1/((pi*(9.5/2)^2)/9.))*ThorlabsnW;
h=6.62607e-34;c=2.998e8;lam=0.633e-6;
ThorlabsnWpixphot=(lam/h/c) *(1e-9)* ThorlabsnWpix;
qe=0.22;
ThorlabsnWpixcnt=qe*ThorlabsnWpixphot;

NDfilter=0.01;
ThorlabsnWND=NDfilter*1e9*power;

ThorlabsnWNDpix=(1/((pi*(9.5/2)^2)/9.))*ThorlabsnWND;
h=6.62607e-34;c=2.998e8;lam=0.633e-6;
ThorlabsnWNDpixphot=(lam/h/c) *(1e-9)* ThorlabsnWNDpix;
qe=0.22;
ThorlabsnWNDpixcnt=qe*ThorlabsnWNDpixphot;

%predicted (remove low end not measured by Thorlabs det)
xi=40;
 P = polyfit(log10((0.001)*currtab(xi:end)),log10(ThorlabsnWND(xi:end)),1);
   % ThorlabsnWNDfit = P(1)*(0.001)*currtab+P(2);
     ThorlabsnWNDfit = 10.^(P(2)+ P(1)* log10((0.001)*currtab) );
    %hold on;
   ThorlabsnWNDpixfit=(1/((pi*(9.5/2)^2)/9.))*ThorlabsnWNDfit;
h=6.62607e-34;c=2.998e8;lam=0.633e-6;
ThorlabsnWNDpixphotfit=(lam/h/c) *(1e-9)* ThorlabsnWNDpixfit;
qe=0.22;
ThorlabsnWNDpixcntfit=qe*ThorlabsnWNDpixphotfit;

vegazeropt_ph=1e3; %ph/cm^-2s^-1A^-1
vegazeropt_ph_pano=(pi*23^2)*3000*1e3; %ph/cm^-2s^-1A^-1 R=23cm dlam=0.3um
ThorlabsnWNDpixphot_vegaratio=ThorlabsnWNDpixphotfit/vegazeropt_ph_pano
magpix=-log(ThorlabsnWNDpixphot_vegaratio)/log(2.52)
pixszas=18*60;
magarcsec2=-(log(1/pixszas^2)/log(2.52))+magpix%mag/arcsec^2

figure('Position',[50,10,1700,1040])

subplot(2,2,1)
plot((0.001)*currtab,1e9*power,'-+b','LineWidth',3)
%plot((0.001)*currtab,1e9*power,'-r','LineWidth',3)
xlabel('Current (mA)')
ylabel('Thorlabs det Power (nW)')
grid on 
box on
set(gca,'FontSize',14)
set(gcf,'Color','w')
set(gca,'XScale','log','YScale','log')

text(0.5, 1.05,[fsstr   NDstr maskstr],'FontSize',14,'Units','norm')

subplot(2,2,2)
hold on
plot((0.001)*currtab,ThorlabsnWpix,'-+b','LineWidth',3)
plot((0.001)*currtab,ThorlabsnWNDpix,'--+r','LineWidth',3)
 plot((0.001)*currtab,ThorlabsnWNDpixfit,'g-.','LineWidth',3);
hold off
xlabel('Current (mA)')
ylabel('Brightness (nW/pix)')
grid on 
box on
set(gca,'FontSize',14)
set(gcf,'Color','w')
set(gca,'XScale','log','YScale','log')
legend('no ND','Predicted with 1% ND filter','Predicted with 1% ND filter & Jim''s PS')
subplot(2,2,3)
hold on
plot((0.001)*currtab,ThorlabsnWpixphot,'-+b','LineWidth',3)
plot((0.001)*currtab,ThorlabsnWNDpixphot,'--+r','LineWidth',3)
plot((0.001)*currtab,ThorlabsnWNDpixphotfit,'-.+g','LineWidth',3)
hold off
xlabel('Current (mA)')
ylabel('Nb of photons arriving on pix (ph/sec/pix)')
legend('no ND','Predicted with 1% ND filter','Predicted with 1% ND filter & Jim''s PS')
grid on 
box on
set(gca,'FontSize',14)
set(gcf,'Color','w')
set(gca,'XScale','log','YScale','log')
subplot(2,2,4)
hold on
plot((0.001)*currtab,ThorlabsnWpixcnt,'-+b','LineWidth',3)
plot((0.001)*currtab,ThorlabsnWNDpixcnt,'--+r','LineWidth',3)
plot((0.001)*currtab,ThorlabsnWNDpixcntfit,'-.+g','LineWidth',3)
hold on
xlabel('Current (mA)')
ylabel(['Nb of expected counts (cps/pix), (QE=' num2str(100*qe,'%3i') '%)'])
legend('no ND','Predicted with 1% ND filter','Predicted with 1% ND filter & Jim''s PS')
grid on 
box on
set(gca,'FontSize',14)
set(gcf,'Color','w')
set(gca,'XScale','log','YScale','log')


datenow=datestr(now,'yymmddHHMMSS');
 saveas(gcf,['BrightLEDND_curr_' datenow '.png'])
    saveas(gcf,['BrightLEDND_curr_' datenow '.fig'])
    
    save(['LEDND_Brightness_current_' datenow '.mat'])
setJimPS(s,0)