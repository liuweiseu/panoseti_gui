function files=findacquisition(myfolder,startnum,endnum)

MyFolderInfo = dir([myfolder '*.fits']);

nbfiles=size(MyFolderInfo,1);
hhmmss=zeros(1,nbfiles);
%extract hh.mm in filename
for ii=1:nbfiles

    file = MyFolderInfo(ii).name;
    if numel(file)>26
   hhmmss(ii)=str2num(file(21:26));
    end
end

indseq=find( (hhmmss>=startnum) & (hhmmss<=endnum));
for ii=1:numel(indseq)
files(ii).name=MyFolderInfo(indseq(ii)).name;
end
end