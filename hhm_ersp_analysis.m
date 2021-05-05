%% time-freq analysis for helpful heatmap

eeglab

%% set up

subs2run = {'03','05','09','10','11'};
heatmap_uses = load('heatmap_uses.mat');
heatmap_uses = heatmap_uses.heatmap_uses;

%%

for z=3:length(subs2run)
    subNum = subs2run{z};
    roomNum = '1';
    main_path = ['/data/projects/ying/VR/escapeRoom/sub' subNum '/room' roomNum'];
    chdir(main_path)

    try
        hhm_uses = heatmap_uses{z, 2};
    catch
        fprintf('look manually\n')
    end

    %% load eeg

    infile = ['room' roomNum '_sub' subNum '_ICA.set'];
    EEG = pop_loadset(infile); 

    %% finish preprocessing eeg
    % remove badcomps
    EEG = pop_subcomp(EEG, EEG.badcomps, 0, 0);

    % run asr/clean artifacts 
    % (will not remove data or channels --> maybe change to a loose channel
    % threshold?)
    clean_EEG = clean_artifacts(EEG, 'WindowCriterion', 'off', 'ChannelCriterion', 'off', 'LineNoiseCriterion','off'); 
    % vis_artifacts(clean_EEG, EEG);  % can turn this line off if you don't want to plot

    EEG = clean_EEG;

    %% get heatmap event indices relative to EEG
    events = EEG.event;
    events = {events.type};
    isEnable = cellfun(@(x)isequal(x,"Enable Heatmap"), events);
    [start_idx] = find(isEnable);
    isDisable= cellfun(@(x)isequal(x,"Disable Heatmap"), events);
    [end_idx] = find(isDisable);

    % convert event latencies to seconds
    starts = (cell2mat({EEG.event(start_idx).latency})-1);
    hhm_start_times = starts./EEG.srate;
    ends = (cell2mat({EEG.event(end_idx).latency})-1);
    hhm_end_times = ends./EEG.srate;


    %% separate by times

    % outpath = [main_path '/segmentedByHHM'];
    % % creates the outpath folder if not already there
    % if ~isfolder('segmentedByHHM')
    %    mkdir('segmentedByHHM')
    % end
    % chdir(outpath)

    outpath =  '/data/projects/ying/VR/escapeRoom/hhm_analysis/data';
    chdir(outpath)

    whichTimes = ["first", "second"];
    time_frame = 120;

    %%
    for i=1:length(hhm_start_times)
    %    fprintf(whichTimes(i))
    %    fprintf('Before:')
    %    sprintf('start: %d s', (hhm_start_times(i)-time_frame)/60)
    %    sprintf('end: %d s', hhm_start_times(i)/60)
       before_EEG =  pop_select(clean_EEG, 'time', [hhm_start_times(i)-time_frame hhm_start_times(i)]);

       outfile_before = [subNum '_' num2str(whichTimes(i)) '_' num2str(time_frame) 's_before.set'];
       pop_saveset(before_EEG, outfile_before, outpath);
       % pop_saveset(before_EEG, outfile_before, outpath); <--this isnt working
       % for whatever reason >:( doing it manually for now

    %    fprintf('After:')
    %    sprintf('start: %d s', hhm_end_times(i)/60)
    %    sprintf('end: %d s', (hhm_end_times(i)+time_frame)/60)
       after_EEG =  pop_select(clean_EEG, 'time', [hhm_end_times(i) hhm_end_times(i)+time_frame]);

       outfile_after = [subNum '_' num2str(whichTimes(i)) '_' num2str(time_frame) 's_after.set'];
       pop_saveset(after_EEG, outfile_after, outpath);

    end

    %% load in segments

    % (and baseline)
    % chdir([main_path '/baseline_clean'])
    % baseline_EEG = pop_loadset(['room' roomNum '_sub' subNum '_baseline_ICA.set']);

    % chdir([main_path '/segmentedByHHM']);
%     EEG_first_before = pop_loadset(['first_' num2str(time_frame) 's_before.set']); 
%     EEG_first_after = pop_loadset(['first_' num2str(time_frame) 's_after.set']); 
% 
%     if hhm_uses>1
%         EEG_second_before = pop_loadset(['second_' num2str(time_frame) 's_before.set']); 
%         EEG_second_after = pop_loadset(['second_' num2str(time_frame) 's_after.set']); 
%     end

end
%% -------------------------------------------------------------------------
% --------------------------------------------------------------------------
% --------------------------------------------------------------------------
%% -------------------------------------------------------------------------
pop_rejmenu(EEG)

%% ERSP
%  with intent to plot powbaseOutput for before vs. after heatmap use
subs2run = {'05','09','10','11'};
time_frame = 120;

% per subject
for i=3  %:length(subs2run)
    
    subNum = subs2run{i};
    hhm_uses = heatmap_uses{i, 2};
    
    Cz.powbase(i).subNum = subNum;
    
    chdir(['/data/projects/ying/VR/escapeRoom/sub' subNum '/room1/baseline_clean']);
    
    % get baseline ersp
%     baseline_EEG  = pop_loadset(['room1_sub' subNum '_baseline_reref_chRm.set']);
%     baseline_tf = get_baseline_chan_TF(baseline_EEG);

    chdir('/data/projects/ying/VR/escapeRoom/hhm_analysis/data');
    
    % per hhm use
    for which_hhm_use=1:hhm_uses
        
        % before or after
        for segment=1:2
            
            % load data
            % first round before
            if segment==1 && which_hhm_use==1
                EEG = pop_loadset([subNum '_first_' num2str(time_frame) 's_before.set']); 
                which_segment = 'Before';
                which_hhm = 'First';
            % second round before
            elseif segment==1 && which_hhm_use==2
                EEG = pop_loadset([subNum '_second_' num2str(time_frame) 's_before.set']); 
                which_segment = 'Before';
                which_hhm = 'Second';
            % first round after
            elseif segment==2 && which_hhm_use==1
                EEG = pop_loadset([subNum '_first_' num2str(time_frame) 's_after.set']); 
                which_segment = 'After'; 
                which_hhm = 'First';
            % second round after
            elseif segment==2 && which_hhm_use==2
                EEG = pop_loadset([subNum '_second_' num2str(time_frame) 's_after.set']); 
                which_segment = 'After'; 
                which_hhm = 'Second';
            end

        %% epoch data

        epoch_time = 1;

        EEG = eeg_regepochs(EEG,'recurrence',epoch_time);

        %% reject bad epochs
        
        pop_rejmenu(EEG, 1);
        % EEG = pop_eegthresh(EEG, 1,[1:EEG.nbchan] ,-22,22,0,1.992,1,1);
        
        % function [EEG, Irej, com] = pop_eegthresh( EEG, icacomp, elecrange, negthresh, posthresh, ...
   						% starttime, endtime, superpose, reject, topcommand)
        % EEG = eegthresh(EEG, EEG.pnts, [1:EEG.nbchan] ,-25,25,[0 998],0,998); 
            % ^^^ this ones to closest to working

        %% declare variables (inputs into newtimef)
        
        chan2check =  'Cz';
        chanNum = get_chan_num(EEG, chan2check);

    %         % all --> 1:1:EEG.nbchan;
    %         chans2check = linspace(1, EEG.nbchan, EEG.nbchan);
    %         % chans2check = [1 3 6 8 10 13 14 15 18];
    %         % chanNames = {'FP1'; 'C3'; 'P4'; 'O2'; 'T7'; 'P8'; 'Cz'; 'Pz'; 'CPz'};
    % 
    %         % for i=1:length(chans2check)
    %         chan = 14; %change later--> this is Cz for sub11
    %         chanNum = chans2check(i);

        data = EEG.data(chanNum,:,:);
        tlimits = [EEG.xmin*1000 (EEG.xmax*1000)/2];
        srate = EEG.srate;
        cycles = [3 0.5];
        frames = EEG.pnts;
        freqs = [4 50];
        numberOfFreqs = 100;
        timesOut = 100;
        
        useCommonPowbase = 0;


        %% run ersp
        if useCommonPowbase

            % declare commonPowbase for matching channel
            commonPowbase = baseline_tf(chan).commonPowbase;
            fprintf('finished\n')

            % set up fig
            figure
            suptitle(['After HHM: '  EEG.chanlocs(chan).labels ' ERSP sub' subNum ]);
            title(['with powbase, ' num2str(time_frame) 's segments, ' num2str(epoch_time) 's epochs, ',...
                'freqs ' num2str(freqs(1)) '-' num2str(freqs(end))]);

            % generate ersp for this channel
            [ersp, itc, powbaseOutput, times, freqs, erspboot,itcboot, ] = newtimef(data, frames, tlimits, ...
                             srate, cycles, ...
                            'powbase', commonPowbase, 'freqs', freqs, 'nfreqs', size(commonPowbase,2), ...
                            'freqscale', 'log',  ...
                            'plotitc', 'off', 'plotersp', 'on', 'plotphasesign', 'off');

        else % no powbase

            % set up fig
            figure
            suptitle([which_hhm ' Time '  which_segment ' HHM: ' ...
                EEG.chanlocs(chan).labels ' ERSP sub' subNum ]);
            title(['no powbase, ' num2str(time_frame) 's segments, ' ...
                num2str(epoch_time) 's epochs, ', 'freqs ' num2str(freqs(1))...
                '-' num2str(freqs(end))]);

            % generate ersp for this channel
            [ersp, itc, powbaseOutput, times, freqs, erspboot,itcboot, ] = newtimef(data, frames, tlimits, ...
                             srate, cycles, ...
                            'freqs', freqs, 'nfreqs', size(commonPowbase,2), ...
                            'freqscale', 'log',  ...
                            'plotitc', 'off', 'plotersp', 'on', 'plotphasesign', 'off');

        end
        
        if segment==1
            Cz.powbase(i).before(which_hhm_use, :) = powbaseOutput;
            before_powbase = powbaseOutput;
        else
            Cz.powbase(i).after(which_hhm_use, :) = powbaseOutput;
            after_powbase = powbaseOutput;
        end
        
        end

    %% plot powbases
    figure;
    set(gcf, 'position',[0,0, 700,500])
    suptitle('Before (k) vs. After (r) Heatmap use: powbaseOutput');  
    plot(freqs, before_powbase, 'k')
    hold on
    plot(freqs, after_powbase, 'r')
    title(['sub' subNum ', room1, '  EEG.chanlocs(i).labels ', ' ...
            num2str(time_frame) 's segments, ' num2str(epoch_time) 's epochs, ',...
            'freqs ' num2str(freqs(1)) '-' num2str(freqs(end))]);
    xlabel('Freqs')
    ylabel('Power')
    
    chdir('/data/projects/ying/VR/escapeRoom/hhm_analysis/figs')
    savefig([subNum '_b4_vs_after_powbase_Cz.fig'])
    
    end

end


%% POWER SPECTRA

% freqrange = [2 50];
% % title = 'First Before';
% toplot = 'on';
% plotchans = []; 

%   Usage:
%                >> spectopo(data, frames, srate);
%                >> [spectra,freqs,speccomp,contrib,specstd] = ...
%                      spectopo(data, frames, srate, 'key1','val1', 'key2','val2' ...);

% figure
% set(gcf,'position',[0,0,1000,600])
% suptitle('Power Spectra Before/After HHM');
% 
% subplot(2,2,1);
% [spectra, freqs] = pop_spectopo(EEG_first_before, 1, [],'EEG', 'freqrange',...
%     freqrange, 'noplot','off');
% ylim([-15 15])
% title('First Before');
% hold on
% subplot(2,2,2);
% [spectra, freqs] = pop_spectopo(EEG_first_after, 1, [],'EEG', 'freqrange',...
%     freqrange, 'noplot','off');
% ylim([-15 15])
% title('First After');
% subplot(2,2,3);
% [spectra, freqs] = pop_spectopo(EEG_second_before, 1, [],'EEG', 'freqrange',...
%     freqrange, 'noplot','off');
% ylim([-15 15])
% title('Second Before');
% hold on
% subplot(2,2,4);
% [spectra, freqs] = pop_spectopo(EEG_second_after, 1, [],'EEG', 'freqrange',...
%     freqrange, 'noplot','off');
% ylim([-15 15])
% title('Second After');


% [spectra, freqs] = pop_spectopo(EEG_first_before, 1, [],'EEG', 'freqrange', [1 50], 'noplot','off');

%     %save labels and spectra in cell array
%     power{i,1} = allLabels;
%     power{i,2} = spectra;
%     power{i,3} = subNum;
%     power{i,4} = freqs;


%%

% for j=1:length(subs2run)
%     EEG_bsl = rm_chans_bsl(subs2run{j});
% end




