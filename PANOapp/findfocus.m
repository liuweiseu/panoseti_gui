

%  if count(py.sys.path,['C:\Users\jerome\Documents\panoseti\pythonlib\']) == 0
%                 insert(py.sys.path,int32(0),['C:\Users\jerome\Documents\panoseti\pythonlib\']); 
%                 % uialert(app.UIFigure,char(py.sys.path),'py.sys.path2')
%              end
ini=0
if ini==1
ser=py.step_control_matlab.start(1)
end
%%take images

%move stage
for pp=1:30
    disp(pp)
py.step_control_matlab.main2('0,200',ser)
pause(2)
im=recordimage;
end