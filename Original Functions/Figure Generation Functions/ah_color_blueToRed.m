function color = ah_color_blueToRed(cVal)

if cVal > 1
    color = [1, 0, 0];
elseif cVal > .75
    color = [1, 4-cVal*4, 0];
elseif cVal > .5
    color = [cVal*4-2, 1, 0];
elseif cVal > .25
    color = [0, 1, 2-cVal*4];
elseif cVal > 0
    color = [0, cVal*4, 1];
elseif isnan(cVal) || cVal <= 0
    color = [0, 0, 1];
else
    error(['Invalid Color Value: ' num2str(cVal)]);
end

end