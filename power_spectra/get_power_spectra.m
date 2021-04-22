% get power spectra BY PUZZLE COMPLETION

subs2run =  {'05','06','08','09','10','11'};

for p=1:length(subs2run)

    %% define parameters   
    subNum = subs2run{p}; %'11';
    roomNum = '1';
    % base path
    mainpathbase = '/data/projects/ying/VR/escapeRoom/'; 

    %% check if powerspectra already exists; if so, open that
    chdir([mainpathbase '/power_spectra'])

    already_struct = isfile(['sub' subNum '_powerSpectra.mat']);

    if already_struct
        this_psd = load(['sub' subNum '_powerSpectra.mat']);
        room = this_psd.room;
    else
        room = [];
    end

    %%
    chdir([mainpathbase '/sub' subNum '/room' roomNum])

    % load in ICA'd EEG
    EEG = pop_loadset(['room' roomNum '_sub' subNum '_ICA.set']);
    
    % remove baseline from end
    EEG = remove_baseline(EEG);

    %% define phases (survey, puzzle completion, etc) (separate script to
    % generate these?)

    % get relevant indices
    idx = get_segments_idx(EEG, 'puzzle', 'room', roomNum);

    % pad with ending
    idx = [1, idx, EEG.times(end)/1000];

    %% for each phase

    for i=1:length(idx)-1

        roomNum_num = str2double(roomNum);

        %% select segment
        % get latency of beginning section
        if i==1
           beginning = 1;
        else
           beginning = (cell2mat({EEG.event(idx(i)).latency})-1)/EEG.srate;
        end
        % get latency of end of section and convert to seconds
        if i<length(idx)-1
            ending = (cell2mat({EEG.event(idx(i+1)).latency})-1)/EEG.srate;
        else
        % last element
            ending = idx(end);
        end

        % select only that section
        new_EEG =  pop_select(EEG, 'time', [beginning ending]);

        if size(new_EEG.times,2)/500 <30  % if data is shorter than 1 minute
            fprintf('-----Phase %d of Sub%s too short-----\n',i,subNum)
        else

            %% clean
            % remove badcomps
            new_EEG = pop_subcomp(new_EEG, new_EEG.badcomps, 0, 0);

            % run asr/clean artifacts 
            clean_EEG = clean_artifacts(new_EEG, 'ChannelCriterion', 'off', 'LineNoiseCriterion', 'off');

            %% get power spectra
            % get chan labels
            allLabels = {};
            for chan = 1:length(clean_EEG.chanlocs)
                allLabels{chan} = {clean_EEG.chanlocs(chan).labels};
            end

            %get spectra
            figure;
            [spectra, freqs] = pop_spectopo(clean_EEG, 1, [],'EEG', 'freqrange', [1 55], 'noplot','on');

            %save labels and spectra in struct
            room(roomNum_num).puzzle(i).chans = allLabels;
            room(roomNum_num).puzzle(i).spectra = spectra;
            room(roomNum_num).puzzle(i).freqs = freqs;
            room(roomNum_num).puzzle(i).time = [beginning/60, ending/60];

        end
    end

    
    
    %% save power struct
    chdir([mainpathbase '/power_spectra'])
    filename =  ['sub' subNum '_powerSpectra.mat'];
    save(filename, 'room')
    
    fprintf('-----Finished Sub%s-----',subNum)
    
    close all
end

