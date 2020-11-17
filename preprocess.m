%% PREPROCESS EEG FOR ESCAPE ROOM
% Run through  **by section**  to preprocess data

%%
clear all
eeglab

%% define parameters
% subject
subNum = '01';
% which room
roomNum = '2';
% base path
mainpathbase = '/data/projects/ying/VR/escapeRoom/';  % <-- change accordingly

%% import, merge, and clean 
% declare paths
scripts_path = strcat(mainpathbase,'/scripts');  % where scripts are
main_path = strcat(mainpathbase,'sub', subNum, '/room', roomNum');  % where all the processed data goes
raw_path = strcat(main_path, '/raw'); % where the xdf files are

addpath(scripts_path)

chdir(main_path)
%%
% import and merge raw data (main file and baseline file, although some are
% missing a baseline file - don't worry about that)
EEG = import_xdf(subNum, raw_path);  

% add chanlocs
EEG.chanlocs = readlocs('Smarting24.ced'); 

% high pass filter (lower edge: 1 Hz, higher edge: 55)
[EEG, ~, ~] = pop_eegfiltnew(EEG, 'locutoff',1, 'hicutoff', 55);

% save
outfile = strcat('room',roomNum,'_sub',subNum,'_full.set');
EEG = pop_saveset(EEG, outfile, main_path); 

fprintf('-------------Imported xdf-------------\n')
%% find and remove weird channels  --> BY HAND!
    % sub01_room1: removed F4
    % sub01_room2: none
% plot scroll data to figure out which chans are weird, then you can
eegplot(EEG.data)
%%
% declare bad chans
badchans = [];  % <-- replace this, make a note in a txt file and/or this script about which one(s) you're removing

% remove bad channels
EEG = pop_select(EEG,'nochannel',badchans);
fprintf('-------------Removed bad channels-------------\n')

%% rereference with average
EEG = pop_reref(EEG, []); %empty brackets mean reref by average

%% get survey data and replace survey marker names
EEG = get_surveys(EEG, subNum, roomNum, main_path);  

%% save
outfile = strcat('room',roomNum,'_sub',subNum,'_reref.set');
EEG = pop_saveset(EEG, outfile, main_path); 

fprintf('-------------Saved-------------\n')

%% run ASR

% filter with asr 
EEG = clean_rawdata(EEG, 5, [0.25 0.75], 0.7, 4, 20, 0.2);  

% indices of channels removed by ASR
try
    [bad_channels_ASR] = find(EEG.etc.clean_channel_mask==0);
    badchansfile = strcat('badchans_', subNum, '_', roomNum, '.mat');
    save(badchansfile, 'bad_channels_ASR'); 
catch
    fprinf('No channels were removed\n');
end

%% save
outfile = strcat('room',roomNum,'_sub',subNum,'_asr.set');
EEG = pop_saveset(EEG, outfile, main_path); 
fprintf('-------------Saved-------------\n')

%% run AMICA on ASR file --> DO THIS IN THE GUI (Tools>Run AMICA) (use defaults)
% 1) File>Load existing dataset --> room#_sub##_asr.set
% 2) Tools>Run AMICA (can just use defaults)
% 3) Wait 1-2 hours until it's finished (2000 iters)

%% Once AMICA is finished, and an 'amicaout' file has been generated... 
%%  load reref file (pre-ASR)
infile = strcat('room',roomNum,'_sub',subNum,'_reref.set');
EEG = pop_loadset(infile, main_path); 

%% remove channels that ASR removed 
try
    badchans_asr = load(badchansfile);  
    EEG = pop_select(EEG,'nochannel',badchans_asr.bad_channels_ASR);
catch
    fprintf('No channels to remove\n');
end

%% apply AMICA weights

% declare directory
chdir(main_path)
outdir = [pwd filesep 'amicaout'];

% load weights
modout = loadmodout15(outdir);

% load individual ICA model into EEG struct
model_index= 1;
EEG.icawinv= modout.A(:,:,model_index);
EEG.icaweights= modout.W(:,:,model_index);
EEG.icasphere= modout.S;
EEG = eeg_checkset(EEG);
fprintf(strcat('-------------Loaded AMICA weights-------------\n'))


%% save
outfile = strcat('room',roomNum,'_sub',subNum,'_ICA.set');
EEG = pop_saveset(EEG, outfile, main_path);  

%% look at ICLabels --> BY HAND
% 1) in GUI, File>Load existing datset --> room#_sub#_ICA.set
% 2) Tools<ICLabel
% 3) To see each component individually:
%    comp = 1  % which component num to plot
%    pop_prop(EEG, 0, comp, NaN, {'freqrange',[2 50]});
% 4) once you've decided which are bad, fill out variables below

% declare good and bad ICAs --> FILL THIS IN
EEG.goodcomps = [ ];
EEG.badcomps = [ ];

%% save
outfile = strcat('room',roomNum,'_sub',subNum,'_ICA.set');
EEG = pop_saveset(EEG, outfile, main_path);  

%% separate by survey

% get indices of surveys
events = EEG.event;
events = {events.type};
isSurvey = cellfun(@(x)isequal(x,'survey'), events);
[survey_idx] = find(isSurvey);
    
for i=1:size(T,1)  % number of surveys
    % get latency of beginning section
    if i==1
       beginning = 1;
    else
       beginning = ending; 
    end
    % get latency of end of section and convert to seconds
    if i<size(T,1)
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

%%








