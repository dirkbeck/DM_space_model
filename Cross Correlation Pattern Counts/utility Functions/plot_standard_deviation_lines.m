function [] = plot_standard_deviation_lines(shortOrLong,standardDeviations,whichPattern)
hold on;
% the long standard deviations lines
if strcmp(shortOrLong,"long")
    if strcmp(whichPattern,"ee")
        yline(standardDeviations(1,1),'--blue',"-3 Excited Excited Standard Deviations")
        yline(standardDeviations(1,2),'--blue',"-2 Excited Excited Standard Deviations")
        yline(standardDeviations(1,3),'--blue',"-1 Excited Excited Standard Deviations")
        yline(standardDeviations(1,4),'--blue',"1 Excited Excited Standard Deviations")
        yline(standardDeviations(1,5),'--blue',"2 Excited Excited Standard Deviations")
        yline(standardDeviations(1,6),'--blue',"3 Excited Excited Standard Deviations")
    end

    if strcmp(whichPattern,"ei")
        yline(standardDeviations(2,1),"--r","-3 Excited Inhibited Standard Deviations")
        yline(standardDeviations(2,2),'--r',"-2 Excited Inhibited Standard Deviations")
        yline(standardDeviations(2,3),'--r',"-1 Excited Inhibited Standard Deviations")
        yline(standardDeviations(2,4),'--r',"1 Excited Inhibited Standard Deviations")
        yline(standardDeviations(2,5),'--r',"2 Excited Inhibited Standard Deviations")
        yline(standardDeviations(2,6),'--r',"3 Excited Inhibited Standard Deviations")
    end

    if strcmp(whichPattern,"ie")
        yline(standardDeviations(3,1),'--y',"-3 Inhibited Excited Standard Deviations")
        yline(standardDeviations(3,2),'--y',"-2 Inhibited Excited Standard Deviations")
        yline(standardDeviations(3,3),'--y',"-1 Inhibited Excited Standard Deviations")
        yline(standardDeviations(3,4),'--y',"1  Inhibited Excited Standard Deviations")
        yline(standardDeviations(3,5),'--y',"2  Inhibited Excited Standard Deviations")
        yline(standardDeviations(3,6),'--y',"3  Inhibited Excited Standard Deviations")
    end

    if strcmp(whichPattern,"ii")
        yline(standardDeviations(4,1),'--m',"-3 Inhibited Inhibited Standard Deviations")
        yline(standardDeviations(4,2),'--m',"-2 Inhibited Inhibited Standard Deviations")
        yline(standardDeviations(4,3),'--m',"-1 Inhibited Inhibited Standard Deviations")
        yline(standardDeviations(4,4),'--m',"1 Inhibited Inhibited Standard Deviations")
        yline(standardDeviations(4,5),'--m',"2 Inhibited Inhibited Standard Deviations")
        yline(standardDeviations(4,6),'--m',"3 Inhibited Inhibited Standard Deviations")
    end

elseif strcmp(shortOrLong,"short")
    % the short standard deviation lines
    if strcmp(whichPattern,"ee")
    yline(standardDeviations(5,1),'--blue',"-3 Excited Excited Standard Deviations")
    yline(standardDeviations(5,2),'--blue',"-2 Excited Excited Standard Deviations")
    yline(standardDeviations(5,3),'--blue',"-1 Excited Excited Standard Deviations")
    yline(standardDeviations(5,4),'--blue',"1 Excited Excited Standard Deviations")
    yline(standardDeviations(5,5),'--blue',"2 Excited Excited Standard Deviations")
    yline(standardDeviations(5,6),'--blue',"3 Excited Excited Standard Deviations")
    end

    if strcmp(whichPattern,"ei")
    yline(standardDeviations(6,1),"--r","-3 Excited Inhibited Standard Deviations")
    yline(standardDeviations(6,2),'--r',"-2 Excited Inhibited Standard Deviations")
    yline(standardDeviations(6,3),'--r',"-1 Excited Inhibited Standard Deviations")
    yline(standardDeviations(6,4),'--r',"1 Excited Inhibited Standard Deviations")
    yline(standardDeviations(6,5),'--r',"2 Excited Inhibited Standard Deviations")
    yline(standardDeviations(6,6),'--r',"3 Excited Inhibited Standard Deviations")
    end

    if strcmp(whichPattern,"ie")
    yline(standardDeviations(7,1),'--y',"-3 Inhibited Excited Standard Deviations")
    yline(standardDeviations(7,2),'--y',"-2 Inhibited Excited Standard Deviations")
    yline(standardDeviations(7,3),'--y',"-1 Inhibited Excited Standard Deviations")
    yline(standardDeviations(7,4),'--y',"1  Inhibited Excited Standard Deviations")
    yline(standardDeviations(7,5),'--y',"2  Inhibited Excited Standard Deviations")
    yline(standardDeviations(7,6),'--y',"3  Inhibited Excited Standard Deviations")
    end

    if strcmp(whichPattern,"ii")
    yline(standardDeviations(8,1),'--m',"-3 Inhibited Inhibited Standard Deviations")
    yline(standardDeviations(8,2),'--m',"-2 Inhibited Inhibited Standard Deviations")
    yline(standardDeviations(8,3),'--m',"-1 Inhibited Inhibited Standard Deviations")
    yline(standardDeviations(8,4),'--m',"1 Inhibited Inhibited Standard Deviations")
    yline(standardDeviations(8,5),'--m',"2 Inhibited Inhibited Standard Deviations")
    yline(standardDeviations(8,6),'--m',"3 Inhibited Inhibited Standard Deviations")
    end
end
end