function quaboconfig=maskbadpix(maskmode,quaboconfig)



load(([getuserdir filesep 'panoseti' filesep 'Calibrations' filesep 'CalibrationDB.mat']))
  [ig,indexquabosn]=ismember(['QuaboSN'] ,quaboconfig);
 inddetrow=find(quaboDETtable(:,1)==str2num(cell2mat(quaboconfig(indexquabosn,3))));

load((([getuserdir filesep 'panoseti' filesep 'Calibrations' filesep 'badpixmaps.mat'])),'badpix')
load('MarocMap.mat');

badpixels=cell2mat(badpix(inddetrow));

nbbadpix=size(badpixels,1);

if nbbadpix>0
maskcoor=zeros(nbbadpix,2);
for pix=1:nbbadpix
maskcoor(pix,:)=squeeze(marocmap16(badpixels(pix,1),badpixels(pix,2),:));
disp(['Masking bad pixel [ ' num2str(badpixels(pix,1)) ','  num2str(badpixels(pix,2)) ']'])
end
allcoor=zeros(256,2);
allcoor(1:64,1)=1:64;allcoor(1:64,2)=1;
allcoor(64+(1:64),1)=1:64;allcoor(64+(1:64),2)=2;
allcoor(2*64+(1:64),1)=1:64;allcoor(2*64+(1:64),2)=3;
allcoor(3*64+(1:64),1)=1:64;allcoor(3*64+(1:64),2)=4;

[ia,ib] = ismember(allcoor,maskcoor,'rows');
indtomask=find(ia==1);
allcoor(indtomask,:)=[];
%maskallexceptedcoor!
 quaboconfig=changemask(maskmode,allcoor,quaboconfig);

end
