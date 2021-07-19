% add AMICA weights

%%
%eeglab

subs2run = {'12','13','14','15','16','17','18'};

for p=1:length(subs2run)

    %% define parameters
    subNum = subs2run{p}; %'03';
    num_models = 5;
    mod_path = 'five_mods';

    % add paths
    mainpath = '/data/projects/ying/VR/escapeRoom/multi_model_AMICA';
    datapath = [mainpath '/input_data'];
    modelspath = [mainpath '/amica_output'];
    scriptspath = [mainpath '/scripts'];
    outpath = [mainpath '/data_w_models'];

    %%
    chdir(mainpath)
    addpath(datapath, genpath(modelspath),  genpath(scriptspath), genpath(outpath))

    fprintf('-------------Set Parameters-------------\n')

    %%  load reref file (pre-ASR)

    for i=1
        roomNum  =  num2str(i);

        %% load clean data
        infile = ['room'  roomNum '_sub' subNum '_asr_full.set'];
        inputpath = ['/data/projects/ying/VR/escapeRoom/sub' subNum '/room' roomNum];
        EEG = pop_loadset(infile, inputpath); 

        %% load in weights

        outdir = [modelspath filesep mod_path '/sub' subNum '/amicaout_room' roomNum '_5mods'];

        % load weights
        modout = loadmodout15(outdir);

        for j=1:num_models
            % load individual ICA model into EEG struct
            model_index= j;
            EEG.icawinv= modout.A(:,:,model_index);
            EEG.icaweights= modout.W(:,:,model_index);
            EEG.icasphere= modout.S;
            EEG = eeg_checkset(EEG);

            EEG.model_prob= 10.^modout.v;

            %% save
            outfile = ['sub' subNum '_room' roomNum  '_mod' num2str(j) '.set'];
            outdatapath = [outpath '/room' roomNum];
            EEG = pop_saveset(EEG, outfile, outdatapath); 

            fprintf('----Saved Room %d Model %d----\n',i,j)
        end

    end
end
