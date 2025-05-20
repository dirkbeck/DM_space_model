The topics correspond to the latest version of the manuscript (updated after one round of review) as follows:
•	model_overview: Figs. 1,2 and Supplementary Fig. 2
•	model_tests: Fig. 3a-d and Supplementary Fig. 3a,o-x
•	disorder_hypotheses: Fig. 4 and Supplementary Fig. 4m-r
•	dynamic_model_and_neural_net: Fig. 5 and Supplementary Figs. 5, 6, 7a-i
•	importance_and_RPEs: Supplementary Fig. 7k,l.
•	day_to_day_space_sampling: Fig. 6 and Supplementary Fig. 8
•	circuit_trajectories: Fig. 7, Supplementary Fig. 9
•	neuron_pair_analysis: Fig. 3f, Supplementary Fig. 3k-p
•	Cross Correlation Pattern Counts: Fig. 3e, Supplementary Fig. 3b-n, Supplementary Fig. 3a-j.
For additional detail on directory<->figure mapping, please refer to the Methods section of the manuscript, where the analysis corresponding to each figure is explained and a link is provided to the github.
All .m files run in MATLAB R2021a. To run the code:
1)	Git clone the repository onto a local machine.
2)	Run the file of interest in MATLAB. Note that (except for the exceptions mentioned below) the codes either A) do not require functions in other files, or B) require functions in other files that are automatically added to the path when the file is run. 

Fig. 2
-	Fig. 2a,b: model_overview/cartoon_of_striosome_matrix_roles.m
-	Fig. 2c,d: model_overview/sSPN_versus_mSPN_effect_on_decision_space_and_action_values.m
-	Fig. 2e,f: model_overview/GPi_LHb_RMTg_DA_model.m
Supplementary Fig. 2
-	Supplementary Fig. 2a: model_overview/ctx_FSI_SPN_firing_rates.m
-	Supplementary Fig. 2b: model_overview/GPi_LH_RMTg_DA_operation_cartoons.m
-	Supplementary Fig. 2c,d: model_overview/GPi_model.m
-	Supplementary Fig. 2e,f: model_overview/LHb_model.m
-	Supplementary Fig. 2g-i: model_overview/GPi_LHb_RMTg_DA_model.m
-	Supplementary Fig. 2k,l: model_overview/mSPN_multinomial_regression_example
-	Supplementary Fig. 2m,n: model_overview/weiner_process_illustration.m
-	Supplementary Fig. 2o,p: model_overview/weiner_process_illustration.m
-	Supplementary Fig. 2q-r: model_overview/dimensionality_from_SPN_activity
Fig. 3
-	Fig. 3a,b. model_tests/friedman2015optogeneticmanipulation.m
-	Fig. 3d. model_tests/ctx_sSPN_mSPN_coordinated_activity.n
-	Fig. 3e. See Exception 2.
-	Fig. 3f. See Exception 1.
Supplementary Fig. 3
-	Supplementary Fig. 3a. model_tests/friedman2015optogeneticmanipulation.m
-	Supplementary Fig. 3b-d. See Exception 2.
-	Supplementary Fig. 3e,f. See Exception 1.
-	Supplementary Fig. 3g. See Exception 2.
-	Supplementary Fig. 3h-n. See Exception 2.
-	Supplementary Fig. 3o-x. model_tests/comparison_to_benchmarks.m
Fig. 4
-	Fig. 4a. disorder_hypotheses/Friedman2017summary.m
-	Fig. 4b,c. disorder_hypotheses/Friedman2017_lowD_space.m
-	Fig. 4d,e. disorder_hypotheses/altered_choice_after_space_transition.m
-	Fig. 4f. disorder_hypotheses/space_dimensionality_vs_FSI.m
-	Fig. 4h. disorder_hypotheses/Friedman2020_lowD_space.m
Supplementary Fig. 4
-	Supplementary Fig. 4a-j
-	Supplementary Fig. 4k,l. See Exception 1.
-	Supplementary Fig. 4m,n,q,r. disorder_hypotheses/ctx_to_FSI_synchrony_analysis.m
-	Supplementary Fig. 4o,p. See Exception 1.
Fig. 5
-	Fig. 5d-i. dynamic_model_and_neural_net/sSPN_DA_mSPN_dynamic_interaction.m
Supplementary Fig. 5
-	Supplementary Fig. 5b-e. dynamic_model_and_neural_net/neural_network_model.m
-	Supplementary Fig. 5g. dynamic_model_and_neural_net/dimension_discrimination_vs_sparsity.m
Fig. 6
-	Fig. 6a. sampling_space_based_on_activity/decision_space_sampling.py
-	Fig. 6b,c. sampling_space_based_on_activity/subjective_value_scores_by_space.m
-	Fig. 6e. sampling_space_based_on_activity/subjective_value_score_extremes.m
Supplementary Fig. 6
-	dynamic_model_and_neural_net/cortical_snr.m
Fig. 7
-	Fig. 7b-e. circuit_trajectories/advantage_cost_net_advantage_example.m
-	Fig. 7f,g. circuit_trajectories/advantage_cost_net_advantage_example.m
Supplementary Fig. 7
-	Supplementary Fig. 7c-f. dynamic_model_and_neural_net/direct_vs_indirect_pathway_SV.m
-	Supplementary Fig. 7i. dynamic_model_and_neural_net/direct_vs_indirect_pathway_proximity_theory.m
Supplementary Fig. 8
-	Supplementary Fig. 8d. sampling_space_based_on_activity/subjective_value_scores_by_space.m
-	Supplementary Fig. 8f. sampling_space_based_on_activity/subjective_value_score_extremes.m
Supplementary Fig. 9
-	Fig. 9a. circuit_trajectories/sSNC_DA_LH_trajectories_examples2.m
-	Fig. 9b,c. circuit_trajectories/changing_space_value_between_trials.m

Exception 1. See neuron_pair_analysis/run_me.m for instructions.
Exception 2. See Cross Correlation Pattern Counts/createPaperFigures.m for instructions.
