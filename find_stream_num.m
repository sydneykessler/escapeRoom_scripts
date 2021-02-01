%% function for finding which stream is which
% given full xdf file loaded in with eeglab, and which stream you're
% looking for, searches through streams to find it
%       located: /data/projects/ying/

% input: 
%     og_file - original xdf file w/multiple data streams (cell)
%     stream_name - which stream you want to find (str)
%           ex:
%             - EEG
%             - GrabMarker
%             - ProEyeMarker
%             - SurveyReport
%             - TestMarker (contains heatmap info)
%             - ProEyeGaze
% output:
%     which_stream - which cell contains that stream (double)

function which_stream = find_stream_num(og_file, stream_name)

numCells = size(og_file, 2);
which_stream = 'Cannot find stream :(';

for i=1:numCells
    if strcmp(og_file{1, i}.info.name, stream_name)
        which_stream = i;
    end
end

end