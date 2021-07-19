% get tables for when looking in new place

%% set parameters
basepath = '/data/projects/ying/VR/escapeRoom';
addpath(genpath([basepath '/scripts']))

% only using subs w/o split datasets
subs2run = {'03','05','07','09','10','11','12','13','15','16'};

heatmap_uses = load('heatmap_uses.mat'); % as of now, MUST update this manually
heatmap_uses = heatmap_uses.heatmap_uses;

time_frame = 120; % to match ersp analysis

%% for each subject...
for i=1:length(subs2run)
    
    % declare subNum/how many times they used the heatmap
    subNum = subs2run{i};
    
    isSub = cellfun(@(x)isequal(x,['sub' subNum]), heatmap_uses);
    [sub_idx] = find(isSub);
    hhm_uses = heatmap_uses{sub_idx,2};
    
    hhm.sub(i).subNum = subNum;
    hhm.sub(i).hhm_uses = hhm_uses;

    %% import data
    chdir([basepath '/sub' subNum '/room1/raw']);
    this_data = load_xdf(['sub' subNum '_room1.xdf']);
    
    % get idx of stream w/eye gaze data
    gaze_stream_num = find_stream_num(this_data, 'ProEyeGaze');
    srate = this_data{1, gaze_stream_num}.info.effective_srate; %<--should be close to 90
    
    % get eye data
    eye_openness = this_data{1, gaze_stream_num}.time_series(27,:); % going off of right eye
    hhmv = this_data{1, gaze_stream_num}.time_series(37,:);% hhmv--> helpful heatmap value
    time_stamps = this_data{1, gaze_stream_num}.time_stamps;
    
    % replace hhmv when eye is closed with NaN
    hhmv(eye_openness==-1) = NaN;
    
    % find time_stamps for heatmap enable/disable
    hhm_stream_num = find_stream_num(this_data, 'TestMarker');
    hhm_markers = this_data{1, hhm_stream_num}.time_series;
    hhm_timestamps = this_data{1, hhm_stream_num}.time_stamps;

    %% get times for heatmap events
    find_hhm = cellfun(@(x) regexp(x, '\w+\sHeatmap'), hhm_markers, 'UniformOutput', false);
    hhm_logical = cellfun(@isempty,find_hhm);
    hhm_times = hhm_timestamps(~hhm_logical);

    % get indices for those time stamps --> these should line up with raw 
    %       EEG/eye gaze
    [minValues, hhm_idx] = min(abs(hhm_times - time_stamps.'));
    
    % check to be sure for every hhm on, there is a hhm off 
    if mod(length(hhm_idx),2) ~= 0
        fprintf('Unbalanced heatmap markers - check event stream\n')
        return
    end
    
    if hhm_uses == 1
        start_idx = hhm_idx(1);
        end_idx = hhm_idx(2);
    elseif hhm_uses == 2
        start_idx = [hhm_idx(1) hhm_idx(3)];
        end_idx = [hhm_idx(2) hhm_idx(4)];
    else
        fprintf('Sometimes fucky with the hhm vals\n')
        return
    end
    
    % store indices in struct
    hhm.sub(i).start_idx = start_idx;
    hhm.sub(i).end_idx = end_idx;    
    hhm.sub(i).values = hhmv;
    
    
    %% for each use of heatmap...
    for j=1:hhm_uses
        time_seg = srate*time_frame; % how many pnts are in 2 minutes
        
        % for each segment, get hhmvs
        % rounding to nearest int 
        before = hhmv(round(start_idx(j)-time_seg, 0):start_idx(j));  
        during = hhmv(start_idx(j):end_idx(j));
        try
            after = hhmv(end_idx(j):round(end_idx(j)+time_seg, 0));
        catch  
            % if time between last use of hhm and end is less than 2 min,
            % then just go until the end (and make note in struct)
            after = hhmv(end_idx(j):length(hhmv));
            hhm.sub(i).use(j).after_duration = length(after)/90;
        end
        
        % get duration of hhm use
        duration = length(during)/90;
        
        % group parts together
        parts = {before, during, after};
        
        % create placeholders for count and percentage
        count = zeros(3,1);
        percentage = zeros(3,1);
        
        % get counts and percentage for each part
        for k=1:3
            count(k) = sum(parts{k} <= 10);
            percentage(k) = count(k)/size(parts{k}, 2)*100;
        end
        
        % store in struct
        hhm.sub(i).use(j).count_under_ten = count;
        hhm.sub(i).use(j).percentage_under_ten = percentage;
        hhm.sub(i).use(j).duration =  duration;
        hhm.sub(i).use(j).std = std(parts{k}, 'omitnan');
        
    end
    
end

chdir([basepath '/hhm_analysis'])
save('hhm_values.mat','hhm')

% to plot sub 1's count for the  first and  second 
%  bar([hhm.sub(1).use(1).count hhm.sub(1).use(2).count])


