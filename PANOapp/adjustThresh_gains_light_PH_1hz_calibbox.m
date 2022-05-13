close all
tic

% if ~exist('s','var')
%     s = serial('COM6','BaudRate',9600);
%     fopen(s)
% end
exposureperdac=10;

exposurestr='';
%dactab=[150:1:280 ];
gaintabtab=[40 60];%11:31 %1:10:121;
%currtabExp=[0. round(logspace(0,log10(4000),10))];
currtabExp=[0.];
%currtabExp=[0. ];

expstr='';
shaperstr='Bipolar fs; ';
maskstr='All-pixels-masked-excepted-one; ';

pestepphcps=zeros(4,numel(gaintabtab),3);

realhvQ0=[];realhvQ1=[];realhvQ2=[];realhvQ3=[];
realcurQ0=[];realcurQ1=[];realcurQ2=[];realcurQ3=[];
temp1=[];temp2=[];
timecomp=[];

 quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config.txt']);
 szq=size(quaboconfig,1);
quaboconfig(szq+1,1)={'IP'};quaboconfig(szq+1,3)={IP};
szq=size(quaboconfig,1);
quaboconfig(szq+1,1)={'QuaboSN'};quaboconfig(szq+1,3)={str2num(quaboSN)};




petab=2.:0.3:7.1;

PHcpsfinalfigcell=cell(numel(gaintaballg),4);

for cc=1:numel(currtabExp)
    disp(['Testing Curr:' num2str(currtabExp(cc))])
    disp(['Setting: U' num2str(currtabExp(cc),'%05g') ';'])
    %setADU(['WR' num2str(currtab(ii),'%05g')]);
    % setJimPS(s,currtabExp(cc))
    disp('Changing Light intensity. Waiting 15s for HV to be adjusted...')
    
    %     if cc>1
    %     pause(15)
    %     end
    
   
    [ig,indexstimon]=ismember(['STIMON '] ,quaboconfig);
    quaboconfig(indexstimon,2)={"0"};
    pausetime=0.5;
    indcol=1:4;
    
    [ig,indexacqmode]=ismember(['ACQMODE '] ,quaboconfig);
    quaboconfig(indexacqmode,2)={"0x01"};
    
    % init the board?
    disp('Init Marocs...')
    sendconfig2Maroc(quaboconfig)
    disp('Waiting 3s...')
    pause(3)
    disp('Init Acq...')
    sentacqparams2board(quaboconfig)
    disp('Waiting 3s...')
    pause(3)
    % [ig,indexacqint]=ismember(['ACQINT '] ,quaboconfig);
    % acqint=(1e-5)*str2num(quaboconfig(indexacqint,2));
    % exposurestr=['Exposure time [ms]:' num2str(1000*acqint,'%3.3g')];
    normcps=1; %/acqint;
    %set gain
    IntensmeanQ8G=[];
    cpsfitH=zeros(4,numel(gaintabtab));
    cpsfitI=zeros(4,numel(gaintabtab));
    pestepPHdac=zeros(4,numel(gaintabtab),3);
    for  gainkk=1:numel(gaintabtab)
        gaintab=gaintabtab(gainkk);
        usegainmap=1;
        quaboconfig=changegain(gaintab(1),quaboconfig,usegainmap)
        
        load(([getuserdir '\panoseti\Calibrations\' 'CalibrationDB.mat']))
[ig,indexquabosn]=ismember(['QuaboSN'] ,quaboconfig);
inddetrow=find(quaboDETtable(:,1)==str2num(cell2mat(quaboconfig(indexquabosn,3))));
A0=gaintab*quaboDETtable(inddetrow,7);
A1=gaintab*quaboDETtable(inddetrow,8);
A2=gaintab*quaboDETtable(inddetrow,9);
A3=gaintab*quaboDETtable(inddetrow,10);
B0=quaboDETtable(inddetrow,11);
B1=quaboDETtable(inddetrow,12);
B2=quaboDETtable(inddetrow,13);
B3=quaboDETtable(inddetrow,14);


        
        for iquad=1:4
            %choose pix and mask
            
            %set masks MASKOR1_
            
            load('Marocmap.mat')
            mx=3; %in agreement with ADC vs dac following charac
            my=iquad;
            
            xt1=squeeze(marocmap(mx,my,1));
            yt1=squeeze(marocmap(mx,my,2));
            xt2=squeeze(marocmap(32,1,1));
            yt2=squeeze(marocmap(32,1,2));
            xt3=squeeze(marocmap(8,4,1));
            yt3=squeeze(marocmap(8,4,2));
            
            mask=1;
            quaboconfig=changemask(mask,[mx my],quaboconfig)
            
            
            
            
            
            
            %dactab=[ 240 250 260 270 280 290 300 305 310 320 350 400 450 500];
            %dactab=[288 290 292 294 296 298 300 305 310 320 350 400 450 500];
            %dactab=[550:1:650 ];
            
            %dactab=[185:5:305  ];
            figure
            [ia,indexdac]=ismember('DAC1',quaboconfig);
            
            %   put high thresh on all 4 quads
            dactabH0=500;
            quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactabH0)]};
            %  pause(pausetime)
            
            
            dactab0=[round(A0*petab(1)+B0):round(A0*petab(end)+B0)];
            dactab1=[round(A1*petab(1)+B1):round(A1*petab(end)+B1)];
            dactab2=[round(A2*petab(1)+B2):round(A2*petab(end)+B2)];
            dactab3=[round(A3*petab(1)+B3):round(A3*petab(end)+B3)];
            
            if iquad==1
                dactab=dactab0;
                Aquad=A0;
                Bquad=B0;
                nbelemdactab=numel(dactab);
            elseif iquad==2
                dactab=dactab1;
                Aquad=A1;
                 Bquad=B1;
            elseif iquad==3
                dactab=dactab2;
                Aquad=A2;
                Bquad=B2;
            elseif iquad==4
                dactab=dactab3;
                Aquad=A3;
                Bquad=B3;
            end
                            if numel(dactab)>nbelemdactab
                                dactab=dactab(1:nbelemdactab);
                            end
                            if numel(dactab)<nbelemdactab
                                dactab=[dactab dactab(end)+(1:nbelemdactab-numel(dactab))];
                            end
                        IntensmeanQ9G=zeros(numel(dactab),numel(gaintabtab),4);        
            
            IntensmeanQ0=[];IntensmeanQ1=[];IntensmeanQ2=[];IntensmeanQ3=[];IntensmeanQ8=[];IntensmeanQ9=[];
            allima=zeros(16,16,numel(dactab),numel(indcol));
            indcol2=1;  
            for dd=1:numel(dactab)
                quaboconfig(indexdac,iquad+1)={['0x' dec2hex(dactab(dd))]};
                disp(['Sending Maroc comm...DAC1:' num2str(dactab(dd)) '/' num2str(dactab(end)) ' Gain:' num2str((gaintabtab(gainkk))) ' (' num2str(gainkk) '/' num2str(numel(gaintabtab)) ')' ...
                    ' Quad: ' num2str(iquad) '/' num2str(4)])
                sendconfig2Maroc(quaboconfig)
                
                %timepause=10;
                %disp(['Q' num2str(indcol2) '  ' num2str( timepause*(numel(dactab)-dd)) 's left...'])
                pause(pausetime)
                %pause(pausetime)
                
                %                IntensmeanQ9G(dd,gainkk,cc)=(meanimage(1,7));
                % IntensmeanQ9G(dd,gainkk,cc)=measframerate(10,1,1);
                [pac1 ti1]=measframerateb;
                pause(exposureperdac)
                [pac2 ti2]=measframerateb;
                if (numel(pac1)==1) && (numel(pac2)==1)
                    pacdiff=double(pac2)-double(pac1);
                elseif (numel(pac1)==0) || (numel(pac2)==0)
                    pacdiff=0;
                end
                if pacdiff<0
                    pacdiff=2^16-double(pac1)+double(pac2)
                end
                timediff=3600*24*(ti2-ti1);
                if numel(timediff)>0
                    IntensmeanQ9G(dd,gainkk,iquad)= double(pacdiff) / timediff;
                    disp(['Nb cnts/s:' num2str(IntensmeanQ9G(dd,gainkk,iquad))])
                end
            end
            % IntensmeanQ8G=[IntensmeanQ8G; IntensmeanQ8];
            
            
            
            %%find 4,5,6 pes levels
            pestart=3.;
            daczeropoint1=Aquad*pestart+Bquad;threshpeak=0.3; steplen=floor(0.24*gaintab(1));pefirst=4;
            disp(['numel(dactab): ' num2str(numel(dactab)) ' numel(squeeze(IntensmeanQ9G(:,gainkk,iquad))): ' num2str(numel(squeeze(IntensmeanQ9G(:,gainkk,iquad))))])
            peakstestdac=findpelevelopt(squeeze(IntensmeanQ9G(:,gainkk,iquad)),dactab,daczeropoint1,threshpeak,-steplen+6,['Q' num2str(iquad-1)],pefirst);
            
            if numel(peakstestdac)>0
                allgood=min([numel(peakstestdac) 3])
                pestepPHdac(iquad,gainkk,1:allgood)=peakstestdac(1:allgood);
            end
            
            %%fitting cps curves
            %remove left part
            
            curv= normcps*squeeze(IntensmeanQ9G(:,gainkk,iquad))';
            intenmax0pt=1.08e3;
            darkref =find(fliplr(curv)>intenmax0pt);
            daczeropointleft=fliplr(dactab(darkref(1)));
            curv=curv(end-darkref(1)+1:end);
            %put Nan instead of zeros at high dacs
            
            indzeroright=find(curv==0);
            if numel(indzeroright)>0
                indcutright=indzeroright(1)-1;
                curv=curv(1:indcutright);
            else
                indcutright=numel(curv);
            end
            if numel(curv)>1
                [countfit, gof] = fit(transpose(squeeze(dactab(end-darkref(1)+1:end-darkref(1)+1+indcutright-1))),log10(curv)', 'poly1')
                cpsfitH(iquad,gainkk)=countfit.p1;
                cpsfitI(iquad,gainkk)=countfit.p2;
            end
            
          %  cps=normcps*IntensmeanQ9G(:,gainkk,iquad)
         for ida=1:3
            dacofpe=find(dactab== pestepPHdac(iquad,gainkk,ida));
            pestepphcps(iquad,gainkk,ida)=normcps*squeeze(IntensmeanQ9G(dacofpe,gainkk,iquad));
           
        end
        
            
            clf
            % FIG: Light Intens. vs dactab for gains
            figure('Position',[10 10 1400 900])
            hold on
            plot(dactab, normcps*IntensmeanQ9G(:,gainkk,iquad),['-'],'Color','b','Linewidth',1.5) %[ii/size(IntensmeanQ8G,1) (1-ii/size(IntensmeanQ8G,1)) ii/size(IntensmeanQ8G,1)]
            yl=ylim;
            for ii=1:numel(peakstestdac)
                plot([peakstestdac(ii) peakstestdac(ii)] ,yl,'--k')
            end
            hold off
            set(gca,'FontSize',16)
            xlabel('Threshold DAC1 ')
            ylabel(' [# triggers per second]')
            hold off
            set(gca, 'YScale','log')
            box on
            grid on
            set(gcf,'Color','w')
            title(['Q' num2str(iquad) ' ' expstr shaperstr maskstr ])
            datenow=datestr(now,'yymmddHHMMSS');
            filenm=[calibdir 'cpsPH_' 'Q' num2str(iquad) '_' datenow '_masked.png'];
            saveas(gcf,filenm)
            saveas(gcf,[calibdir 'cpsPH_' 'Q' num2str(iquad) '_' datenow '_masked.fig'])
            PHcpsfinalfigcell(iquad,gainkk)={filenm};
            %save hk
            
            try
                hk = getlastHK;
            catch
                pause(0.11)
                hk = getlastHK;
            end
            realhvQ0=[realhvQ0 hk.hvmon0];
            realhvQ1=[realhvQ1 hk.hvmon1];
            realhvQ2=[realhvQ2 hk.hvmon2];
            realhvQ3=[realhvQ3 hk.hvmon3];
            realcurQ0=[realcurQ0 hk.ihvmon0];
            realcurQ1=[realcurQ1 hk.ihvmon1];
            realcurQ2=[realcurQ2 hk.ihvmon2];
            realcurQ3=[realcurQ3 hk.ihvmon3];
            
            temp1=[temp1 hk.temp1];temp2=[temp2 hk.temp2];
            timecomp=[timecomp hk.timecomp];
        end
    end
end

datenow=datestr(now,'yymmddHHMMSS');
save([calibdir 'calibph' datenow '.mat'], 'pestepPHdac','pestepphcps','cpsfitH','cpsfitI')

tph=toc;
