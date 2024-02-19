%%%%%%%%%%%%%%%%%%%% Ubiquitous Preprocessing Variables %%%%%%%%%%%%%%%%%%%
%lfp_getEvtIDs_comon

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Event IDs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% TTL Signals %%%
lick_right_on = 2;
lick_left_on = 3;
lick_right_off = 112;
lick_left_off = 113;

push_button_on = 8;
push_button_off = 118;

starting_recording = 60;
stopping_recording = 61;

%%% Maze Configurations %%%
% For TR and Comb
mix_black_on_right = 11;
choc_black_on_right = 12;
mix_white_on_right = 45;
choc_white_on_right = 46;
maze_milk_configs = [mix_black_on_right choc_black_on_right mix_white_on_right choc_white_on_right];

conc_5 = 13;
conc_15 = 14;
conc_30 = 15;
conc_45 = 17;
conc_60 = 18;
conc_70 = 19;
conc_ids = [conc_5 conc_15 conc_30 conc_45 conc_60 conc_70];

% For Cost
light_intensity_06_ba = 20;
light_intensity_12_ba = 21;
light_intensity_36_ba = 22;
light_intensity_40_ba = 23;

light_intensity_06_fr = 47;
light_intensity_12_fr = 48;
light_intensity_36_fr = 49;
light_intensity_40_fr = 50;

light_ids = [light_intensity_06_ba light_intensity_12_ba light_intensity_36_ba light_intensity_40_ba...
    light_intensity_06_fr light_intensity_12_fr light_intensity_36_fr light_intensity_40_fr];

%%% Subsession Structure (Fragmentation Blocks) %%%
cal_sub_start = 24;

% T-Maze Subsessions
tr_sub_start = 27;
comb_sub_start = 29;
same_rew=51;
tr2_sub_start = 221;
comb2_sub_start = 222;
negacomb_sub_start = 223;
frl_sub_start=227;
frr_sub_start=228;
laser=97;
optic= 96;   

tmaze_ids = [tr_sub_start comb_sub_start tr2_sub_start comb2_sub_start negacomb_sub_start frl_sub_start  frr_sub_start same_rew ];

% Linear Maze Subsessions
lr_sub_start = 26;
lc_sub_start = 28;
lc2_sub_start = 224;
lr2_sub_start = 225;
ln_sub_start = 226;
lin_maze_ids = [lr_sub_start lc_sub_start lc2_sub_start lr2_sub_start ln_sub_start];

% Cost Subsessions
cost_sub_start = 75;
cost1_sub_start = 25;
cost2_sub_start = 70;
cost3_sub_start = 71;
cost4_sub_start = 72;
cost5_sub_start = 73;
cost6_sub_start = 74;
cost_ids=[cost_sub_start cost1_sub_start cost2_sub_start cost3_sub_start cost4_sub_start cost5_sub_start cost6_sub_start];
% Stimulation Subsessions
base_sub_start = 40;
vta_sub_start = 41;
pl_sub_start = 42;
dms_sub_start = 43;
dls_sub_start = 44;


stim=98;

sub_start_ids = [pl_sub_start vta_sub_start dms_sub_start dls_sub_start stim laser];

subsession_end = 100;

%%% Run Structure (Behavioral Trials) %%%
run_start = 31;
run_frl = 32;
run_frr = 33;

lin_run_start = 9002;


run_enter_light = 37;
run_exit_light = 38;
in_light=80;
in_dark=81;
StartCostTrial = 512;
EndCostTrial = 513;

% Bad Run Markers
run_end_junk = 35;
run_end_incomplete = 36;
run_steriotype = 52;
run_lick_bad = 53;

% Tracker-Based Linear Maze Run Events
xing_right_linear = 9000;
xing_left_linear = 9001;

run_end = 200;

%%% Pulse Structure (Stimulation ON/OFFs) %%%
pl_stim_on = 4;
vta_stim_on = 5;
dms_stim_on = 6;
dls_stim_on = 7;

pulse_end = 9;

%%% Important Non-Trial Structure Events %%%
start_drink_right = 1010;
start_drink_left = 2020;
end_drink_right = 3030;
end_drink_left = 4040;
start_drink_ids = [NaN start_drink_right start_drink_left];
end_drink_ids = [NaN end_drink_right end_drink_left];

% Tracker-Related Events
tracker_checkpt_1 = 555;
tracker_checkpt_2 = 556;
tracker_checkpt_3 = 557;
tracker_checkpt_4 = 558;
tracker_checkpt_5 = 559;
tracker_checkpt_6 = 560;
tracker_checkpt_ids = sort([tracker_checkpt_1 tracker_checkpt_2 tracker_checkpt_3 ...
    tracker_checkpt_4 tracker_checkpt_5 tracker_checkpt_6], 'descend');

midsection_stop = 564;
midsection_start = 565;
beggining_initiate_movement = 888;

%%% These are within the runs, but not related to trial structure.
track_right_decision = 54;
track_left_decision = 55;
track_mix_decision = 56;
track_choc_decision = 57;
mix_decision = 1001;
choc_decision = 2011 ;

