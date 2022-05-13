function quaboconfig=maskbadpixPH(maskmode,quaboconfig)



load(([getuserdir '\panoseti\Calibrations\' 'CalibrationDB.mat']))
  [ig,indexquabosn]=ismember(['QuaboSN'] ,quaboconfig);
 inddetrow=find(quaboDETtable(:,1)==str2num(cell2mat(quaboconfig(indexquabosn,3))));

load((([getuserdir '\panoseti\Calibrations\' 'badpixmaps.mat'])),'badpix')
load('MarocMap.mat');

badpixels=cell2mat(badpix(inddetrow));

nbbadpix=size(badpixels,1);

if nbbadpix>0
maskcoor=zeros(nbbadpix,2);
for pix=1:nbbadpix
maskcoor(pix,:)=squeeze(marocmap16(badpixels(pix,1),badpixels(pix,2),:));
disp(['Masking bad pixel [ ' num2str(badpixels(pix,1)) ','  num2str(badpixels(pix,2)) ']'])
end

 quaboconfig=changemaskPH(maskmode,maskcoor,quaboconfig);

end
