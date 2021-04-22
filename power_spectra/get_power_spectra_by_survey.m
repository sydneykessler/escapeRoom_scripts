% function to generate power spectra for entire subject by survey
% (referenced from epoch_and_reject in the sdma folder)
subs2run =  {'05','06','08','09','10','11'};

for p=1:length(subs2run)
    
    
    
    %% define parameters
    % subject
    subNum = subs2run{p}; %'05';

    % base path
    mainpathbase = '/data/projects/ying/VR/escapeRoom/';  % <-- change accordingly

    % declare paths
    scripts_path = [mainpathbase '/scripts'];  % where scripts are
    output_path = [mainpathbase 'power_spectra']; % where saved files will go

    addpath(genpath(scripts_path), genpath(output_path))

    %% FOR EACH ROOM
    for i=1

        roomNum = num2str(i);

        main_file_name = ['room' roomNum '_sub' subNum];

        maindata_path = [mainpathbase 'sub' subNum '/room' roomNum]; % specific sub/room path

        addpath(genpath(maindata_path))

        %% load survey

        survey = load(['sub' subNum  '_room' roomNum '_surveys.mat']);
        try
            survey = survey.T;
        catch
            survey = survey.survey.T;
        end

        num_surveys = size(survey, 1);

        chdir(output_path)

        %%
        if strcmp(subNum, 'sub03')
            %% for each survey, get spectra and freq

            for j=1:num_surveys

                % load survey data
                EEG = pop_loadset(['survey_' num2str(j) '.set'], data_path);

                % get chan labels
                allLabels = {};
                for chan = 1:length(EEG.chanlocs)
                    allLabels{chan} = {EEG.chanlocs(chan).labels};
                end

                %get spectra
                figure;
                [spectra, freqs] = pop_spectopo(EEG, 1, [],'EEG', 'freqrange', [1 55], 'noplot','on');

                %save labels and spectra in cell array
                room(j).survey(j).emotion = survey.emotion{j};
                room(j).survey(j).intensity = survey.emotion_intensity{j};
                room(j).survey(j).experience = survey.experience{j};
                room(j).survey(j).flow = survey.flow{j};

                room(j).survey(j).chans = allLabels;
                room(j).survey(j).spectra = spectra;
                room(j).survey(j).freqs = freqs;

            end

        else
            %%TODO!!!!! CHECK IF THIS WORKSSSSSS
            room = [];
            idx = [];

            % load in data
            EEG = pop_loadset(['room' roomNum '_sub' subNum '_ICA.set'], maindata_path);
            EEG = remove_baseline(EEG);

            % get chan labels
            allLabels = {};
            for chan = 1:length(EEG.chanlocs)
                allLabels{chan} = {EEG.chanlocs(chan).labels};
            end

            % get relevant indices
            idx = get_segments_idx(EEG, 'survey');

            % pad with beginning and ending
            idx = [1, idx, EEG.times(end)/1000];

            %% for each phase
            for k=1:size(survey,1)  %length(idx)-1

                %% select segment
                % get latency of beginning section
                if k==1
                   beginning = 1;
                else
                   beginning = (cell2mat({EEG.event(idx(k)).latency})-1)/EEG.srate;
                end
                % get latency of end of section and convert to seconds
                if k<length(idx)-1
                    ending = (cell2mat({EEG.event(idx(k+1)).latency})-1)/EEG.srate;
                else
                % last element
                    ending = idx(end);
                end

                fprintf('Beginning: %d\nEnding: %d\n', beginning, ending)

                % select only that section
                new_EEG =  pop_select(EEG, 'time', [beginning ending]);

                if size(new_EEG.times,2)/500 <120  % if data is shorter than 2 minutes
                    return
                else

                    %% clean
                    % remove badcomps
                    new_EEG = pop_subcomp(new_EEG, new_EEG.badcomps, 0, 0);

                    % run asr/clean artifacts 
                    clean_EEG = clean_artifacts(new_EEG, 'ChannelCriterion', 'off', 'LineNoiseCriterion', 'off');

                    %% get power spectra

                    %get spectra
                    figure;
                    [spectra, freqs] = pop_spectopo(clean_EEG, 1, [],'EEG', 'freqrange', [1 55], 'noplot','on');

                     %save labels and spectra in cell array
                    room(i).survey(k).emotion = survey.emotion{k};
                    room(i).survey(k).intensity = survey.emotion_intensity{k};
                    room(i).survey(k).experience = survey.experience{k};
                    room(i).survey(k).flow = survey.flow{k};

                    room(i).survey(k).chans = allLabels;
                    room(i).survey(k).spectra = spectra;
                    room(i).survey(k).freqs = freqs;
                end

            end

        end         
    end
    %% save power struct

    filename =  ['sub' subNum '_powerSpectra.mat'];
    save(filename, 'room')

    close all
    
    
end

%% make directories for each chan
% 
% for j=1:length(all_chans)
%     mkdir(all_chans{j})
% end
% 
% %% Generating plots for each channel w/spectra for each group
% 
% %TODO!!
% %       normalize y axis
% 
% % load room
% room = load('sub03_powerSpectra.mat');
% room = room.room;
% 
% % load colors (in scripts>dependencies
% color_ref = load('color_reference.mat');
% color_ref = color_ref.color_ref;
% 
% % line styles
% line_styles = {'-','--','-.',':'};
% 
% % emotions (for legend)
% emotion_colors = {'Happy','Angry','Sad','Thinking','Questioning','Lost','Ambivalent'};
% legend_labels = {'Happy = yellow', 'Angry = red', 'Sad = dark blue'...
%     'Thinking = blue', 'Questioning = pink', 'Lost = dark green', ...
%     'Ambivalent = mint'};   
%    
% % for each room
% for k=1:3 
%     roomNum = k;
%     num_surveys = size(room(k).survey,2);
%     
%     % for each chan
%     for m=1:length(all_chans)
%         % which channel (str)
%         chan_label = all_chans{m};
%         
%         % does this room have this channel? check first survey. if not, move on
%         these_channels = room(k).survey(1).chans;
%         these_chans = cellfun(@cell2mat, these_channels, 'UniformOutput', false);  % converting cells
% 
%         hasChan = ismember(chan_label, these_chans);
%         
%         if hasChan
%             these_colors = cell(1,num_surveys);  % temp storage for legend
%             figure
%             % check if each survey has this chan; if so, plot power spectra
%             for n=1:num_surveys
%                 these_channels = room(k).survey(n).chans;
%                 these_chans = cellfun(@cell2mat, these_channels, 'UniformOutput', false);  % converting cells
% 
%                 % returns logical of where channel is in channel list for this
%                 % data set (since some bad channels were removed)
%                 which_chan = ismember(these_chans, chan_label);
% 
%                 % load in freqs and spectra
%                 these_freqs = room(k).survey(n).freqs(1:55);
%                 these_spectra = room(k).survey(n).spectra(which_chan,1:55);
% 
%                 % figure out which emotion; get color based on that
%                 this_emotion = room(k).survey(n).emotion;
%                 % add these emotions to legent
%                 these_emotions{n} = cell2mat(this_emotion);
%                 this_color = color_ref{2,ismember(emotion_colors, this_emotion)};
%                 
%                 this_intensity = room(k).survey(n).intensity;  % UNUSED
%                 this_linestyle = line_styles{n};
% 
%                 % plot freq x spectra, color
%                 plot(these_freqs, these_spectra, 'color', this_color, ...
%                     'LineStyle',this_linestyle, 'LineWidth',1.5)
%                 hold on
% 
%             end
% 
%             % only show applicable emotions in legend
%             legend_colors = cell(1,num_surveys);
%             for p=1:num_surveys
%                 legend_emotions_idx = ismember(emotion_colors, these_emotions{p});
%                 legend_colors{p} = legend_labels{legend_emotions_idx};
%             end
%             
%             legend(legend_colors)
% 
%             % add labels
%             title(['Room ' num2str(roomNum) ': ' chan_label ' Power Spectra'])
%             xlabel('Freq (Hz)')
%             ylabel('Log Power Spectral Density')
%             
%             % save
%             filename = ['sub' subNum '_room' num2str(roomNum) '_' chan_label '_spectra.fig'];
%             folderpath = [output_path '/' chan_label];
%             saveas(gcf, fullfile(folderpath, filename))
%             
%             fprintf('----Finished %s for Room %d----\n', chan_label, k)
%         else
%             
%             fprintf('No %s for Room %d\n', chan_label, k)
%             
%         end
%     end
%     
%     close all
% 
% end


