clc
close all
clear

Pbase = fullfile(pwd, ['..' filesep]);
Pmetadata     = fullfile(Pbase, 'spm_datasets_anon'); 
Pdata     = fullfile(Pbase, ['models' filesep 'DMN' filesep 'fitted_adjusted']); 
Psave = fullfile(Pdata, 'PEBs_180sec_DCT_sep_6DTC');

Pgcm = Pdata;
Presults = Pgcm; 

addpath(Pdata);

spm('defaults','EEG');

GCMfiles = dir([Pdata filesep 'GCMout*.mat']);

if ~exist(Psave, 'dir')
    mkdir(Psave);
end

fitPEBs = 1;
fitPEBofPEBs = 0;

%%  II level: within-subject between-window analysis
%--------------------------------------------------------------------------
if fitPEBs

    % modeling systematic connectivity fluctuations
    W = 180;
    n = 0:W-1;
    k = 2:6;
    k = k*3;
    F = sqrt(6/W)*cos((k*pi/W)' * n+0.5)';
    k2 = 1:5;
    F2 = sqrt(2/W)*cos((k2*pi/W)' * (n+0.5))';

    for kk = 1:length(GCMfiles)
        cd(Pgcm);
        GCMfile = GCMfiles(kk).name;

        GCM = importdata(GCMfile);
        GCM = GCM(61:240);      
    
        %--------------------------------------------------------------------------
        % Define the GLM
        %--------------------------------------------------------------------------
        
        M = struct();
        
        M.Q = 'all';
        % M.Q = 'single';
        
        Nwin = length(GCM);
        
        Xb = [ones(Nwin,1), F];
        M.X = Xb;
        M.maxit = 64;  
        
        for ii = 1:3
            effect = ['A{' num2str(ii) '}'];    % no between-trial effects. Only resting-state condition
            field = {effect};
            
            PEBsubj = ['PEB_subject_' num2str(kk)  '_' effect '.mat'];
            PEBname = [Psave filesep PEBsubj];
%             if exist(PEBname, 'file')
%                 fprintf('\n Skipping %s \n', PEBname);
%                 continue;
%             end

            % Estimate the model
            %--------------------------------------------------------------------------
            PEB = spm_dcm_peb(GCM,M,field); 
            
            fprintf('\n Saving %s PEB model \n', PEBsubj);
            save(PEBname, 'PEB');
        end
    end   
end

%%  III level: between-subject analysis (testing for experience effect)
%--------------------------------------------------------------------------
if fitPEBofPEBs
    close all
    clc

    age = importdata([Pmetadata filesep 'age.mat']);

    effect = 1;
    PEBfiles = dir([Psave filesep 'PEB_*A{' num2str(effect) '}.mat']);

    
    Nsubj = length(PEBfiles);
    PEBgroup = {};
    for kk = 1:Nsubj
        PEBfilename = PEBfiles(kk).name;
        PEBgroup{kk,1} = importdata([Psave filesep PEBfilename]);
    end

    % get the "experience" covariate for analysis
    exp = importdata([Pmetadata filesep 'experience_selected_withIntermediates.mat']);

    % between-subject design matrix
    exp1 = zeros(Nsubj, 1);
    exp1(exp==1) = -1;
    exp1(exp==2) = 1;
    exp2 = zeros(Nsubj, 1);
    exp2(exp==2) = -1;
    exp2(exp==3) = 1;
    exp = exp - mean(exp);
    exp1 = exp1 - mean(exp1);
    exp2 = exp2 - mean(exp2);
    Xb = [ones(Nsubj, 1), exp];
    
    M = struct();    
    M.Q = 'all';
    M.X = Xb;
    M.maxit = 64;

    PEBgroupFitted = spm_dcm_peb(PEBgroup, M);
    [BMA,BMR] = spm_dcm_peb_bmc(PEBgroupFitted);
    close all

    GCM = importdata(GCMfiles(1).name);
    spm_dcm_peb_review(BMA,GCM{1});

end

%% Figure editing (exemplary code - adjust it based on your needs ...) 

% titles = {'Forward connections', 'Backward connections', 'Lateral connections'};
% regressor = {'Mean', 'DCT1', 'DCT2', 'DCT3', 'DCT4', 'DCT5'};
% Nconn = 6;%length(Snames{effect});
% Ncov = 6;
% 
% f = gcf();
% % f.Position = [-1.8934   -0.1342    1.8800    0.7936]*1e3;
% f.Position = [0.0010    0.0490    1.5360    0.7408]*1e3;
% f.CurrentAxes.XTickLabel = repmat(1:Nconn, [1 Ncov]);
% f.CurrentAxes.XTickLabelRotation = 0;
% f.CurrentAxes.LineWidth = 1.5;
% xlabel ''
% ylabel 'Posterior effect size'
% % title(titles{effect});
% title('');
% % txt = Snames{effect};
% % t = text(18.2,f.CurrentAxes.YLim(2)*0.75,txt, 'FontSize', 18);
% 
% f.CurrentAxes.YLim = [f.CurrentAxes.YLim(1) f.CurrentAxes.YLim(2)+0.05];
% 
% hold on
% txt = regressor{1};
% % t = text(Nconn/2+0.25,f.CurrentAxes.YLim(2)*0.90,txt, 'FontSize', 24);
% for kk = 1:Ncov-1
%     xline(kk*Nconn+0.5, 'k-', 'LineWidth', 2);
%     txt = regressor{kk+1};
% %     t = text(Nconn/2+0.25+kk*Nconn,f.CurrentAxes.YLim(2)*0.90,txt, 'FontSize', 24);
% end
% 
% f.CurrentAxes.FontSize = 24;
