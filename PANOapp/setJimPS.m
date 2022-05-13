function setJimPS(s,microamp)
% J. Maire 2019-05-28
if ~isnumeric(s)
    fprintf(s,['U' num2str(microamp) ';'])
else
    ss = serial('COM6','BaudRate',9600);
    fopen(ss)
    fprintf(ss,['U' num2str(s) ';'])
    fclose(ss)
end
%seriallist

end

