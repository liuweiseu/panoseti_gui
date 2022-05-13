function latestfile = getavantdernierfile(directory)

dirc=dir(directory);
dirc = dirc(find(~cellfun(@isdir,{dirc(:).name})));

[A,I]= max([dirc(:).datenum]);
dirc(I)=[];
[A,I]= max([dirc(:).datenum]);
if ~isempty(I)
    latestfile=dirc(I).name;
end

end