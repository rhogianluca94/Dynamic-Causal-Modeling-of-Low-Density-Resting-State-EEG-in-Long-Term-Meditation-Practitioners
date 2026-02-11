% clear
% clc

Pdata = fullfile(Pbase, [filesep 'models' filesep 'DMN' filesep 'GCM_fitted']);
Psave = fullfile(Pbase, [filesep 'models' filesep 'DMN' filesep 'fitted_adjusted']);

if ~exist(Psave, 'dir')
    mkdir(Psave);
end

files = dir([Pdata filesep 'GCM*.mat']);

use_parfor = 1;

%%
if use_parfor
    p = gcp('nocreate');
    try
        isParpool = p.Connected;
    catch
        isParpool = 0;
    end
    if(~isParpool)
        c = parcluster('local');
        numWorkers = c.NumWorkers;
        parpool(numWorkers);
    end
end


for kk = 1:2%length(files)
    GCM = importdata([Pdata filesep files(kk).name]);
    for ii = 1%:length(GCM)
        tmpDCM = GCM{ii};
        setname = split(tmpDCM.xY.Dfile, filesep);
        setname = setname{end};
        tmpDCM.M.P = tmpDCM.Ep; % parameters init
        tmpDCM.M.hE = 8;        % switch off overfitting
        GCM{ii} = tmpDCM;
    end
    
    GCM_out = spm_dcm_fit(GCM, use_parfor, Psave);
    save([Psave filesep 'GCMout_' setname], 'GCM_out');
    
end