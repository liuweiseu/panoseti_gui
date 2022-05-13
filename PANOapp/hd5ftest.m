filename='/home/panosetigraph/HSD_PANOSETI/2020/20201105/PANOSETI_LICK_2020_11_05_05-10-09.h5'
h5disp(filename)
info = h5info(filename)

info.Groups.Name

h5disp(filename,'/bit8IMGData')
h5disp(filename,'/bit16IMGData/ModulePair_00254_00001')


im=h5read(filename,'/bit16IMGData/ModulePair_00254_00001/DATA000000001')
[x y]=ind2sub(im,1848);
im2=im(:,x);

load('MarocMap.mat');

