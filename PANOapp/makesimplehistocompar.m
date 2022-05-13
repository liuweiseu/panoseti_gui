images2=grabimages(100,1,1);

figure
hold on
  histogram( (images(:,:,:)),'BinWidth',1,'FaceColor','b','FaceAlpha',1)
  histogram( (images2(:,:,:)),'BinWidth',1,'FaceColor','r','FaceAlpha',0.5)