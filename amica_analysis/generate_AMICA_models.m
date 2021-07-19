%% AMICA multiple-model analysis
% this script generates AMICA weights

% eeglab 

%% define parameters

subs2run = {'12','13','14','15','16','17','18'};

for p=2:length(subs2run)
    i = 1; % this is roomNum
    subNum = subs2run{p}; %'05';

    numprocs = 1;       % # of nodes (1-4: default 1)
    num_models = 5;     % # of models of mixture ICA
    max_threads = 24;   % # of threads (1-24: default = 24)

    mainpath = '/data/projects/ying/VR/escapeRoom/multi_model_AMICA';

    if num_models==5
        mod_path = 'five_mods';
    elseif num_models==8
        mod_path = 'eight_mods';
    else
        fprintf('---DEFINE MODEL PATH AND RERUN---\n')
        return
    end

    % add paths
    % datapath = [mainpath '/input_data'];
    datapath = ['/data/projects/ying/VR/escapeRoom/sub' subNum '/room' num2str(i)];
    outpath = [mainpath '/amica_output/' mod_path '/sub' subNum];

    addpath(datapath)
    addpath(outpath)

    fprintf('-------------Set Parameters-------------\n')

    %% load dataset
    %for i=1:3

    i=1;

    chdir(datapath)
    roomNum = num2str(i);
    fprintf('-------------ROOM %d-------------\n', i)
    filename = ['room' roomNum '_sub' subNum '_asr_nobsl.set'];
    
    EEG = pop_loadset(filename);
    fprintf('-------------Loaded file-------------\n')
    
    % create subject folder
    chdir(['/data/projects/ying/VR/escapeRoom/multi_model_AMICA/amica_output/' mod_path])
    if ~isfolder(['sub' subNum])
        mkdir(['sub' subNum])
    end

    outdir = [outpath '/amicaout_room' roomNum '_' num2str(num_models) 'mods/'];
    %% run
    fprintf('-------------Starting AMICA-------------\n')

    % run amica
    [weights,sphere,mods] = runamica15(EEG.data,'num_models',num_models, 'outdir',outdir, ...
        'numprocs', numprocs, 'max_threads', max_threads);

    fprintf('-------------Finished AMICA for %s-------------\n', subNum)
    % end
end
