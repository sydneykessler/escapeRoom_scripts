%% strip coords
% gets rid of the coordinates following "Start/End" of teleportation
% GrabMarker labels for easier grouping

% input: 
%     grab_markers - grab marker time series (cell)
% output:
%     new_grab_markers - grab_markers but with coords removed

function new_grab_markers = strip_coords(grab_markers)

new_grab_markers = cellfun(@(x) regexprep(x, ':(\S+\s\S+\s\S+)',''), grab_markers, 'UniformOutput', false);

