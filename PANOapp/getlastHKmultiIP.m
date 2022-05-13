function [hk] = getlastHKmultiIP(fromlast,bn) %(inputArg1,inputArg2)
%

    
%  
  rep=[getuserdir  '\panoseti\panoHK\'];
   latestfile = getlatestfile([rep  '*' num2str(bn) '.mat'])
   try
load([rep latestfile])
   catch
       pause(0.1)
       load([rep latestfile])
   end
if ~exist('fromlast','var')
    fromlast=0;
end

if fromlast>numel(hvmon0tab)
    avantdernierfile = getavantdernierfile(rep)
hvmon0tab0=hvmon0tab;
hvmon1tab0=hvmon1tab;
hvmon2tab0=hvmon2tab;
hvmon3tab0=hvmon3tab;
                       
ihvmon0tab0  = ihvmon0tab;
ihvmon1tab0   = ihvmon1tab;
ihvmon2tab0  =  ihvmon2tab;
ihvmon3tab0   = ihvmon3tab;
 rawhvmontab0   = rawhvmontab;
v12montab0    = v12montab;
 v18montab0   =  v18montab;
v33montab0   =  v33montab;
v37montab0   =  v37montab;
i10montab0   =  i10montab;
 i18montab0   =  i18montab;
i33montab0    =  i33montab;
temp1tab0   =  temp1tab;
  temp2tab0  =  temp2tab;
vccinttab0  =  vccinttab;
  vccauxtab0  =  vccauxtab;
  utctab0 =  utctab;
 timecomptab0 =  timecomptab;
load([rep avantdernierfile])

hvmon0tab=[hvmon0tab hvmon0tab0];
hvmon1tab=[hvmon1tab hvmon1tab0];
hvmon2tab=[hvmon2tab hvmon2tab0];
hvmon3tab0=[hvmon3tab hvmon3tab0];
                       
ihvmon0tab  = [ihvmon0tab ihvmon0tab0];
ihvmon1tab  = [ihvmon1tab ihvmon1tab0];
ihvmon2tab =  [ihvmon2tab  ihvmon2tab0];
ihvmon3tab   = [ihvmon3tab ihvmon3tab0];
 rawhvmontab  = [rawhvmontab rawhvmontab0];
v12montab    = [v12montab v12montab0];
 v18montab  = [ v18montab v18montab0];
v33montab =  [v33montab v33montab0];
v37montab = [ v37montab v37montab0];
i10montab = [ i10montab i10montab0];
 i18montab  = [ i18montab i18montab0];
i33montab  = [ i33montab i33montab0];
temp1tab  =  [temp1tab temp1tab0];
  temp2tab = [ temp2tab temp2tab0];
vccinttab  = [ vccinttab vccinttab0];
  vccauxtab  = [ vccauxtab vccauxtab0];
  utctab = [ utctab utctab0];
 timecomptab = [ timecomptab timecomptab0];
end
    
hk.hvmon0=hvmon0tab(end-fromlast:end);
hk.hvmon1=hvmon1tab(end-fromlast:end);
hk.hvmon2=hvmon2tab(end-fromlast:end);
hk.hvmon3=hvmon3tab(end-fromlast:end);
                       
                     hk.ihvmon0  = ihvmon0tab(end-fromlast:end);
                    hk.ihvmon1   = ihvmon1tab(end-fromlast:end);
                    hk.ihvmon2  =  ihvmon2tab(end-fromlast:end);
                    hk.ihvmon3   = ihvmon3tab(end-fromlast:end);
                   hk.rawhvmon    = rawhvmontab(end-fromlast:end);
                   hk.v12mon    = v12montab(end-fromlast:end);
                   hk.v18mon   =  v18montab(end-fromlast:end);
                   hk.v33mon   =  v33montab(end-fromlast:end);
                   hk.v37mon   =  v37montab(end-fromlast:end);
                   hk.i10mon   =  i10montab(end-fromlast:end);
                   hk.i18mon   =  i18montab(end-fromlast:end);
                  hk.i33mon    =  i33montab(end-fromlast:end);
                   hk.temp1   =  temp1tab(end-fromlast:end);
                   hk.temp2   =  temp2tab(end-fromlast:end);
                    hk.vccint  =  vccinttab(end-fromlast:end);
                   hk.vccaux  =  vccauxtab(end-fromlast:end);
                    hk.utc  =  utctab(end-fromlast:end);
                     hk.timecomp =  timecomptab(end-fromlast:end);

end

