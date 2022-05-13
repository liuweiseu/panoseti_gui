function numout= addcoma(numin)
jf=java.text.DecimalFormat;
numout=char(jf.format(numin));
end