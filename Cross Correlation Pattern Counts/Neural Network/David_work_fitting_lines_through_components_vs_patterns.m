%use this to code to find the number of components in the experimental data
%

clear; close all
% some random data that is similar to the pattern counts
% rows are the four types of patterns (excitation/excitation, E/I, I/E,
% I/I)
% columns are the tasks (CB BB TR NBC for stress and control)

%for my sanity's sake I'm assuming the column order is
%rev CB control, EQR control, TR Control, CB control, TR Stress, CB Stress
patterns = [1 .5 .2 .1]' .* (randn(4,6) + linspace(1,3,6));

patterns = [1  0.824 1.00418   1.15817   0.775    0.584906;
           0   0.256 0.286708  0.409766  0.266667 0.143396;
           0   0.192 0.140571  0.292994  0.114583 0.124528;
           0   0.072 0.0668058 0.0955414 0.075    0.0415094];

taskTypeOrder = {'CB Stress', 'Rev CB Control', 'TR Stress', 'EQR Control', 'TR Control', 'CB Control'};

taskTypeOrder = {'RCB Control', 'EQR Control', 'TR Control', 'CB Control', 'TR Stress', 'CB Stress'};

% add all rows to that you're fitting to each of the pattern types
all_patterns = sum(patterns);

% find what the # components used would be, assuming a perfect linear
% relationship 
% set the boundaries by letting the minimimum be the origin 
% (i.e. no patterns when 0 components used) and the maximum be 2 for the
% CB task (i.e. cost-benefit conflict task uses cost and reward components)

slope= all_patterns(:,4)/2; % the CB pattern
n_components_used_by_task = all_patterns/slope;


%% plotting to demonstrate

figure; hold on
scatter(n_components_used_by_task,patterns)
line(n_components_used_by_task, ...
    slope*sum(patterns,2)/sum(patterns,'all') * n_components_used_by_task)
% legend("Excited Excited", "Excited Inhibited", "Inhibited Excited", "Inhibited Inhibited",'','','','','','')
xlabel("Components Used")
ylabel("Pattern Counts")
xticklabels({'' , '1', ' ', ' ',' ',' ', '2'})
text(n_components_used_by_task -.025,[0 0 0 0 0 0] ,taskTypeOrder)
xline(n_components_used_by_task,"-")
legend('Excited Excited', 'Excited Inhibited', 'Inhibited Excited', 'Inhibited Inhibited','','','','','','')
title("Actual Number Of Components Vs Pattern Counts")
subtitle("Created by David\_work\_fitting\_lines\_through\_components\_vs\_patterns.m")
hold off


