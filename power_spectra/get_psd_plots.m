%% Generating plots for each channel w/spectra for each group

%TODO!!
%       normalize y axis
%% parameters
output_path = '/data/projects/ying/VR/escapeRoom/power_spectra';

addpath(genpath('/data/projects/ying/VR/escapeRoom/scripts'))
addpath(genpath(output_path))

all_chans = {'Fp1', 'Fp2', 'F3', 'F4', 'C3', 'C4', 'P3', 'P4', 'O1', ...
    'O2', 'F7', 'F8', 'T7', 'T8', 'P7', 'P8', 'Fz', 'Cz', 'Pz', 'M1', ...
    'M2', 'AFz', 'CPz', 'POz'};

% load colors (in scripts>dependencies
color_ref = load('color_reference.mat');
color_ref = color_ref.color_ref;

% line styles
line_styles = {'-','--','-.',':'};

% emotions (for legend)
emotion_colors = {'Happy','Angry','Sad','Thinking','Questioning','Lost','Ambivalent'};
emotion_legend_labels = {'Happy = yellow', 'Angry = red', 'Sad = dark blue'...
    'Thinking = blue', 'Questioning = pink', 'Lost = dark green', ...
    'Ambivalent = mint'}; 
emotion_ref = color_ref(1).emotion_ref;

puzzle_colors = {'Puzzle 1', 'Puzzle 2', 'Puzzle 3', 'After completion'};
puzzle_legend_labels = {'1 = blue', '2 = darkblue', '3 = navy'...
    'Finished = violet'};  
puzzle_ref = color_ref(1).puzzle_ref;

fprintf('-----Set Parameters-----\n')

%% INDIVIDUAL PLOTS

subNum = '05';

% load room
room = load(['sub' subNum '_powerSpectra.mat']);
room = room.room;
   
% for each room
for k=1:3 
    roomNum = k;
    num_surveys = size(room(k).survey,2);
    
    % for each chan
    for m=1:length(all_chans)
        % which channel (str)
        chan_label = all_chans{m};
        
        % does this room have this channel? check first survey. if not, move on
        these_channels = room(k).survey(1).chans;
        these_chans = cellfun(@cell2mat, these_channels, 'UniformOutput', false);  % converting cells

        hasChan = ismember(chan_label, these_chans);
        
        if hasChan
            these_colors = cell(1,num_surveys);  % temp storage for legend
            figure
            % check if each survey has this chan; if so, plot power spectra
            for n=1:num_surveys
                these_channels = room(k).survey(n).chans;
                these_chans = cellfun(@cell2mat, these_channels, 'UniformOutput', false);  % converting cells

                % returns logical of where channel is in channel list for this
                % data set (since some bad channels were removed)
                which_chan = ismember(these_chans, chan_label);

                % load in freqs and spectra
                these_freqs = room(k).survey(n).freqs(1:55);
                these_spectra = room(k).survey(n).spectra(which_chan,1:55);

                % figure out which emotion; get color based on that
                this_emotion = room(k).survey(n).emotion;
                % add these emotions to legent
                these_emotions{n} = cell2mat(this_emotion);
                this_color = color_ref{2,ismember(emotion_colors, this_emotion)};
                
                this_intensity = room(k).survey(n).intensity;  % UNUSED
                this_linestyle = line_styles{n};

                % plot freq x spectra, color
                plot(these_freqs, these_spectra, 'color', this_color, ...
                    'LineStyle',this_linestyle, 'LineWidth',1.5)
                hold on

            end

            % only show applicable emotions in legend
            legend_colors = cell(1,num_surveys);
            for p=1:num_surveys
                legend_emotions_idx = ismember(emotion_colors, these_emotions{p});
                legend_colors{p} = puzzle_colors{legend_emotions_idx};
            end
            
            legend(legend_colors)

            % add labels
            title(['Room ' num2str(roomNum) ': ' chan_label ' Power Spectra'])
            xlabel('Freq (Hz)')
            ylabel('Log Power Spectral Density')
            
            % save
            filename = ['sub' subNum '_room' num2str(roomNum) '_' chan_label '_spectra.fig'];
            folderpath = [output_path '/' chan_label];
            saveas(gcf, fullfile(folderpath, filename))
            
            fprintf('----Finished %s for Room %d----\n', chan_label, k)
        else
            
            fprintf('No %s for Room %d\n', chan_label, k)
            
        end
    end
    
    close all

end


%% GROUP PLOTS

% which phases?
phase = 'puzzle';  % alternatively: 'puzzle'
subs2plot = {'05','06','08','09','10','11'};

% which chans
% all_chans = {'Fp1', 'Fp2', 'F3', 'F4', 'C3', 'C4', 'P3', 'P4', 'O1', ...
%     'O2', 'F7', 'F8', 'T7', 'T8', 'P7', 'P8', 'Fz', 'Cz', 'Pz', 'M1', ...
%     'M2', 'AFz', 'CPz', 'POz'};

% make struct of all subs to plot
all_subs = struct();
% load in subs2plot
for p=1:length(subs2plot)
    this_sub = load(['sub' subs2plot{p} '_powerSpectra.mat']);
    all_subs.sub(p) = this_sub;
end
    % access this like:
        % all_subs.sub(1).room(1).survey(1) 
        % will give the first survey from room 1 for subject 5

        
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++       
%% for plotting surveys

roomNum = '1';

if strcmp('survey',phase)
    % for each channel
    for q=1:length(all_chans)
        % which channel (str)
        chan_label = all_chans{q};
        
        % fig with 6 subplots
        figure;
        set(gcf,'position',[0,0,1300,600]) %TODO change dimensions
        suptitle(['PSD by Survey - ' chan_label ' (Room 1)' ]);
 
        % for each sub
        for r=1:length(subs2plot)
            % if sub has channel
            
            % does this room have this channel? check first survey. if not, move on
            these_channels = all_subs.sub(r).room(1).survey(1).chans;
            these_chans = cellfun(@cell2mat, these_channels, 'UniformOutput', false);  % converting cells

            hasChan = ismember(chan_label, these_chans);

            if hasChan
                num_surveys = size(all_subs.sub(r).room(1).survey,2);
                
                for n=1:num_surveys
                    % returns logical of where channel is in channel list for this
                    % data set (since some bad channels were removed)
                    which_chan = ismember(these_chans, chan_label);

                    % load in freqs and spectra
                    these_freqs = all_subs.sub(r).room(1).survey(n).freqs(1:55);
                    these_spectra = all_subs.sub(r).room(1).survey(n).spectra(which_chan,1:55);

                    % figure out which emotion; get color based on that
                    this_emotion = all_subs.sub(r).room(1).survey(n).emotion;
                    % add these emotions to legend
                    these_emotions{n} = cell2mat(this_emotion);
                    this_color = emotion_ref{2,ismember(emotion_colors, this_emotion)};

                    this_intensity = all_subs.sub(r).room(1).survey(n).intensity;  % UNUSED
                    this_linestyle = line_styles{n};

                    % plot freq x spectra, color
                    subplot(3,2,r)
                    plot(these_freqs, these_spectra, 'color', this_color, ...
                        'LineStyle',this_linestyle, 'LineWidth',1.5)
                    hold on
                end

                % only show applicable emotions in legend
                legend_colors = cell(1,num_surveys);
                for p=1:num_surveys
                    legend_emotions_idx = ismember(emotion_colors, these_emotions{p});
                    legend_colors{p} = emotion_legend_labels{legend_emotions_idx};
                end

                legend(legend_colors)

                % add labels
                title(['Sub' subs2plot{r}])
                xlabel('Freq (Hz)')
                ylabel('Log Power Spectral Density')
                
            end  
        end

        % save
        filename = ['room' num2str(roomNum) '_' chan_label '_survey_spectra.png'];
        folderpath = [output_path '/' chan_label];
        saveas(gcf, fullfile(folderpath, filename))

        fprintf('----Finished %s----\n', chan_label)
        
        
    end
    
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++     
%% for plotting puzzles
elseif strcmp('puzzle', phase)
    
    % same as emotions, except want to list time period somewhere...
        % for each channel
    for q=1:length(all_chans)
        % which channel (str)
        chan_label = all_chans{q};
        
        % fig with 6 subplots
        figure;
        set(gcf,'position',[0,0,1300,600]) %TODO change dimensions
        suptitle(['PSD by Puzzle Completion - ' chan_label ' (Room 1)' ]);
 
        % for each sub
        for r=1:length(subs2plot)
            % if sub has channel
            
            % does this room have this channel? check first survey. if not, move on
            these_channels = all_subs.sub(r).room(1).puzzle(1).chans;
            these_chans = cellfun(@cell2mat, these_channels, 'UniformOutput', false);  % converting cells

            hasChan = ismember(chan_label, these_chans);

            if hasChan
                num_puzzles = size(all_subs.sub(r).room(1).puzzle,2);
                this_time = zeros(1,num_puzzles);
                
                for n=1:num_puzzles
                    % returns logical of where channel is in channel list for this
                    % data set (since some bad channels were removed)
                    which_chan = ismember(these_chans, chan_label);

                    % load in freqs and spectra
                    these_freqs = all_subs.sub(r).room(1).puzzle(n).freqs(1:55);
                    these_spectra = all_subs.sub(r).room(1).puzzle(n).spectra(which_chan,1:55);

                    % figure out how much time it took
                    start_time = all_subs.sub(r).room(1).puzzle(n).time(1);
                    end_time = all_subs.sub(r).room(1).puzzle(n).time(2);
                    this_time(n) = round(end_time - start_time, 1);
                    
                    this_color = puzzle_ref{2,n};

                    % plot freq x spectra, color
                    subplot(3,2,r)
                    plot(these_freqs, these_spectra, 'color', this_color, ...
                         'LineWidth',1.5)
                    hold on
                end

                % only show applicable emotions in legend
                legend_colors = cell(1,num_puzzles);
                legend_labels = cell(1,num_puzzles);
                for p=1:num_puzzles
                    legend_labels{p} = [puzzle_colors{p} ' (' num2str(this_time(p)) ' min)'];
                    legend_colors{p} = puzzle_legend_labels{p};
                end

                legend(legend_labels)
                % legend(legend_colors)

                % add labels
                title(['Sub' subs2plot{r}])
                xlabel('Freq (Hz)')
                ylabel('Log Power Spectral Density')
                
            end  
        end

        % save
        filename = ['room' num2str(roomNum) '_' chan_label '_puzzle_spectra.png'];
        folderpath = [output_path '/' chan_label];
        saveas(gcf, fullfile(folderpath, filename))

        fprintf('----Finished %s----\n', chan_label)
        
        
    end
    
end


%% TODO:
% replace color_ref in survey plots with emotion_ref
% try survey plots
% fix color in puzzle plots
% test