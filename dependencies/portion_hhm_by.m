%% select hhm portion

% given if  before, after, or during, and which hhm use, returns selected
% portion  of eeg


function outEEG = portion_hhm_by(EEG, which_phase, which_use, time_frame)

% check if varagin are good
if ~((which_use == 1) || (which_use == 2))
    fprintf('Please use valid input for which_use\n')
    return
end

% get all important idxs
[enable_idx] = get_marker_idx(EEG, 'Enable Heatmap');
[disable_idx] = get_marker_idx(EEG, 'Disable Heatmap');

% get latencies of idxs
% 1st or 2nd use of 'Enable'
evtlat_enable = EEG.event(enable_idx(which_use)).latency;
% 1st or 2nd use of 'Disable'
try
    evtlat_disable = EEG.event(disable_idx(which_use)).latency;
catch
    % if there is no disable to  match the endable, use last latency
    evtlat_disable = EEG.event(end).latency;
end

% a bunch of if statements to figure out idxs
if strcmp(which_phase, 'before')
    % get beginning and ending pnts
    % 5 min before hhm use
    evtbeg = evtlat_enable+EEG.srate*(-60*time_frame);
    evtend = evtlat_enable+EEG.srate*(1);
    
    % account for if time before heatmap is <5 min by setting start time to
    % 1
    if evtbeg < 0  
        evtbeg = 1;
    end

elseif strcmp(which_phase, 'during')
    % get beginning and ending pnts
    % period during hhm use
    evtbeg = evtlat_enable+EEG.srate*(-1);
    evtend = evtlat_disable+EEG.srate*(1);
    
elseif strcmp(which_phase, 'after')
    % get beginning and ending pnts
    % 5 min after hhm use
    evtbeg = evtlat_enable+EEG.srate*(-1);
    evtend = evtlat_disable+EEG.srate*(60*time_frame);
    
    % if 5 minutes extends past actual length of recording, use last 
    % point
    if evtend > EEG.pnts
        evtend = EEG.pnts-1;
    end
    
else
    fprintf('Please use valid input for which_phase\n')
    return
end

% select data 
outEEG = pop_select( EEG, 'point',[evtbeg evtend] );



%% for reference, if you want to select by 'time' instead of points:   
%  pop_rmdat
  
% translate to seconds
% for i=1:length(enable_idx)
%     % from pop_rmdat:
%     % evtbeg = evtlat+EEG.srate*timelims(1);
%     % evtend = evtlat+EEG.srate*timelims(2);
%     % array = [ array; evtbeg  evtend];
%     % EEG = pop_select(EEG, 'time', (array-1)/EEG.srate);
%     enable_seconds(i) = (EEG.event(enable_idx(i)).latency-EEG.event(1).latency)/EEG.srate; %1000; % (EEG.event(enable_idx(i)).latency-1)/EEG.srate;
% end
% 
% for i=1:length(disable_idx)
%     disable_seconds(i) = (EEG.event(disable_idx(i)).latency-EEG.event(1).latency)/EEG.srate;
% end
% 
% % a bunch of if statements to figure out idxs
% if strcmp(which_phase, 'before')
%     %start_pnt = enable_idx - 
%     start_time = enable_seconds(which_use) - 60*time_frame; 
%     % if start time of 5 minutes is before recording starts, use 1 seconds
%     % starting time
%     if start_time < 0  
%         start_time = 1;
%     end
%     
%     end_time = enable_seconds(which_use);
%     
%     evtlat = EEG.event(enable_idx(i)).latency;
%     evtbeg = evtlat+EEG.srate*(-60*time_frame);
%     evtend = evtlat+EEG.srate*(1);
% 
% elseif strcmp(which_phase, 'during')
%     evtbeg = 
%     start_time = enable_seconds(which_use);
%     try
%         end_time = disable_seconds(which_use);
%     catch
%         % assuming if there is no 'disable' to match the enable, hhm use
%         % extends to end of recording
%         end_time = EEG.times(end)/1000;
%     end
%     
% elseif strcmp(which_phase, 'after')
%     start_time = disable_seconds(which_use);
%     end_time = disable_seconds(which_use) + 60*time_frame;
%     % if 5 minutes extends past actual length of recording, use last time
%     % point
%     if end_time > EEG.times(end)/1000
%         end_time = EEG.times(end)/1000;
%     end
%     
% else
%     fprintf('Please use valid input for which_phase\n')
%     return
% end
% 
% array = [evtbeg  evtend];
% outEEG = pop_select(EEG, 'time', (array-1)/EEG.srate);
% % outEEG = pop_select(EEG, 'time', [evtbeg evtend]);
    
