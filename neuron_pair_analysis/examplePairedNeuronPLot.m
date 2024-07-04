% Date: 09/27/2023
% Firing rate plot of single paired neurons in triplet

function examplePairedNeuronPLot(dataTable, plotType, row)

% Example usage
% examplePairedNeuronPLot('twdb_control', 'PLSvsFSI', 54)

% All dataTable: 'twdb_control', 'twdb_stress', 'twdb_stress2'
% All plotType: 'PLSvsFSI', 'FSIvsSTRIO'

if strcmpi(dataTable, 'twdb_control')
    loadFile = load('pairsTableControl.mat');
elseif strcmpi(dataTable, 'twdb_stress')
    loadFile = load('pairsTableStress.mat');
else
    loadFile = load('pairsTableStress2.mat');
end

fitData = loadFile.fitData;

if strcmpi(plotType, 'PLSvsFSI')
        try
            fitResult1 = fitData.fitresultArray_PLSvsFSI{row};
            a = fitResult1.a;
            b = fitResult1.b;
            x = fitData.xValArray_PLSvsFSI{row};
            y = fitData.yValArray_PLSvsFSI{row};
            plot(x, y, 'o', 'Color', 'blue');
            hold on;
            x_fit = linspace(min(x), max(x), 100);
            y_fit = a*x_fit + b;
            plot(x_fit, y_fit, 'LineWidth', 2, 'Color', 'blue');
            hold off;
            xlabel("PLS Firing Rate","Interpreter","latex");
            ylabel("FSI Firing Rate","Interpreter","latex");
            title(sprintf("PLS: %d, FSI: %d", fitData.plsIndex(row), fitData.fsiIndex(row)));
            
        catch
            fprintf("Plotting error\n");
        end

elseif strcmpi(plotType, 'FSIvsSTRIO')
    disp("Work on it.")

elseif strcmpi(plotType, 'PLSvsSTRIO')
     row = input("Which row do you want to plot? ");
        
        try
            %% For linear fit
            fitResult = fitData.fitResultArray_PLSvsSTRIO{row};
            c = fitResult.c;
            data = fitResult.d;

            x = fitData.xValArray_PLSvsSTRIO{row};
            y = fitData.yValArray_PLSvsSTRIO{row};
            plot(x, y, 'o', 'Color', 'r');
            hold on;
            x_fit = linspace(min(x), max(x), 100);

            %% For linear fit
            y_fit = c*x_fit + data;

            plot(x_fit, y_fit, 'LineWidth', 2, 'Color', 'r');
            hold off;
            xlabel("PLS Firing Rate","Interpreter","latex");
            ylabel("Strio Firing Rate","Interpreter","latex");
            title(sprintf("PLS: %d, Strio: %d", fitData.plsIndex(row), ...
                fitData.striosomeIndex(row)));
            
        catch
            fprintf("Plotting error\n");
        end
end
set(gcf, 'Windowstyle', 'docked');
end