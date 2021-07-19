%% powbaseoutput comparison
%  based on code in hhm_ersp_analysis

% comparing the ~5 minutes before and after heatmap usage

%% ERSP

addpath(genpath('/data/projects/ying/VR/escapeRoom/scripts'))

%  with intent to plot powbaseOutput for before vs. after heatmap use
%subs2run = {'09','10','11','12','13','14','15','16','17','18'};
% subs2run = {'03','05','06'};
viable_subs = {'03','05','09','10','11','12','13','15'};
subs2run = viable_subs;

time_frame = 4;   % in minutes
chan2check = 'Fz';
which_use_str = {'first','second'};
phases =  {'before','during','after'};

% newtimef inputs
cycles = [3 0.5];
freqs = [3 50];   % [4 50]
numberOfFreqs = 100;
timesOut = 100;

%% per subject
for i=1   %:length(subs2run)
    
    % go to subject folder
    subNum = subs2run{i};
    chdir(['/data/projects/ying/VR/escapeRoom/sub' subNum '/room1']);
    addpath([pwd '/baseline_clean'])
    
    % import full EEG
    EEG = pop_loadset(['room1_sub' subNum '_ICA.set']);
    hhm_uses = get_num_hhm_uses(EEG);
    
    % import baseline
    baseline_EEG = pop_loadset(['room1_sub' subNum '_baseline_reref_chRm.set']);
    
    % calculate baseline_tf if doesn't exist, else import it
    baseline_tf_file = ['room1_sub' subNum '_baseline_tf_' num2str(freqs(1)) '-50.mat'];
    if isfile(fullfile([pwd '/baseline_clean'],baseline_tf_file))
        baseline_tf = load(baseline_tf_file);
        baseline_tf = baseline_tf.baseline_tf;
    else
        baseline_tf = get_baseline_chan_TF(baseline_EEG, freqs);
        save(fullfile([pwd '/baseline_clean'],baseline_tf_file), 'baseline_tf')
    end
    
    try
        chanNum = get_chan_num(EEG, chan2check);
    catch chanNum
    end

    % check if spectra file already exists; if not, create
    chdir('/data/projects/ying/VR/escapeRoom/hhm_analysis')
    spectra_file = ['sub' subNum '_powbase_' num2str(time_frame) 'min_comp_vals.mat'];
    if isfile(spectra_file)
        spectra = load(spectra_file);
        spectra = spectra.spectra;
    else
        spectra = struct();
    end
    
    % check if has channel of interest; if not, skip to next subject
    if ~isnumeric(chanNum)
        fprintf('Channel %s not found for subject %s. Skipping subject.\n', ...
            chan2check,subNum)
        continue;
        
    % if subject has channel, continue calculations
    else

        chdir('/data/projects/ying/VR/escapeRoom/hhm_analysis/figs');

        %% per hhm use
        for which_hhm_use=1:hhm_uses

            % before, during, after
            for segment=1:3

                % load data
                outEEG = portion_hhm_by(EEG, phases{segment}, which_hhm_use, time_frame);

                % preprocess
                [outEEG, percent_kept, seconds_kept] = preprocess_for_psd(outEEG,...
                    baseline_EEG);

                which_hhm = which_use_str{which_hhm_use};

                %% epoch data (1 sec epochs)

                outEEG = eeg_regepochs(outEEG, 'recurrence', 1.5, 'limits',[0 1.5]);

                %% declare variables (inputs into newtimef)

                data = outEEG.data(chanNum,:,:);
                tlimits = [outEEG.xmin*1000 (outEEG.xmax*1000)/2];
                srate = outEEG.srate;
                frames = outEEG.pnts;
                
                commonPowbase = baseline_tf(chanNum).commonPowbase;

                %% run ersp

                [ersp, itc, powbaseOutput, times, freqs, erspboot,itcboot, ] ...
                    = newtimef(data, ...
                        frames, tlimits, srate, cycles, ...
                        'freqs', freqs, 'nfreqs', size(commonPowbase,2), ...
                        'freqscale', 'log',  ...
                        'plotitc', 'off', 'plotersp', 'off', 'plotphasesign', 'off');
%%
                if segment == 1
                    before_powbase = powbaseOutput;
                    before_time = seconds_kept;
                elseif segment == 2
                    during_powbase = powbaseOutput;
                    during_time = seconds_kept;
                else 
                    after_powbase = powbaseOutput;
                    after_time = seconds_kept;
                end

            end

            %% plot powbases
            figure;
            set(gcf, 'position',[0,0,700,500])
            suptitle('powbaseOutput around HHM usage'); 

            % plot data
            plot(freqs, before_powbase, 'r')
            hold on
            plot(freqs, during_powbase, 'g')
            hold on
            plot(freqs, after_powbase, 'b')

            % add details
            title(['sub' subNum ', '  chan2check ', freqs ' num2str(freqs(1))...
                '-' num2str(freqs(end))]);
            xlabel('Freqs')
            ylabel('Power')

            legend(['Before (' num2str(floor(before_time)) 's)'],...
                   ['During (' num2str(floor(during_time)) 's)'],...
                   ['After (' num2str(floor(after_time)) 's)'])

            savefig([subNum '_powbase_comp_' chan2check '_' which_hhm '_use.fig'])
            saveas(gcf, [subNum '_powbase_comp_' chan2check '_' which_hhm '_use.png'])

            % save spectra
            % command that is run looks like: 
            %   'spectra.Fz(which_hhm_use).before = before_powbase;'
            eval(['spectra.' chan2check '(which_hhm_use).before = before_powbase;'])
            eval(['spectra.' chan2check '(which_hhm_use).before_time = before_time;'])
            eval(['spectra.' chan2check '(which_hhm_use).during = during_powbase;'])
            eval(['spectra.' chan2check '(which_hhm_use).during_time = during_time;'])
            eval(['spectra.' chan2check '(which_hhm_use).after = after_powbase;'])
            eval(['spectra.' chan2check '(which_hhm_use).after_time = after_time;'])
            eval(['spectra.' chan2check '(which_hhm_use).freqs = freqs;'])
            
        end
        
        % save vals

        save(fullfile('/data/projects/ying/VR/escapeRoom/hhm_analysis/',spectra_file), 'spectra')
        clear spectra
        
    end
end

%% AVERAGE SPECTRA FOR VIABLE SUBJECTS
%  before and after comparison
chdir('/data/projects/ying/VR/escapeRoom/hhm_analysis')

% figure out freq range? I believe it's 50 but just checking
subNum = viable_subs{1};
spectra_file = load(['sub' subNum '_powbase_' num2str(time_frame) 'min_comp_vals.mat']);
spectra = spectra_file.spectra;

%%
eval(['freqs = spectra.' chan2check '(1).freqs;'])
num_freqs = length(freqs);

% viable_subs = {'05','09','10','11','12','13','15'};
num_subs = length(viable_subs);

%% get average of subs
% init empty arrays
before_freqs = zeros(num_subs, num_freqs);
after_freqs = zeros(num_subs, num_freqs);

% fill arrays
for i=1:num_subs
    % load file
    subNum = viable_subs{i};
    spectra_file = load(['sub' subNum '_powbase_' num2str(time_frame) 'min_comp_vals.mat']);
    spectra = spectra_file.spectra;
    
    % get according spectra and put into empty array
    try
        eval(['before_freqs(i,:) = spectra.' chan2check '(1).before;'])
        eval(['after_freqs(i,:) = spectra.' chan2check '(1).after;'])
    catch
        % if no spectra for channel, remove offending row
        fprintf('No %s for sub %s\n', chan2check, subNum)
        before_freqs(i,:) = [];
        after_freqs(i,:) = []; 
    end
    
end

% get averages
before_ave = mean(before_freqs, 1);
after_ave = mean(after_freqs, 1);

%% plot
figure;
set(gcf, 'position',[0,0,500,500])
suptitle('average powbaseOutput around HHM usage')

plot(freqs, before_ave, 'r')
hold on
plot(freqs, after_ave, 'b')

% add details
title([chan2check ', ' num2str(time_frame) 'min, freqs ' num2str(freqs(1))...
    '-' num2str(freqs(end))]);
xlabel('Freqs')
ylabel('Power')
legend({'Before','After'})

chdir('/data/projects/ying/VR/escapeRoom/hhm_analysis/figs');

% save 
savefig(['ave_powbase_comp_' chan2check '.fig'])
saveas(gcf, ['ave_powbase_comp_' chan2check '.png'])


%% PLOT AVE POWER PER FREQ BAND
%% AND GET POWER PER FREQ BAND FOR EACH SUBJECT 
%  and add that to the big spectra struct

% chans = {'POz','O2','P3','P4','P7','P8','Pz','Fz','Cz'};
chans = {'POz','O2','P7','P8','P3','P4','Fz'};
% chans = {'F4'};
figpath = '/data/projects/ying/VR/escapeRoom/hhm_analysis/figs';
freqbandpath = '/data/projects/ying/VR/escapeRoom/hhm_analysis/freqbands_per_sub';

num_subs = length(viable_subs);
freq_bands_per_sub = {'theta_before','theta_after','lowAlpha_before','lowAlpha_after', ...
                      'hiAlpha_before','hiAlpha_after','lowBeta_before','lowBeta_after',...
                      'hiBeta_before','hiBeta_after','gamma_before','gamma_after'};

% for each chan
for m=1:length(chans)
    chan2check = chans{m};
    
    % set up empty arrays
    theta_before = zeros(num_subs,1);
    theta_after = zeros(num_subs,1);
    lowAlpha_before = zeros(num_subs,1);
    lowAlpha_after = zeros(num_subs,1);
    hiAlpha_before = zeros(num_subs,1);
    hiAlpha_after = zeros(num_subs,1);
    lowBeta_before = zeros(num_subs,1);
    lowBeta_after = zeros(num_subs,1);
    hiBeta_before = zeros(num_subs,1);
    hiBeta_after = zeros(num_subs,1);
    gamma_before = zeros(num_subs,1);
    gamma_after = zeros(num_subs,1);
    
    %this part for generating freq band
    % per channel
    spectra.chan(m).name = chan2check;
        
    % okay moving on...
    % for each subject, load powbase vals
    chdir('/data/projects/ying/VR/escapeRoom/hhm_analysis')
    % viable_subs = {'05','09','10','11','12','13','15'};
    num_subs = length(viable_subs);

    % figure out freq range? I believe it's 50 but just checking
    subNum = viable_subs{2};
    spectra_file = load(['sub' subNum '_powbase_' num2str(time_frame) 'min_comp_vals.mat']);
    spectra = spectra_file.spectra;

    eval(['freqs = spectra.' chan2check '(1).freqs;'])
    num_freqs = length(freqs);

    % this is from Makoto's helpful code:
    % Set the following frequency bands: delta=1-4, theta=4-8, alpha=8-13, beta=13-30, gamma=30-80.
    thetaIdx = find(freqs>3 & freqs<8); % changing since we don't go to down to 1
    % separating low and high alpha to capture differences
    lowAlphaIdx = find(freqs>8 & freqs<10);
    hiAlphaIdx = find(freqs>10 & freqs<13);
    lowBetaIdx = find(freqs>13 & freqs<20);
    hiBetaIdx = find(freqs>20 & freqs<30);
    gammaIdx = find(freqs>30 & freqs<50);

    freq_ranges = {thetaIdx, lowAlphaIdx, hiAlphaIdx, lowBetaIdx, hiBetaIdx, gammaIdx};
    freq_range_names = {'Theta (3-8 Hz)','Low Alpha (8-10 Hz)','High Alpha (10-13 Hz)',...
        'Low Beta (13-20 Hz)','High Beta (20-30 Hz)','Gamma (30-50 Hz)'};
    freq_range_ylims = [25 31; 20 30; 15 25];

    % plotting stuff
    figure;
    set(gcf, 'position',[0,0,1200,700])
    suptitle(['Average powbaseOutput around HHM usage per frequency band for ' chan2check])

    %% get averages per band

    % per each freq band...
    for k=1:length(freq_ranges)
        % get freq range of interest
        these_freqs = freq_ranges{k};

        % init empty arrays
        before_freqs = zeros(num_subs, length(these_freqs));
        after_freqs = zeros(num_subs, length(these_freqs));

        % for each sub...
        for i=1:num_subs
            % load file
            subNum = viable_subs{i};
            
            spectra_file = load(['sub' subNum '_powbase_' num2str(time_frame) 'min_comp_vals.mat']);
            spectra = spectra_file.spectra;

            % get according spectra and put into empty array
            try
                % get all spectra
                eval(['spectra_before = spectra.' chan2check '(1).before;'])
                eval(['spectra_after = spectra.' chan2check '(1).after;'])

                % get spectra in band of interest
                before_freqs(i,:) = spectra_before(these_freqs);
                after_freqs(i,:) = spectra_after(these_freqs);
                
                 %% THIS PART FOR INDIVIDUAL SPECTRA
        
                % add before and after spectra
                eval([freq_bands_per_sub{(k*2)-1} '(i) = mean(spectra_before(these_freqs));'])
                eval([freq_bands_per_sub{k*2} '(i) = mean(spectra_after(these_freqs));'])
                
            catch
                % if no spectra for channel, viable_chans.chans = chans;
                fprintf('No %s for sub %s\n', chan2check, subNum)
                before_freqs(i,:) = [];
                after_freqs(i,:) = []; 
                
                eval([freq_bands_per_sub{(k*2)-1} '(i) = "NaN";'])
                eval([freq_bands_per_sub{k*2} '(i) = "NaN";'])
            end

        end
        
        % get averages
        before_ave = mean(before_freqs, 'all');
        after_ave = mean(after_freqs, 'all');
        
        % plot
        subplot(2,3,k)
        b = bar([before_ave, after_ave]); % TODO: set colors to be different

        % change color
        b.FaceColor = 'flat';
        b.CData(1,:) = [1 0 0];
        b.CData(2,:) = [0 0 1];
        % add details
        xticks([1 2])
        xticklabels({'before','after'})
        ylabel('Ave Spectral Power')
        title(freq_range_names{k})
        % set ylims based on freqband
        if k==1
            ylim(freq_range_ylims(1,:))
        elseif k>4
            ylim(freq_range_ylims(3,:))
        else
            ylim(freq_range_ylims(2,:))
        end
            

        %%

        % save 
        savefig(fullfile(figpath, ['ave_powbase_freqbands_' chan2check '.fig']))
        saveas(gcf, fullfile(figpath, ['ave_powbase_freqbands_' chan2check '.png']))

    end
    
    % make table of subs power
    T = table(theta_before,theta_after,lowAlpha_before,lowAlpha_after,hiAlpha_before,hiAlpha_after,...
              lowBeta_before,lowBeta_after,hiBeta_before,hiBeta_after,gamma_before,gamma_after,...
              'VariableNames', freq_bands_per_sub, 'RowNames',viable_subs);
          
    save(fullfile(freqbandpath, [chan2check '_freqbands_good.mat']),'T')
    writetable(T, fullfile(freqbandpath, [chan2check '_freqbands_good.csv']),'Delimiter',',')
    
end
    
%% WHICH SUBS HAVE WHICH ELECTRODES

chans = {'POz','O2','P3','P4','P7','P8','Pz','Fz','Cz'};

% for each chan
for i=1:length(chans)
    chan2check = chans{i};
    
    these_subs = [];

    % for each sub
    for j=1:length(viable_subs)
        
        % load sub
        subNum = viable_subs{j};
        spectra_file = load(['sub' subNum '_powbase_' num2str(time_frame) 'min_comp_vals.mat']);
        spectra = spectra_file.spectra;

        % see if chan is there
        try 
             eval(['spectra_before = spectra.' chan2check '(1).before;'])
             
             % add sub to chans
             these_subs = [ these_subs str2double(subNum) ];
             
        catch
            % do nothing
        end

    end
    
    % add row to struct
    viable_chans(i).name = chans{i};
    viable_chans(i).subs = these_subs;
    
end

save('subs_per_chan.mat','viable_chans')
