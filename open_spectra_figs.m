% look at power spectra for each channel, then close

mainpath = '/data/projects/ying/VR/escapeRoom/power_spectra';
addpath('/data/projects/ying/VR/escapeRoom/scripts')  % scripts path
addpath(genpath('/data/projects/ying/VR/escapeRoom/power_spectra'))
chdir(mainpath)

%%

all_chans = {'Fp1', 'Fp2', 'F3', 'F4', 'C3', 'C4', 'P3', 'P4', 'O1', ...
    'O2', 'F7', 'F8', 'T7', 'T8', 'P7', 'P8', 'Fz', 'Cz', 'Pz', 'M1', ...
    'M2', 'AFz', 'CPz', 'POz'};

mainfile = 'sub03_room'; 

%% 
for i=1:length(all_chans) % for each channel
   
    for j=1:3  % for each room
        try
            filename = [mainfile num2str(j) '_' all_chans{i} '_spectra.fig'];
            openfig(filename);
            saveas(gcf, [mainfile num2str(j) '_' all_chans{i} '_spectra.png'])
        catch
            fprintf('No spectra for Room %d Chan %s\n', j, all_chans{i})
        end
    end
    % INSERT BREAKPOINT HERE
    close all
end

%     % save a file of just chan labels, to be opened
%     % for each channel, open all figs in file
%     dd = dir('*.fig');
%     fileNames = {dd.name}; 
%     how_many_figs = length(fileNames);
%     
%     if how_many_figs
%         for i=1:how_many_figs
%             load(fileNames{i})
%         end
%     end
