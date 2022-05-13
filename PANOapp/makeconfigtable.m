
%SN Quabo - det#Q0 - .. - det#Q3 - AQ0 - .. - AQ3 - BQ0 - .. - BQ3
load([getuserdir '\panoseti\Calibrations\' 'CalibrationDB.mat'],'quaboDETtable')

%dacQ0ref .. dacQ3ref..M1dacQ0ref...//S2dacQ3ref
load('testquickcalib.mat')
load('testquickcalibb.mat')

%{'A. Fresnel'}    {'moboSN003'}    {'quaboSN009*'}    {[1267]}    {[1268]}    {[1270]}    {[1269]} ...
%                              ....  {'quaboSN011*'}    {[1263]}    {[1264]}    {[1266]}    {[1265]}    {'quaboSN003*'}  
load([getuserdir '\panoseti\Calibrations\' 'Panoconfig.mat'],'config')

%IP to SN
IPtab=["192.168.0.4","192.168.0.5","192.168.0.6","192.168.0.7",...
   "192.168.3.248","192.168.3.249","192.168.3.250"] %,"192.168.3.251" 
%IP='192.168.0.4';

for IPn=1:size(IPtab,2)
    IP=IPtab(IPn); %'192.168.0.4';
%find it in config
if IPn>4 
 [qx,qy] = ind2sub(szq,find(contains(config(:,1),'J. Maxwell'))); 
else
     [qx,qy] = ind2sub(szq,find(contains(config(:,1),'C. Sagan'))); 
end
    if IPn<5
        IPn2=IPn;
    else
        IPn2=IPn-4;
    end
 SNboardcell=config(qx,5*((IPn2)-1)+3);
 SNboardstr=cell2mat(SNboardcell);
 SNboard=str2num(SNboardstr(end-2:end));
indquabo= find(quaboDETtable(:,1)==SNboard);

% DAC=A g pe + B
%assuming some pente A based on mean of other As
        nonzeros=find(quaboDETtable(:,7)~=0)
        Amoy = mean(quaboDETtable( nonzeros,7:10),'all');
         pelev= 4.5; gainG= 60; 
     quaboDETtable(indquabo,7:10) = Amoy;
    %%% M0dacQ0ref - Amoy * gainG * pelev  
     %quaboDETtable(indquabo,7)=mean(quaboDETtable( nonzeros,6:9),'all');
    % quaboDETtable(indquabo,8)=mean(quaboDETtable( nonzeros,6:9),'all');
     %quaboDETtable(indquabo,9)=mean(quaboDETtable( nonzeros,6:9),'all');
  % DAC=A g pe + B
  % dacQ0ref .. dacQ3ref..M1dacQ0ref...//S2dacQ3ref
  %  dacQ0ref =  A g pe + B
  %% we were measuring at cpsref=100 which is pe=5 
  %% B=  M0dacQ0ref - Amoy g pe 
  switch IPn
      case 5
          gdacQ0ref= M0dacQ0ref; 
          gdacQ1ref= M0dacQ1ref; 
          gdacQ2ref= M0dacQ2ref; 
          gdacQ3ref= M0dacQ3ref; 

      case 6
           gdacQ0ref=M1dacQ0ref; 
          gdacQ1ref= M1dacQ1ref; 
          gdacQ2ref= M1dacQ2ref; 
          gdacQ3ref= M1dacQ3ref; 
      case 7
          gdacQ0ref= M2dacQ0ref; 
          gdacQ1ref= M2dacQ1ref; 
          gdacQ2ref= M2dacQ2ref; 
          gdacQ3ref= M2dacQ3ref; 
      case 8
          gdacQ0ref= M3dacQ0ref; 
          gdacQ1ref= M3dacQ1ref; 
          gdacQ2ref= M3dacQ2ref; 
          gdacQ3ref= M3dacQ3ref; 
      case 1
          gdacQ0ref= S0dacQ0ref; 
          gdacQ1ref= S0dacQ1ref; 
          gdacQ2ref= S0dacQ2ref; 
          gdacQ3ref= S0dacQ3ref; 
      case 2
           gdacQ0ref=S1dacQ0ref; 
          gdacQ1ref= S1dacQ1ref; 
          gdacQ2ref= S1dacQ2ref; 
          gdacQ3ref= S1dacQ3ref; 
      case 3
          gdacQ0ref= S2dacQ0ref; 
          gdacQ1ref= S2dacQ1ref; 
          gdacQ2ref= S2dacQ2ref; 
          gdacQ3ref= S2dacQ3ref; 
      case 4
          gdacQ0ref= S3dacQ0ref; 
          gdacQ1ref= S3dacQ1ref; 
          gdacQ2ref= S3dacQ2ref; 
          gdacQ3ref= S3dacQ3ref; 
  end
      quaboDETtable(indquabo,11)=gdacQ0ref - Amoy * gainG * pelev  ;
      quaboDETtable(indquabo,12)=gdacQ1ref - Amoy * gainG * pelev  ;
      quaboDETtable(indquabo,13)=gdacQ2ref - Amoy * gainG * pelev  ;
      quaboDETtable(indquabo,14)=gdacQ3ref - Amoy * gainG * pelev  ;

end
save([getuserdir '\panoseti\Calibrations\' 'CalibrationDB.mat'],'quaboDETtable')

 
%              quabos=[config(:,3)  config(:,8) config(:,13) config(:,18)];
%             szq=size(quabos);
%             [qx,qy] = ind2sub(szq,find(contains(quabos,quabo))); 
%     
% 
% 
% [ig,indexquabosn]=ismember(['QuaboSN'] ,quaboconfig);
% inddetrow=find(quaboDETtable(:,1)==str2num(cell2mat(quaboconfig(indexquabosn,3))));
% 
% AAima=zeros(1,4);
% BBima=zeros(1,4);
% for quad=1:4
%     AAima(quad)=quaboDETtable(inddetrow,6+quad);
%     BBima(quad)=quaboDETtable(inddetrow,10+quad);
% end
% 
% quaboDETtable(inddetrow,7)=Af(1);
%     quaboDETtable(inddetrow,8)=Af(2);
%     quaboDETtable(inddetrow,9)=Af(3);
%     quaboDETtable(inddetrow,10)=Af(4);
%     quaboDETtable(inddetrow,11)=Bf(1);
%     quaboDETtable(inddetrow,12)=Bf(2);
%     quaboDETtable(inddetrow,13)=Bf(3);
%     quaboDETtable(inddetrow,14)=Bf(4);
%     
% 
%              quabos=[config(:,3)  config(:,8) config(:,13) config(:,18)];
%             szq=size(quabos);
%             [qx,qy] = ind2sub(szq,find(contains(quabos,quabo))); 
%     