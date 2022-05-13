function [peaksdac2, filenm]=findpelevelopt(phdref,dactab,daczeropoint,threshpeak,smaller,legendfig,pefirst)

if ~exist('smaller','var')
    smaller=0;
end
if ~exist('pefirst','var')
    pefirst=1;
end
%d0=phdref - circshift(phdref,1);
d1=phdref - circshift(phdref,-1);
d1rat=d1.*(phdref.^-1);
dd1rat=d1- circshift(d1,-1);
%do peak detection on derivative corrected for slope (dd1rat):
%
d0r=d1rat - circshift(d1rat,1);
d1r=d1rat - circshift(d1rat,-1);
pk= find( d1r>0 & d0r>0);
%counting peaks:
%threshpeak=5*(1/nim);
peaksdac2=[];
while numel(peaksdac2)<3
    peakslocpk=(find(d1rat(pk) > threshpeak));
    threshpeak=threshpeak-0.01;
    
    
    
    peaksloc=dactab(pk(peakslocpk));
    %find peaks after zeropoint=190
    %daczeropoint1=190;
    if daczeropoint ==0
        [void indmax]=max(d1);
        daczeropoint=dactab(indmax);
    end
    indindpeaks=find(peaksloc>=daczeropoint);
    peaksdac= peaksloc(indindpeaks);
    
    if numel(peaksdac)>0
        %check first one is in good range
        indfirst=find(dactab== peaksdac(1));
        while phdref(indfirst)>1e3
            peaksdac(1)=[];
            indfirst=find(dactab, peaksdac(1));
        end
        %check for neighboors
        %neighb=circshift(peaksdac,-1)-peaksdac ;
        
        peaksdac2=[peaksdac(1)];
        for ii=2:numel(peaksdac)
            if  peaksdac(ii)-peaksdac2(end)>=4-smaller
                peaksdac2=[peaksdac2 peaksdac(ii)];
            end
        end
    else
        disp('No pe level detected on this pixel...')
        peaksdac2=[];
    end
end


fig=1;
if (fig==1) && (numel(peaksdac2)>0)
    figure
    hold on
    plot(dactab, phdref,'-+b')
    plot(dactab, d1rat,'-+r')
    plot(dactab(pk), d1rat(pk),'--or')
    %    plot(dactab, dd1rat,'-y')
    %    plot(dactab, d1r,'-g')
    %    plot(dactab, d0r,'-m')
    
    hold off
    set(gca,'YScale','log')
    hold on
    yl=ylim;
    plot([peaksdac2(1) peaksdac2(1)] , yl,'--')
    text(peaksdac2(1)-4 ,0.9*yl(2),[num2str(pefirst) 'pe'],'FontSize',16)
    plot([peaksdac2(2) peaksdac2(2)] , yl,'--')
    text(peaksdac2(2)-4 ,0.9*yl(2),[num2str(pefirst+1) 'pe'],'FontSize',16)
    if numel(peaksdac2)>2
        plot([peaksdac2(3) peaksdac2(3)] , yl,'--')
        text(peaksdac2(3)-4,0.9*yl(2),[num2str(pefirst+2) 'pe'],'FontSize',16)
    end
    hold off
    box on
    grid on
    xlabel('DAC1')
    ylabel('Counts ')
    legend(legendfig,'$\frac{\delta cps(dac)}{(\delta dac)} / cps(dac)$','Interpreter','latex')
    datenow=datestr(now,'yymmddHHMMSSFFF');
    filenm=[getuserdir '\panoseti\DATA\Calibrations\' 'pesteps' datenow '_'   'PEstepdetecction.png'];
    saveas(gcf,filenm)
    saveas(gcf,[getuserdir '\panoseti\DATA\Calibrations\' 'pesteps' datenow '_'  'PEstepdetecction.fig'])
end
end