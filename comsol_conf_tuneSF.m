% runTuneSF.m
% main program to call shift factor tuning

% Input:
% 1. mphfile: file name of built comsol model
% 2. EXPTPerm: experimental data of dielectric spectroscopy for final comparison 
% 3. shift factors for alpha and beta relaxation shift in phase and magnitude. Five in total
% 4: tau0: threshold that separates alpha and beta relaxation
% 5. comsol path: path to source files of comsol binary files 

global id PortNum TauShift1 DeltaEpsilonShift1 TauShift2 DeltaEpsilonShift2 ConstEpsilonShift tau0

clear all; close all; clc; warning('off', 'all')

%--------------------------- Input ----------------
id = 1; 
PortNum = 2036; 	% port number of comsol server, default 2036. 

mphfile = 'HZ_2D_comsolbuild_AC_recon_10-Nov-2015_IP10+50_run_1'; % Output COMSOL project name. No .mph suffix 
EXPTPerm = csvread('../expt_epoxy_DS/ferrocene_PGMA_2wt-TK.csv');
TauShift1 			= 0.75;  % beta relaxation, s_beta, For tau <= 1, Shift multiplier along x direction. 1 is no shift
DeltaEpsilonShift1 	= 1.8;  % beta relaxation, M_beta, For tau <= 1, Shift multiplier along y direction. 1 is no shift
TauShift2 			= 0.01;  % Alpha relaxation, s_alpha, for tau > 1, Shift multiplier along x direction. 1 is no shift
DeltaEpsilonShift2	= 2;  % Alpha relaxation, M_alpha, For tau > 1, Shift multiplier along y direction. 1 is no shift
ConstEpsilonShift		= 0;
tau0                   = 0.1; % tau*freq_crit = 1. E.g, for freq_crit = 10 Hz, tau = 0.1 s. 
addpath('/home/hzg972/comsol42/mli','/home/hzg972/comsol42/mli/startup');

%---------------------------

set(0,'DefaultFigureColor',[1 1 1])
% Set figure axes linewidth to 2
set(0,'defaultaxeslinewidth',2);
% Set figure linewidth to 2
set(0,'defaultlinelinewidth',2);
% Set figure axes fontsize to 20
set(0,'defaultaxesfontsize',20);
% Set figure text fontsize to 20
set(0,'defaulttextfontsize',20);

tic
comsol_tune_sf(mphfile,const)

% Plot FE and expt data together for comparison
% FEA data
txtfilenameImag = [mphfile,'_CompPermImag.csv'];
txtfilenameReal = [mphfile,'_CompPermReal.csv'];
FEAPermReal = csvread(txtfilenameReal);
FEAPermImag = csvread(txtfilenameImag);
freq = FEAPermImag(:,1);
epp1 = FEAPermImag(:,2);
ep1 = FEAPermReal(:,2);

% Experimental data
freqEXPT = EXPTPerm(:,1);
epEXPT = EXPTPerm(:,2);
eppEXPT = EXPTPerm(:,3);

f1=figure('visible','off'); % real
semilogx(freq,ep1), hold on
semilogx(freqEXPT, epEXPT, 'r')
legend(MATNAME, 'expt')
xlabel 'log(Frequency [Hz])'
ylabel '\epsilon^'''
set(gca, 'XTick', [10.^-4 10.^-3 10.^-2 10.^-1 10.^0 10.^1 10.^2 10.^3 10.^4 10.^5 10.^6 ])
axis([freq(1) freq(end) min(ep1)*0.9 max(ep1)*1.1 ])

f2=figure('visible','off'); % imag
semilogx(freq,epp1),hold on
semilogx(freqEXPT, eppEXPT, 'r')
legend(MATNAME, 'expt')
xlabel 'log(Frequency [Hz])'
ylabel '\epsilon^"'
axis([freq(1),freq(end), min(epp1)*0.9, max(epp1)*1.1 ]) 
set(gca, 'XTick', [10.^-4 10.^-3 10.^-2 10.^-1 10.^0 10.^1 10.^2 10.^3 10.^4 10.^5 10.^6 ])

saveas(f1,'./compare_epsilon_real','jpeg')
saveas(f2,'./compare_epsilon_imag','jpeg')
toc