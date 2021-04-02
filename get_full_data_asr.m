% script for generating clean data to apply AMICA weights to (full time
% period of experiment, no windows removed)

% set parameters
subNum = '03';
addpath(genpath('/data/projects/ying/VR/escapeRoom/scripts'))

for i=1:3
    roomNum = num2str(i);
    
    chdir(['/data/projects/ying/VR/escapeRoom/sub' subNum '/room' roomNum])
    addpath([pwd  '/baseline_clean'])

    % load reref and bsl EEG files
    EEG = pop_loadset(['room' roomNum '_sub' subNum '_reref.set']);
    bsl_EEG = pop_loadset(['room' roomNum '_sub' subNum '_baseline_reref.set']);

    bad_chans = load(['badchans_' subNum '_' roomNum '.mat']);
    bad_channels_ASR = bad_chans.bad_channels_ASR;

    % remove bad chans 
    EEG_rmbadCh = pop_select(EEG,'nochannel', bad_channels_ASR);
    bsl_EEG = pop_select(bsl_EEG,'nochannel', bad_channels_ASR);
    
    % run burst correction 
    EEG = clean_asr(EEG_rmbadCh, 5, [], [], [], bsl_EEG);
    
    % remove baseline (that had been appended to end of dataset)
    EEG = remove_baseline(EEG);

    % save
    outfile = ['room' roomNum '_sub' subNum '_asr_full.set'];
    EEG = pop_saveset(EEG, outfile, pwd); 
    
end
