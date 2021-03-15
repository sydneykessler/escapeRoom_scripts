% add AMICA weights

%%
%eeglab

%% define parameters
subNum = '03';

% add paths
mainpath = '/data/projects/ying/VR/escapeRoom/multi_model_AMICA';
datapath = [mainpath '/input_data'];
modelspath = [mainpath '/output'];
scriptspath = [mainpath '/scripts'];
outpath = [mainpath '/data_w_models'];

%%
chdir(mainpath)
addpath(datapath, modelspath,  genpath(scriptspath), genpath(outpath))

fprintf('-------------Set Parameters-------------\n')

%%  load reref file (pre-ASR)

for i=3
    roomNum  =  num2str(i);
    
    %% load clean data
    infile = ['room'  roomNum '_sub' subNum '_asr_full.set'];
    EEG = pop_loadset(infile, datapath); 

    %% load in weights

    outdir = [modelspath filesep 'amicaout_room' roomNum];

    % load weights
    modout = loadmodout15(outdir);

    for j=1:8
        % load individual ICA model into EEG struct
        model_index= j;
        EEG.icawinv= modout.A(:,:,model_index);
        EEG.icaweights= modout.W(:,:,model_index);
        EEG.icasphere= modout.S;
        EEG = eeg_checkset(EEG);
        
        EEG.model_prob= 10.^modout.v;
        
        %% save
        outfile = ['room' roomNum  '_mod' num2str(j) '.set'];
        outdatapath = [outpath '/room' roomNum];
        EEG = pop_saveset(EEG, outfile, outdatapath); 
        
        fprintf('----Saved Room %d Model %d----\n',i,j)
    end

end

