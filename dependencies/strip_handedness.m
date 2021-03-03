%% strip handedness
% gets rid of the "Right hand grabs:" and "Left hand grabs:" part of
% GrabMarker labels for easier viewing

% input: 
%     grab_markers - grab marker time series (cell)
% output:
%     new_grab_markers - grab_markers but with leading text removed

function new_grab_markers = strip_handedness(grab_markers)

new_grab_markers = cellfun(@(x) regexprep(x, '\w+\shand\s\grabs:',''), grab_markers, 'UniformOutput', false);

