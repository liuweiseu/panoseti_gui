import mlreportgen.report.*
import mlreportgen.dom.*
datenow1='191013150713'
loopgaincnt1=13;
filenmnehk='C:\Users\jerome\Documents\panoseti\reports\calibboxSN009_191013150449\HK_SN009_191013231645'
dateini=now;
datenow=datestr(dateini,'yymmddHHMMSS');
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


%else
% load('report6.mat','rpt')
% makereport=1
% end



%%%%%%%%%%%%%%%%%%%%%%CALIB IMA
if makereport==1
    import mlreportgen.report.*
    import mlreportgen.dom.*
    sec3 = Section;
    sec3.Title = 'Gain calibration';
    logm12 = {Color('black'),FontFamily(),FontSize('12pt'),WhiteSpace('preserve')};
    
    para = Paragraph(['In this section, the gain between pixels are adjusted ' ...
        'such as the pe steps between pixels get aligned. The procedure starts with ' ...
        'the same initial gain value on all pixels. Pe steps  are detected on each ' ...
        'pixel cps curve as a function of their DAC values. The 2-pe step location of each tested pixel is compared to the reference pixel 2-pe step location to determine if the gain ' ...
        'on that pixel should be incremented or decremented.']);para.Style=logm12; add(sec3,para)
    para = Paragraph(['This section shows initial cps curves before gain adjustment' ...
        '(same Maroc gain value on each pixel) and final adjusted cps curves. ' ...
        '']); para.Style=logm12; add(sec3,para)
    
    secB = Section;
    secB.Title = ['DAC vs PE relationship'];
end

%%%in the loop
for igg=1:numel(gaintaballg)
    pausetime=1.;
    indcol=1:4;
    %set gain
    gaintab=gaintaballg(igg);%33;
    if makereport==1
        %         import mlreportgen.report.*
        %         import mlreportgen.dom.*
        %         sec3 = Section;
        
        sec3a = Section;
        sec3a.Title = ['Gain adjustment. Gain initial:' num2str(gaintab)];
        %add cps curves (ini):
        para=Paragraph('Dark frames were recorded in imaging mode to measure cps curves on eack pixel (no mask). '); para.Style=logm12;
        add(sec3a,para);
        para=Paragraph(['Without gain adjustment, i.e. using the same Maroc gain value  on each pixel (initial gains were set to ' num2str(gaintab) '), initial cps curves shows some pixel-to-pixel variations of pe steps locations:']);
        para.Style=logm12;add(sec3a,para);
        
        plot1=Image([calibdir 'cpsadjustGain' num2str(gaintab) '_' datenow1 '_' num2str(1) '.png']);
        widthch=plot1.Width;
        widthima=str2num(widthch(1:strfind(widthch,'px')-1));
        heightch=plot1.Height;
        heightima=str2num(heightch(1:strfind(heightch,'px')-1));
        plot1.Width='600px';
        plot1.Height=[ num2str(floor(600/widthima*heightima)) 'px'];
        add(sec3a,plot1);
        %add cps final
        add(sec3a,Paragraph(['After ' num2str(loopgaincnt) ' iterations of gain adjustment (with initial gains set to ' num2str(gaintab) '), final cps curves are represented in the following figure. ']));
        plot1=Image([calibdir  'cpsadjustGain' num2str(gaintab) '_' datenow1 '_' num2str(loopgaincnt1) '.png']);
        widthch=plot1.Width;
        widthima=str2num(widthch(1:strfind(widthch,'px')-1));
        heightch=plot1.Height;
        heightima=str2num(heightch(1:strfind(heightch,'px')-1));
        plot1.Width='600px';
        plot1.Height=[ num2str(floor(600/widthima*heightima)) 'px'];
        add(sec3a,plot1);
        add(sec3a,Paragraph(['If the gain adjustment routine worked properly, the dispersion in pe step locations between pixels should be smaller than the initial one.']));
        
        %Ima ini/finale
        add(sec3a,Paragraph(['A comparison of the initial and final frames in imaging mode (darks at 2.5pe) is given by the next two figures before and after gain adjustment. The pixel intensities in the second figure should be more uniform spatially over all pixels.']));
        imgStyle = {ScaleToFit(true)};
        img1 = Image([calibdir 'ImaGain' num2str(gaintab) '_' num2str(1) '_' datenow1 '.png']);
        img1.Style = imgStyle;
        img2 = Image([calibdir 'ImaGain' num2str(gaintab) '_' num2str(loopgaincnt1) '_' datenow1 '.png']);
        img2.Style = imgStyle;
        %Insert images in the row of a 1x3, invisible layout table (lot).
        
        lot = Table({img1, ' ', img2});
        %The images will be sized to fit the table entries only if their height and width is specified.
        
        lot.entry(1,1).Style = {Width('3.2in'), Height('3in')};
        lot.entry(1,2).Style = {Width('.2in'), Height('3in')};
        lot.entry(1,3).Style = {Width('3.2in'), Height('3in')};
        %Make the table span the width of the page between the margins. Tell the table layout manager to not resize the table columns to fit the images.
        
        lot.Style = {ResizeToFitContents(false), Width('100%')};
        %Generate and display the report.
        
        add(sec3a, lot);
        %         add(sec3a,Paragraph(['Image at ' num2str(peval) 'pe without gain adjustment (all gains set to ' num2str(gaintab) ', imaging mode):']));
        %         plot1=Image([calibdir 'ImaGain' num2str(gaintab) '_' num2str(1) '_' datenow1 '.png']);
        %         widthch=plot1.Width;
        %         widthima=str2num(widthch(1:strfind(widthch,'px')-1));
        %         heightch=plot1.Height;
        %         heightima=str2num(heightch(1:strfind(heightch,'px')-1));
        %         plot1.Width='350px';
        %         plot1.Height=[ num2str(floor(350/widthima*heightima)) 'px'];
        %         add(sec3a,plot1);
        %         add(sec3a,Paragraph(['Image at ' num2str(peval) 'pe after ' num2str(loopgaincnt) ' iterations of gain adjustment (initial gains set to ' num2str(gaintab) '):']));
        %         plot1=Image([calibdir 'ImaGain' num2str(gaintab) '_' num2str(loopgaincnt) '_' datenow1 '.png']);
        %         widthch=plot1.Width;
        %         widthima=str2num(widthch(1:strfind(widthch,'px')-1));
        %         heightch=plot1.Height;
        %         heightima=str2num(heightch(1:strfind(heightch,'px')-1));
        %         plot1.Width='350px';
        %         plot1.Height=[ num2str(floor(350/widthima*heightima)) 'px'];
        %         add(sec3a,plot1);
        %
        %save hist ini/fin
        add(sec3a,Paragraph(['A comparison of the initial and final histograms of pixel intensities in imaging mode at 2.5pe is given by the next two figures before and after gain adjustment. The pixel intensity distribution in the second figure should be narrower than the first one.']));
        imgStyle = {ScaleToFit(true)};
        img1 = Image([calibdir 'FinalHistImaGain' num2str(gaintab) '_' num2str(1) '_' datenow1 '.png']);
        img1.Style = imgStyle;
        img2=Image([calibdir 'FinalHistImaGain' num2str(gaintab) '_' num2str(loopgaincnt1) '_' datenow1 '.png']);
        img2.Style = imgStyle;
        %Insert images in the row of a 1x3, invisible layout table (lot).
        
        lot = Table({img1, ' ', img2});
        %The images will be sized to fit the table entries only if their height and width is specified.
        
        lot.entry(1,1).Style = {Width('3.2in'), Height('3in')};
        lot.entry(1,2).Style = {Width('.2in'), Height('3in')};
        lot.entry(1,3).Style = {Width('3.2in'), Height('3in')};
        %Make the table span the width of the page between the margins. Tell the table layout manager to not resize the table columns to fit the images.
        
        lot.Style = {ResizeToFitContents(false), Width('100%')};
        %Generate and display the report.
        
        add(sec3a, lot);
        %         add(sec3a,Paragraph(['Histogram of pixel values at ' num2str(peval) 'pe without gain adjustment (all gains set to ' num2str(gaintab) ', imaging mode):']));
        %         plot1=Image([calibdir 'FinalHistImaGain' num2str(gaintab) '_' num2str(1) '_' datenow1 '.png']);
        %         widthch=plot1.Width;
        %         widthima=str2num(widthch(1:strfind(widthch,'px')-1));
        %         heightch=plot1.Height;
        %         heightima=str2num(heightch(1:strfind(heightch,'px')-1));
        %         plot1.Width='450px';
        %         plot1.Height=[ num2str(floor(450/widthima*heightima)) 'px'];
        %         add(sec3a,plot1);
        %         add(sec3a,Paragraph(['Histogram of pixel values at ' num2str(peval) 'pe after ' num2str(loopgaincnt) ' iterations of gain adjustment (initial gains set to ' num2str(gaintab) '):']));
        %         plot1=Image([calibdir 'FinalHistImaGain' num2str(gaintab) '_' num2str(loopgaincnt) '_' datenow1 '.png']);
        %         widthch=plot1.Width;
        %         widthima=str2num(widthch(1:strfind(widthch,'px')-1));
        %         heightch=plot1.Height;
        %         heightima=str2num(heightch(1:strfind(heightch,'px')-1));
        %         plot1.Width='450px';
        %         plot1.Height=[ num2str(floor(450/widthima*heightima)) 'px'];
        %         add(sec3a,plot1);
        
        %add gain map final
        add(sec3a,Paragraph([' Final gain map after ' num2str(loopgaincnt) ' iterations of gain adjustment (initial gains set to ' num2str(gaintab) '):']));
        plot1=Image([calibdir 'Gain' num2str(gaintab) 'map_' num2str(loopgaincnt1) '_' datenow1 '.png']);
        widthch=plot1.Width;
        widthima=str2num(widthch(1:strfind(widthch,'px')-1));
        heightch=plot1.Height;
        heightima=str2num(heightch(1:strfind(heightch,'px')-1));
        plot1.Width='350px';
        plot1.Height=[ num2str(floor(350/widthima*heightima)) 'px'];
        add(sec3a,plot1);
        %residus final
        add(sec3a,Paragraph(['To stop automatically the gain adjustment iterations, the residual is calculated as  the sum of squared differences ' ...
            'of counts between  pixels and the reference one at 2-pe. ' ...
            ' Iterations are stopped when the residual (next figure) does not decrease anymore.']));
        
        add(sec3a,Paragraph(['The following figure shows the residual at ' num2str(peval) 'pe after ' num2str(loopgaincnt) ' iterations of gain adjustment (initial gains set to ' num2str(gaintab) '):']));
        plot1=Image([calibdir 'ResiduImaGain' num2str(gaintab) '_' num2str(loopgaincnt1) '_' datenow1 '.png']);
        widthch=plot1.Width;
        widthima=str2num(widthch(1:strfind(widthch,'px')-1));
        heightch=plot1.Height;
        heightima=str2num(heightch(1:strfind(heightch,'px')-1));
        plot1.Width='500px';
        plot1.Height=[ num2str(floor(500/widthima*heightima)) 'px'];
        add(sec3a,plot1);
        add(sec3,sec3a);
        
        
    end
    
    
end

%%second loop

if makereport==1
    
    
    for ig=1:numel(gaintaballg)
        %add cps curves (finales):
        secB1 = Section;
        secB1.Title = ['PE step detection (Gain initial ' num2str(gaintaballg(ig)) ')'];
        add(secB1,Paragraph(['To deduce the DAC vs pe# relationship for each quadrant, dark acquisitions were recorded and pe steps detected.']));
        
        add(secB1,Paragraph(['To detect pe step locations (as a function of DAC), we used final cps curves after ' num2str(loopgaincnt) ' iterations of gain adjustment (initial gains set to ' num2str(gaintaballg(ig)) ') as shown in the previous section.']));
        %         plot1=Image(cell2mat(cpsfinalfigcell(ig)));
        %         widthch=plot1.Width;
        %         widthima=str2num(widthch(1:strfind(widthch,'px')-1));
        %         heightch=plot1.Height;
        %         heightima=str2num(heightch(1:strfind(heightch,'px')-1));
        %         plot1.Width='650px';
        %         plot1.Height=[ num2str(floor(650/widthima*heightima)) 'px'];
        %         add(secB1,plot1);
        %
        %%add pe step figures
        add(secB1,Paragraph(['To detect pe steps, the cps derivative over DAC is calculated and divided by cps(dac) to give more weight to low cps values at high DAC. Then, a peak detection is performed on the derivative to determine pe step locations. The following figures are showing the chosen cps curves as well as their derivatives and detected peaks. ']));
        
        for qq=1:4
            filenm=cell2mat(pestepfigcell(ig,qq))
            add(secB1,Paragraph(['The following figure shows the pe-step detection on quadrant ' num2str(qq-1) ' (initial gains set to ' num2str(gaintaballg(ig)) '):']));
            plot1=Image(filenm);
            widthch=plot1.Width;
            widthima=str2num(widthch(1:strfind(widthch,'px')-1));
            heightch=plot1.Height;
            heightima=str2num(heightch(1:strfind(heightch,'px')-1));
            plot1.Width='500px';
            plot1.Height=[ num2str(floor(500/widthima*heightima)) 'px'];
            add(secB1,plot1);
            
            
        end
        add(secB,secB1);
    end
end

sec3c = Section;
sec3c.Title = ['Gain adjusment map'];
add(sec3c,Paragraph(['It could be shown from the gain adjustment maps above that the adjusted-gain map difference  (adjusted-gain map - initial gain g) scales with the initial gain g such that ' ]));
add(sec3c,Paragraph([' Adjusted_Gain_map(g) = g (1 + G) ' ]));

add(sec3c,Paragraph([' where G is a 16x16 matrix deduced from the previous equation and recorded for adjusting the detector array to any gain value.']));
add(sec3c,Paragraph(['For sanity check, the ratio of gain map differences at initial gains of 40 and 60 is represented in the following figure and should be equal or close to 60/40 = 1.5 on each pixel.' ]));
% 'the gain map difference is divided by the initial gain before being recorded.']));
add(sec3c,Paragraph(['The following figure shows the ratio of (gain map - gain initial) at gains of ' num2str(gaintaballg(2)) ' and ' num2str(gaintaballg(1))]));
plot1=Image([calibdir 'RatioGain' 'map_'  datenow1 '.png']);
widthch=plot1.Width;
widthima=str2num(widthch(1:strfind(widthch,'px')-1));
heightch=plot1.Height;
heightima=str2num(heightch(1:strfind(heightch,'px')-1));
plot1.Width='450px';
plot1.Height=[ num2str(floor(450/widthima*heightima)) 'px'];
add(sec3c,plot1);
add(sec3,sec3c);

%%add DAC vs pe coeffs table
secB2 = Section;

secB2.Title = ['DAC = A gain pe# + B (Imaging mode only)'];
add(secB2,Paragraph(['From all these previous measurements in imaging mode (dark), we can deduce an initial set of A and B coefficients that will be refined with PH mode measurements in the following sections.']));

tableDACvsPE=BaseTable({['Gain ini'] ['A Q0'] ...
    ['B Q0' ] ...
    ['A Q1' ] ...
    ['B Q1' ] ...
    ['A Q2' ] ...
    ['B Q2'] ...
    ['A Q3'] ...
    ['B Q3'] ...
    ; ...
    [num2str(gaintaballg(1))] ...
    [num2str(coeffsallg(1,2)/coeffsallg(1,1))] ...
    [num2str(coeffsallg(1,6))] ...
    [num2str(coeffsallg(1,3)/coeffsallg(1,1))] ...
    [num2str(coeffsallg(1,7))] ...
    [num2str(coeffsallg(1,4)/coeffsallg(1,1))] ...
    [num2str(coeffsallg(1,8))] ...
    [num2str(coeffsallg(1,5)/coeffsallg(1,1))] ...
    [num2str(coeffsallg(1,9))] ...
    ; ...
    [num2str(gaintaballg(2))] ...
    [num2str(coeffsallg(2,2)/coeffsallg(2,1))] ...
    [num2str(coeffsallg(2,6))] ...
    [num2str(coeffsallg(2,3)/coeffsallg(2,1))] ...
    [num2str(coeffsallg(2,7))] ...
    [num2str(coeffsallg(2,4)/coeffsallg(2,1))] ...
    [num2str(coeffsallg(2,8))] ...
    [num2str(coeffsallg(2,5)/coeffsallg(2,1))] ...
    [num2str(coeffsallg(2,9))] ...
    ; ...
    ['Mean'] ...
    [num2str(quaboDETtable(inddetrow,7))] ...
    [num2str(quaboDETtable(inddetrow,11))] ...
    [num2str(quaboDETtable(inddetrow,8))] ...
    [num2str(quaboDETtable(inddetrow,12))] ...
    [num2str(quaboDETtable(inddetrow,9))] ...
    [num2str(quaboDETtable(inddetrow,13))] ...
    [num2str(quaboDETtable(inddetrow,10))] ...
    [num2str(quaboDETtable(inddetrow,14))] ...
    });
add(secB2,tableDACvsPE);



if makereport==1
    
    add(rpt,sec3);
    %keep secB for next routine
    %   add(rpt,secB);
    
    %  add(rpt,secD);
    %     sec4 = Section;
    %     sec4.Title = 'DAC vs ADC calibration';
end



%%%%%%%%

calibmixImaPh

%%%%%%%%
%%
%%ADC

%makereport=
if makereport ==1

    sec4 = Section;
    sec4.Title = 'ADC vs PE relationship';
end


for  gainkk=1:numel(gaintabtab)
    gaintab=gaintabtab(gainkk);
    
    if makereport==1
        sec40 = Section;
        sec40.Title = ['Gain ini:' num2str(gaintab)];
    end
    
    
    
    for mx=3:3 %64
        
        
        % makereport=0
        if makereport==1
            
            %   sec41 = Section;
            %  sec41.Title = ['Quadrant ' num2str(my)];
            
            add(sec40,Paragraph(['The following figures sgows ADC vs DAC and fitted curve (darks, all pixelmasked excepted-one) at an initial gain of '  num2str(gaintab(1)) ' for Q0.Q1,Q2,Q3:' ]));
            %    plot1=Image(filenmadcvsdac);
            
            
            imgStyle = {ScaleToFit(true)};
            img1 = Image(cell2mat(filenmadcvsdacQ(gainkk,1)));
            img1.Style = imgStyle;
            img2=Image(cell2mat(filenmadcvsdacQ(gainkk,2)));
            img2.Style = imgStyle;
            img3 = Image(cell2mat(filenmadcvsdacQ(gainkk,3)));
            img3.Style = imgStyle;
            img4=Image(cell2mat(filenmadcvsdacQ(gainkk,4)));
            img4.Style = imgStyle;
            %Insert images in the row of a 1x3, invisible layout table (lot).
            
            lot = Table({img1, ' ', img2; img3, ' ', img4});
            %The images will be sized to fit the table entries only if their height and width is specified.
            
            lot.entry(1,1).Style = {Width('3.2in'), Height('3in')};
            lot.entry(1,2).Style = {Width('.2in'), Height('3in')};
            lot.entry(1,3).Style = {Width('3.2in'), Height('3in')};
            lot.entry(2,1).Style = {Width('3.2in'), Height('3in')};
            lot.entry(2,2).Style = {Width('.2in'), Height('3in')};
            lot.entry(2,3).Style = {Width('3.2in'), Height('3in')};
            %Make the table span the width of the page between the margins. Tell the table layout manager to not resize the table columns to fit the images.
            
            lot.Style = {ResizeToFitContents(false), Width('100%')};
            %Generate and display the report.
            
            add(sec40, lot);
            
            
            %                 widthch=plot1.Width;
            %                 widthima=str2num(widthch(1:strfind(widthch,'px')-1));
            %                 heightch=plot1.Height;
            %                 heightima=str2num(heightch(1:strfind(heightch,'px')-1));
            %                 plot1.Width='450px';
            %                 plot1.Height=[ num2str(floor(450/widthima*heightima)) 'px'];
            %                 add(sec41,plot1);
            
            add(sec40,Paragraph(['For sanity check, the following figures represent the mean and std deviation of pixel intensities over ' num2str(nbimperdac) ' frames at a given DAC (PH mode, darks, Initial Gain: '  num2str(gaintab(1)) ') for Q0,Q1,Q2,Q3. ' ]));
            %  plot1=Image(filenmmeanstd);
            
            imgStyle = {ScaleToFit(true)};
            img1 = Image(cell2mat(filenmmeanstdQ(gainkk,1)));
            img1.Style = imgStyle;
            img2=Image(cell2mat(filenmmeanstdQ(gainkk,2)));
            img2.Style = imgStyle;
            img3 = Image(cell2mat(filenmmeanstdQ(gainkk,3)));
            img3.Style = imgStyle;
            img4=Image(cell2mat(filenmmeanstdQ(gainkk,4)));
            img4.Style = imgStyle;
            %Insert images in the row of a 1x3, invisible layout table (lot).
            
            lot = Table({img1, ' ', img2; img3, ' ', img4});
            %The images will be sized to fit the table entries only if their height and width is specified.
            
            lot.entry(1,1).Style = {Width('3.2in'), Height('1.5in')};
            lot.entry(1,2).Style = {Width('.2in'), Height('1.5in')};
            lot.entry(1,3).Style = {Width('3.2in'), Height('1.5in')};
            lot.entry(2,1).Style = {Width('3.2in'), Height('1.5in')};
            lot.entry(2,2).Style = {Width('.2in'), Height('1.5in')};
            lot.entry(2,3).Style = {Width('3.2in'), Height('1.5in')};
            %Make the table span the width of the page between the margins. Tell the table layout manager to not resize the table columns to fit the images.
            
            lot.Style = {ResizeToFitContents(false), Width('100%')};
            %Generate and display the report.
            
            add(sec40, lot);
            
            
            %                 widthch=plot1.Width;
            %                 widthima=str2num(widthch(1:strfind(widthch,'px')-1));
            %                 heightch=plot1.Height;
            %                 heightima=str2num(heightch(1:strfind(heightch,'px')-1));
            %                 plot1.Width='400px';
            %                 plot1.Height=[ num2str(floor(450/widthima*heightima)) 'px'];
            %                 add(sec41,plot1);
            
            add(sec40,Paragraph(['Another sanity check, the following figures shows the mean and median of frame intensities vs time at a given DAC at an initial gain of '  num2str(gaintab(1)) ') for Q0,Q1,Q2,Q3 :' ]));
            %plot1=Image(filenmmeanmed);
            imgStyle = {ScaleToFit(true)};
            img1 = Image(cell2mat(filenmmeanmedQ(gainkk,1)));
            img1.Style = imgStyle;
            img2=Image(cell2mat(filenmmeanmedQ(gainkk,2)));
            img2.Style = imgStyle;
            img3 = Image(cell2mat(filenmmeanmedQ(gainkk,3)));
            img3.Style = imgStyle;
            img4=Image(cell2mat(filenmmeanmedQ(gainkk,4)));
            img4.Style = imgStyle;
            %Insert images in the row of a 1x3, invisible layout table (lot).
            
            lot = Table({img1, ' ', img2; img3, ' ', img4});
            %The images will be sized to fit the table entries only if their height and width is specified.
            
            lot.entry(1,1).Style = {Width('3.2in'), Height('3in')};
            lot.entry(1,2).Style = {Width('.2in'), Height('3in')};
            lot.entry(1,3).Style = {Width('3.2in'), Height('3in')};
            lot.entry(2,1).Style = {Width('3.2in'), Height('3in')};
            lot.entry(2,2).Style = {Width('.2in'), Height('3in')};
            lot.entry(2,3).Style = {Width('3.2in'), Height('3in')};
            %Make the table span the width of the page between the margins. Tell the table layout manager to not resize the table columns to fit the images.
            
            lot.Style = {ResizeToFitContents(false), Width('100%')};
            %Generate and display the report.
            
            add(sec40, lot);
            %                 widthch=plot1.Width;
            %                 widthima=str2num(widthch(1:strfind(widthch,'px')-1));
            %                 heightch=plot1.Height;
            %                 heightima=str2num(heightch(1:strfind(heightch,'px')-1));
            %                 plot1.Width='400px';
            %                 plot1.Height=[ num2str(floor(450/widthima*heightima)) 'px'];
            %                 add(sec41,plot1);
            
            
            
            add(sec4,sec40);
            
            %  add(sec40,sec41);
            %  add(sec4,sec42);
            
            
        end
        
        
        
    end
    
end


%%add DAC vs pe coeffs table
sec42 = Section;
sec42.Title = ['ADC = G pe# + H'];
add(sec42,Paragraph(['Coefficients of the linear function ADC = C DAC + D and ADC = G pe# + H are given in the following table.' ]));
add(sec42,Paragraph(['C, D coefficients are deduced from PH-mode dark ADC data using a specific pixel on each quadrant.' ]));
add(sec42,Paragraph(['G, H coefficients are deduced from A,B,C,D coeffcients such as' ]));
add(sec42,Paragraph(['G = A C g' ]));
add(sec42,Paragraph(['and' ]));
add(sec42,Paragraph(['H = BC + D' ]));
add(sec42,Paragraph(['For the relationship to be scalable to any gain, the coefficient G'' is recorded as' ]));
add(sec42,Paragraph(['G'' = A C' ]));

add(sec42,Paragraph(['The following table gives E, F, J, K coefficients for Quandrants#0,1,2,3.']));
tableStyle = ...
    { ...
    Width("100%"), ...
    Border("solid"), ...
    RowSep("solid"), ...
    ColSep("solid") ...
    };

tableEntriesStyle = ...
    { ...
    HAlign("center"), ...
    VAlign("middle") ...
    };

headerRowStyle = ...
    { ...
    InnerMargin("2pt","2pt","2pt","2pt"), ...
    BackgroundColor("gray"), ...
    Bold(true) ...
    };
grps(1) = TableColSpecGroup;
grps(1).Span = 11;

%specs=[];
specs2(1) = TableColSpec;
specs2(1).Span = 1;
specs2(1).Style = {Width("8%")};

specs2(2) = TableColSpec;
specs2(2).Span = 1;
specs2(2).Style = {Width("12%")};

specs2(3) = TableColSpec;
specs2(3).Span = 1;
specs2(3).Style = {Width("16%")};

specs2(4) = TableColSpec;
specs2(4).Span = 1;
specs2(4).Style = {Width("16%")};

specs2(5) = TableColSpec;
specs2(5).Span = 1;
specs2(5).Style = {Width("16%")};

specs2(6) = TableColSpec;
specs2(6).Span = 1;
specs2(6).Style = {Width("16%")};

specs2(7) = TableColSpec;
specs2(7).Span = 1;
specs2(7).Style = {Width("16%")};


grps(1).ColSpecs = specs2;
headerContent = ...
    { ...
    ' ', ['Gain ini'], ['C'], ['D' ], ['G'], ['G'''], ['H'] ...
    };

bodyContent = ...
    { ...
    'Q0', [num2str( gaintabtab(1))], ...
    [num2str( ADCDACtabQ(1,1,1))], ...
    [num2str( ADCDACtabQ(1,1,2))], ...
    [num2str( ADCDACtabQ(1,1,3))], ...
    [num2str( ADCDACtabQ(1,1,3)/gaintabtab(1))], ...
    [num2str( ADCDACtabQ(1,1,4))] ...
    ; ...
    'Q0', [num2str( gaintabtab(2))], ...
    [num2str( ADCDACtabQ(2,1,1))], ...
    [num2str( ADCDACtabQ(2,1,2))], ...
    [num2str( ADCDACtabQ(2,1,3))], ...
    [num2str( ADCDACtabQ(2,1,3)/gaintabtab(2))], ...
    [num2str( ADCDACtabQ(2,1,4))] ...
    ; ...
    'Q1', [num2str(  gaintabtab(1))], ...
    [num2str( ADCDACtabQ(1,2,1))], ...
    [num2str( ADCDACtabQ(1,2,2))], ...
    [num2str( ADCDACtabQ(1,2,3))], ...
    [num2str( ADCDACtabQ(1,2,3)/gaintabtab(1))], ...
    [num2str( ADCDACtabQ(1,2,4))] ...
    ; ...
    'Q1', [num2str(  gaintabtab(2))], ...
    [num2str( ADCDACtabQ(2,2,1))], ...
    [num2str( ADCDACtabQ(2,2,2))], ...
    [num2str( ADCDACtabQ(2,2,3))], ...
    [num2str( ADCDACtabQ(2,2,3)/gaintabtab(2))], ...
    [num2str( ADCDACtabQ(2,2,4))] ...
    ; ...
    'Q2', [num2str(  gaintabtab(1))], ...
    [num2str( ADCDACtabQ(1,3,1))], ...
    [num2str( ADCDACtabQ(1,3,2))], ...
    [num2str( ADCDACtabQ(1,3,3))], ...
    [num2str( ADCDACtabQ(1,3,3)/gaintabtab(1))], ...
    [num2str( ADCDACtabQ(1,3,4))] ...
    ; ...
    'Q2', [num2str(  gaintabtab(2))], ...
    [num2str( ADCDACtabQ(2,3,1))], ...
    [num2str( ADCDACtabQ(2,3,2))], ...
    [num2str( ADCDACtabQ(2,3,3))], ...
    [num2str( ADCDACtabQ(2,3,3)/gaintabtab(2))], ...
    [num2str( ADCDACtabQ(2,3,4))] ...
    ; ...
    'Q3', [num2str(  gaintabtab(1))], ...
    [num2str( ADCDACtabQ(1,4,1))], ...
    [num2str( ADCDACtabQ(1,4,2))], ...
    [num2str( ADCDACtabQ(1,4,3))], ...
    [num2str( ADCDACtabQ(1,4,3)/gaintabtab(1))], ...
    [num2str( ADCDACtabQ(1,4,4))] ...
    ; ...
    'Q3', [num2str(  gaintabtab(2))], ...
    [num2str( ADCDACtabQ(2,4,1))], ...
    [num2str( ADCDACtabQ(2,4,2))], ...
    [num2str( ADCDACtabQ(2,4,3))], ...
    [num2str( ADCDACtabQ(2,4,3)/gaintabtab(2))], ...
    [num2str( ADCDACtabQ(2,4,4))] ...
    };
tableContent = [headerContent; bodyContent];

table = Table(tableContent);
table.ColSpecGroups = grps;

table.Style = tableStyle;
table.TableEntriesStyle = tableEntriesStyle;

firstRow = table.Children(1);
firstRow.Style = headerRowStyle;

add(sec42,table);

%                 tableADCvsDAC=BaseTable({' ' ['Gain ini'] ['C'] ['D' ] ['G'] ['G'''] ['H'] ...
%                     ; ...
%
%                     });
%                 add(sec42,tableADCvsDAC);
add(sec4,sec42);




if makereport==1
    
    add(rpt,sec4);
    %  sec4 = Section;
end

if makereport==1

    sec7 = Section;
    sec7.Title = ['HK during calibrations'];
    add(sec7,Paragraph([' Quabo SN' quaboSNstr ', started ' datestr(hktimecomp(1),'yyyy-mm-dd HH:MM') ]));
    plot1=Image([filenmnehk '.png']);
    widthch=plot1.Width;
    widthima=str2num(widthch(1:strfind(widthch,'px')-1));
    heightch=plot1.Height;
    heightima=str2num(heightch(1:strfind(heightch,'px')-1));
    plot1.Width='600px';
    plot1.Height=[ num2str(floor(600/widthima*heightima)) 'px'];
    add(sec7,plot1);
    add(sec7,Paragraph(['Duration of FPGA upgrade: ' addcoma(round(tfpga)) ' sec' ]));
    add(sec7,Paragraph(['Duration of Imaging-mode acquisitions (darks): ' addcoma(round(tima)) ' sec']));
    add(sec7,Paragraph(['Duration of PH-mode (counting) acquisitions (darks): ' addcoma(round(tph)) ' sec']));
    add(sec7,Paragraph(['Duration of PH-mode ADC acquisitions: ' addcoma(round(tadc)) ' sec']));
    add(sec7,Paragraph(['Total elapsed time: ' addcoma(round(ttot)) ' sec']));
    add(rpt,sec7)
end


close(rpt)
rptview(rpt)

