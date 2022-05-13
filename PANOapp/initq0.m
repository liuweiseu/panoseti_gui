cd '/home/panosetigraph/panoseti/PANOapp';
fpgadir=[getuserdir  filesep 'panoseti' filesep 'FPGA' filesep 'quabo_v0105'];

disp('Starting boards initialization...')

 commandStr = ['python ' fpgadir filesep 'startq248.py']; 
[status248, commandOut248] = system(commandStr);
 if status248==1
     disp('Board IP 248 initialized...')
   %  fprintf('squared result is %s\n',(commandOut248));
 else
     disp(commandOut248)
 end
 
 commandStr = ['python ' fpgadir filesep 'startq249.py']; 
 [status249, commandOut249] = system(commandStr);
 if status249==1
     disp('Board IP 249 initialized...')
   %  fprintf('squared result is %s\n',(commandOut249));
    else
     disp(commandOut249)
 end
 
 commandStr = ['python ' fpgadir filesep 'startq250.py']; 
[status250, commandOut250] = system(commandStr);
 if status250==1
     disp('Board IP 250 initialized...')
   %  fprintf('squared result is %s\n',(commandOut250));
    else
     disp(commandOut250)
 end
 
 commandStr = ['python ' fpgadir filesep 'startq251.py']; 
 [status251, commandOut251] = system(commandStr);
 if status251==1
     disp('Board IP 251 initialized...')
    % fprintf('squared result is %s\n',(commandOut251));
     else
     disp(commandOut251)
 end
 
  commandStr = ['python ' fpgadir filesep 'startq4.py']; 
 [status4, commandOut4] = system(commandStr);
 if status4==1
     disp('Board IP 4 initialized...')
    % fprintf('squared result is %s\n',(commandOut4));
     else
     disp(commandOut4)
 end

  commandStr = ['python ' fpgadir filesep 'startq5.py'];  
 [status5, commandOut5] = system(commandStr);
 if status5==1
     disp('Board IP 5 initialized...')
    % fprintf('squared result is %s\n',(commandOut5));
     else
     disp(commandOut5)
 end

 
 commandStr = ['python ' fpgadir filesep 'startq6.py']; 
 [status6, commandOut6] = system(commandStr);
 if status6==1
     disp('Board IP 6 initialized...')
    % fprintf('squared result is %s\n',(commandOut6));
     else
     disp(commandOut6)
 end
 
 commandStr = ['python ' fpgadir filesep 'startq7.py']; 
 [status7, commandOut7] = system(commandStr);
 if status7==1
     disp('Board IP 7 initialized...')
 %    fprintf('squared result is %s\n',(commandOut7));
  else
     disp(commandOut7)
 end
 
  disp('Boards initializations finished!!!')