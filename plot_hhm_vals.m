% plot hhm effect 

%% load data
basepath = '/data/projects/ying/VR/escapeRoom';
addpath(genpath([basepath '/scripts']))

chdir([basepath '/hhm_analysis'])

% only using subs w/o split datasets
subs2run = {'03','05','07','09','10','11','12','13','15','16'};
% 
% heatmap_uses = load('heatmap_uses.mat'); % as of now, MUST update this manually
% heatmap_uses = heatmap_uses.heatmap_uses;

segment_names = {'Before','During','After'};

hhm = load('hhm_values.mat');
hhm = hhm.hhm;

%% set up fig
figure
set(gcf, 'position',[0,0, 2000,800])
suptitle('% of new places looked at with respect to heatmap usage')

for i=1:length(subs2run)
    subplot(3, 4, i)
    
    heatmap_uses = hhm.sub(i).hhm_uses;
    
    % plot
    if heatmap_uses == 1
        b = bar(hhm.sub(i).use(1).percentage_under_ten, 'FaceColor','b', ...
            'BarWidth', 0.5);
        legend('First Use')
    else
        b = bar([hhm.sub(i).use(1).percentage_under_ten hhm.sub(i).use(2).percentage_under_ten], ...
            'BarWidth', 0.5);
        b(1).FaceColor = 'b';
        b(2).FaceColor = 'g';
        legend('First Use', 'Second Use')
    end

    % garnish
    title(['sub' subs2run{i}])
    xticks(1:1:3)
    xticklabels(segment_names)
    ylim([0 100])
    ylabel('% of time looking in new areas', 'FontSize',  10)

end

%%

chdir([basepath '/hhm_analysis/figs'])
savefig('hhm_values.fig')
saveas(gcf, 'hhm_values.png')
