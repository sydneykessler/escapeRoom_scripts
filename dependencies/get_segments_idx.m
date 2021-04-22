% script to get idx

% phases: 
% survey
% puzzle completion

function idx = get_segments_idx(EEG, which_segments, varargin)

%% parameter setting
p = inputParser;
p.KeepUnmatched = true;
addRequired(p,'EEG');
addRequired(p,'which_segments');
addParameter(p,'room',[]) % if 'puzzle', add room (str)

parse(p,EEG, which_segments ,varargin{:})

%%
if strcmp(which_segments, 'survey')
    idx = get_marker_idx(EEG, 'survey');
end

%%
if strcmp(which_segments, 'puzzle')
    room = p.Results.room;
    
    if strcmp(room, '1')
        puzzles = {'key_gold','book_table_proxy','key'};
        reverse_order = 0;  % meaning, look for the first occurence
        stream = 'ProEyeMarker'; % gaze stream
    elseif strcmp(room, '2')
        puzzles = {'Door_Controls','Window_Shutter','slider_puzzle_piece'}; 
        reverse_order = 1;  % meaning, look for the last occurence
        stream = 'GrabStream';
    elseif strcmp(room, '3')
        puzzles = {'PlunderbussPete_body','PlunderbussPete_Head','PlunderbussPete_Cape'};
        reverse_order = 0;  
        stream = 'ProEyeMarker';
    end
    
    %--------ONLY WORKS FOR ROOM1!!!!!--------%
    idx = [];
    for i=1:length(puzzles)
        try
            indices = get_marker_idx(EEG, puzzles{i});
            if ~reverse_order
                idx(end+1) = indices(1);
            else
                idx(end+1) = indices(end);
            end
        catch
            fprintf('Did not complete puzzle %d\n', i)
        end
    end
    
end