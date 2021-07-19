% script to figure out if there was significant hhm usage, if there's no
% video to refer to

% doing this by looking at all the unique event markers (esp grab markers)
% that happen between the start and event of the hhm 

EEG = pop_loadset('room1_sub18_full.set');

% get start and end indices
start_hhm = get_marker_idx(EEG, 'Enable Heatmap');
end_hhm = get_marker_idx(EEG, 'Disable Heatmap');

% get all events
events = EEG.event;
events = {events.type};

try
    these_events = events(start_hhm(1):end_hhm(1));
catch % if there is no end marker for turning off hhm
    these_events = events(start_hhm(1):end);
end
outevents = transpose(unique(these_events));
