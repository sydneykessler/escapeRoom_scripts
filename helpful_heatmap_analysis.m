%% Helpful Heatmap Analysis
% exploratory analysis of if using the heatmap in room 1 has any
% interesting effects

%% ------SET UP------
% import raw streams
% eeglab
subNum = '03';
roomNum = '1';
main_path = ['/data/projects/ying/VR/escapeRoom/sub' subNum '/room' roomNum];
fig_path = [main_path '/hhm_analysis/figures'];
table_path = [main_path '/hhm_analysis/tables'];
chdir([main_path '/raw']);

sub3_rm1 = load_xdf('sub03_room1.xdf');

% colors for figs  
purple = [85;26;139]./255;
pink = [208;32;144]./255;
blue_1 = [30 144 255]./255;
purple_2 = [224 102 255]./255;
dark_orange = [139 69 19]./255;
grey_1 = [105 105 105]./255;
rose = [255 193 193]./255;

%% ------GET HEATMAP VALUES------
% get important info %%TODO: general statement to find_stream_num
eye_openness = sub3_rm1{1,6}.time_series(27,:); % going off of right eye
hhmv = sub3_rm1{1,6}.time_series(37,:); % hhmv--> helpful heatmap value
time_stamps = sub3_rm1{1,6}.time_stamps;
% replace hhmv when eye is closed with NaN
hhmv(eye_openness==-1) = NaN;

% find time_stamps for heatmap enable/disable
heatmap_stream = sub3_rm1{1, 5}.time_series;
heatmap_timestamps = sub3_rm1{1, 5}.time_stamps;

% get times for heatmap events
find_hhm = cellfun(@(x) regexp(x, '\w+\sHeatmap'), heatmap_stream, 'UniformOutput', false);
hhm_logical = cellfun(@isempty,find_hhm);
hhm_times = heatmap_timestamps(~hhm_logical);

% get indices for those time stamps
[minValues, hhm_idx] = min(abs(hhm_times - time_stamps.'));


%% ------GET SURVEY INFO------

% load in surveys
chdir(main_path)
surveys_full = load('sub03_room1_surveys.mat'); %NOTE: REPLACE W/GENERAL STATEMENT LATER
surveys = surveys_full.T;

% find surveys stream
survey_stream = find_stream_num(sub3_rm1, 'SurveyReport');
% get survey timestamps
survey_timestamps = sub3_rm1{1, survey_stream}.time_stamps;
% get indices for those time stamps
[minValues, survey_idx] = min(abs(survey_timestamps - time_stamps.'));
survey_idx(5) = size(time_stamps,2); % add index for last time stamp

% add col to surveys table for reference later
surveys.color = {blue_1; dark_orange; grey_1; grey_1};

% add col for color
% this is for reference only
% emotion_colors = {{'thinking', blue_1}{'questioning', purple_2}{'lost',grey_1}};

%% ------PLOT #1: FULL EXPERIMENT------
% divide into parts
% plot parts (time vs. heatmap value) to see if there's any variation
% between parts; see if there's any visible trend
xvals = time_stamps;
yvals = hhmv;
x_first_view = time_stamps(hhm_idx(1):hhm_idx(2));
y_first_view = hhmv(hhm_idx(1):hhm_idx(2));
x_second_view = time_stamps(hhm_idx(3):hhm_idx(4));
y_second_view = hhmv(hhm_idx(3):hhm_idx(4));

x0=xvals(1);
y0=0;
width=1900;
height=400;

%% plot
figure
set(gcf,'position',[x0,y0,width,height])
% plot background
area(xvals, yvals, 'FaceColor',	[0 0 1], 'EdgeColor',[0 0 1]);
% overlay heatmap viewing color
hold on
area(x_first_view, y_first_view, 'FaceColor', [1 1 0], 'EdgeColor',[1 1 0]);
hold on 
area(x_second_view, y_second_view, 'FaceColor', [1 1 0], 'EdgeColor',[1 1 0]);

% adding in survey data:
% for each emotion, plot emotion line
% plchldr = 1;
for k=1:size(surveys,1)
    hold on
    xvals_emotion = time_stamps(survey_idx(k): survey_idx(k+1));
    % plchldr = survey_idx(k); 
    yvals_emotion = 325*ones(1,length(xvals_emotion));
    
    plot(xvals_emotion, yvals_emotion, 'Color', cell2mat(surveys.color(k)), 'LineWidth', 10)
end

% plot points where survey is
hold on
scatter(time_stamps(survey_idx(1:4)), 325*ones(length(survey_idx)-1,1), 'Marker', 'o', 'MarkerEdgeColor', rose, 'MarkerFaceColor', rose, 'SizeData', 80);

% add final touches
xlabel('Time Stamp', 'FontSize',  14)
ylabel('Heatmap value', 'FontSize',  14)
%set(gca,'fontsize',20)
title('Heatmap values (sub03 room1)', 'FontSize',  16)

%%
chdir(fig_path)
savefig('hhmv_full_experiment.fig')

%% ------SEPARATE HHMV BY SECTION------

% dividing into sections, separated by when the heatmap is turned on
i = hhmv(1:hhm_idx(1));  % before its turned on
ii = hhmv(hhm_idx(1)+1:hhm_idx(2));  % during first time turned on
iii = hhmv(hhm_idx(2)+1:hhm_idx(3));  %  after first time turned on
iv = hhmv(hhm_idx(3)+1:hhm_idx(4));  % during second time turned on
v = hhmv(hhm_idx(4)+1:end);  % after second time turned on

full_parts = {i, ii, iii, iv, v};
full_parts_names = {'i', 'ii','iii','iv','v'};

%% time segment to look at
time_frame = 5; % in seconds
end_idx = 90*time_frame;

% for plots:
xlim_max_1 = ceil(max([i(length(i)-end_idx:end) iii(1:end_idx) ii]));
xlim_max_2 = ceil(max([iii(length(iii)-end_idx:end) v(1:end_idx) iv]));
ylim_max = 0.17;

%% separate parts for plotting
before_first = i(length(i)-end_idx:end);
during_first = ii;
after_first = iii(1:end_idx);
before_second = iii(length(iii)-end_idx:end);
during_second = iv;
after_second = v(1:end_idx);

parts = {before_first, during_first, after_first, before_second, during_second, after_second};
parts_names = {'before_first', 'during_first', 'after_first', 'before_second', 'during_second', 'after_second'};

%% ------PLOT #2: HHMV DISTRIBUTIONS BY SECTION------
figure
set(gcf,'position',[0,0,1000,600])
suptitle(sprintf('%d second intervals', time_frame))

subplot(3, 2, 1)
first = histogram(i(length(i)-end_idx:end), 100, 'FaceColor', [0 0 1], 'EdgeColor', [0 0 1]);
first.Normalization = 'pdf';
title('Part i (before hhm)', 'FontSize', 12)
ylabel('Freq', 'FontSize', 10)
xlim([0 xlim_max_1])
ylim([0 ylim_max])

subplot(3, 2, 3)
first = histogram(ii, 100, 'FaceColor', pink, 'EdgeColor', pink);
first.Normalization = 'pdf';
title('Part ii (during hhm, 1st try)', 'FontSize', 12)
ylabel('Freq', 'FontSize', 10)
xlim([0 xlim_max_1])
ylim([0 ylim_max])

subplot(3, 2, 5)
second = histogram(iii(1:end_idx), 100, 'FaceColor', [0 0 1], 'EdgeColor', [0 0 1]);
second.Normalization = 'pdf';
title('Part iii (after hhm)', 'FontSize', 12)
ylabel('Freq', 'FontSize', 10)
xlabel('HHMV', 'FontSize', 10)
xlim([0 xlim_max_1])
ylim([0 ylim_max])

subplot(3, 2, 2)
third = histogram(iii(length(iii)-end_idx:end), 100, 'FaceColor', purple, 'EdgeColor', purple);
third.Normalization = 'pdf';
title('Part iii (before hhm)', 'FontSize', 12)
xlim([0 xlim_max_2])
ylim([0 ylim_max])

subplot(3, 2, 4)
first = histogram(iv, 100, 'FaceColor', pink, 'EdgeColor', pink);
first.Normalization = 'pdf';
title('Part iv (during hhm, 2nd try)', 'FontSize', 12)
xlim([0 xlim_max_2])
ylim([0 ylim_max])

subplot(3, 2, 6)
fourth = histogram(v(1:end_idx), 100, 'FaceColor', purple, 'EdgeColor', purple);
fourth.Normalization = 'pdf';
title('Part v (after hhm)', 'FontSize', 12)
xlabel('HHMV', 'FontSize', 10)
xlim([0 xlim_max_2])
ylim([0 ylim_max])

%%
chdir(fig_path)
savefig(['hhmv_dist_' num2str(time_frame) 's.fig'])

%%
% -----TODO: standardize all axis, convert yaxis to relative freq
% -----------run some kind of significance test
% -----------plot when survey occurs on overall plot
% -----------plot interval before/after hhp (% during?) for small second
% intervals (like a segment of the first plot)
%  ----------plot dist during heatmap


% (Just during heatmap dists)
% figure
% set(gcf,'position',[0,0,700,400])
% suptitle(sprintf('%d second intervals', time_frame))
% subplot(1, 2, 1)
% first = histogram(ii, 100, 'FaceColor', pink, 'EdgeColor', pink);
% first.Normalization = 'pdf';
% title('Part ii (during hhm, 1st try)', 'FontSize', 12)
% ylabel('Freq', 'FontSize', 10)
% xlabel('HHMV', 'FontSize', 10)
% %xlim([0 xlim_max_1])
% %ylim([0 0.17])
% subplot(1, 2, 2)
% first = histogram(iv, 100, 'FaceColor', pink, 'EdgeColor', pink);
% first.Normalization = 'pdf';
% title('Part iv (during hhm, 2nd try)', 'FontSize', 12)
% xlabel('HHMV', 'FontSize', 10)
%
% filename = strcat('hhmv_dist_', num2str(time_frame), '_seconds.png');
% saveas(gcf, filename);

%% ------COMPARE SUMS OF VALS <10 FOR EACH PART------
% see how many values <10 for each part
num_of_parts = size(parts,2);  % this should be 6
count = zeros(num_of_parts,1);
percentage = zeros(num_of_parts,1);

for j=1:num_of_parts
    this_part = parts{j};
    count(j) = sum(this_part <= 10);
    percentage(j) = count(j)/size(this_part, 2)*100;
end

% less_than_10 = table(transpose(parts_names), count, percentage);

% for 5 seconds
% NOTE: to get this, changed  time_frame variable from 10 to 5, and
% overwrote parts variables; left less_than_10 variable intact
less_than_10 = table(transpose(parts_names), count, percentage);
% chdir(table_path)
% save(['less_than_10_' num2str(time_frame) 's_increment_.mat'], 'less_than_10')

%% ------HEAD VELOCITY ANALYSIS------
% does head velocity change with relation to hhm usage?

% 3d angular velocities
ang_vs = sub3_rm1{1,6}.time_series(23:25, :);

% divide into sections 
i = ang_vs(:, 1:hhm_idx(1));
ii = ang_vs(:, hhm_idx(1)+1:hhm_idx(2));
iii = ang_vs(:, hhm_idx(2)+1:hhm_idx(3));
iv = ang_vs(:, hhm_idx(3)+1:hhm_idx(4));
v = ang_vs(:, hhm_idx(4)+1:end);

full_parts = {i, ii, iii, iv, v};
full_parts_names = {'i', 'ii','iii','iv','v'};

coords = ['x'; 'y'; 'z'];

%%
% add first row
for k=1:3
    % set up zeros col
    eval([coords(k) '_aves = zeros(5,1);']);
        % ref: x_aves = zeros(5);
    % for each part, get average velocity
    for m=1:5
        % ref: x_aves(m) = mean(abs(i(1,:)));
        eval([coords(k) '_aves(m) = mean(abs(' cell2mat(full_parts_names(m)) '(' num2str(k) ',:)));'])
    end
end

full_ang_v_table = table(x_aves, y_aves,z_aves, 'RowNames', full_parts_names);
% chdir(table_path)
% save('ave_head_ang_v_full.m', 'full_ang_v_table')

%% same, for definted time segments

time_period_names = {'20s', '10s', '5s'};
time_periods = [20,10,5];

for p=1:3
    % define times
    time_frame = time_periods(p);
    end_idx = 90*time_frame;

    % separare parts
    before_first = i(:,length(i)-end_idx:end);
    during_first = ii;
    after_first = iii(:,1:end_idx);
    before_second = iii(:,length(iii)-end_idx:end);
    during_second = iv;
    after_second = v(:,1:end_idx);

    parts = {before_first, during_first, after_first, before_second, during_second, after_second};
    parts_names = {'before_first', 'during_first', 'after_first', 'before_second', 'during_second', 'after_second'};

    coords = ['x'; 'y'; 'z'];

    % for this time segment, get aves
    for k=1:3
        % set up zeros col
        eval([coords(k) '_aves = zeros(6,1);']);
            % ref: x_aves = zeros(5);
        % for each part, get average velocity
        for m=1:6
            % ref: x_aves(m) = mean(abs(i(1,:)));
            % fprintf([coords(k) '_aves(m) = mean(abs(' cell2mat(parts_names(m)) '(' num2str(k) ',:)));'])
            eval([coords(k) '_aves(m) = mean(abs(' cell2mat(parts_names(m)) '(' num2str(k) ',:)));'])
        end
    end

    % put in aptly named table
    % ref: full_ang_v_table = table(x_aves, y_aves,z_aves, 'RowNames', full_parts_names);
    eval(['ang_v_table_' cell2mat(time_period_names(p)) ' = table(x_aves, y_aves, z_aves, ''RowNames'', parts_names);'])
end

ang_head_v = struct('full', full_ang_v_table, 'twenty', ang_v_table_20s, 'ten', ang_v_table_10s, 'five', ang_v_table_5s);
save('ang_head_v_struct.m', 'ang_head_v')
%  s = struct('a',[1 2 3])

%% plot head velocity

ylim_max = 0.8;
xlim_max = 7;
figure
% full for reference
set(gcf,'position',[0,0,2000,800])
subplot(2, 3, 2)
suptitle('Ave. Angular Head Velocity')
%  
plot((1:1:5), ang_head_v.full.x_aves, 'Color', 'r', 'Marker', 'o')
hold on
plot((1:1:5), ang_head_v.full.y_aves, 'Color', 'b', 'Marker', 'o')
hold on
plot((1:1:5), ang_head_v.full.z_aves, 'Color', 'g', 'Marker', 'o')
ylim([0 ylim_max])
ylabel('Ave. Velocity', 'FontSize', 10)
xlabel('HHM Period', 'FontSize', 10)
xticks(1:1:5)
xticklabels(full_parts_names)
legend('x','y','z')
title('Full Experiment')

% 20 seconds
subplot(2, 3, 4) 
plot((1:1:6), ang_head_v.twenty.x_aves, 'Color', 'r', 'Marker', 'o')
hold on
plot((1:1:6), ang_head_v.twenty.y_aves, 'Color', 'b', 'Marker', 'o')
hold on
plot((1:1:6), ang_head_v.twenty.z_aves, 'Color', 'g', 'Marker', 'o')
ylim([0 ylim_max])
ylabel('Ave. Velocity', 'FontSize', 10)
xlabel('HHM Period', 'FontSize', 10)
xticks(1:1:6)
xticklabels(parts_names)
xtickangle(30)
legend('x','y','z')
title('20s')
% 10 seconds
subplot(2, 3, 5) 
plot((1:1:6), ang_head_v.ten.x_aves, 'Color', 'r', 'Marker', 'o')
hold on
plot((1:1:6), ang_head_v.ten.y_aves, 'Color', 'b', 'Marker', 'o')
hold on
plot((1:1:6), ang_head_v.ten.z_aves, 'Color', 'g', 'Marker', 'o')
ylim([0 ylim_max])
xlabel('HHM Period', 'FontSize', 10)
xticks(1:1:6)
xticklabels(parts_names)
xtickangle(30)
legend('x','y','z')
title('10s')
% 5 seconds
subplot(2, 3, 6) 
plot((1:1:6), ang_head_v.five.x_aves, 'Color', 'r', 'Marker', 'o')
hold on
plot((1:1:6), ang_head_v.five.y_aves, 'Color', 'b', 'Marker', 'o')
hold on
plot((1:1:6), ang_head_v.five.z_aves, 'Color', 'g', 'Marker', 'o')
ylim([0 ylim_max])
xlabel('HHM Period', 'FontSize', 10)
xticks(1:1:6)
xticklabels(parts_names)
xtickangle(30)
legend('x','y','z')
title('5s')

%%
chdir(fig_path)
savefig('ang_head_v.fig')
saveas(gcf,'ang_head_v.png')

%%



%% ERSP analysis (moved)
% 
% % load eeg
% infile = strcat('room',roomNum,'_sub',subNum,'_ICA.set');
% EEG = pop_loadset(infile); 
% %EEG = pop_loadset(infile, main_path); 
% 
% % get heatmap event indices relative to EEG
% events = EEG.event;
% events = {events.type};
% isEnable = cellfun(@(x)isequal(x,"Enable Heatmap"), events);
% [start_idx] = find(isEnable);
% isDisable= cellfun(@(x)isequal(x,"Disable Heatmap"), events);
% [end_idx] = find(isDisable);
% 
% % convert event latencies to seconds
% starts = (cell2mat({EEG.event(start_idx).latency})-1);
% hhm_start_times = starts./EEG.srate;
% 
% ends = (cell2mat({EEG.event(end_idx).latency})-1);
% hhm_end_times = ends./EEG.srate;
% 
% %% preprocess eeg
% % remove badcomps
% EEG = pop_subcomp(EEG, EEG.badcomps, 0, 0);
% 
% % run asr/clean artifacts 
% clean_EEG = clean_artifacts(EEG, 'WindowCriterion', 'off', 'ChannelCriterion', 'off');  % will not remove data or channels
% vis_artifacts(clean_EEG, EEG);  % can turn this line off if you don't want to plot
% 
% %% separate by times
% 
% outpath = strcat(main_path, "/segmentedByHHM");
% whichTimes = ["first", "second"];
% time_frame = 5;
% 
% for i=1:2
%    fprintf(whichTimes(i))
%    fprintf('Before:')
%    sprintf('start: %d s', (hhm_start_times(i)-time_frame)/60)
%    sprintf('end: %d s', hhm_start_times(i)/60)
%    before_EEG =  pop_select(clean_EEG, 'time', [hhm_start_times(i)-time_frame hhm_start_times(i)]);
%    outfile_before = strcat(whichTimes(i), '_',num2str(time_frame), 's_before.set');
%    pop_saveset(before_EEG);
%    % pop_saveset(before_EEG, outfile_before, outpath); <--this isnt working
%    % for whatever reason >:( doing it manually for now
%    
%    fprintf('After:')
%    sprintf('start: %d s', hhm_end_times(i)/60)
%    sprintf('end: %d s', (hhm_end_times(i)+time_frame)/60)
%    after_EEG =  pop_select(clean_EEG, 'time', [hhm_end_times(i) hhm_end_times(i)+time_frame]);
%    outfile_after = strcat(whichTimes(i), '_',num2str(time_frame), 's_after.set');
%    pop_saveset(after_EEG); %, outfile_after, outpath);
%    
% end
% 


%% Statistical tests to investigate differences
% ANOVA between before (i), after 1st viewing (iii), after 2nd viewing (v)?

% t-test for first 10 seconds before, 10 seconds after (i & iii)

% t-test for first 10 seconds before, 10 seconds after (iii & v)
% t-test for first 5 seconds before, 5 seconds after (i & iii)
% t-test for first 5 seconds before, 5 seconds after (iii & v)

% between part I and part III, and part III and part V (at different time
% intervals?) 
% factor in emotions from survey?