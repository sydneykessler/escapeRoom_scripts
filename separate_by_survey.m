%% separate by survey
% generates separate files for each survey segment

%% define parameters
subNum = '02';
roomNum = '1';
% base path
mainpathbase = '/data/projects/ying/VR/escapeRoom/'; 

chdir([mainpathbase '/sub' subNum '/room' roomNum])

% load in ICA'd EEG
EEG = pop_loadset(['room' roomNum '_sub' subNum '_ICA.set']);

%% get indices of surveys
events = EEG.event;
events = {events.type};
isSurvey = cellfun(@(x)isequal(x,'survey'), events);
[survey_idx] = find(isSurvey);

surveys = load(['sub' subNum '_room' roomNum '_surveys.mat']);
    
for i=1:size(surveys,1)  % number of surveys
    % get latency of beginning section
    if i==1
       beginning = 1;
    else
       beginning = ending; 
    end
    % get latency of end of section and convert to seconds
    if i<size(surveys,1)
        ending = (cell2mat({EEG.event(survey_idx(i)).latency})-1)/EEG.srate;
    else
    % last element
        ending = EEG.times(end)/1000;  % /1000 since EEG.times is in miliseconds
    end
    
    % select only that section
    new_EEG =  pop_select(EEG, 'time', [beginning ending]);
    
    % remove badcomps
    new_EEG = pop_subcomp(new_EEG, new_EEG.badcomps, 0, 0);

    % run asr/clean artifacts 
    clean_EEG = clean_artifacts(new_EEG);
    vis_artifacts(clean_EEG, new_EEG);  % can turn this line off if you don't want to plot
    
    % save/export
    outfile =  strcat('sub', subNum,'_room',roomNum,'_survey',num2str(i),'.set');
    outpath = strcat(main_path, '/segmentedBySurvey');
    pop_saveset(new_EEG, outfile, outpath);
end
