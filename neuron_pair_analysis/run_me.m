%% Synchrony plot (1st plot)
% 1st step
extractNeuronsFromSameSession('twdb_control', 'PL');
extractNeuronsFromSameSession('twdb_control', 'FSI');
extractNeuronsFromSameSession('twdb_control', 'Matrix');
extractNeuronsFromSameSession('twdb_control', 'Striosome');

% 2nd step
covAndBinCtMatrixOfNeuronsFromSameSession('twdb_control', 'sameSessionPLneuronsINcontrol.mat');
covAndBinCtMatrixOfNeuronsFromSameSession('twdb_control', 'sameSessionFSIneuronsINcontrol.mat');
covAndBinCtMatrixOfNeuronsFromSameSession('twdb_control', 'sameSessionMatrixneuronsINcontrol.mat');
covAndBinCtMatrixOfNeuronsFromSameSession('twdb_control', 'sameSessionStriosomeneuronsINcontrol.mat');

% 3rd step
neuronSynchronyPlot(varargin);

%%  PLS-FSI firing rate (2nd plot)
% 1st step
differentNeuronPairsInDatabase('twdb_control');
differentNeuronPairsInDatabase('twdb_stress');
differentNeuronPairsInDatabase('twdb_stress2');

% 2nd step
extractFitData('twdb_control', 'PLSvsFSI');
extractFitData('twdb_control', 'PLSvsSTRIO');
extractFitData('twdb_stress', 'PLSvsFSI');
extractFitData('twdb_stress', 'PLSvsSTRIO');
extractFitData('twdb_stress2', 'PLSvsFSI');
extractFitData('twdb_stress2', 'PLSvsSTRIO');

% 3rd step
examplePairedNeuronPLot('twdb_control', 'PLSvsFSI', 54); % subplot 1
examplePairedNeuronPLot('twdb_stress', 'PLSvsFSI', 32); % subplot 2

%% PLS-Striosome firing rate (3rd plot)


%% Experimental FSI and sSPN projecting cortex correlation (4th plot)
plotFitParamOfNeuronTriplets;

%% Experimental Coeff. a (5th Plot)
plotFitParamOfNeuronTriplets;
