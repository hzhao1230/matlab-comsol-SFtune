function [] = comsol_tune_sf(mphfile, const)
global extra_E_infi epmodel id PortNum TauShift1 DeltaEpsilonShift1 TauShift2 DeltaEpsilonShift2 ConstEpsilonShift tau0
%addpath('/usr/local/comsol42/mli','/usr/local/comsol42/mli/startup');

mphstart(PortNum);
extra_E_infi = -0.55; % Epoxy data

import com.comsol.model.*
import com.comsol.model.util.*
model = mphload([mphfile,'.mph']);
disp('Loaded original mph model.')

PScoeff = './RoomTempEpoxy.mat';             % Dynamfit result of polymer matrix Prony series coefficients% Modified epsilon_inf.
comsol_load_epsilon_model(PScoeff);

% Update interphase model string if tau0 is changed
model.variable('var1').set('ep',epmodel.ep);
model.variable('var1').set('epp',epmodel.epp);
model.variable('var1').set('epint',epmodel.epint);
model.variable('var1').set('eppint',epmodel.eppint);

% Update new shifting factors
SF  	= [TauShift1, DeltaEpsilonShift1, TauShift2 ,DeltaEpsilonShift2,ConstEpsilonShift  ];
model   = comsol_create_shifting_factors(model, SF);
disp('Assigned new shift factors in model.')

% Run solution and output new csv files with complex permittivity
model.sol('sol1').runAll;
model.result('pg1').run;
model.result('pg2').run;
model.result('pg3').run;
disp('Finished re-running model.')

model.result.numerical('av1').setResult;
txtfilenameImag = [mphfile,'_CompPermImag.csv'];
model.result.export('plot1').run;
disp('Wrote imaginary composite permittivity to file:'); disp(txtfilenameImag);

model.result.numerical('av2').setResult;
txtfilenameReal = [mphfile,'_CompPermReal.csv'];
model.result.export('plot2').run;
disp('Wrote real composite permittivity to file:'); disp(txtfilenameReal);

mphsave(model, [mphfile,'_solved_',num2str(id)]);
end