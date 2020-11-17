%% find, rename, and grab surveys
%  given an EEG struct, gets survey data and exports it in a table as a matlab
%  variable, and replaces the names of the survey event markers with
%  survey1, 2, etc

% input: 
%     EEG - eeglab EEG structure
%     subNum - subject number (int)
%     roomNum - room number (Int)
%     main_path - path that surveys are saved in (string)
% output:
%     EEG - eeglab EEG structure with changed event marker names

function EEG = get_surveys(EEG, subNum, roomNum, main_path)

% get list of all markers
all_markers = unique({EEG.event.type});
% save only surveys to cell array
which_surveys = cellfun(@(x) regexp(x, '\d+:.+', 'match'), all_markers, 'UniformOutput', false);
% get indices for which aren't surveys
survey_idx = cellfun(@isempty, which_surveys);
% cell array of only surveys
survey_contents_arr = all_markers(~survey_idx);
% !!!!!!!!Need to account for 0 surveys
num_surveys = length(survey_contents_arr);

%%
% init empty cell arrays to fill
emotion = cell(num_surveys, 1);
emotion_intensity = cell(num_surveys, 1);
experience = cell(num_surveys, 1);
flow = cell(num_surveys, 1);  
room_col = cell(num_surveys, 1);
room_col(:) = {roomNum};

% put survey contents into table
for i=1:num_surveys
    % extract contents
    content = cell2mat(survey_contents_arr(i));
    % split by colon  
    content = regexp(content, ':','split');
    % get invidual scores
    emotion{i} = regexp(convertCharsToStrings(content(4)),'[A-Z][a-z]+', 'match');
    emotion_intensity{i} = regexp(convertCharsToStrings(content(4)),'\d+',  'match');
    experience{i} = regexp(convertCharsToStrings(content(5)),'\d+', 'match');
    flow{i} = regexp(convertCharsToStrings(content(6)),'\d+', 'match');
end

% save into table and export
T = table(emotion, emotion_intensity, experience, flow, room_col);
table_filename = strcat('sub', subNum,'_room',roomNum,'_surveys.mat');
chdir(main_path);
save(table_filename, 'T')

% change survey names
for j=1:num_surveys
    for i=1:length(EEG.event)
         if strcmp(EEG.event(i).type, survey_contents_arr{j})
             EEG.event(i).type = 'survey';
         end
    end
end

fprintf('-------------Exported surveys-------------\n')

%%
% testing to see if names actually got changed
% indices for sub01 room 1 surveys:
    % survey 1: 2691
    % survey 2: 5428
    % survey 3: 8501
% events = EEG.event;
% events = {events.type};
% for i=1:num_surveys
%     isSurvey = cellfun(@(x)isequal(x,survey_contents_arr{i}), events);
%     [idx] = find(isSurvey);
%     fprintf('%d\n', idx)
% end