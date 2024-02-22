function [xnew, ynew] = y_mean(x,y)
xnew = [];
ynew = [];

uniqx = unique(x);
%original code is lines 7-10
% for ix=uniqx
%    xnew = [xnew; ix];
%    ynew = [ynew; mean(y(ix == x))];
% end
for ix=uniqx
    if mean(y(ix==x)) ==0
    else
        xnew = [xnew;ix];
        ynew = [ynew;mean(y(ix==x))];
    end
end
end

