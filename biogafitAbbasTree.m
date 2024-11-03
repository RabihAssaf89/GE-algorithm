function classPerformance = biogafitAbbasTree(thePopulation,Y,id)
%BIOGAFIT The fitness function for BIOGAMSDEMO
%
%   This function uses the classify function to measure how well mass
%   spectrometry data is grouped using certain masses. The input argument
%   thePopulation is a vector of row indices from the mass spectrometry
%   data Y. Classification performance is a linear combination of the error
%   rate and the posteriori probability of the classifier. 
  
%   Copyright 2003-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/09/27 00:18:16 $
N = size(Y,2);
thePopulation = round(thePopulation);
try  
    nbGau= fitctree(Y(thePopulation,:)',double(id));
    [c,Posterior] = predict(nbGau,Y(thePopulation,:)');
     p = abs(Posterior);
     cp = classperf(id,c);
     classPerformance = 100*cp.ErrorRate	 + ( 1 - mean(max(abs(p),[],2)));
 
  
catch
   classPerformance = Inf; 
end       