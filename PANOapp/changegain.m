function quaboconfig=changegain(gain,quaboconfig,map)
indcol=1:4;
load('MarocMap.mat');
  if map==0
    for pp=0:63
        [ig,indexgain]=ismember(['GAIN' num2str(pp)] ,quaboconfig);
        quaboconfig(indexgain,indcol+1)={['0x' dec2hex(gain)]};
    end
    disp(['Sending Maroc comm...Gain on all pix:' num2str(gain)])
  else
    %load(['gainmap_gain' num2str(gain) '.mat'])
    %argh needs first the indice of the quabo...
    load(([getuserdir filesep 'panoseti' filesep 'Calibrations' filesep 'CalibrationDB.mat']))
    [ig,indexquabosn]=ismember(['QuaboSN'] ,quaboconfig);
    inddetrow=find(quaboDETtable(:,1)==str2num(cell2mat(quaboconfig(indexquabosn,3))));
    %load([getuserdir '\panoseti\Calibrations\' 'gainmap_mean_.mat'])
    %quaboconfig_gain=gain+gainmapallgmeanSN(:,:,inddetrow);
    load([getuserdir filesep 'panoseti' filesep 'Calibrations' filesep 'gainmap_inc.mat'])
    quaboconfig_gain=gain+(gain)*gainmapallgmeanSN(:,:,inddetrow);
    disp(['Loading gainma'])
    outliersind=find(quaboconfig_gain>255);
    if numel(outliersind)>0
        disp('*** CAREFUL: some requested gain values are out-of-range: limiting to 255. *****')
        quaboconfig_gain(outliersind)=255;
    end
        outliersindn=find(quaboconfig_gain<0);
    if numel(outliersindn)>0
        disp('*** CAREFUL: some requested gain values are out-of-range: limiting to 0. *****')
        quaboconfig_gain(outliersindn)=0;
    end
    indcol=1:4;
    for pp=0:63
        %[ig,indexgainmap]=ismember(['GAIN' num2str(pp)] ,quaboconfig_gain);
        [ig,indexgain]=ismember(['GAIN' num2str(pp)] ,quaboconfig);
        % quaboconfig(indexgain,indcol+1)=quaboconfig_gain(indexgainmap,indcol+1);
        quaboconfig(indexgain,1+1)={['0x' dec2hex(round(quaboconfig_gain(marocmap(pp+1,1,1),marocmap(pp+1,1,2))))]};
        quaboconfig(indexgain,2+1)={['0x' dec2hex(round(quaboconfig_gain(marocmap(pp+1,2,1),marocmap(pp+1,2,2))))]};
        quaboconfig(indexgain,3+1)={['0x' dec2hex(round(quaboconfig_gain(marocmap(pp+1,3,1),marocmap(pp+1,3,2))))]};
        quaboconfig(indexgain,4+1)={['0x' dec2hex(round(quaboconfig_gain(marocmap(pp+1,4,1),marocmap(pp+1,4,2))))]};
    end
    disp(['Sending Maroc comm...Gain adjusted map for gain:' num2str(gain)])
  end
    disp(['Sending Maroc comm...Gain on all pix:' num2str(gain)])
    sendconfig2Maroc(quaboconfig)