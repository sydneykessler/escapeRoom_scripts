%% remove_baseline:
%  returns a dataset (room[#]_sub[#]_ICA.set) with the baseline part 
%  (which has been concatted onto the end) removed

% input: 
%     EEG - eeglab EEG structure
% output:
%     new_EEG - eeglab EEG structure w/o last 2ish minutes of baseline

function new_EEG = remove_baseline(EEG)

% get loc of last boundary
idx = get_marker_idx(EEG, 'boundary');
last_boundary = idx(length(idx));

% get time in  seconds
boundary_time = (cell2mat({EEG.event(last_boundary).latency})-1)/EEG.srate;

% check is baseline is between 1.5-3.5 minutes; if not, this is probably not
% the baseline boundary --> quit
end_time = EEG.times(end)/1000; 
length_of_boundary = end_time - boundary_time; 

if ~((length_of_boundary > 60*1.5) || (length_of_boundary < 60*3.5))
    fprintf('No baseline found - check boundary events\n')
    new_EEG = EEG;
    return
end

% select only that section
new_EEG = pop_select(EEG, 'time',[1 boundary_time]);



% get boundary latency
% boundary_lat = EEG.event(last_boundary).latency;
% % convert to pnts
% evtbeg = boundary_lat+EEG.srate*(-1); % one second before boundary
% 

%NEW (based on rmdat())
% get boundary latency
% boundary_lat = EEG.event(last_boundary).latency;
% evtbeg = boundary_lat+EEG.srate*(-1);
% boundary_time = (evtbeg-1)/EEG.srate;

