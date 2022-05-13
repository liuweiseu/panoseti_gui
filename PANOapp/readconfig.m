%JM 2015-02-19
function val=readconfig(field,mode)
val='N/A';
if (nargin==2) && (strncmp(mode,'count',4))
    file='NirosetiConfigCount.txt';
else
     file='NirosetiConfig.txt';
end
fid = fopen(file);
config = textscan(fid, '%s %s');
fclose(fid);

ind=find(ismember(config{1},field));
dim=2;
if numel(ind)==0 
    ind=find(ismember(config{2},field));
    dim=1;
end
if numel(ind)~=0 
    if (strncmp(field,'OBSERVER',8))
        fid = fopen(file);
        tline = fgetl(fid);
        fclose(fid);
        if numel(tline) >1
            deb = strfind(tline,'OBSERVER')+8;
            fin = strfind(tline,'%')-1;
            val = strtrim(tline(deb(1):fin(1)));
        end
    else
        val=config{dim}{ind};
    end
end


%ugly, but repeat the reading in acquisition config file
% if not found in the count config file,
% so no need to write two redundant parameters
if (numel(ind)==0) & (nargin==2) & (strncmp(mode,'count',4))
    
      file='NirosetiConfig.txt';

    fid = fopen(file);
    config = textscan(fid, '%s %s');
    fclose(fid);

    ind=find(ismember(config{1},field));
    dim=2;
    if numel(ind)==0 
        ind=find(ismember(config{2},field));
        dim=1;
    end
    
    if numel(ind)~=0 
        val=config{dim}{ind};
    end
end
end