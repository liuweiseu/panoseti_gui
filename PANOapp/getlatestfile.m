function latestfile = getlatestfile(directory)

dirc=dir(directory);
dirc = dirc(find(~cellfun(@isdir,{dirc(:).name})));

[A,I]= max([dirc(:).datenum]);

if ~isempty(I)
    latestfile=dirc(I).name;
end

end