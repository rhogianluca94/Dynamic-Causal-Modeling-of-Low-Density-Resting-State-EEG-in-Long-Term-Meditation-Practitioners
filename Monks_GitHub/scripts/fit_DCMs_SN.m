Pmodels = fullfile(Pbase, [filesep 'models' filesep 'SN' filesep]);
Pdata = fullfile(Pbase, 'spm_datasets_anon');
Psave = fullfile(Pmodels, 'GCM_fitted');

use_parfor = 0;

winStart = 61;
winStop = 240;

files = dir([Pmodels filesep 'GCM*.mat']);
%%
if ~exist(Psave, 'dir')
    mkdir(Psave);
end

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
    GCM = importdata([Pmodels filesep files(kk).name]);
    GCMout = {};
    for ii = winStart%:winStop
        tmpDCM = GCM{ii};
        
        % Prendi solo il nome del file (es: subject_1.mat)
        [~, name, ext] = fileparts(tmpDCM.xY.Dfile);
        setname = [name, ext];
        
        % Ricostruisci il percorso corretto usando fullfile
        Dfile = fullfile(Pdata, setname);
        
        % AGGIORNAMENTO CRITICO:
        % 1. Aggiorna il percorso stringa
        tmpDCM.xY.Dfile = Dfile;
        
        % 2. Forza SPM a ricollegare il dataset (evita il popup)
        % spm_dcm_check_descr verifica la coerenza tra DCM e dataset
        try
            tmpDCM = spm_dcm_ext_check(tmpDCM); 
        catch
            % Se spm_dcm_ext_check non è disponibile, assicurati almeno 
            % che il file esista fisicamente
            if ~exist(Dfile, 'file')
                error('Il file %s non esiste!', Dfile);
            end
        end

        tmpDCM.options.Nmodes = 5;
        tmpDCM.M.hE = 20;       
        GCMout{ii-winStart+1} = tmpDCM;
    end
    
    GCM_out = spm_dcm_fit(GCMout, use_parfor, Psave);
    save([Psave filesep 'GCMout_' setname], 'GCM_out');
    
end