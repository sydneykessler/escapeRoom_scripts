% colors

% referenced from here: http://www.fifi.org/doc/wwwcount/Count2.5/rgb.txt.html

% violetred1
pink = [255;62;150];

% firebrick1
firered = [255;48;48];

% OrangeRed
orangered = [255;69;0];

% DarkOrange;1
orange = [255;127;0];

% gold
gold = [255;215;0];

% LawnGreen
lightgreen = [124;252;0];

% ForestGreen
mediumgreen = [34;139;34];

% DarkGreen
darkgreen = [0;100;0];

% MediumSpringGreen
mint = [0;250;154];

% DeepSkyBlue
mediumblue = [0;191;255];

% DodgerBlue4 
darkblue = [16;78;139];

% NavyBlue
navy = [0;0;128];

% BlueViolet
violet = [138;43;226];

% purple3
purple = [125;38;205];

%% creating cell array

emotion_legend_labels = {'Happy = yellow', 'Angry = red', 'Sad = dark blue'...
    'Thinking = blue', 'Questioning = pink', 'Lost = dark green', ...
    'Ambivalent = mint'};   

color_ref_ = cell(2, 7);

%%
puzzle_legend_labels = {'1 = blue', '2 = darkblue', '3 = navy'...
    'Finished = violet'};  

% puzzle_ref = cell(2,4);
% puzzle_labels = {'1', '2', '3', 'Finished'};
% puzzle_ref(1,:) =  puzzle_labels;
% puzzle_ref(2,1) = {mediumblue ./ 256};
%...
% color_ref(1).puzzle_ref =  puzzle_ref;
% save('color_reference.mat','color_ref')

