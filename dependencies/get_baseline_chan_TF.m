function [tf] = get_baseline_chan_TF(EEG)
% reference: data/projects/ying/Aha/scripts/tf (get_baseline_AhaTf.m)

for chan = 1:EEG.nbchan
    
    %comp = EEG.goodComps(compNum);
   
    tlimits=[EEG.xmin*1000 EEG.xmax*1000];
    srate=EEG.srate;
    cycles=[3 0.5];
    frames=size(EEG.data,2);
    freqs = [3 50]; %[4 50];  
    
    data = EEG.data(chan, :, :);
    
    [ersp, itc, powbaseOutput, times, freqs, erspboot,itcboot] = newtimef(data, frames, tlimits, srate, cycles, ...
        'freqs', freqs,  'nfreqs', 100,  'freqscale', 'log', 'alpha', .03,'plotersp', 'off', 'plotitc', 'off', 'plotphasesign', 'off');
    
    h = gcf;
    clf(h)
    
    tf(chan).chanName = EEG.chanlocs(chan).labels;
    tf(chan).baseErsp = ersp;
    tf(chan).baseErspBoot = erspboot;
    tf(chan).commonPowbase = powbaseOutput;
    tf(chan).baseTimes = times;
    tf(chan).baseFreqs = freqs;
end