%real physical detector 5x5 array with corresponding sma#
NIRArr=[13 14 16 18 20;11 12 17 19 21;10 9 15 22 23;8 7 4 1 24;6 5 3 2 25];
%array 25 sma 1..25 to pixelquadrant nomenclature
%dizaines: A=1 . B=2 c=3 d=4 e=5 f=6 g=7 h=8
NIRSma=['H3' 'G3' 'G2' 'H2' 'H1' 'G1' 'E4' 'F4' 'F5' 'E5' 'E6' 'F7' 'F6' 'E3' 'F3' 'F2' 'E2' 'E1' 'F1' 'G6' 'H6' 'H5' 'G5' 'G4' 'H4'];
%map NIRsma into panotv:
NIRquabo=zeros(numel(NIRSma),2);
for ii=1:numel(NIRSma)
    pixquad=NIRSma(ii);
    column=pixquad(1);
    switch column
        case 'E'
            colnum=5;
        case 'F'
            colnum=6;
        case 'G'
            colnum=7;
       case 'H'
            colnum=8;
    end
      NIRquabo(ii,:)=[colnum str2num(pixquad(2))];      
end


NIRarrX=1; %1..5
NIRarrY=1; %1..5 
dimNIRarr=5;
NIRpano=zeros(dimNIRarr,dimNIRarr);
for ii=1:dimNIRarr
   for jj=1:dimNIRarr 
        NIRpano(ii,jj)=sub2ind([16 16],NIRquabo(NIRArr(ii,jj),2),NIRquabo(NIRArr(ii,jj),1));
   end
end