clear; close all
addpath(fileparts(pwd))

n_dimension = 4; % # of SPN dimensions in space

%% components added/removed
% for each of the GPi->LH,LH->RMTg,RMTg->DA connections,
% assume first that the upstream brain region has created a space with a
% certain number of dimensions. Then ask: given that knowlegde, what is the
% probability of the downstream brain region transitioning to the state to
% any of the possible # components in state

n_components_list = 0:n_dimension;

% arbitrary: what range do we assume the brain regions can take?
% this affects results because in the analysis we're, for example,
% starting from the # of components built by GPi and then inferring what 
% GPi activity was.
activity_bounds = [-5 5];

% each transition (GPi -> LHb, LHb -> RMTg, RMTg -> DA),
% calculate probability of transitions from the previous component to the
% next.

z = [2 2 -2]; % LHb, RMTg, DA

%% form transition matrices for each transition


for i=1:3 % connections between brain regions
    for j=1:5
        starting_n_components = n_components_list(j);
        for k=1:5
            ending_n_components = n_components_list(k);
            % P(ending & starting)
            and_fun = @(x) ...
                nchoosek(n_dimension,starting_n_components) .* ...
                1./(1 + exp(-x)).^starting_n_components .* ...
                (1-1./(1 + exp(-x))).^(n_dimension-starting_n_components) .* ...
                nchoosek(n_dimension,ending_n_components) .* ...
                1./(1 + exp(-x + z(i))).^ending_n_components .* ...
                (1-1./(1 + exp(-x + z(i)))).^(n_dimension-ending_n_components);
            and_part = integral(and_fun,activity_bounds(1)+z(i),...
                activity_bounds(2)+z(i));

            % P(starting)
            starting_fun = @(x) ...
                nchoosek(n_dimension,starting_n_components) .* ...
                1./(1 + exp(-x)).^starting_n_components .* ...
                (1-1./(1 + exp(-x))).^(n_dimension-starting_n_components);
            starting_part = integral(starting_fun,activity_bounds(1)+z(i),...
                activity_bounds(2)+z(i));

            % P(ending | starting) = P(starting & ending) | P(starting)
            prob_component_transitions{i}(j,k) = and_part / starting_part;
        end
    end
end

%% scale to the overall probabilities from start to end

prob_component_transitions_GPi_LH = prob_component_transitions{1};
prob_component_transitions_LH_RMTg = sum(prob_component_transitions_GPi_LH)' ...
    .* prob_component_transitions{2};
prob_component_transitions_RMTg_DA = sum(prob_component_transitions_LH_RMTg)' ...
    .* prob_component_transitions{3};

%% form the Sankey plot mappings

from_n_components_GPi_LH = cellstr(strcat(string(repelem(0:4,5)), " comp. GPi"));
to_n_components_GPi_LH = cellstr(strcat(string(repmat(0:4,1,5)), " comp. LH"));
from_n_components_LH_RMTg = cellstr(strcat(string(repelem(0:4,5)), " comp. LH"));
to_n_components_LH_RMTg = cellstr(strcat(string(repmat(0:4,1,5)), " comp. RMTg"));
from_n_components_RMTg_DA = cellstr(strcat(string(repelem(0:4,5)), " comp. RMTg"));
to_n_components_RMTg_DA = cellstr(strcat(string(repmat(0:4,1,5)), " comp. DA"));
from_n_components = [from_n_components_GPi_LH, from_n_components_LH_RMTg, ...
    from_n_components_RMTg_DA];
to_n_components = [to_n_components_GPi_LH, to_n_components_LH_RMTg, ...
    to_n_components_RMTg_DA];
prob_component_transitions_GPi_LH = prob_component_transitions_GPi_LH';
prob_component_transitions_LH_RMTg = prob_component_transitions_LH_RMTg';
prob_component_transitions_RMTg_DA = prob_component_transitions_RMTg_DA';
prob_component_transitions = num2cell([prob_component_transitions_GPi_LH(:); ...
    prob_component_transitions_LH_RMTg(:); prob_component_transitions_RMTg_DA(:)]);
SK = SSankey_edited(from_n_components, to_n_components, prob_component_transitions);

%% plotting

cols = colororder;
SK.ColorList=repmat(cols(1:5,:),4,1);
SK.ColorList=[cols(1,:);cols(1:5,:);cols(2:5,:);cols(1:5,:);cols(1:5,:)];
SK.draw();
set(gcf,'renderer','opengl');