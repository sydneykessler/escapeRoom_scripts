% remove bad  chans from rerefed version of baseline

function EEG = rm_chans_bsl(subNum)

path = ['/data/projects/ying/VR/escapeRoom/sub' subNum '/room1'];
baseline_path = ['/data/projects/ying/VR/escapeRoom/sub' subNum '/room1/baseline_clean'];
addpath(baseline_path)
chdir(path)

EEG = pop_loadset(['room1_sub' subNum '_baseline_reref.set']);

% save EEG baseline 
badchans = load(['badchans_' subNum '_1.mat']);
badchans = badchans.bad_channels_ASR;
EEG = pop_select(EEG,'nochannel',badchans);
EEG = pop_saveset(EEG, ['room1_sub' subNum '_baseline_reref_chRm.set'], baseline_path);
