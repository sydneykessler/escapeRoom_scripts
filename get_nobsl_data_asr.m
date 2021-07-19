% generate 

subs2run = {'12','13','14','15','16','17','18'};
addpath(genpath('/data/projects/ying/VR/escapeRoom/scripts'))

for i=1:length(subs2run)
    subNum = subs2run{i};
    
    chdir(['/data/projects/ying/VR/escapeRoom/sub' subNum '/room1'])

    % load asr
    EEG = pop_loadset(['room1_sub' subNum '_asr.set']);
    
    % remove baseline from main recording
    EEG = remove_baseline(EEG);
    
    % save
    outfile = ['room1_sub' subNum '_asr_nobsl.set'];
    EEG = pop_saveset(EEG, outfile, pwd); 
    
end
