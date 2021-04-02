%% remove_baseline:
%  returns a dataset (room[#]_sub[#]_ICA.set) with the baseline part 
%  (which has been concatted onto the end) removed

% input: 
%     EEG - eeglab EEG structure
% output:
%     new_EEG - eeglab EEG structure w/o last 2ish minutes of baseline

function new_EEG = remove_baseline(EEG)

% get loc of last boundary
idx = get_marker_idx(EEG, 'boundary');
last_boundary = idx(length(idx));
% convert to seconds
boundary = (cell2mat({EEG.event(last_boundary).latency})-1)/EEG.srate;

% select only that section
new_EEG =  pop_select(EEG, 'time', [1 boundary]);

