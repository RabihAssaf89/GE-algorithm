load('data_MIR_Martin.mat');
Lmin = 2; Lmax = 20;
T=100;
Nmin = 100;  Nmax = 500;
data=dataE;
id=idC;
[numPoints numSamples] = size(data);
l=1;
for L=Lmin:Lmax, 
    axeL(l) = L;
    n=1;
   
     for N=Nmin:100:Nmax,
        axeN(n) = N;
      
             options = gaoptimset('CreationFcn', {@biogacreateAbbas,data,id},'PopulationSize',N,'Generations',T,'Display', 'iter'); 
            rand('seed',1)
            randn('seed',1)
            nVars = L;                             % set the number of desired features (taille d'un chromosome)
            FitnessFcn = {@biogafitAbbasLDA,data,id};
           
            [feat best] = ga(FitnessFcn,nVars,options);  % call the Genetic Algorithm
             feat = round(feat);
              
                Resultat{l,n,1} = feat;
                Resultat{l,n,2} = best;
           
        n = n+1;
    end
    l = l+1;
    end
save resultat_AG_BayesFigure1_Martin_MIR.mat Resultat axeL 
clear
           