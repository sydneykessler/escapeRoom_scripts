%% remove markers of a certain type
% using regex. mostly just "book_proxy"

% input: 
%     label - label name (str)
%     gaze_markers - unique gaze markers (cell)
% output:
%     new_gaze_markers - gaze_markers but with bad markers removed

function new_gaze_markers = remove_these_mrkrs(label, gaze_markers)

bad_phrase = strcat(label, '+'); % eg: "book_proxy"
which_bad = cellfun(@(x) regexp(x, bad_phrase, 'match'), gaze_markers, 'UniformOutput', false);
not_bad = cellfun(@isempty, which_bad);
new_gaze_markers = gaze_markers(not_bad);
