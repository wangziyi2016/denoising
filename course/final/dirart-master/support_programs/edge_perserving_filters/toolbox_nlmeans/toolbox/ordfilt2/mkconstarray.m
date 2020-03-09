function out = mkconstarray(class, value, size)
%MKCONSTARRAY creates a constant array of a specified numeric class.
%   A = MKCONSTARRAY(CLASS, VALUE, SIZE) creates a constant array 
%   of value VALUE and of size SIZE.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.1.1.1 $  $Date: 2008/10/14 19:32:25 $

out = repmat(feval(class, value), size);

