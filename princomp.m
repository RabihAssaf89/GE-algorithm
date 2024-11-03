function varargout = princomp(varargin)
%PRINCOMP Principal Components Analysis (PCA). 
%   PRINCOMP will be removed in a future release. Use PCA instead. 
%
%   Calls to PRINCOMP are routed to PCA.
%
%   [coeff, score, latent, tsquare] = princomp(x,econFlag)
% 
%   See also: PCA

%   Copyright 1993-2016 The MathWorks, Inc.

warning(message('stats:obsolete:ReplaceThisWith','princomp','pca'));

fEconomy = false;

if nargin > 1
    if isequal (varargin{2},0)
        fEconomy = false;
    end
    
    if strcmp(varargin{2},'econ')
        fEconomy = true;
    end
end

if nargout ==1
    varargout{1} = pca(varargin{1},'Algorithm','eig','Economy',fEconomy);
    return;
else
    [varargout{1:nargout}]=pca(varargin{1},'Algorithm','svd','Economy',fEconomy);
end
