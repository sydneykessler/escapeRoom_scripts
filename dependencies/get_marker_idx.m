%% get_marker_idx:
%  given an EEG set, 

% input: 
%     EEG - eeglab EEG struct containing events
%     marker - str, name of relavent event code
% output:
%     idx - array of event indices (double)

function idx = get_marker_idx(EEG, marker)

events = EEG.event;
events = {events.type};
isEvent= cellfun(@(x)isequal(x, marker), events);
[idx] = find(isEvent);