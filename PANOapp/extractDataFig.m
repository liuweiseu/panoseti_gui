h=gcf;
axesObjs=get(h,'Children')
dataObjs=get(axesObjs,'Children')
xdata=get(dataObjs,'XData');
ydata=get(dataObjs,'YData');

xd=cell2mat(xdata(45));
yd=cell2mat(ydata(45));


datape=xd;
datath=yd;

datath(8)=646
datath(9)=648
datath(11)=652

th1=350 %what pe?
pe=interp1(datath,datape,th1,'cubic')

pe1=3. %what th?
th=interp1(datape,datath,pe1,'cubic')

petab=1:5;
thtab=interp1(datape,datath,petab,'cubic')

datath2=datath(2:end);
datape2=datape(2:end);

petab=1:5;
thtab2=interp1(datape2,datath2,petab,'cubic')

hold on
for ii=1:numel(petab)
   plot([thtab2(ii) thtab2(ii)], [1 1e5], '--')
   text(thtab2(ii),1.1,[num2str(petab(ii)) ' pe'],'FontSize',16)
end
hold off