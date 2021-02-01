%% Use cal_fix_pupil to extract fixations from escapeRoom data
% cal_fix_pupil func is: 
%   /data/projects/ying/street_view/

%% load file
%  eeglab

% define parameters
subNum = '03';
roomNum = '1';
fileName = ['sub', subNum, '_room', roomNum, '.xdf'];

sub_path = ['/data/projects/ying/VR/escapeRoom/sub', subNum, '/room', roomNum];
raw_path = ['/data/projects/ying/VR/escapeRoom/sub', subNum, '/room', roomNum,'/raw'];
addpath('/data/projects/ying/street_view/');
addpath('/data/projects/ying/VR/escapeRoom/scripts');
chdir(raw_path)

% load in file
og_file = load_xdf(fileName);

%% prepare inputs
% find which stream is gaze 
gaze_stream = find_stream_num(og_file, 'ProEyeGaze');

% separate out inputs for cal_fix_pupil
gaze_raw = og_file{1,gaze_stream}.time_series; % 2d coords
eye_open_idx = gaze_raw(26:27,:); 
pupil_loc = gaze_raw(5:10,:); 
gip = gaze_raw(11:13,:); 
srate = round(og_file{1,gaze_stream}.info.effective_srate);

test_data = [pupil_loc; eye_open_idx];
%% get fixations
% change dir to use function
% func_path = '/data/projects/ying/street_view/visual_search_in_VR/eye_movement/';
% chdir(func_path)

fix_struct = cal_fix_pupil(test_data,srate);

%% test validity
sanity_check(fix_struct);  % in dependencies folder of visual_search_in_VR

%% export
chdir(sub_path)

fixations = [fix_struct.eye_fixation.eye_fix_idx; test_data; gip];
outfilename = ['escapeRoom_sub', subNum, '_rm', roomNum, '_fix.mat'];
save(outfilename,'fixations');
% also export as csv?
% writematrix(og_file, 'escapeRoom_sub1_rm1_fix.csv') <--change ame

