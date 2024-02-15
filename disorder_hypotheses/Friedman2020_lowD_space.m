clear; close all

%% Cell 2020 licking task

incsxy = linspace(-1,1,3);
B = [0 1 -1; -3 -1 1]';
x_axis = [1 0];
y_axis = [0 1];
% learned, not learned, very not learned
spaces = {{[0 0], [0 1]}, {[0 0], [0 .5]}, {[0 .5], [0 .5]}};

for i=1:length(spaces) % group
    for j=1:2 % reward vs cost task
        space = spaces{i}{j};
        logoddsSV = B(1,:) + space*B(2:3,:);
        SV_diffs(i,j) = 1./(1+exp(-5*logoddsSV(1))) - 1./(1+exp(-5*logoddsSV(2)));
    end
end

figure
bar(SV_diffs)
xticklabels(["learned","reward task learned","not learned"])
ylabel("SV lick - SV no lick")
legend("reward trial","cost trial")
