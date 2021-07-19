% given chan name, get chan num

function chanNum = get_chan_num(EEG, chan_name)

% get chan labels
allLabels = cell(length(EEG.chanlocs), 1);
for chan = 1:length(EEG.chanlocs)
    allLabels{chan} = EEG.chanlocs(chan).labels;
end

possible_chanNum = find(ismember(allLabels, chan_name));

if isempty(possible_chanNum)
    fprintf('Channel not found\n')
    return
else 
    chanNum = possible_chanNum;
end