%% import_xdf:
%  loads in all xdf files from subject file and appends them
%  together

% input: 
%     subNum - subject number
% output:
%     EEG - eeglab EEG structure of appended datasets

function EEG = import_xdf(subNum, filepath)

% add path
addpath(filepath)

% get list of files
filePattern = fullfile(filepath, '*.xdf');
files = dir(filePattern);

for i=1:length(files)
   % get file name
   baseFileName = files(i).name; 
   
   if i==1
       % load in first file as EEG
       [EEG] = pop_loadxdf(baseFileName,'streamtype','EEG');
   else
       % import another file
       try
           [EEG_2] = pop_loadxdf(baseFileName,'streamtype','EEG');
       catch
           warning('Importing failure, skipping: %s', baseFileName);
       end
       % merge with OG file
       if exist('EEG_2', 'var')  % check if new EEG struct exists
           EEG = pop_mergeset(EEG,EEG_2, 0);  % merge
           clearvars EEG_2  % clear for next trial
           % there's a strjoin problem, try running this:
           % which strjoin -all
       end
   end    
end
fprintf(strcat('-------------Imported & concatted EEG-------------\n'))
end
