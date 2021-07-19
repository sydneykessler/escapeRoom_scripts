%% preprocess for spectral analysis
%  based on method 1b in test_preproc.m

% if you want to use this method, MUST separate out into sections first,
% since this script will remove windows that may contain markers of
% interest

function [outEEG, percent_kept, seconds_kept] = preprocess_for_psd(EEG, baseline_EEG)

%% remove baseline
% try
%     EEG = remove_baseline(EEG);
% catch
%     fprintf('Baseline already removed - continuing preprocessing\n')
% end

%% remove bad comps
try
    EEG = pop_subcomp(EEG, EEG.badcomps, 0, 0);
catch
    % check if it looks like ics were already removed
    if size(EEG.icaact, 1) == (EEG.nbchan - length(EEG.badcomps))
        fprintf('Bad comps already removed - continuing preprocessing\n')
    % else stop the function
    else
        fprintf('Error in pop_subcomp - check ICs\n')
        return
    end
end

%% run ASR separately and assign clean section for calculating threshold by clean_asr
EEG = clean_asr(EEG, 20, [], [], [], baseline_EEG);
%   = clean_asr(Signal,StandardDevCutoff,WindowLength,BlockSize,MaxDimensions,ReferenceMaxBadChannels,RefTolerances,ReferenceWindowLength,UseGPU,UseRiemannian,MaxMem)

%% ASR, but just rejecting messy windows
    % should be same as: 
        % EEG = clean_rawdata(EEG, -1, -1 , -1, -1, -1, 0.2);
[outEEG, sample_mask] = clean_windows(EEG, 0.2, [-inf 7]);
    % copying format in clean_artifacts:
    % EEG = clean_windows(EEG,window_crit,window_crit_tolerances); 

percent_kept = 100*(mean(sample_mask));
seconds_kept = nnz(sample_mask)/EEG.srate;

