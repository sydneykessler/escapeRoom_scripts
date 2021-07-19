% script for generating clean data to apply AMICA weights to (full time
% period of experiment, no windows removed)

% set parameters
subs2run = {'12','13','14','15','16','17','18'};
addpath(genpath('/data/projects/ying/VR/escapeRoom/scripts'))

%%
for i=3:length(subs2run)
    subNum = subs2run{i};
    roomNum = '1';
    
    chdir(['/data/projects/ying/VR/escapeRoom/sub' subNum '/room' roomNum])
    addpath([pwd  '/baseline_clean'])

    % load reref and bsl EEG files
    EEG = pop_loadset(['room' roomNum '_sub' subNum '_reref.set']);
    bsl_EEG = pop_loadset(fullfile([pwd  '/baseline_clean'],['room' roomNum '_sub' subNum '_baseline_reref_chRm.set']));
    
    bad_chans = load(['badchans_' subNum '_' roomNum '.mat']);
    bad_channels_ASR = bad_chans.bad_channels_ASR;

    % remove bad chans 
    EEG = pop_select(EEG,'nochannel', bad_channels_ASR);

    % run burst correction 
    EEG = clean_asr(EEG, 5, [], [], [], bsl_EEG);
    
    % remove baseline (that had been appended to end of dataset)
    EEG = remove_baseline(EEG);

    % save
    outfile = ['room' roomNum '_sub' subNum '_asr_full.set'];
    EEG = pop_saveset(EEG, outfile, pwd); 
    
end
