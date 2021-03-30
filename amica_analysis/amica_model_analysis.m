% analysis of AMICA models

clearvars; close all;

eeglab

%% add paths
<<<<<<< Updated upstream
mainpath = 'C:\Users\lelange\Documents\Leon\Forschung\SCCN\Escape_Room_AMICA_Analysis\amica_models_data'; 
%mainpath = '/data/projects/ying/VR/escapeRoom/multi_model_AMICA'; 
=======

%  parent path where all other data is
mainpath = '/data/projects/ying/VR/escapeRoom/multi_model_AMICA'; 
>>>>>>> Stashed changes
    %^^^ replace with your own and comment this out
scriptspath = [mainpath '/scripts'];  % this is the main folder of the repo; change name accordingly
datapath = [mainpath '/data_w_models']; % path to data (includes subfolders)

addpath(genpath(scriptspath), genpath(datapath))

<<<<<<< Updated upstream


%% plot model probability while loading in EEG sets

subNum = '03';
modelNum = '1'; %does not need to change, since I accidentally added
                %probabilities of all models per room to each dataset

figure(1), clf;

for actual_room = 1:3
    
    %% prepare plot and load data
    
    subplot(3,1,actual_room)

    roomNum  = num2str(actual_room);
    roompath = [datapath '/room' roomNum];
    infile = ['room' roomNum '_mod' modelNum '.set'];
    EEG = pop_loadset(infile, roompath); 

    
    %% get indices of surveys [adopted from "separate_by_survey.m"]
    events = EEG.event;
    events = {events.type};
    isSurvey = cellfun(@(x)isequal(x,'survey'), events);
    [survey_idx] = find(isSurvey);
    
    surveyspath = [mainpath '\surveys\'];
    surveys = load([surveyspath 'sub' subNum '_room' roomNum '_surveys.mat']);
    surveys =  surveys.T;
    
    % adding latencies to the surveys variable
    for i = 1:height(surveys)
        surveys.latency(i) = EEG.event(survey_idx(i)).latency;
    end
    
    %% start plotting
    
    imagesc(EEG.model_prob(:,:)); % plotting model probability across time series
    title(['room ' roomNum])
    xlabel('Time (min)') 
    xticks(0:EEG.srate*60:length(EEG.model_prob))
    xticklabels(0:(length(EEG.model_prob)/(EEG.srate*60)))
    ylabel('Model index')
    yticks(1:8)
    for i = 1:height(surveys)
        text(surveys.latency(i),-0.2,[surveys.emotion(i) '\downarrow'])
    end

end
=======
%% load in EEG sets
%  this is just loading in one set as a sample to get you started - change
%  it however you see fit!

% declare which room and model you want
roomNum  = '1';
modelNum = '1';

% generate path where that file will be
roompath = [datapath  '/room' roomNum];

% load in file as EEGLAB variable
infile = ['room'  roomNum '_mod' modelNum '.set'];
EEG = pop_loadset(infile, roompath); 

%% get EEG.event indices for surveys 
%  (referenced from separate_by_survey.m)

% get all events & associated vars
events = EEG.event; 
% get cell array of just event names
events = {events.type};
% generate bool of where the survey events are
isSurvey = cellfun(@(x)isequal(x,'survey'), events);
% get indices of where the bool is true 
[survey_idx] = find(isSurvey);
>>>>>>> Stashed changes

