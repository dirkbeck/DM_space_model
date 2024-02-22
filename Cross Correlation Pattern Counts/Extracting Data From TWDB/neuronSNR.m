function [voltages, snr_parameters,neuron_ids] = neuronSNR(twdb,DBtype,search_type,plot_,start,check_ids)
%NEURONSNR finds all neurons in the database satifying a certain criteria,
%and for those neurons, determines a set of parameters based on the mean
%spike waveform of those neurons. 
%
%INPUTS:
%twdb(struct array)- DB to be used (for fast loading purposes)
%DBtype(integer)- DB to be used (2:Stress 2, others not included because lack of
%data) (not fast loading) 
%search_type(integer)- type of twdb_lookup (0:loads saved ids, 1:dms neurons with conc fom 50 to 100)
%plot_(integer) - tells the function what type of plot (0:none, 1:velocity and
%acceleration, 2: snr parameters)
%start(integer) - to observe a specific neuron one can start in the desired index (1
%for checking all)
%check_ids(array or integer) - specific neuron IDs to be observed (0 to observe all)
%
%OUTPUTS:
%debug(array) - specific feature of each ID to be analyzed for debugging purposes (currently
%set to nothing, but can be set to anything)
%snr_parameters(cell array) - cell array of parameters of each neuron waveform that
%when combined could provide a better SNR
%neuron_ids(cell array) - IDs of neurons that are not considered noise
%(these should be saved for loading later)

%% DataBase Search
if DBtype == 2
    DB_string = 'Stress 2';
elseif DBtype == 1
    DB_string = 'Stress';
elseif DBtype == 0
    DB_string = 'Control';
end

%% Neuron Search

if search_type == 1
    neuron_ids = twdb_lookup(twdb, 'index', 'key', 'tetrodeType', 'dms',...
        'grade', 'final_michael_grade', 1, 5);
    disp(length(neuron_ids));
elseif search_type == 2
    load(['snr_ids_' DB_string '.mat']);
else
    %loads saved ids
    snr_ids = load('snr_ids');
    neuron_ids = snr_ids.neuron_ids;
end

%% Debugging

%Paramaeter can be set to anything. Returns a value to be verified for IDs
% debug = zeros(1,length(neuron_ids));

%Specific neuron IDs to check. If not, check all
if check_ids == 0
    check = 1:length(neuron_ids);
else
    check = check_ids;
end

%% SNR Parameters
%values for later use
firing_rates = zeros(1,length(check));
max_min_ratio = zeros(1,length(check));
peak_width = zeros(1,length(check)); %width of peak
valley_width = zeros(1,length(check)); %width of valley after peak
half_peak_width = zeros(1,length(check)); %half peak width
peakRise_slope = zeros(1,length(check)); %slope of the peak rise
peakFall_slope = zeros(1,length(check)); %slope of the peak fall
valleyRise_slope = zeros(1,length(check)); %slope of the rise of the valley after peak
snr_nan = zeros(1,length(check)); %indicates if any of the parameters above are not able to be calculated
bad_ids = [];
voltages = []; % Return the MSWs
%% Signal To Noise Ratio

for n=start:length(check) %starts at input index
    %% Spike Waveform with Interpolation, Velocity and Acceleration
    
    %Neuron Parameters
    id = str2double(neuron_ids{check(n)});
    tetrodeID = twdb(id).tetrodeID;
    neuronNum = str2double(twdb(id).neuronN);
    sessionDir = twdb(id).sessionDir;
    
    %Load Mean Spike Wafeform for Neurons
    sessionDir = strrep(sessionDir,'/Users/Seba/Dropbox/UROP/stress_project','../Final Stress Data/Data');
    sessionDir = strrep(sessionDir,'D:\UROP','../Final Stress Data/Data');
    tetrodeInfo = load([sessionDir,'/',tetrodeID,'_info.mat']);
    means = tetrodeInfo.means;
    if neuronNum > max(size(means))
        continue
    end
    MSW = means{1,neuronNum};%Mean Spike Waveform for Neuron
    
    %Obtaining Closest Recording from Tetrode
    dif = zeros(1,size(MSW,1));
    for i=1:size(MSW,1)
        dif(i) = max(MSW(i,:)) - min(MSW(i,:));%Highest difference between peak and valley
    end
    [~,I] = max(dif);%Index for closest recording
    
    
    %Interpolation
    x = 1:150;
    s = size(MSW);
    if s(2) ~= 150
        MSW = MSW';
    end
    v = MSW(I,x);%Closest Recording to Tetrode
    v = dg_smoothFreqTrace(v, 3); v(1) = 0;
    voltages = [voltages; (v-min(v))/(max(v)-min(v))];
    xq = 1:0.25:150;%values for interpolation
    vq = interp1(x,v,xq,'spline');%interpolated waveform
    sample_tops = dg_findFlattops(abs(vq),0.0015);%Interpolation Peaks and Valleys
    
    %Velocity of Spike w/ Peaks and Valleys    
    vel = [NaN diff(vq)];
    smooth_vel = dg_smoothFreqTrace(vel, 50); %Smoothing of Velocity
    vel_tops = dg_findFlattops(abs(smooth_vel),0.0015);%peaks and valleys of velocity
    
    %Acceleration
    acc = [NaN diff(smooth_vel)];
    acc_tops = dg_findFlattops(abs(acc),0.0015);%peaks and valleys of acceleration
    
    %% Parameters for Signal to Noise Ratio(SNR)
    
    [peak,peak_I] = max(vq);%highest point in the waveform (peak)
    peak_topsI = find(sample_tops==peak_I); %peak tops index
    if isempty(peak_topsI)
        peak_topsI = 0;
    end
    [acc_min,acc_minI] = min(acc); %tops index
    min_acc_topsI = find(acc_tops==acc_minI); %minimum acceleration index
    [vel_max,vel_maxI] = max(smooth_vel); %tops index
    vel_max_topsI = find(vel_tops==vel_max); %peak tops index
    [vel_min,vel_minI] = min(smooth_vel(peak_I:end)); vel_minI = vel_minI+peak_I;%tops index after peak
    
    %Spike Peak Width
    %Using waveform acceleration changes to find peak start and peak end
    if ~isempty(acc_tops) && ~isempty(min_acc_topsI) && ~isempty(peak_topsI) && length(acc_tops)>=(min_acc_topsI+1) && peak_topsI>1
        peak_startI = sample_tops(peak_topsI-1);
        % first acc top after peak is peak end
        acc_tops_after_peakI = acc_tops(acc_tops>peak_I);
        acc_top_after_peakI = [];
        for a = acc_tops_after_peakI'
            if acc(a) < 0
                continue
            else
                acc_top_after_peakI = a;
                break
            end
        end
%         peak_endI = acc_tops(min_acc_topsI+1);
        if ~isempty(acc_top_after_peakI)
            peak_endI = acc_top_after_peakI;
            peak_width(n) = xq(peak_endI)-xq(peak_startI);
        else
            peak_width(n) = NaN;
            peak_startI = NaN;
            peak_endI = NaN;
            snr_nan(n) = NaN;
        end
    else
        peak_width(n) = NaN;
        peak_startI = NaN;
        peak_endI = NaN;
        snr_nan(n) = NaN;
    end
    
    %After Spike Valley Width
    %Using waveform acceleration changes to find peak end and valley end
    if ~isnan(peak_endI)
        valley_endI = vel_tops(find(vel_tops>peak_endI,1));
        if ~isempty(valley_endI)
            valley_width(n) = xq(valley_endI)-xq(peak_endI);
        else
            valley_width(n) = NaN;
            snr_nan(n) = NaN;
        end
    else 
        valley_width(n) = NaN;
        snr_nan(n) = NaN;
    end
     
    %Half Peak Width
    %Using waveform velocity changes to find half peak start and half peak end
    %Maximum Velocity corresponds to half peak start
    %Minimum Velocity corresponds to halp peak end
    if acc_minI>vel_maxI && acc_minI<vel_minI && vel_maxI>peak_startI && peak_endI>vel_minI
        half_peak_width(n) = xq(vel_minI)-xq(vel_maxI);
    else
        half_peak_width(n) = NaN;
        snr_nan(n) = NaN;
    end
    
    %Peak Rise and Fall Slope
    if ~isnan(half_peak_width(n)) && ~isnan(peak_width(n))
        %Slope from peak start to half peak start
        peakRise_slope(n) = (vq(vel_maxI)-vq(peak_startI))/(xq(vel_maxI)-xq(peak_startI));
        %Slope from peak to half peak end
        peakFall_slope(n) = (vq(vel_minI)-vq(peak_I))/(xq(vel_minI)-xq(peak_I)); 
    else
        peakRise_slope(n) = NaN;
        peakFall_slope(n) = NaN;
        snr_nan(n) = NaN;
    end
    
    %Valley Rise Slope and Peak to Valley Width
    if ~isnan(valley_width(n))
        [~,min_valleyI] = min(vq(peak_I:end));
        min_valleyI = min_valleyI + peak_I-1;
        %Slope from minimum point of valley to valley end
        valleyRise_slope(n) = (vq(valley_endI)-vq(min_valleyI))/(xq(valley_endI)-xq(min_valleyI));
        %Length from Highest Peak to Lowest Valley Point
        peakToValley_length(n) = xq(min_valleyI)-xq(peak_I);
    else
        min_valleyI = NaN;
        valleyRise_slope(n) = NaN;
        peakToValley_length(n) = NaN;
        snr_nan(n) = NaN;
    end
    
    %Full Spike Width
    %Length from start of peak to end of valley
    if ~isnan(peak_width(n)) && ~isnan(valley_width(n)) && ~isempty(valley_endI)
        full_spike_width(n) = xq(valley_endI)-xq(peak_startI);
    else
        full_spike_width(n) = NaN;
        snr_nan(n) = NaN;
    end
    
    % Firing Rates and ISI
    tetrodefile=fullfile(sessionDir,strcat(tetrodeID,'.mat'));
    tetrodeMat=load(tetrodefile);
%     tetrodeinfo = fullfile(sessionDir,strcat(tetrodeID,'_info.mat'));
%     infoMat = load(tetrodeinfo);
%     mat=infoMat.means{1,neuronNum};

    list=tetrodeMat.output(:,1);
    tstamps=list(tetrodeMat.output(:,2)==neuronNum);
    FiringRate=1/mean(diff(tstamps));
    MedianISI=median(diff(tstamps));
    MeanMedianRatio=log(1/FiringRate/MedianISI);
    
    firing_rates(n) = FiringRate; %twdb(id).inRun_firing_rate; % twdb(id).firing_rate
    if ~isnan(peak_I) && ~isnan(min_valleyI)
        max_min_ratio(n) = log(vq(peak_I)/-vq(min_valleyI));
%         max_min_ratio(n) = log(-vq(min_valleyI));
    else
        max_min_ratio(n) = NaN;
        snr_nan(n) = NaN;
    end
%% Bad Neuron Detection
    %Detection of neurons that have parameters that are already determined
    %to be noise parameters
    
    %Small Peak Threshold
    % Any waveform under 60 is considered unusable
    if peak<60
        bad_ids = [bad_ids n];
    end
    
    %Dendritic Spike Detection
    %Detects dendritic spikes (valley before peak has very sharp slope)
    %using velocity changes before the peak
    if vel_max_topsI>1
        den_vel = abs(smooth_vel(vel_tops(vel_max_tops-1)));
        %if the velocity of the valley is to big then dendritic spike detected
%        if den_vel>%set parameter here
              %if dentridtic spike containing neuron is to be considered a bad neuron
%             bad_ids = [bad_ids n];
%        end
    end
    
    if 2*min(vq(1:peak_I)) < min(vq(peak_I+1:end)) && peakToValley_length(n)/150 < .15 ...
                && valley_width(n)/150 < .1 && half_peak_width(n)/150 < .125
        bad_ids = [bad_ids n];
    end
    %% Plotting 
    if plot_ == 1
        %Plots Interpolated Sample Waveform, Velocity and Acceleration with
        %significant points
        figure
        hold on

        plot(xq,vq,'b') %interpolated waveform
        plot(xq(sample_tops),vq(sample_tops),'bo','MarkerFaceColor','b')%peaks and valleys
        plot(xq(peak_I),peak,'co','MarkerFaceColor','c')%Max peak
        
        plot(xq,40*smooth_vel,'r')%velocity scaled by 40 to be visible
        plot(xq(vel_tops),40*smooth_vel(vel_tops),'ro','MarkerFaceColor','r')%peaks and valleys
        plot(xq(vel_maxI),40*vel_max,'mo','MarkerFaceColor','m')%Max peak
        plot(xq(vel_minI),40*vel_min,'mo','MarkerFaceColor','m')%Min peak
        
        plot(xq,400*acc,'g')%acceleration scaled by 400 to be visible 
        plot(xq(acc_tops),400*acc(acc_tops),'go','MarkerFaceColor','g')%peaks and valleys
        plot(xq(acc_minI),400*acc_min,'yo','MarkerFaceColor','y')%Min Peak

        hold off
        title([DB_string,' ',tetrodeID,' Neuron #',twdb(id).neuronN])
        legend('Samples','Sample Tops','Sample Peak','Velocity','Vel Tops',...
            'Max Vel','Min Vel','Acceleration','Acc Tops','Min Acc')

        close all %place debug point here to view plots for individual neurons
        
    elseif plot_ == 2
        %Plots Interpolated Sample Waveform, with SNR parameters
        figure
        hold on
        
        plot(xq,vq,'b') %interpolated waveform
          
        %peak_width
        plot([xq(peak_startI),xq(peak_endI)],[vq(peak_startI),vq(peak_endI)],'y','LineWidth',3)
        %valley_width
        plot([xq(peak_endI),xq(valley_endI)],[vq(peak_endI),vq(valley_endI)],'k','LineWidth',3)
        %peakRise_slope
        plot([xq(peak_startI),xq(vel_maxI)],[vq(peak_startI),vq(vel_maxI)],'r','LineWidth',3)
        %peakFall_slope
        plot([xq(peak_I),xq(vel_minI)],[vq(peak_I),vq(vel_minI)],'c','LineWidth',3)
        %valleyRise_slope
        plot([xq(min_valleyI),xq(valley_endI)],[vq(min_valleyI),vq(valley_endI)],'m','LineWidth',3)
        %peakToValley_length
        plot([xq(peak_I),xq(min_valleyI)],[vq(peak_I),vq(peak_I)],'g','LineWidth',3)
        plot([xq(min_valleyI),xq(min_valleyI)],[vq(peak_I),vq(min_valleyI)],'g--','LineWidth',3)
        
        hold off
        title([DB_string,' ',tetrodeID,' Neuron #',twdb(id).neuronN])
        legend({'Sample Waveform', ['Peak Width = ',num2str(peak_width(n))],...
            ['Valley Width = ',num2str(valley_width(n))],['Peak Rise Slope = ',num2str(peakRise_slope(n))],...
            ['Peak Fall Slope = ',num2str(peakFall_slope(n))],['Valley Rise Slope = ',num2str(valleyRise_slope(n))],...
            ['Peak to Valley Length = ',num2str(peakToValley_length(n))]},...
            'FontWeight','bold')
        close all %place debug point here to view plots for individual neurons
    end
end

%% Getting Rid of Noise
neuron_ids(bad_ids) = [];
peak_width(bad_ids) = [];
valley_width(bad_ids) = [];
half_peak_width(bad_ids) = [];
peakRise_slope(bad_ids) = [];
peakFall_slope(bad_ids) = [];
valleyRise_slope(bad_ids) = [];
peakToValley_length(bad_ids) = [];
full_spike_width(bad_ids) = [];
firing_rates(bad_ids) = [];
max_min_ratio(bad_ids) = [];
snr_nan(bad_ids) = [];
voltages = voltages(setdiff(1:size(voltages),bad_ids),:);

%% Return Parameters for SNR
%Combinations of these parameters are to be chosen for the SNR
%For now any waveform that is missing parameters is considered noise i.e.
%check_ids = find(~isnan(snr_nan))
snr_parameters = {peak_width, valley_width, half_peak_width, peakRise_slope,...
    peakFall_slope, valleyRise_slope, peakToValley_length, full_spike_width,...
    firing_rates, max_min_ratio, snr_nan};
    
%% Change Log
% 1. Peak end is now the first postive acc top after peak instead of
%       the first acc top after the minimum acc top
% 2. Half peak end is now the first minimum vecocity after peak
% 3. Added smoothing for neuron potential data.
% 4. Added firing rates and log(meanISI/medianISI)... but they're not
%       necessary.
% 5. Using control databases there were some errors. Some if statements
%       to skip neuron in case of error (not sure what's wrong).