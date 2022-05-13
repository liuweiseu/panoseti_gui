
% Create a serial port object.
obj1 = instrfind('Type', 'serial', 'Port', 'COM1', 'Tag', '');
% Create the serial port object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = serial('COM1');
else
    fclose(obj1);
    obj1 = obj1(1)
end
% Connect to instrument object, obj1.
fopen(obj1);
% Communicating with instrument object, obj1.
data1 = query(obj1, '*IDN?');
% Disconnect from instrument object, obj1.
fclose(obj1);
% Clean up all objects.
delete(obj1);