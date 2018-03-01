function frequnits = getfrequnitstrs(menuflag)
%GETFREQUNITSTRS Return a cell array of frequency units strings.
%
%   STRS = GETFREQUNITS returns a cell array of standard frequency units 
%   strings.

%   STRS = GETFREQUNITS(MENUFLAG) returns a cell array of frequency units
%   with the "Normalized Frequency" string for use in a uimenu.

%   Author(s): P. Costa
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2011/10/31 06:34:49 $

frequnits = {[getString(message('signal:sigtools:getfrequnitstrs:NormalizedFrequency')) '  (\times\pi rad/sample)'],...
            [getString(message('signal:sigtools:getfrequnitstrs:Frequency')) ' (Hz)'],...
            [getString(message('signal:sigtools:getfrequnitstrs:Frequency')) ' (kHz)'],...
            [getString(message('signal:sigtools:getfrequnitstrs:Frequency')) ' (MHz)'],...
            [getString(message('signal:sigtools:getfrequnitstrs:Frequency')) ' (GHz)'],...
            [getString(message('signal:sigtools:getfrequnitstrs:Frequency')) ' (THz)'],...
            [getString(message('signal:sigtools:getfrequnitstrs:Frequency')) ' (PHz)'],...
            [getString(message('signal:sigtools:getfrequnitstrs:Frequency')) ' (EHz)'],...
            [getString(message('signal:sigtools:getfrequnitstrs:Frequency')) ' (aHz)'],...
            [getString(message('signal:sigtools:getfrequnitstrs:Frequency')) ' (fHz)'],...
            [getString(message('signal:sigtools:getfrequnitstrs:Frequency')) ' (pHz)'],...
            [getString(message('signal:sigtools:getfrequnitstrs:Frequency')) ' (\muHz)'],...
            [getString(message('signal:sigtools:getfrequnitstrs:Frequency')) ' (mHz)']};

% Return the proper version of the Normalized Frequency string
% for the X-axis label or menu item.
if nargin == 1,
    frequnits{1} = getString(message('signal:sigtools:getfrequnitstrs:NormalizedFrequency'));
end

% [EOF]
