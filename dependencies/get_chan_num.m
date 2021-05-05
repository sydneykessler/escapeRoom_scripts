% given chan name, get chan num

function chanNum = get_chan_num(EEG, chan_name)

% get chan labels
allLabels = cell(length(EEG.chanlocs), 1);
for chan = 1:length(EEG.chanlocs)
    allLabels{chan} = EEG.chanlocs(chan).labels;
end

chanNum = find(ismember(allLabels, chan_name));