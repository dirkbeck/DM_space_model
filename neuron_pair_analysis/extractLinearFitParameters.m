% Date: 10/12/2023
% Author: Atanu Giri

% This function extracts fitting parameters

function [coeffA, coeffB, allGOF] = extractLinearFitParameters(pairsInTriplet, twdbs)

% Load database data
databaseData = cell(1,3);
databaseData{1} = twdbs.twdb_control;
databaseData{2} = twdbs.twdb_stress;
databaseData{3} = twdbs.twdb_stress2;

coeffA = cell(1, 3);
coeffB = cell(1, 3);
allGOF = cell(1, 3);

for group = 1:3
    coeffA{group} = cell(1,3);
    coeffB{group} = cell(1,3);
    allGOF{group} = cell(1,3);
end

for group = 1:3
    for pair = 1:3

        coeffA{group}{pair} = nan(height(pairsInTriplet{group}{pair}), 1);
        coeffB{group}{pair} = nan(height(pairsInTriplet{group}{pair}), 1);
        allGOF{group}{pair} = nan(height(pairsInTriplet{group}{pair}), 1);

        for row = 1:height(pairsInTriplet{group}{pair})
            N1id = pairsInTriplet{group}{pair}.(1)(row);
            N2id = pairsInTriplet{group}{pair}.(2)(row);

            N1spikes = databaseData{group}(N1id).trial_spikes;
            N2spikes = databaseData{group}(N2id).trial_spikes;

            % Get the output values
            try
                [fitresult, gof, xnew, ynew, Rval, Pval] = plotDynamicsDoublet( ...
                    N1spikes, N2spikes, 1.33, 1);

                coeffA{group}{pair}(row) = fitresult.a;
                coeffB{group}{pair}(row) = fitresult.b;
                allGOF{group}{pair}(row) = gof.rsquare;

            catch
                fprintf('Skipping iteration %d due to an error.\n', row);
            end
        end % Analysis of row
    
    end % End of neuron pair

end % End of neuron group

end