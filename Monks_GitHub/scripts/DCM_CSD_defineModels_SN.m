% clc
% clear

%--------------------------------------------------------------------------
spm('defaults','EEG');

% Data and analysis directories
%--------------------------------------------------------------------------

Pdata     = fullfile(Pbase, ['models' filesep 'DMN']); 
Panalysis = fullfile(Pbase, ['models' filesep 'SN']); 

if ~exist(Panalysis, 'dir')
    mkdir(Panalysis);
end

addpath(Pdata);
%--------------------------------------------------------------------------

Nwindows = 300; % 5min, 1s windows
files = dir([Pdata filesep 'GCM_to_fit*.mat']);
GCM = {};
for kk = 1:2%length(files)
    cd(Pdata);
    filename = files(kk).name;

    GCM = importdata(filename);
    for ii = 1:length(GCM)
        DCM = GCM{ii};

        %--------------------------------------------------------------------------
        % Location priors for dipoles
        %--------------------------------------------------------------------------
        %               laPFC         raPFC           dACC         lLP        rLP
        DCM.Lpos  = [[-35; 45; 30] [32; 45; 30] [0; 21; 36] [-62; -45; 30] [62; -45; 30]];
        DCM.Sname = {'laPFC', 'raPFC', 'dACC', 'lLP', 'rLP'};
        Nareas    = size(DCM.Lpos,2);

        %--------------------------------------------------------------------------
        % Spatial model
        %--------------------------------------------------------------------------
        DCM = spm_dcm_erp_dipfit(DCM);
        DCM.M.dipfit.vol = [spmPath filesep 'canonical' filesep 'single_subj_T1_EEG_BEM.mat'];

        %--------------------------------------------------------------------------
        % Specify connectivity model
        %--------------------------------------------------------------------------
    
        % forward
        DCM.A{1} = zeros(Nareas,Nareas);
        DCM.A{1}(1,4) = 1;
        DCM.A{1}(3,1) = 1;
        DCM.A{1}(3,2) = 1;
        DCM.A{1}(2,5) = 1;
        DCM.A{1}(3,4) = 1;
        DCM.A{1}(3,5) = 1;
        
        % backward
        DCM.A{2} = zeros(Nareas,Nareas);
        DCM.A{2}(4,1) = 1;
        DCM.A{2}(1,3) = 1;
        DCM.A{2}(4,3) = 1;
        DCM.A{2}(5,3) = 1;
        DCM.A{2}(2,3) = 1;
        DCM.A{2}(5,2) = 1;
    
        % lateral
        DCM.A{3} = zeros(Nareas,Nareas);
        DCM.A{3}(1,2) = 1;
        DCM.A{3}(2,1) = 1;
        DCM.A{3}(4,5) = 1;
        DCM.A{3}(5,4) = 1;
    
        DCM.B = {};
    
        DCM.C = [0; 0; 0; 0]; 
    
        %--------------------------------------------------------------------------
        % Between trial effects
        %--------------------------------------------------------------------------
        DCM.xU.X = []'; % no between-trial effects. Only baseline connectivity
        DCM.xU.name = {};

        T_start = (ii-1)*1e3;
        T_end = (ii)*1e3;

        DCM.options.Tdcm(1)  = T_start;     
        DCM.options.Tdcm(2)  = T_end;  

        subjName = filename(20:end-4);
        DCM.name = ['DCM_SN_' subjName '_win' num2str(ii)];
        GCM{ii,1} = DCM;
    end

    %--------------------------------------------------------------------------
    % Save
    %--------------------------------------------------------------------------
    fprintf('\n Saving %s GCM structure ... \n', subjName);
    save([Panalysis filesep 'GCM_to_fit_' DCM.name(1:end-7) '.mat'], 'GCM');
    clear DCM;
end
fprintf('\n Done. \n');
