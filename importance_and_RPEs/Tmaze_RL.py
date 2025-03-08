
import numpy as np
import random
import matplotlib.pyplot as plt
import matplotlib as mpl



show_plots = True
random.seed(0)

option_values = [1, -1]
num_episodes = 20
flip_at = 10
explore_rate = .5
learning_rate = .5

rpes = [[], []]
values = [0, 0]  # options 1, 2
choices = []
for episode in range(num_episodes):
    if episode < flip_at:
        rewards = option_values
    else:
        rewards = option_values[::-1]  # flip so that reward 1 is at option 2 and vice versa
    if random.uniform(0, 1) < explore_rate:
        choice = random.randint(0, 1)
    else:
        choice = np.argmax(values)
    choices.append(choice)
    other_choice = 1 if choice == 0 else 0
    rpes[choice].append(rewards[choice] - values[choice])
    rpes[other_choice].append(np.nan)
    # updates through Bellman equation
    values[choice] += learning_rate * (rewards[choice] - values[choice])

fig, axes = plt.subplots(2, 1, figsize=(10, 15))

axes[0].plot(rpes[0], label='RPEs Option 1', marker='o', linestyle='-')
axes[0].plot(rpes[1], label='RPEs Option 2', marker='o', linestyle='-')
axes[0].axvline(x=flip_at, label="Rewards swapped", color='gray', linestyle='--')

# Find the first occurence of each option before and after the dashed line
first_option1_before = next((i for i, x in enumerate(choices[:flip_at]) if x == 0), None)
first_option2_before = next((i for i, x in enumerate(choices[:flip_at]) if x == 1), None)
first_option1_after = next((i for i, x in enumerate(choices[flip_at:]) if x == 0), None)
if first_option1_after is not None:
    first_option1_after += flip_at
first_option2_after = next((i for i, x in enumerate(choices[flip_at:]) if x == 1), None)
if first_option2_after is not None:
    first_option2_after += flip_at

if first_option1_before is not None:
    axes[0].axvspan(first_option1_before -0.4, first_option1_before + 0.4, color='blue', alpha=0.3, label='transition to reward-predominant decision-dimension')
if first_option2_before is not None:
    axes[0].axvspan(first_option2_before -0.4, first_option2_before + 0.4, color='orange', alpha=0.3, label='transition to cost-predominant decision-dimension')
if first_option1_after is not None:
    axes[0].axvspan(first_option1_after - 0.4, first_option1_after + 0.4, color='red', alpha=0.3, label='transition from reward-predominant to cost-predominant decision-dimension')
if first_option2_after is not None:
    axes[0].axvspan(first_option2_after - 0.4, first_option2_after + 0.4, color='purple', alpha=0.3, label='transition from cost-predominant to reward-predominant decision-dimension')


axes[0].set_ylabel('RPEs')
axes[0].legend()
axes[0].set_xlabel("Episode")
axes[0].set_title('RPEs Over Episodes')

axes[1].plot(choices, label='Choice', marker='o', linestyle='-')
axes[1].axvline(x=flip_at, label="Rewards swapped", color='gray', linestyle='--')
axes[1].set_ylabel('Choice')
axes[1].legend()
axes[1].set_xlabel("Episode")
axes[1].set_title('Choice Over Episodes')
mpl.rcParams['pdf.fonttype'] = 42
plt.savefig('Tmaze.pdf')


plt.tight_layout()
if show_plots:
    plt.show()
