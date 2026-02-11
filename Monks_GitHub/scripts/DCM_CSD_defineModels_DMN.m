% clc

%--------------------------------------------------------------------------
spm('defaults','EEG');
spmPath = fileparts(which('spm'));
% Data and analysis directories
%--------------------------------------------------------------------------

Pdata     = fullfile(Pbase, 'spm_datasets_anon'); 
Panalysis = fullfile(Pbase, ['models' filesep 'DMN']); 

if ~exist(Panalysis, 'dir')
    mkdir(Panalysis);
end

addpath(Pdata);
%--------------------------------------------------------------------------
conditions = {'Baseline'};


% Data filename
%--------------------------------------------------------------------------
cd(Pdata);
Nwindows = 300; % 5min, 1s windows
files = dir([Pdata filesep 'subject_*.mat']);
GCM = {};
for kk = 1:2%length(files)
    cd(Pdata);
    filename = files(kk).name;

    spmData = spm_eeg_load(filename);
    subjName = filename;
    DCM.xY.Dfile = fullfile(Pdata, filename);

    % Parameters and options used for setting up model
    %--------------------------------------------------------------------------
    DCM.options.analysis = 'CSD'; % analyze cross-spectral densities
    DCM.options.model   = 'ERP'; % ERP model
    DCM.options.spatial  = 'ECD'; % spatial model
    DCM.options.trials   = [1]; % index of the trials
    DCM.options.Tdcm(1)  = 0;     % start of peri-stimulus time to be modelled
    DCM.options.Tdcm(2)  = 1000;   % end of peri-stimulus time to be modelled
    DCM.options.Fdcm(1) = 4;    % starting frequency of the spectrum to be modelled
    DCM.options.Fdcm(2) = 45;    % end frequency of the spectrum to be modelled
    DCM.options.Nmodes   = 6;     % nr of modes for data selection
    DCM.options.D        = 1;     % downsampling
    DCM.options.Nmax     = 250;     % max number of iterations for inversion
    DCM.options.location = 0;     % optimize source locations

    %--------------------------------------------------------------------------
    % Data and spatial model
    %--------------------------------------------------------------------------
    DCM  = spm_dcm_erp_data(DCM);

    %--------------------------------------------------------------------------
    % Location priors for dipoles
    %--------------------------------------------------------------------------
    %               mPFC            PCC/PCu           lLP           rLP
    DCM.Lpos  = [[-1; 54; 27] [0; -58; 0] [-46; -66; 30] [49; -63; 33]];
    DCM.Sname = {'mPFC', 'PCC/PCu', 'lLP', 'rLP'};
    Nareas    = size(DCM.Lpos,2);

    %--------------------------------------------------------------------------
    % Spatial model
    %--------------------------------------------------------------------------
    DCM = spm_dcm_erp_dipfit(DCM);
    DCM.M.dipfit.vol = [spmPath filesep 'canonical' filesep 'single_subj_T1_EEG_BEM.mat'];

    %--------------------------------------------------------------------------
    % Specify connectivity model
    %--------------------------------------------------------------------------
    cd(Panalysis)

    % forward
    DCM.A{1} = zeros(Nareas,Nareas);
    DCM.A{1}(1,2) = 1;
    DCM.A{1}(1,3) = 1;
    DCM.A{1}(1,4) = 1;
    DCM.A{1}(2,3) = 1;
    DCM.A{1}(2,4) = 1;

    % backward
    DCM.A{2} = zeros(Nareas,Nareas);
    DCM.A{2}(2,1) = 1;
    DCM.A{2}(3,1) = 1;
    DCM.A{2}(3,2) = 1;
    DCM.A{2}(4,1) = 1;
    DCM.A{2}(4,2) = 1;

    % lateral
    DCM.A{3} = zeros(Nareas,Nareas);
    DCM.A{3}(4,3) = 1;
    DCM.A{3}(3,4) = 1;

    DCM.B = {};

    DCM.C = [0; 0; 0; 0]; % input rIOG

    %--------------------------------------------------------------------------
    % Between trial effects
    %--------------------------------------------------------------------------
    DCM.xU.X = []'; % no between-trial effects. Only baseline connectivity
    DCM.xU.name = {};


    %--------------------------------------------------------------------------
    % Save
    %--------------------------------------------------------------------------
    cd(Panalysis);
    subjName = subjName(1:end-4);
    for ii = 1:Nwindows

        T_start = (ii-1)*1e3;
        T_end = (ii)*1e3;

        DCM.options.Tdcm(1)  = T_start;     
        DCM.options.Tdcm(2)  = T_end;  

        DCM.name = ['DCM_DMN_' subjName '_win' num2str(ii)];
        filename = [DCM.name '.mat'];
        GCM{ii,1} = DCM;
    end
    fprintf('\n Saving %s GCM structure ... \n', subjName);
    save([Panalysis filesep 'GCM_to_fit_' DCM.name(1:end-7) '.mat'], 'GCM');
    clear DCM;
end
fprintf('\n Done. \n');
% save('GCM_DCM_to_fit.mat', 'GCM');
% DCM      = spm_dcm_csd(DCM);
% fprintf('\n\n Optimization procedure done. \n');