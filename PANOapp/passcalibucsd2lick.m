quaboDETtable(13,:) =   1.0e+03 * [0.0190    1.0760    1.0750    1.0740    1.0770    0.0100    0.0002    0.0002    0.0002    0.0002    0.2030    0.1870    0.1930    0.1970];

quaboDETtable(3,:)=1.0e+03 * [0.0080    1.0760    1.0750    1.0740    1.0770         0    0.0002    0.0002    0.0002    0.0002    0.1800    0.1910    0.1900    0.1900];

quaboDETtable(15,:)=1.0e+03 * [0.0110    1.2630    1.2640    1.2660    1.2650    0.0100    0.0002    0.0002    0.0002    0.0002    0.1960    0.1960    0.1960    0.2030];

quaboDETtable(4,:) =1.0e+03 * [0.0050    1.0840    1.0780    1.0680    1.0830    0.0060    0.0002    0.0002    0.0002    0.0002    0.1820    0.1850    0.1910    0.1940];

save(([getuserdir filesep 'panoseti' filesep 'Calibrations' filesep 'CalibrationDB.mat']),'quaboDETtable')


%gainmapallgmeanSNold=gainmapallgmeanSN;
gainmapallgmeanSNnew2=cat(3,gainmapallgmeanSNold,gainmapallgmeanSN(:,:,14),gainmapallgmeanSN(:,:,14),gainmapallgmeanSN(:,:,6));
gainmapallgmeanSN=gainmapallgmeanSNnew2;
save(([getuserdir filesep 'panoseti' filesep 'Calibrations' filesep 'gainmap_inc.mat']),'gainmapallgmeanSN')




