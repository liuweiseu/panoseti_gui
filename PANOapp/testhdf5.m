%Write a 5-by-5 data set of uint8 values to the root group.

%hdf5write('myfile.h5', '/dataset1', uint16(magic(16)))
%Write a 2-by-2 data set of text entries into a subgroup.

dataset = {'north', 'south'; 'east', 'west'};
hdf5write('myfile4.h5', '/group1/dataset1.1', dataset);
%Write a data set and attribute to an existing group.
for imnum=2:10000
dset = uint16(rand(16,16)); %single
dset_details.Location = ['/group1/dataset1.' num2str(imnum)];
dset_details.Name = 'Random';

attr = 'Some random data';
attr_details.Name = 'Description';
attr_details.AttachedTo = ['/group1/dataset1.' num2str(imnum) '/Random'];
attr_details.AttachType = 'dataset';

hdf5write('myfile4.h5', dset_details, dset, ...
           attr_details, attr, 'WriteMode', 'append');
       
end       
       
       