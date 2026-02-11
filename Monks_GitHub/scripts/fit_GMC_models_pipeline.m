clear
clc

Pbase = fullfile(pwd, ['..' filesep]);
Pscripts = fullfile(Pbase, 'scripts');

% create DCM template models for fitting 
fprintf('\n ------ Preparing DCM models for DMN ------ \n')
run([Pscripts filesep 'DCM_CSD_defineModels_DMN.m']);
fprintf('\n ------ Preparing DCM models for SN ------ \n')
run([Pscripts filesep 'DCM_CSD_defineModels_SN.m']);
%%
% fit models on both the DMN and SN 
fprintf('\n ------ Fit models for DMN ------ \n')
run([Pscripts filesep 'fit_DCMs_DMN.m']);
fprintf('\n ------ Fit models for SN ------ \n')
run([Pscripts filesep 'fit_DCMs_SN.m']);
%%
% re-fit models on both the DMN and SN 
fprintf('\n ------ Re-fit models for DMN ------ \n')
run([Pscripts filesep 'reFit_DCMs_DMN.m']);
fprintf('\n ------ Re-fit models for SN ------ \n')
run([Pscripts filesep 'reFit_DCMs_SN.m']);