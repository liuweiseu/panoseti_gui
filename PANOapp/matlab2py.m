%Matlab setup for using python code ("call-user-defined-module")
% add current folder to the Python path search:
if count(py.sys.path,'') == 0
    insert(py.sys.path,int32(0),'');
end

