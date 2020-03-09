function [M,padpre] = padImage(MData, pof2, padval)
%
% [M,padpre] = padImage(MData, pof2, padval)
% 
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

if ~exist('padval','var')
    padval = 0;
end

dim = size(MData);
s = 2^pof2;
newdim = ceil(dim/s)*s;

paddim = newdim-dim;
padpre = floor(paddim/2);
padpost = paddim-padpre;

M = padarray(MData,padpre,padval,'pre');
M = padarray(M,padpost,padval,'post');

 

