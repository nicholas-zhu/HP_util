function J = imnorm(I)

%
%IMNORM Normalizes image brightness from zero to one.  Works for
%       n-Dimensional images.
% 
%  Syntax:
%   J = IMNORM(I)
%
%  Inputs:
%   I = original image
%
%  Outputs:
%   J = normalized image
%
%  9/27/10, Dave J. Niles, dave.j.niles@gmail.com
%

minn = min(I(:));
maxx = max(I(:));

J = (I - minn)./(maxx - minn);

end
