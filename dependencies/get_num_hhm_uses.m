%%  get_num_hhm_uses
%  (requires get_marker_idx func) given an EEG set, determines how many
%  times the subject turned on the heatmap (based on 'start' marker)

% input: 
%     EEG - eeglab EEG struct containing events
% output:
%     num_uses - (double) number of instances subject turned on hhm


function num_uses = get_num_hhm_uses(EEG)

marker = 'Enable Heatmap';

events = EEG.event;
events = {events.type};
isEvent= cellfun(@(x)isequal(x, marker), events);
[idx] = find(isEvent);

num_uses = length(idx);