function [TS, TTL, ES, Hdr] = dg_readEvents(filename, varargin)
%[TS, TTL, ES, Hdr] = dg_readEvents(filename, 'text')
%[TS, TTL, ES, Hdr] = dg_readEvents(filename)
% Invokes a Neuralynx event file reading function as appropriate to the
% platform.
% OUTPUTS
%   TS:  Timestamps in clock ticks (units as recorded)
%   TTL:  TTL IDs.  These are returned as signed integers, with 2^15 bit 
%       (strobe/sync) propagated to the left.  To extract the lower 15
%       bits, add 2^15 to negative values to yield positive integers.
%   ES:  Event strings.
% OPTIONS
%   'mode', modenum, modearg - invokes the Neuralynx "Extraction Mode"
%       specified by <modenum> (default is 1).  In keeping with the new
%       convention of Nlx library v5.0.1, the first record is record 1,
%       whereas in releases through v4.1.3 it was record 0.
%   'preset', outfilename - Bypass the GUI for specifying the output file
%       location, and write to <outfilename>, overwriting any existing file
%       at that location.
%   'text' - creates a text translation of the events file; presents a GUI
%       to specify the location of the output file.  All header lines have
%       a single blank inserted at the beginning to prevent Excel from
%       treating them as numeric.
%   'unsigned' - TTL values are returned as unsigned integers, which means
%       that when the strobe bit is set, the value is >= 2^15.  To extract
%       the non-strobe bits, subtract 2^15.
% NOTES
%   See dg_txt2nev for converting from text files to Nlx.  See
%   dg_writeNlxEvents for writing values as returned by dg_readEvents.

%$Rev: 162 $
%$Date: 2012-12-15 20:48:35 -0500 (Sat, 15 Dec 2012) $
%$Author: dgibson $

modenum = 1;
modearg = [];
presetflag = false;
textflag = false;
unsignedflag = false;
argnum = 1;
while argnum <= length(varargin)
    switch varargin{argnum}
        case 'mode'
            argnum = argnum + 1;
            modenum = varargin{argnum};
            argnum = argnum + 1;
            modearg = varargin{argnum};
        case 'preset'
            presetflag = true;
            argnum = argnum + 1;
            outfilename = varargin{argnum};
        case 'text'
            textflag = true;
        case 'unsigned'
            unsignedflag = true;
        otherwise
            error('dg_readEvents:badoption', ...
                ['The option "' varargin{argnum} '" is not recognized.'] );
    end
    argnum = argnum + 1;
end
if isempty(filename)
    [FileName,PathName] = uigetfile({'*.nev'
        '*.dat'
        '*.*' }, ...
        'Choose events file');
    filename = fullfile(PathName, FileName);
end
[p, n, ext] = fileparts(filename); %#ok<ASGLU>
if strcmpi(ext, '.dat')
    warning('dg_readEvents:ext', ...
        'This Nlx function requires .nev extension; making temporary copy of %s.', ...
        filename );
    tempfn = [tempname '.nev'];
    while exist(tempfn) %#ok<EXIST>
        tempfn = [tempname '.nev'];
    end
    dg_copyfile(filename, tempfn);
    file2read = tempfn;
else
    file2read = filename;
end
try
    if ispc
        if ismember(modenum, [2 3])
            % v4.1.1 uses 0 to denote the first record
            modearg = modearg - 1;
        end
        [TS, TTL, ES, Hdr] = Nlx2MatEV_411(file2read, [1, 0, 1, 0, 1], 1, ...
            modenum, modearg);
        if ~unsignedflag
            % Convert to the "bugged" representation of v4.1.2 and earlier:
            TTL(TTL>=2^15) = TTL(TTL>=2^15) - 2^16;
        end
    elseif ismac || isunix
        if ismember(modenum, [2 3])
            % The unix version uses 0 to denote the first record
            modearg = modearg - 1;
        end
        [TS, TTL, ES, Hdr] = Nlx2MatEV_v3(file2read, [1, 0, 1, 0, 1], 1, ...
            modenum, modearg);
        if strcmpi(ext, '.dat')
            dg_deletefile(tempfn);
        end
        if unsignedflag
            % Convert to the "correct" unsigned integer representation of
            % v4.1.3 and later:
            TTL(TTL<0) = TTL(TTL<0) + 2^16;
        end
    else
        error('dg_readEvents:arch', ...
            'Unrecognized computer platform');
    end
catch e
    errmsg = sprintf( ...
        'Nlx2Mat arguments in dg_readEvents:\nfile:%s\nmodenum:%s\nmodearg:%s', ...
        dg_thing2str(file2read), ...
        dg_thing2str(modenum), ...
        dg_thing2str(modearg) );
    errmsg = sprintf('%s\n%s\n%s', ...
        errmsg, e.identifier, e.message);
    for stackframe = 1:length(e.stack)
        errmsg = sprintf('%s\n%s\nline %d', ...
            errmsg, e.stack(stackframe).file, ...
            e.stack(stackframe).line);
    end
    error('dg_readEvents:failed', '%s', errmsg);
end
if isempty(Hdr{end}) || ~isempty(regexp(Hdr{end}, '^\s*$', 'once' ))
    Hdr(end) = [];
end
if textflag
    if ~presetflag
        [FileName,PathName] = uiputfile('events.txt');
        outfilename = fullfile(PathName, FileName);
    end
    fid = fopen(outfilename, 'w');
    if fid == -1
        error('dg_readEvents:badoutfile', ...
            'Could not open %s for writing', fullfile(PathName, FileName) );
    end
    for k = 1:length(Hdr)
        fprintf(fid, ' %s\n', Hdr{k});
    end
    for k = 1:length(TS)
        fprintf(fid, '%.0f\t%.0f\t%s\n', TS(k), TTL(k), ES{k});
    end
    fclose(fid);
end
