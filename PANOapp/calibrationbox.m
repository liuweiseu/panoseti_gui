clear all
close all
firmware=0; %update firmware? 0=No; 5 means quabo_v005; 6 means quabo_v006, etc...
IP='192.168.1.11'
makereport=1
startguis=1
 fakefpga=1
 
firmwarestr=num2str(firmware)
if mod(firmware,1) ~=0
    firmwarestr=strrep(firmwarestr,'.','_')
end

bitfile=[getuserdir '\panoseti\FPGA\quabo_v00' firmwarestr '\quabo_v00' firmwarestr '.bit']; %%use the same directory delimiter "/" even on Windows syst
mcsfile=[getuserdir '\panoseti\FPGA\quabo_v00' firmwarestr '\quabo_v00' firmwarestr '.mcs'];
impactdir='C:\Xilinx\14.4\LabTools\LabTools\bin\nt';

boxversion=0.1;



%%%%% ask info about the calibration
% quaboSN
quaboSN=input('Enter quabo SN:','s');
quaboSNstr=num2str(str2num(quaboSN),'%03d');
disp(['You decided to calibrate quabo SN' quaboSNstr])

% detector
%%load quabo detector list
if isfile(([getuserdir '\panoseti\Calibrations\' 'CalibrationDB.mat']))
    load(([getuserdir '\panoseti\Calibrations\' 'CalibrationDB.mat']))
else
    quaboDETtable=[]
end

if size(quaboDETtable,1)>0
    inddetrow=find(quaboDETtable(:,1)==str2num(quaboSN));
else
    inddetrow=[];
end
if numel(inddetrow) >0
    ans=input(['Is it still the same detector quadrants (' num2str(quaboDETtable(inddetrow,2:5)) ') installed on the quabo: y[all keys]/n?'],'s')
else
    detQ0=input(['Enter detector Q0:'])
    detQ1=input(['Enter detector Q1:'])
    detQ2=input(['Enter detector Q2:'])
    detQ3=input(['Enter detector Q3:'])
    quaboDETtable=cat(1,quaboDETtable,[str2num(quaboSN) detQ0 detQ1 detQ2 detQ3 firmware zeros(1,8)])
    save([getuserdir '\panoseti\Calibrations\' 'CalibrationDB.mat'],'quaboDETtable')
end

% operator
operator=input('Enter operator:','s');
disp(['******************************'])
disp(['Welcome ' operator '!'])
dateini=now;
datenow=datestr(dateini,'yymmddHHMMSS');

disp('You are going to calibrate:')
disp(['Quabo SN' quaboSNstr])
disp(['  with detector quadrants (' num2str(quaboDETtable(inddetrow,2:end)) ') installed on the quabo.'])
if firmware>0
    disp(['This FPGA firmware bit and mcs files will be installed:'])
    disp(['        '  bitfile])
    disp(['        '  mcsfile])
else
    disp('  No change in FPGA firmware will be done.')
end
disp(['  Operator will be ' operator '.'])
ans=input('Continue? y[any key]/n','s')

%%create report folder
calibdir=[getuserdir '\panoseti\reports\calibboxSN' quaboSNstr '_' datenow '\'];
if ~exist(calibdir,'dir')
    mkdir(calibdir)
end
    
   
  tfpga=0;tph=0;tima=0;tadc=0; 
%%%%% REPROGRAM FPGA

if firmware>0
     tic
    %make a cmd bat file where to insert the bit & mcs files and directory:
    str1='setMode -bs';
    % setMode -bs
    % setMode -bs
    % setMode -bs
    str2='setCable -port auto';
    str3='Identify -inferir';
    str4='identifyMPM';
    str5=['assignFile -p 1 -file "' bitfile '"'];
    str6='attachflash -position 1 -spi "S25FL256S"';
    str7=['assignfiletoattachedflash -position 1 -file "' mcsfile '"'];
    str8='attachflash -position 1 -spi "S25FL256S"';
    str9='Program -p 1 -dataWidth 1';
    str10='Program -p 1 -dataWidth 1 -spionly -e -v -loadfpga';
    str11='quit';
    panoxilibatchfile=[impactdir '/' 'panoxilinkcmd' datenow '.txt'];
    fid= fopen(panoxilibatchfile,'w');
    fprintf(fid, '%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n',...
        str1,str1,str1,str1,str2,str3,str4,str5,str6,str7,str8,str9,str10,str11);
    fclose(fid);
    
    %start Xilink impact
    command1=['cd "' impactdir '"'];
    command2=['impact -batch ' panoxilibatchfile];
           
        if fakefpga==0 
    [status, cmdout] = system([command1 ' & ' command2],'-echo')
    tfpga=toc;
 
            save('debug.mat','cmdout','tfpga')
        else
            load('debug.mat','cmdout', 'tfpga')
        end
     
    ans=input('Did you remove the fpga cable and close the dark box? y[any key]/n','s')
end


%%%generate report
if makereport==1
    import mlreportgen.report.*
    import mlreportgen.dom.*
    rpt = Report([calibdir 'CalibrationSN' quaboSNstr '_' datenow]); %,'html'
    
    tp = TitlePage;
    tp.Title = 'PANOSETI Quabo Calibrations';
    tp.Subtitle =  ['QUABO SN' quaboSNstr ];
    %tp.Author = ['Operator: ' operator];
    tp.Author = [' ' ];
        tp.Publisher = 'UC San Diego';
    tp.Image='C:\Users\jerome\Documents\panoseti\PANOapp\PANOlogo0small.png';
    
    
    add(rpt,tp);
    add(rpt,TableOfContents);
    
    
    
    %ch1 = Chapter;
    %ch1.Title = 'Introduction';
    sec1 = Section;
    sec1.Title = 'Calibration ID';
    

    para = Paragraph(['Calibrated Quabo: SN' quaboSNstr]); add(sec1,para)
    para = Paragraph(['Installed Quadrants: Hamamatsu S13361-3050AE, SN ' num2str(quaboDETtable(inddetrow,2:5)) ', respectively Q0, Q1, Q2, Q3']); add(sec1,para)
    para = Paragraph(['     ']); add(sec1,para)
    txt = Text((['Quadrant physical configuration:']));
    txt.Style={Underline('single')};
    append(para,txt);
    %add(sec1,txt)
    para = Paragraph(['Looking down onto quabo with the detector side of board facing up - as if you were looking down from the module''s lens:']); add(sec1,para)
    para = Paragraph(['                                                                 detector']); para.Style={WhiteSpace('preserve')};add(sec1,para)
    para = Paragraph(['-------------------------------------------------      corner']);  para.Style={WhiteSpace('preserve')};add(sec1,para)
%     para = Paragraph(['Quabo board                Q1      Q0  |   of   ']);  para.Style={WhiteSpace('preserve')};add(sec1,para)
%     para = Paragraph(['                                                           |   board   ']);  para.Style={WhiteSpace('preserve')};add(sec1,para)
%     para = Paragraph(['                                        Q2      Q3  |     ']);   para.Style={WhiteSpace('preserve')};para.Style={WhiteSpace('preserve')};add(sec1,para)
%     para = Paragraph(['                                                          |    ']);  para.Style={WhiteSpace('preserve')};add(sec1,para)
%     para = Paragraph([' which has detectors:   ']); add(sec1,para)
%     para = Paragraph(['                                                              detector']); para.Style={WhiteSpace('preserve')};add(sec1,para)
%     para = Paragraph(['----------------------------------------------      corner']);  para.Style={WhiteSpace('preserve')};add(sec1,para)
    para = Paragraph(['Quabo board      SN' num2str(quaboDETtable(inddetrow,3)) '    SN' num2str(quaboDETtable(inddetrow,2)) '  |   of   ']);  para.Style={WhiteSpace('preserve')};add(sec1,para)
    para = Paragraph(['                                                                |   board   ']);  para.Style={WhiteSpace('preserve')};add(sec1,para)
    para = Paragraph(['                               SN' num2str(quaboDETtable(inddetrow,4)) '    SN' num2str(quaboDETtable(inddetrow,5)) ' |     ']);   para.Style={WhiteSpace('preserve')};para.Style={WhiteSpace('preserve')};add(sec1,para)
    para = Paragraph(['                                                                |    ']);  para.Style={WhiteSpace('preserve')};add(sec1,para)
    para = Paragraph(['Time of calibration: ' datestr(dateini,'yyyy/mm/dd, HH:MM:SS')]); add(sec1,para)
    para = Paragraph(['Calibration Operator: ' operator]); add(sec1,para)
    para = Paragraph(['Calibration box version: ' num2str(boxversion)]); add(sec1,para)
    para = Paragraph(['Calibration box outputs: ']); add(sec1,para)
    output0=ListItem(['Gain adjustment map: 16x16 values, i.e. gain increments scalable to any gain.'])
    output1=ListItem('DAC = A g pe# + B : A, B coeffs for each quadrant, 8 coeffs total, scalable to any gain.')
    output2=ListItem('FAR = 10^(E dac + F) : E, F coeffs for each quadrant, 8 coeffs total.')
    output3=ListItem('FAR = 10^(J pe# + K) : J, K coeffs for each quadrant, 8 coeffs total, deduced from A, B, E and F.')
    output4=ListItem('ADC = C g dac + D : C, D coeffs for each quadrant, 8 coeffs total, scalable to any gain.')
    output5=ListItem('ADC = G pe# + H : G, H coeffs for each quadrant, 8 coeffs total, deduced from A, B, C and D.')
    output0.Style={ListStyleType('lower-greek')}; 
    output1.Style={ListStyleType('lower-greek')}; 
    output2.Style={ListStyleType('lower-greek')}; 
    output3.Style={ListStyleType('lower-greek')}; 
    output4.Style={ListStyleType('lower-greek')}; 
    output5.Style={ListStyleType('lower-greek')}; 
    listout = OrderedList();
    append(listout, output0)
     append(listout, output1)
      append(listout, output2)
       append(listout, output3)
        append(listout, output4)
    append(listout, output5)
    
%     txt = Text((['Quadrant physical configuration:']));
%     txt.Style={Underline('single')};
%    append(para,txt);
%       para = Paragraph(['   ']);  para.Style={WhiteSpace('preserve')};
%       add(sec1,para)
  
   % add(para,listout)
     add(sec1,listout)
    add(rpt,sec1)
    %add(rpt,ch1)
    
    
    sec2 = Section;
    sec2.Title = 'FPGA firmware';
    
    if firmware>0
        para = Paragraph(['The FPGA firmware was updated with:']); add(sec2,para)
        [fol, basefilenm, exte]=fileparts(bitfile) ;
        para = Paragraph([basefilenm exte]); add(sec2,para)
         [fol, basefilenmmcs, extemcs]=fileparts(mcsfile) ;
        para = Paragraph([[basefilenmmcs extemcs]]); add(sec2,para)
        para = Paragraph(['     ']); add(sec2,para)
         sec20 = Section;
        sec20.Title = 'FPGA commands';
        txt = Text((['The following IMPACT commands were used to program the quabo:']));
        txt.Style={Underline('single')};
         para = Paragraph([' ']);append(para,txt); add(sec20,para)
        %para = Paragraph(['using the following IMPACT commands:']); add(sec2,para)
        para = Paragraph(str1); add(sec20,para)
        para = Paragraph(str1); add(sec20,para)
        para = Paragraph(str1); add(sec20,para)
        para = Paragraph(str1); add(sec20,para)
        para = Paragraph(str2); add(sec20,para)
        para = Paragraph(str3); add(sec20,para)
        para = Paragraph(str4); add(sec20,para)
        para = Paragraph(str5); add(sec20,para)
        para = Paragraph(str6); add(sec20,para)
        para = Paragraph(str7); add(sec20,para)
        para = Paragraph(str8); add(sec20,para)
        para = Paragraph(str9); add(sec20,para)
        para = Paragraph(str10); add(sec20,para)
        para = Paragraph(str11); add(sec20,para)
        
        para = Paragraph(['     ']); add(sec20,para)
        add(sec2, sec20);
                 sec21 = Section;
        sec21.Title = 'FPGA log';
        txt = Text((['During reprogramming of the quabo, the firmware log was recorded and is given below to check whether the reprogramming was successful.']));
        txt.Style={Underline('single')};
          para = Paragraph([' ']);append(para,txt); add(sec21,para)
        %para = Paragraph(['Firmware log:']); add(sec2,para)
        
       % newstr=splitlines(cmdout) %para.Style={WhiteSpace('preserve')}
       logm = {Color('black'),FontFamily(),FontSize('10pt'),WhiteSpace('preserve')};
        para = Paragraph([' ']);para.Style=logm;append(para,cmdout); add(sec21,para)
%         para.Style={WhiteSpace('preserve')};
% %         for ii=1:size(newstr,1)
% %             para = Paragraph(cell2mat(newstr(ii)));  add(sec21,para)
% %         end
% para = Paragraph([' ']);
%         for ii=1:size(newstr,1)
%             txt = Text(cell2mat(newstr(ii)));  add(para,txt); add
%         end
                add(sec2, sec21);
    else

        para = Paragraph(['The FPGA firmware was NOT updated.']); add(sec2,para)
        para = Paragraph(['The last FPGA firmware installed wav quabo_v00' num2str(quaboDETtable(inddetrow,6))]); add(sec2,para)
           
        
        end
    add(rpt,sec2)
    
 
else
   % load('report6.mat','rpt')
   % makereport=1
end


quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config.txt']);
disp('Starting HV...')
szq=size(quaboconfig,1);
quaboconfig(szq+1,1)={'IP'};quaboconfig(szq+1,3)={IP};
szq=size(quaboconfig,1);
quaboconfig(szq+1,1)={'QuaboSN'};quaboconfig(szq+1,3)={str2num(quaboSN)};


%%%%%%%% CALIBRATE GAIN pix, PE-DAC
%% start HK recording in parallel, start HV, start HV loop in parallel...
if startguis==1
    system('cd C:\Users\jerome\Documents\panoseti\PANOapp\housekeeping17\for_testing & housekeeping17, 1 &')
    disp('Starting HK...')
    pause(25)
    
    sendHV(quaboconfig)
    
    system(['cd C:\Users\jerome\Documents\panoseti\PANOapp\HVloop14\for_testing & HVloop14 "' IP '" "SN' quaboSNstr '" &'])
    disp('Starting HV loop...')
    pause(10)
end
%%find dac offset


%% start gain adjustment / DAC vs PE, gain
%% make it at 3 different gains for gain interpolation

%% test pixel uniformity

%% start ADC vs DAC

calib_ima


adjustThresh_gains_light_PH_1hz_calibbox

calibmixImaPh

calibADCvsDACPEc

calibHK

%%report
%%close report

close(rpt)
rptview(rpt)







