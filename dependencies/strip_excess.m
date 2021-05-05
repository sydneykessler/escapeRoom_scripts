%% strip excess
% gets rid of the "Right hand grabs:" and "Left hand grabs:" part of
% GrabMarker labels for easier viewing

% input: 
%     grab_markers - grab marker time series (cell)
% output:
%     new_grab_markers - grab_markers but with leading text removed

function new = strip_excess(grab_markers)

% get rid of the "Right hand grabs:" and "Left hand grabs:"
new = cellfun(@(x) regexprep(x, '\w+\shand\s\grabs:',''), grab_markers, 'UniformOutput', false);

% get rid of the coordinates following "Start/End" of teleportation
new = cellfun(@(x) regexprep(x, ':(\S+\s\S+\s\S+)',''), new, 'UniformOutput', false);

% rename candlestick
new = cellfun(@(x) regexprep(x, 'candlestick.001','candlestick_puzzle'), new, 'UniformOutput', false);

% rename clue.002
new = cellfun(@(x) regexprep(x, 'clue.002', 'clue_2'), new, 'UniformOutput', false);

% rename num_combos
new = cellfun(@(x) regexprep(x, 'num_combo_2','num_combo_1'), new, 'UniformOutput', false);
new = cellfun(@(x) regexprep(x, 'num_combo_3','num_combo_2'), new, 'UniformOutput', false);
new = cellfun(@(x) regexprep(x, 'num_combo_3.001','num_combo_3'), new, 'UniformOutput', false);

% get rid of ID's on objects w/multiples
new = cellfun(@(x) regexprep(x, '.\d{3}',''), new, 'UniformOutput', false);

% get rid of ID on brick_puzzle_piece
new = cellfun(@(x) regexprep(x, '\s\(\d\)',''), new, 'UniformOutput', false);





