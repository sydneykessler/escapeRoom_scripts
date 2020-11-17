% trying to use cal_fix_pupil to extract fixations
% cal_fix_pupil func is: 
%   /data/projects/ying/street_view/

% load test file
%  eeglab
sub01room1 = load_xdf('sub01_room1.xdf');
    % proeyegaze is stream 4 in this file
%%
% separate out inputs for cal_fix_pupil
gaze_raw = sub01room1{1,4}.time_series;
eye_open_idx = gaze_raw(26:27,:);
pupil_loc = gaze_raw(5:10,:);
srate = round(sub01room1{1,4}.info.effective_srate);

test_data = [pupil_loc; eye_open_idx];
%%
% Input:
%   [test_data]: pupil 3D location (n by time)
%                n = 6 for left_xyz, right_xyz
%                n = 8 for left_xyz, right_xyz, left_eye_open_idx, right_eye_open_idx
%                eye_open_idx: eye openess [0, 1]
%   [srate]: sampling rate
%   [calibration_data]: fixation data for defining threshold. Dimension is
%   same as test_data.
func_path = '/data/projects/ying/street_view/visual_search_in_VR/eye_movement/';
chdir(func_path)
%addpath('/data/projects/ying/street_view/visual_search_in_VR/eye_movement/cal_fix_pupil.m')

fix_struct = cal_fix_pupil(test_data,srate);

%% test validity
sanity_check(fix_struct);  % in dependencies
% [General information]
% ---------------------
% Exeriment length: 20.22 min
% Calibration data: False
% Eye open index: True
% Fix definition: velocity
% Average number of blink per min: 5.54 (average for adults: 10)
% Data missing rate: 3.080%
% ====================
% [Threshold setting]
% ---------------------
% Angle threshold: 1.00 deg
% Angular speed threshold: 91.67 deg/sec
% Fixation portion: 61.4%
% ====================

