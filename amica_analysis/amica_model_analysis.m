% analysis of AMICA models

eeglab

%% add paths
mainpath = '/data/projects/ying/VR/escapeRoom/multi_model_AMICA'; 
    %^^^ replace with your own and comment this out
scriptspath = [mainpath '/scripts'];  % this is the main folder of the repo; change name accordingly
datapath = [mainpath '/data_w_models']; % path to data (includes subfolders)

addpath(genpath(scriptspath), genpath(datapath))

%% load in EEG sets
% this is just loading in one set as a sample to get you started - change
% it however you see fit!

roomNum  = '1';
modelNum = '1';

roompath = [datapath  '/room' roomNum];
infile = ['room'  roomNum '_mod' modelNum '.set'];
EEG = pop_loadset(infile, roompath); 



