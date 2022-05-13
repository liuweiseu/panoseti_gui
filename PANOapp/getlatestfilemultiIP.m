function latestfile = getlatestfilemultiIP(directory,bn)

dirc=dir(directory);
dirc = dirc(find(~cellfun(@isdir,{dirc(:).name})));
dirc(:).name
[A,I]= max([dirc(:).datenum]);

if ~isempty(I)
    latestfile=dirc(I).name;
end

end