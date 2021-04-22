%% power spectra test

root_name = 'room1_sub03';
chdir(main_path);

%% load eeg setsa
EEG_reref = pop_loadset([root_name '_reref.set']); 
EEG_asr = pop_loadset([root_name '_asr.set']); 
EEG_ica = pop_loadset([root_name '_ICA.set']); 

%%
EEG_ica_rm = pop_subcomp(EEG_ica, EEG_ica.badcomps, 0, 0);
EEG_ica_rm_asr = clean_artifacts(EEG_ica_rm, 'WindowCriterion', 'off', 'ChannelCriterion', 'off'); 

%% plot

freqrange = [2 50];

figure
set(gcf,'position',[0,0,1000,600])
suptitle('Power Spectra - Full Experiment');

subplot(2,2,1);
[~, ~] = pop_spectopo(EEG_reref, 1, [],'EEG', 'freqrange',...
    freqrange, 'noplot','off');
title('Reref only');
hold on
subplot(2,2,2);
[~, ~] = pop_spectopo(EEG_asr, 1, [],'EEG', 'freqrange',...
    freqrange, 'noplot','off');
title('After ASR');  % includes window removal
subplot(2,2,3);
[~, ~] = pop_spectopo(EEG_ica_rm, 1, [],'EEG', 'freqrange',...
    freqrange, 'noplot','off');
title('After Removing ICs'); % from  reref
hold on
subplot(2,2,4);
[~, ~] = pop_spectopo(EEG_ica_rm_asr, 1, [],'EEG', 'freqrange',...
    freqrange, 'noplot','off');
title('After Removing ICs & ASR'); % no window removal

%% try diff asr

EEG_asr_rmwin = clean_artifacts(EEG_ica_rm, 'ChannelCriterion', 'off'); 


% % remove chans from bsl
% addpath([main_path '/baseline_clean']);
% bsl_EEG = pop_loadset('room1_sub03_baseline_asr.set');
% 
% % Run ASR separately and assign clean section for calculating threshold by clean_asr
% EEG_interp = clean_asr(EEG_ica_rm, 5, [], [], [], bsl_EEG);
% %   = clean_asr(Signal,StandardDevCutoff,WindowLength,BlockSize,MaxDimensions,ReferenceMaxBadChannels,RefTolerances,ReferenceWindowLength,UseGPU,UseRiemannian,MaxMem)
% 
% % ASR, but just rejecting messy windows
% EEG_asr_strong = clean_rawdata(EEG_interp, -1, -1 , -1, -1, -1, 0.2);

