function dg_deletefile(filepath)
%dg_deletefile(filepath)
% This is a replacement for Matlab's 'delete', which might be perfectly
% fine, but I got superstitious after being burned by 'copyfile'.

%$Rev: 135 $
%$Date: 2011-12-01 19:44:37 -0500 (Thu, 01 Dec 2011) $
%$Author: dgibson $

if ispc
    system(sprintf('del %s', filepath));
elseif ismac || isunix
    system(sprintf('rm %s', filepath));
else
    error('dg_copyfile:arch', ...
        'Unrecognized computer platform');
end
