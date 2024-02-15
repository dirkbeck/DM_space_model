clear; close all
addpath(fileparts(pwd))
rng(1)

cols = actioncmap();

x = 0:.01:1;
inptx = .9;
slopes = [5 -5 -1 1]';
shifts = rand(4,1);
addition = [0 0 -3 -3];
y = 1./(1+exp(slopes.*(shifts-x)));

figure; hold on
for i=1:4
    plot(x,y(i,:),'Color',cols(i+1,:))
end
xline(inptx)
hold off
xlabel("reward level (arb. u.)")
ylabel("SV (arb. u.)")
legend(["approach","avoid","freeze","wander"])

SVs = 1./(1+exp(slopes.*(shifts-inptx)));

figure
b = bar(SVs);
xticklabels(["turn right","turn left","turn around","wander"])
ylabel("SV (arb. u.)")
b.FaceColor = 'flat';
for i=1:4
    b.CData(i,:) = cols(i+1,:);
end