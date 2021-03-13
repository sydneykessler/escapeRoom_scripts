%% PREPROCESS EEG 

% Runing this script in full will generate:
    % room[#]_sub[#]_full.set
        % full data set (including baseline, if available) that has gone
        % through a [1-55]  bandpass filer and  has channel locations
    % room[#]_sub[#]_reref.set
        % above set that has been rerefered to the average and has had bad
        % channels removed by hand (if applicable)
    % room[#]_sub[#]_asr.set
        % above set that has used ASR to:
        %   - removed bad channels
        %   - clean sections without removing data
        %   - remove messy windows 
    % room[#]_sub[#]_ICA.set
        % rerefed file that contains ICA weights and parameters for 
        % suggested good and bad channels (but has NOT removed them)

%% INSTRUCTIONS
%  - Change the values in 'define paraments' section
%  - Run through  **by section**  to preprocess data
%  - You may need to make adjustments per dataset

%  if you have any questions, ask Sydney (sekessle at ucsd dot edu)

%% if eeglab is not already running, uncomment this
% clear all
% eeglab

%% define parameters
% subject
subNum = '03';
% which room
roomNum = '3';
% base path
mainpathbase = '/data/projects/ying/VR/escapeRoom/';  % <-- change accordingly
% is there a baseline file? If no, change to 0
isBaseline = 1;

%% import, merge, and clean 
% declare paths
scripts_path = [mainpathbase '/scripts'];  % where scripts are
main_path = [mainpathbase 'sub' subNum '/room' roomNum]; % specific sub/room path
raw_path = [main_path '/raw']; % where the xdf files are

chdir(main_path)

main_file_name = ['room' roomNum '_sub' subNum];

addpath(genpath(scripts_path))
addpath(raw_path)

if isBaseline
    % name baseline path
    bsl_path = [main_path '/baseline_clean']; % where clean baseline is stored
    % creates the baseline_clean folder if not already there
    if ~isfolder('baseline_clean')
       mkdir('baseline_clean')
    end
    % name baseline base name
    bsl_file_name = ['room' roomNum '_sub' subNum  '_baseline'];
    addpath(bsl_path)
end

%% import and merge raw data 
%  (main file and baseline file, although some are missing a baseline file - don't worry about that)

EEG = import_xdf(subNum, raw_path);  
%[EEG] = pop_loadxdf(['sub' subNum '_room' roomNum '.xdf'],'streamtype','EEG'); 

if isBaseline
    [bsl_EEG] = pop_loadxdf(['sub' subNum '_room' roomNum '_baseline.xdf'],'streamtype','EEG'); 
end

%%
% add chanlocs
EEG.chanlocs = readlocs('Smarting24.ced'); 

% high pass filter (lower edge: 1 Hz, higher edge: 55)
[EEG, ~, ~] = pop_eegfiltnew(EEG, 'locutoff',1, 'hicutoff', 55);

% save
outfile = [main_file_name '_full.set'];
EEG = pop_saveset(EEG, outfile, main_path); 

% same as above, but for baseline
if isBaseline
    bsl_EEG.chanlocs = readlocs('Smarting24.ced'); 
    [bsl_EEG, ~, ~] = pop_eegfiltnew(bsl_EEG, 'locutoff',1, 'hicutoff', 55);
    bsl_outfile = [main_file_name '_baseline_full.set'];
    bsl_EEG = pop_saveset(bsl_EEG, bsl_outfile, bsl_path); 
end

fprintf('-------------Imported xdf-------------\n')
%% find and remove weird channels  --> BY HAND!
    % sub01_room1: removed F4
    % sub01_room2: none
    % sub03_room1: removed AFz
% plot scroll data to figure out which chans are weird, then you can remove
eegplot(EEG.data)
%%
% declare bad chans
% !!!NOTE: for baseline files, must match OG files
badchans = [];  % <-- replace this, make a note in a txt file and/or this script about which one(s) you're removing

% remove bad channels
EEG = pop_select(EEG,'nochannel',badchans);

if isBaseline
    bsl_EEG = pop_select(bsl_EEG,'nochannel',badchans);
end

fprintf('-------------Removed bad channels-------------\n')

%% rereference with average
EEG = pop_reref(EEG, []); %empty brackets mean reref by average

if isBaseline
    bsl_EEG = pop_reref(bsl_EEG, []);
end

%% get survey data and replace survey marker names
EEG = get_surveys(EEG, subNum, roomNum, main_path);  

%% save
outfile = [main_file_name '_reref.set'];
EEG = pop_saveset(EEG, outfile, main_path); 

if isBaseline
    bsl_outfile = [main_file_name '_baseline_reref.set'];
    bsl_EEG = pop_saveset(bsl_EEG, bsl_outfile, bsl_path); 
end

fprintf('-------------Saved-------------\n')

%% run ASR

% if no baseline, just regular clean_rawdata
if ~isBaseline
    EEG = clean_rawdata(EEG, 5, [0.25 0.75], 0.7, 4, 20, 0.2); 
    
    % if channels removed, create file w/indices of channels removed by ASR
    try
        [bad_channels_ASR] = find(EEG.etc.clean_channel_mask==0);
        badchansfile = ['badchans_' subNum '_' roomNum '.mat'];
        save(badchansfile, 'bad_channels_ASR'); 
    catch
        fprinf('No channels were removed\n');
    end

% if there's a baseline, use that as references for ASR
else

    % Chi-Yuan's pseudo-code
    % % Remove bad channels using clean_rawdata without ASR function
    % EEG_rmbadCh = clean_rawdata(EEG, ... , -1 (where ASR cutoff parameter is), ... );
    % % Run ASR separately and assign clean section for calculating threshold by clean_asr
    % EEG_asr = clean_asr(EEG_rmbadCh, cutoff parameter, [], [], [], EEG_ref (the clean section in your recording));

    % only remove channels
    EEG_rmbadCh = clean_rawdata(EEG, -1, -1 , 0.7, -1, -1, -1);
        % ref: EEG = clean_rawdata(EEG, arg_flatline, arg_highpass, arg_channel, arg_noisy, arg_burst, arg_window)
        % OLD: EEG = clean_rawdata(EEG, 5, [0.25 0.75], 0.7, 4, 20, 0.2);  

    % if channels removed, create file w/indices of channels removed by ASR
    try
        [bad_channels_ASR] = find(EEG_rmbadCh.etc.clean_channel_mask==0);
        badchansfile = ['badchans_' subNum '_' roomNum '.mat'];
        save(badchansfile, 'bad_channels_ASR'); 
    catch
        fprinf('No channels were removed\n');
    end

    % remove chans from bsl
    bsl_EEG = pop_select(bsl_EEG,'nochannel', bad_channels_ASR);

    % Run ASR separately and assign clean section for calculating threshold by clean_asr
    EEG_interp = clean_asr(EEG_rmbadCh, 5, [], [], [], bsl_EEG);
    %   = clean_asr(Signal,StandardDevCutoff,WindowLength,BlockSize,MaxDimensions,ReferenceMaxBadChannels,RefTolerances,ReferenceWindowLength,UseGPU,UseRiemannian,MaxMem)

    % ASR, but just rejecting messy windows
    EEG = clean_rawdata(EEG_interp, -1, -1 , -1, -1, -1, 0.2);

end 

%% save
outfile = [main_file_name '_asr.set'];
EEG = pop_saveset(EEG, outfile, main_path); 
fprintf('-------------Saved-------------\n')

%% run AMICA on ASR file --> DO THIS IN THE GUI (Tools>Run AMICA) (use defaults)
% 1) File>Load existing dataset --> room#_sub##_asr.set
% 2) Tools>Run AMICA (can just use defaults)
% 3) Wait 1-2 hours until it's finished (2000 iters)

%% Once AMICA is finished, and an 'amicaout' file has been generated... 
%%  load reref file (pre-ASR)
infile = [main_file_name '_reref.set'];
EEG = pop_loadset(infile, main_path); 

%% remove channels that ASR removed 
try
    badchansfile = ['badchans_' subNum '_' roomNum '.mat'];
    badchans_asr = load(badchansfile);  
    EEG = pop_select(EEG,'nochannel',badchans_asr.bad_channels_ASR);
catch
    fprintf('No channels to remove\n');
end

%% apply AMICA weights

chdir([mainpathbase 'sub' subNum '/room' roomNum])

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
chdir(main_path)
outfile = [main_file_name '_ICA.set'];
EEG = pop_saveset(EEG, outfile, main_path);  

%% look at ICLabels --> BY HAND
% 1) in GUI, File>Load existing datset --> room#_sub#_ICA.set
% 2) Tools<ICLabel
% 3) To see each component individually:
%    comp = 1  % which component num to plot
%    pop_prop(EEG, 0, comp, NaN, {'freqrange',[2 50]});
% 4) once you've decided which are bad, fill out variables below

% plot all at once:
% for i=1:EEG.nbchan
%     pop_prop(EEG, 0, i, NaN, {'freqrange',[2 50]});
% end

%% declare good and bad ICAs --> FILL THIS IN
EEG.goodcomps = [1 2 3 5 8 9 10 11 12 15 16 17 18 21 22];
EEG.badcomps = [4 6 7 13 14 19 20];

%% save
outfile = [main_file_name '_ICA.set'];
EEG = pop_saveset(EEG, outfile, main_path);  



