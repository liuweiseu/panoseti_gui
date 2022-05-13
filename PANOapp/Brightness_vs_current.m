% needs thorlabs powermeter soft logging...
%
% meas. Thorlb power vs current LED
NDfilter=1.;
fsstr='Bipolar fs. ';
maskstr='No Mask. ';

if NDfilter==1
    NDstr='No ND filter. ';
else
    NDstr=[num2str(100*NDfilter) '% ND Filter'];
end

currtab=round(logspace(0,log10(65535),100));
power=zeros(1,numel(currtab));
for ii=1:numel(currtab)
    disp(['Testing Curr:' num2str(currtab(ii))])
    disp(['Setting: WR' num2str(currtab(ii),'%05g')])
   setADU(['WR' num2str(currtab(ii),'%05g')]);
   pause(1.1)
   C=readPowermeter;
   disp(['Power:' cell2mat(C(4))])
   power(ii)=str2num(cell2mat(C(4)));
   
    
end


ThorlabsnWND=NDfilter*1e9*power;

ThorlabsnWNDpix=(1/((pi*(9.5/2)^2)/9.))*ThorlabsnWND;
h=6.62607e-34;c=2.998e8;lam=0.633e-6;
ThorlabsnWNDpixphot=(lam/h/c) *(1e-9)* ThorlabsnWNDpix;
qe=0.22;
ThorlabsnWNDpixcnt=qe*ThorlabsnWNDpixphot;

vegazeropt_ph=1e3; %ph/cm^-2s^-1A^-1
vegazeropt_ph_pano=(pi*23^2)*3000*1e3; %ph/cm^-2s^-1A^-1 R=23cm dlam=0.3um
ThorlabsnWNDpixphot_vegaratio=ThorlabsnWNDpixphot/vegazeropt_ph_pano
magpix=-log(ThorlabsnWNDpixphot_vegaratio)/log(2.52)
pixszas=18*60;
magarcsec2=-(log(1/pixszas^2)/log(2.52))+magpix%mag/arcsec^2

figure('Position',[50,10,1700,1040])

subplot(2,2,1)
plot((20/65535)*currtab,1e9*power,'-+b','LineWidth',3)
xlabel('Current (mA)')
ylabel('Thorlabs det Power (nW)')
grid on 
box on
set(gca,'FontSize',14)
set(gcf,'Color','w')
set(gca,'XScale','log','YScale','log')

text(0.5, 1.05,[fsstr   NDstr maskstr],'FontSize',14,'Units','norm')

subplot(2,2,2)
plot((20/65535)*currtab,ThorlabsnWNDpix,'-+b','LineWidth',3)
xlabel('Current (mA)')
ylabel('Brightness (nW/pix)')
grid on 
box on
set(gca,'FontSize',14)
set(gcf,'Color','w')
set(gca,'XScale','log','YScale','log')
subplot(2,2,3)
plot((20/65535)*currtab,ThorlabsnWNDpixphot,'-+b','LineWidth',3)
xlabel('Current (mA)')
ylabel('Nb of photons arriving on pix (ph/sec/pix)')
grid on 
box on
set(gca,'FontSize',14)
set(gcf,'Color','w')
set(gca,'XScale','log','YScale','log')
subplot(2,2,4)
plot((20/65535)*currtab,ThorlabsnWNDpixcnt,'-+b','LineWidth',3)
xlabel('Current (mA)')
ylabel(['Nb of expected counts (cps/pix), (QE=' num2str(100*qe,'%3i') '%)'])
grid on 
box on
set(gca,'FontSize',14)
set(gcf,'Color','w')
set(gca,'XScale','log','YScale','log')


datenow=datestr(now,'yymmddHHMMSS');
 saveas(gcf,['BrightLEDND_curr_' datenow '.png'])
    saveas(gcf,['BrightLEDND_curr_' datenow '.fig'])
    
    save('LEDND_Brightness_current.mat','NDfilter','NDstr','qe','currtab','power','ThorlabsnWND','ThorlabsnWNDpix','ThorlabsnWNDpixcnt','ThorlabsnWNDpixphot')

     saveas(gcf,['HarvardJimPS_ADU71_RickLED_Brightness_vs_curr_' datenow '.png'])
    saveas(gcf,['HarvardJimPS_ADU71_RickLED_Brightness_vs_curr_' datenow '.fig'])