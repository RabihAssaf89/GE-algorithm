% File: EMSC_Main
% Purpose: Demonstrate how to run Extended Multiplicative Signal Correction (EMSC) and Extended Inverse Scatter Correction (EISC) 
%            under various input conditions, using program EMSCEISC.m
%
%  Made by H. Martens January 2003
%       (c) Consensus Analysis AS 2002
%
% NB! the EMSC/EISC methodology is patented. 
%       Academic use of of this code is free, but
%       commercial use of it requires permission from the author.
%       Contact: StarkEdw@aol.com   or Harald.Martens@matforsk.no
%
% Matlab Call: 	EMSC_Main
%
% ............................  Overview: ...............................................
% Transforms a set of "spectra", read from file  <Inputfile> , (default: EMSC_Z.mat) by
%       EMSC or EISC or various optimized versions of this, and 
% Saves:
%       Corrected spectra for the samples to file EMSCCor_<Inputfile>                  e.g. EMSCModSpectra_Z.mat
%       EMSC parameters for the samples to file EMSCModParam_<Inputfile>               e.g. EMSCModParam_Z.mat
%       EMSC residual spectra for the samples to file EMSCRes_<Inputfile>              e.g. EMSCRes_Z.mat
%
%       If used in calibration mode (DataCases>=0):
%           Saves EMSC model spectra to file EMSCModSpectra_<Inputfile>                e.g. EMSCModSpectra_Z.mat
%           Saves EMSC model  for later prediction, to file EMSCModel_<Inputfile>      e.g. EMSCModel_Z.mat
%       If used in prediction model (DataCases<0):
%           Reads EMSC model  to file EMSCModel_<Inputfile>                             e.g. EMSCModel_Z.mat
% ...................................................................................................
%
% ............................... More details: ..........................................
% Input:
%   Screen input: DataCases (scalar or vector) integer that controls program operation, 
%                           =-1000=stop, 
%                           0=manual calibration control, 
%                          =-1 or -2: manual prediction control
%                          = 1000 gives an overview of pre-defined data/method combinations, 
%                           defined in files
%           For Calibration: yielding an EMSC model file as well as EMSC parameters and EMSC-treated spectra :
%                   EMSC_GetUserDefinedDataCases.m  (User's own EMSC cal. methods)
%                   or 
%                   EMSCGetInternalDataCases.m      (Pre-defined EMSC cal. methods)
%
%           For Prediction , using an already established EMSC model file,yielding EMSC parameters and EMSC-treated spectra:
%                   EMSC_GetUserDefPredDataCases.m  (User's own EMSC pred. methods)
%                   or
%                   EMSCGetDefaultInputDataForPred      (Pre-defined EMSC pred. methods)
%
%   File Input:   Multichannel "spectra" Z to be treated: <Inputfile> , default: EMSC_Z.mat
%       Format: as stored e.g. from The Unscrambler (TM):
%            spectra inMatrix(nObj x nZVar)
%            row-and column name labels (character arrays) in ObjLabels(nObj,:) and VarLabels(nZVar,:)
%    Optional input files ( same format as <Inputfile>):
%           <YFileName>, jY : file name and column % to be used in target variable Y, e.g. EMSC_Y.mat, jY=1
%               (Required for optimized model definition by simplex optimization or direct orthogonalization)
%           <WgtFile>  file name with a row of statistical ChannelWeights for the nZVar channels
%               (Content may be overridden by re-estimated weights using nWeightIter>0)
%           <RefFileName>  file name with a row RefSpectrum for the nZVar channels
%               (Content may be overridden by re-estimated weights using OptPar=1) 
%           <FileNameBad>  file name with one or more rows of spectra of "bad" (undesired) phenomena, to be eliminated 
%               (Content may be overridden by re-estimated weights using OptPar=2) 
%               (Content may be extended by n new vectors by   using OptPar=-n) 
%           <FileNameGood> file name with one or more rows of spectra of "good" (desired) phenomena, to be retained 
%               (Content may be overridden by re-estimated weights using OptPar=3) 
%               (Content may be extended by n new vectors by   using OptPar=-n) 
%
% Internal parameters:
%   Control parameters for the calibration are defined default in file EMSCGetOptimizationDefaults.m,
%       but they may be modified by the user in file EMSC_GetUserDefinedDataCases.m 
%       (or fixed at non-default values in file EMSCGetInternalDataCases.m)
%
%
% Output:
%   Saves corrected spectra for the samples to file EMSCCor_<Inputfile>                  e.g. EMSCModSpectra_Z.mat
%   Saves EMSC parameters for the samples to file EMSCModParam_<Inputfile>               e.g. EMSCModParam_Z.mat
%   Saves EMSC model spectra to file EMSCModSpectra_<Inputfile> (only calibration)       e.g. EMSCModSpectra_Z.mat
%
%
% .................... Program overview: .....................................
% EMSC_Main.m has the following sub-functions:
%
%   Calls   EMSCDialogue.m                        Controls the SOURCE of definitions of data input and modelling.
%           EMSCGetParametersAndData.m            Data input and specification of modelling.
%
%           EMSCEISCReWgtd.m                      EMSC / EISC (with reweighting of Z-variables; optional)
%               or 
%           EMSCEISCOpt.m                         EMSC / EISC with model optimized by SIMPLEX optimization.
%               or 
%           EMSCDoDo.m                            EMSC / EISC with model extended automatically with  model spectra  
%						                             re-estimated by Direct Orthogonalization.
%
%           EMSCPlotEMSCModelling.m               Plot some  details from the EMSC model estimation
%           EMSCPlotThisDataCase.m                Plot results from the EMSC model estimation
%           EMSCSaveResults.m                     Save results from the EMSC model estimation to file
%           EMSCPlotAllDataCases.m                Compare the performance of all the parameter settings tested till now
%
%
%..................... Detailed program structure: ........................................
%
%   EMSCDialogue.m                                Controls the SOURCE of definitions of data input and modelling.
%
%   For each DataCase: eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
%       Input specification: .....................................
%           EMSCGetParametersAndData.m            Data input and specification of modelling.
%             Calls   EMSCGetOptimizationDefaults.m   Initialises various parameters and constants
%
%              Either CALIBRATION input: cccccccccccccccccccccccccccccc
%                    EMSCGetInputData.m              Full manual definition of data file and modelling type
%                       or 
%                    EMSCGetDefaultInputData.m       Definition of data file and modelling type pre-defined in file
%
%                     Calls  EMSCGetOptimizationDefaults.m (again)  Initialises various parameters and constants
%                            EMSCGetDefaults<date> :          A set of defaults for all control parameters
%                            EMSC_GetUserDefinedDataCases.m   The user's own default methods 
%                               or 
%                            EMSCGetInternalDataCases.m       Pre-defined default methods
%
%                            EMSCGetReadDefaultInputData.m    Read and check the input data 
%               cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
%
%               Or PREDICTION input: ppppppppppppppppppppppppppppppppppp
%
%                    EMSCGetInputDataForPrediction.m  Full manual definition of data file and old model file
%                       or 
%                    EMSCGetDefaultInputDataForPred.m               Sets some default pred. methods
%                       Calls: EMSC_GetUserDefinedPredDataCases.m   The user's own default methods 
%                              EMSCGetReadDefaultInputData.m        Read and check the input data 
%
%                ppppppppppppppppppppppppppppppppppppppppppppppppppppppp
%
%           .................... EMSC or EISC pre-treatment: .....................................
%           EMSCEISCReWgtd.m           Simple  EMSC / EISC (with reweighting of Z-variables; optional)
%               or 
%           EMSCEISCOpt.m              Iteratively optimised   EMSC / EISC with some parameters optimized by SIMPLEX optimization.
%               or 
%           EMSCDoDo.m                 Iteratively optimised   EMSC / EISC with model extended automatically with  model spectra  
%						                             re-estimated by Direct Orthogonalization.
%
%           .................... Plotting and storing of results: .....................................
%           EMSCPlotEMSCModelling.m               Plot some  details from the EMSC model estimation
%           EMSCPlotThisDataCase.m                Plot results from the EMSC model estimation
%           EMSCSaveResults.m                     Save results from the EMSC model estimation to file
%   end of each DataCase: eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee%
%
% For all DataCases examined:
%           EMSCPlotAllDataCases.m                Compare the performance of all the parameter settings tested till now
%           
% ....................End of EMSC_Main.m .....................................
%
%   Auxillary programs:
%
%   Defaults for files  EMSC_Ref.mat, EMSC_Wgt.mat, EMSC_GoodSpectra.mat and EMSC_BadSpectra.mat
%       can be defined by running program EMSCMakeDefaults.m
%   Default reference for file EMSC_Ref.mat can be defined by running program program EMSCMakeRef.m
%   Weights for file EMSC_Wgt.mat can be defined by running program program EMSCMakeWeights.m
%   Good dummy spectrum for EMSC_GoodSpectra.mat can be defined as sample from from EMSC_Z.mat, by 
%		running program program EMSCMakeGoodSpectra.m
%   Bad dummy spectrum for EMSC_BadSpectra.mat can be defined as sample from EMSC_Z.mat, by running program 
%		 EMSCMakeBadSpectra.m
%   Good and Bad spectra can alternatively be defined as PCs from EMSC_Z.mat, by running program EMSCMakeGoodBadSpectra.m
%
%
%   Remaining issues: Documentation not yet finished
%   Optimize w.r.t. predictive ability of X= EMSC parameter estimates, not EMSC corrected spectra
%   Improve reweighting scheme
%   Implement Optimal Scaling to account for curvatures in X-Y relationship
%   Stabilize nonlinear optimization of Ref, e.g. so scale it to ss=ss(start Ref)
%
%

%xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

% ...............................Initializations: .................................
disp(' ___________________________________________________ '),disp(' ')
disp(' ')
disp(' EMSC / EISC pre-treatment of multichannel data')
disp(' Matlab code copyright (c) Consensus Analysis AS 2003')
disp(' The EMSC/EISC methodology is covered by:')
disp(' US Patent 5,568,400, E.Stark and H. Martens: "Multiplicative Signal Correction Method and Apparatus", and')
disp(' European patent 0415401, E.Stark and H. Martens: "Improved Multiplicative Signal Correction Method and Apparatus"')
disp(' ___________________________________________________ '),disp(' ')
disp('Literature: ')
disp('Original EMSC: H.Martens and E.Stark (1991) Extended multiplicative signal')
disp('                  correction and spectral interference subtraction: New preprocessing methods')
disp('                  for near infrared spectroscopy. J.Pharmaceutical & Biomedical Analysis 9(8),625-635.')
disp('Recent   EMSC: Harald Martens , Martin Høy , Barry M. Wise , Rasmus Bro , Per B. Brockhoff (2003) ')
disp('                  Pre-whitening of data by covariance-weighted pre-processing.    J. Chemometric 17,153-165 . ')
disp('Recent   EISC: Pedersen, D.K., Martens, H., Pram Nielsen, J. and Balling Engelsen (2002), S. ')
disp('                  Light absorbance and light scattering separated by Extended Inverted Multiplicative Signal Correction (EIMSC). ')
disp('                  Analysis of NIT spectra of single wheat seeds. Applied Spectroscopy,  56(9) 1206-1214.')
disp(' ___________________________________________________ '),disp(' ')
disp('Conditions: ')
disp(' Academic use of this code is free, but commercial use of it requires a license')
disp('  from the patent holders. Contact: StarkEdw@aol.com or Harald.Martens@matforsk.no')
disp(' ')
disp(' ___________________________________________________ ')

%
% Plot control:
%   PlotIt=0: No plots
%   PlotIt=1; Plot the results for the treated data
%   PlotIt=2: Plot also steps in the estimation process
%   PlotIt=3: Display also some internal parameters on the screen
%
% Set Graphics resolution:
GraphicsResolution= 2 % 1 or 2;
if GraphicsResolution==1
    DFigH=800;DFigV=600;dFig=20;
elseif GraphicsResolution==2
    DFigH=400;DFigV=300;dFig=10;
else
    error('wrong GraphicsResolution')
end % if
GraphicsResolutions=[DFigH,DFigV,dFig]

global EMSCLog  
format compact
iCase=0; CaseLog=[];
EMSCDataCases=[]; % summary
CorrectedChemModelParam= []; 
PrintPlots=0; %Default
PauseBetweenDataCases=0;
EnoughDataCases=0;
DataCasesUsed=[];
PlotALot=1; % Default for PlotIt: use the plot control in the input files

%..............................................................................


while EnoughDataCases==0

    DialogueParams =[EnoughDataCases, PrintPlots,PrintPlots,PlotALot,PauseBetweenDataCases];
    OldPlotALot=PlotALot;

     [DataCases,DialogueParams]=EMSCDialogue( DialogueParams);    
  
   
     EnoughDataCases=DialogueParams(1);     PrintPlots=DialogueParams(2);     PrintPlots=DialogueParams(3);
     PlotALot=DialogueParams(4);     PauseBetweenDataCases=DialogueParams(5);
       %if PlotALot~=1
     %     OptionPlot{1}=PlotALot;
     % end % if PlotALot
     %ChangedPlotALot=(PlotALot~=OldPlotALot); % 1= changed plot level

     
     if EnoughDataCases==0
        iCaseInThisSet=0;
       for DataCase=DataCases %DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
            iCaseInThisSet=iCaseInThisSet+1;
            iCase=iCase+1; 
                            
            close all % close all previous plots

            % Define parameter settings and data: .........................................................................
            EMSCLog=[];DataCaseName=[];PredCaseName=[]; 
            [OptionsEMSC,OptionsSearch,OptionPlot,EMSCDataCases,DataCaseCal,DataCaseName]= EMSCGetParametersAndData(DataCase, EMSCDataCases,GraphicsResolutions);
            
            disp(' ')
            disp('--------------------------------------------------------------------')
            disp(' ')
            disp(['Now treating DataCase ',num2str(DataCase),'=',DataCaseName])
            
            % Control the plots: if PlotALot has not been defined, then the data input controls the plotting, else, PlotALot controls it:
            
            %PlotIt=OptionPlot{1}; % Default: Use the PlotIt from the local input
            %if ChangedPlotALot==1 
            PlotIt=PlotALot; % The user as asked to change the general PlotIt level  in the dialogue
                %end
            OptionPlot{1}=PlotIt;
            
            
            if ~isempty(DataCaseName) % A new data case has been found
                DataCasesUsed(iCase)=1;
                
                
                % Perform pre-processing ...........................................................
                OptimizedPar=OptionsSearch{20};
                if sum(OptimizedPar)==0 
                    % non-optimised EMSC/EISC:  
                    
                    
                   [ZCorrected,ModelParamNames,ZMod,ModelParam,CovModelParam,SModelParam,LocalEMSCResults,OptionsEMSC] ...
                        = EMSCEISCReWgtd(OptionsEMSC,OptionPlot);
    
                   
                    %[ZCorrected,ModelParamNames,ZMod,ModelParam,CovModelParam,SModelParam,LocalEMSCResults] ...
                    %    = EMSCEISC(OptionsEMSC,OptionPlot);
                    
                elseif sum(OptimizedPar) >0 
                    % Optimised EMSC/EISC:  
                    %[OptC,OptRMSEP,EXITFLAGFminsearch,OUTPUT, OptionsSearch, ...
                     %   ZCorrected,ModelParamNames,ZMod,ModelParam,CovModelParam,SModelParam,EHat,OptionsEMSC] ...
                     %   = EMSCEISCOpt(OptionsEMSC, OptionsSearch,OptionPlot);
                     
                    [cOpt,OptRMSEP,EXITFLAGFminsearch,OUTPUT,OptionsSearch, ...
                        ZCorrected,ModelParamNames,ZMod,ModelParam,CovModelParam,SModelParam, ...
                        OptionsEMSC, LocalEMSCResults] = EMSCEISCOpt(OptionsEMSC, OptionsSearch,OptionPlot);
                
                    % The optimised spectra:
                    %if  OptimizedPar(1)==1,  RefSpectrum=OptionsEMSC{10};
                    %elseif OptimizedPar(2)==1, BadC=OptionsEMSC{11};
                    %elseif OptimizedPar(3)==1, GoodC=OptionsEMSC{12};
                    %end %if
                elseif sum(OptimizedPar)<0
                     
                     [ZCorrected,ModelParamNames,ZMod,ModelParam,CovModelParam,SModelParam,LocalEMSCResults,OptionsEMSC] ...
                        = EMSCDoDo(OptimizedPar,OptionsEMSC,OptionsSearch,OptionPlot);
                   
                    
                end %if sum(OptimizedPar)        % End of Perform pre-processing ...............................................
                           

                  
                
                % Plot final results ..............................................
                [nVar,nModParam]=size(ZMod);
                if nModParam>0
                        [CorrectedChemModelParam,OK]=EMSCPlotEMSCModelling(ZMod, ModelParamNames,ModelParam, SModelParam,CovModelParam,OptionsEMSC, OptionPlot,LocalEMSCResults,DataCase, DataCaseCal);
                        %else
                        %MedianSModelParam=median(SModelParam);  TrunkatedSModelParam=max(SModelParam, ones(nObj,1)*MedianSModelParam/2);
                        %TrunkatedTModelParam= ModelParam./TrunkatedSModelParam;     MaxTrunkatedTModelParam=max(abs(TrunkatedTModelParam));
                end % if nModParam
                  
                [CaseLog]=EMSCPlotThisDataCase(DataCase,  DataCaseCal,DataCaseName, ZCorrected, PlotIt, PrintPlots,CaseLog,OptionsEMSC, OptionsSearch,OptionPlot);
                        
                % Save the results: ......................................................................................

                [OK]=EMSCSaveResults(DataCase,DataCaseCal,DataCaseName,ZCorrected,ModelParamNames,ZMod,ModelParam,CovModelParam,SModelParam,OptionsEMSC,OptionsSearch,LocalEMSCResults, ...
                    CorrectedChemModelParam,PlotIt);
                 
                if iCase~=length(DataCases)
                    if PauseBetweenDataCases==1
                        disp('! NB Press spacebar for next demo!'),pause
                    else                    
                        pause(.1)
                    end %if

                end % if
            else  % if ~isempty(DataCaseName)         
                DataCasesUsed(iCase)=0;
            end % if ~isempty(DataCaseName)
            

        end % for DataCase DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
        
    end % if EnoughDataCases==0; %
    
    % Compare the DataCases computed till now:
    if size(CaseLog,1)>0
        [OK]=EMSCPlotAllDataCases(iCase, CaseLog, OptionPlot);
    
        % List  the DataCases so far:        
        disp('Cases tested:')
        k=char(EMSCDataCases);
    
        for jCase=1:size(k,1)
            disp(['     ',num2str(jCase),' DataCase=',k(jCase,:)])
        end % for jCase
        disp(['     RMSEPY  @1PC: In     EMSC/ @OptPCs:In   EMSC/ OptPCs: In   EMSC'])
        disp(CaseLog)
    end % if size()
  
end % while EnoughDataCases==0

disp('RunEMSC end')

