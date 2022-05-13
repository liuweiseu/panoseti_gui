%use matlab2py first
fhand=py.open('quabo_config.txt');

py.control_quabo_matlab7.send_maroc_params(fhand);





