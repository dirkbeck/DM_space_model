import copy
import numpy as np
import random
import matplotlib.pyplot as plt
import matplotlib as mpl

random.seed(0)
show_plots = True

# Environment setup
grid_size = 10
environment = np.zeros((grid_size, grid_size))

# Multiple reward locations and sizes
reward_locations = [(8, 8)]
reward_sizes = [1]

for location, reward in zip(reward_locations, reward_sizes):
    environment[location] = reward

movement_cost = -0.04

# Q-learning parameters
learning_rate = 0.8
discount_factor = 0.95
initial_exploration_rate = .2
exploration_decay_rate = 0.95
num_episodes = 1000

# Actions
actions = [(0, 1), (0, -1), (1, 0), (-1, 0)]


def is_valid(state):
    x, y = state
    return 0 <= x < grid_size and 0 <= y < grid_size


def get_next_state(current_state, action):
    x, y = current_state
    dx, dy = actions[action]
    new_x, new_y = x + dx, y + dy
    return (new_x, new_y) if is_valid((new_x, new_y)) else current_state


def calculate_importance(q_table, current_state, window_size=1, n_dims=2, grid_size=10):
    if n_dims == 0:
        window_q_values = [0]
    elif n_dims == 1:
        x, y = current_state
        window_q_values = q_table[max(0, x - window_size):min(grid_size, x + window_size + 1), y, :]
    elif n_dims == 2:
        x, y = current_state
        window_q_values = q_table[max(0, x - window_size):min(grid_size, x + window_size + 1),
                          max(0, y - window_size):min(grid_size, y + window_size + 1), :]
    else:
        raise ValueError("n_dims must be 0, 1 or 2")

    return np.std(window_q_values)


# Initialize Q-table -- equal chance of reward being anywhere on the grid by the starting point
q_table = 1 / (10 ** 2 - 1) * np.ones((grid_size, grid_size, 4))

rewards_per_episode = []
rpes_per_episode = []
importances_per_episode = []
q_tables_per_episode = []
trajectories = []

for episode in range(num_episodes):
    exploration_rate = initial_exploration_rate * (exploration_decay_rate ** episode)
    current_state = (0, 0)
    total_reward = 0
    steps = 0
    rpes = []
    importances = []
    trajectory = []

    while current_state not in reward_locations and steps < 100:
        action = random.randint(0, 3) if random.uniform(0, 1) < exploration_rate else np.argmax(q_table[current_state])
        next_state = get_next_state(current_state, action)

        reward = environment[next_state] + movement_cost  # Get reward from environment
        total_reward += reward

        old_q_value = q_table[current_state][action]
        q_table[current_state][action] = (1 - learning_rate) * q_table[current_state][action] + \
                                         learning_rate * (reward + discount_factor * np.max(q_table[next_state]))
        rpes.append(q_table[current_state][action] - old_q_value)
        importances.append(calculate_importance(q_table, current_state))
        trajectory.append(current_state)

        current_state = next_state
        steps += 1

    rewards_per_episode.append(total_reward)
    rpes_per_episode.append(rpes)
    importances_per_episode.append(importances)
    q_tables_per_episode.append(copy.deepcopy(q_table))
    trajectories.append(copy.deepcopy(trajectory))

# Plot total rewards
plt.figure(figsize=(8, 6))
for i, trajectory in enumerate(trajectories):
    trajectory.append((8, 8))
    x_coords = [state[0] for state in trajectory]
    y_coords = [state[1] for state in trajectory]
    plt.plot(x_coords, y_coords, label=f'Episode {i + 1}', color='k', alpha=i / num_episodes)

plt.plot(8, 8, 'go', markersize=8, label='Reward')
plt.plot(0, 0, 'ko', markersize=8, label='Origin')

sm = plt.cm.ScalarMappable(cmap='Greys', norm=plt.Normalize(vmin=0, vmax=num_episodes))
cbar = plt.colorbar(sm)
cbar.set_ticks(np.linspace(0, num_episodes, 6))
cbar.set_ticklabels(np.round(np.linspace(0, 2, 6), 1))
cbar.set_label('Episode #')
plt.xlabel('X Coordinate')
plt.ylabel('Y Coordinate')
plt.title('Agent Trajectories')
mpl.rcParams['pdf.fonttype'] = 42
plt.savefig('Plot1.pdf')
if show_plots:
    plt.show()

# Plot rpes versus importances
plt.figure(figsize=(8, 6))
all_rpes = [rpe for episode_rpes in rpes_per_episode for rpe in episode_rpes]
all_importances = [imp for episode_imps in importances_per_episode for imp in episode_imps]
plt.scatter(all_rpes, all_importances, s=10, alpha=0.3, color='black')
plt.xlabel("RPEs over all episodes")
plt.ylabel("Importances over all episodes")
mpl.rcParams['pdf.fonttype'] = 42
plt.savefig('Plot2.pdf')
if show_plots:
    plt.show()

eps_to_plot = [0, 9, num_episodes - 1]

# examples of RPEs and importances plot
fig, axes = plt.subplots(len(eps_to_plot), 3, figsize=(5, 5))

min_rpe = 0
max_rpe = 0
min_imp = 0
max_imp = 0
max_qval = 0

for i, ep in enumerate(eps_to_plot):
    # Plot RPEs
    colors = ['green' if val >= 0 else 'red' for val in rpes_per_episode[ep]]
    axes[i, 0].bar(range(len(rpes_per_episode[ep][-10:])), rpes_per_episode[ep][-10:], color=colors[-10:])
    axes[i, 0].set_xlabel('Time Step')
    axes[i, 0].set_ylabel("RPEs")
    axes[i, 0].set_title(f'RPEs During Episode {ep}')

    # Plot Importances
    colors = ['green' if val >= 0 else 'red' for val in importances_per_episode[ep]]
    axes[i, 1].bar(range(len(importances_per_episode[ep][-10:])), importances_per_episode[ep][-10:], color=colors[-10:])
    axes[i, 1].set_xlabel('Time Step')
    axes[i, 1].set_ylabel("Importances")
    axes[i, 1].set_title(f'Importances During Episode {ep}')

    min_rpe = min(min_rpe, np.min(rpes_per_episode[ep]))
    max_rpe = max(max_rpe, np.max(rpes_per_episode[ep]))
    min_imp = min(min_rpe, np.min(importances_per_episode[ep]))
    max_imp = max(max_imp, np.max(importances_per_episode[ep]))
    max_qval = max(max_qval, np.max(q_tables_per_episode[ep]))

    x = np.arange(grid_size)
    y = np.arange(grid_size)
    X, Y = np.meshgrid(x, y)
    Z = np.max(q_tables_per_episode[ep], axis=2)

    im = axes[i, 2].imshow(Z, cmap='viridis', origin='lower', extent=[0, grid_size, 0, grid_size],vmin=0,vmax=1)

    fig.colorbar(im, ax=axes[i, 2])

    axes[i, 2].set_xlabel('X')
    axes[i, 2].set_ylabel('Y')
    axes[i, 2].set_title(f'Q-table at Episode {ep}')

for i, _ in enumerate(eps_to_plot):
    axes[i, 0].set_ylim([min_rpe, max_rpe])
    axes[i, 1].set_ylim([min_imp, max_imp])
    im = axes[i, 2].get_images()[0]
    im.set_clim(0, max_qval)

plt.tight_layout()
mpl.rcParams['pdf.fonttype'] = 42
plt.savefig('Plot3.pdf')
if show_plots:
    plt.show()


def calculate_true_q_values(reward_locations, reward_sizes, grid_size, movement_cost, n_sim):
    q_table = np.zeros((grid_size, grid_size, 4)) # for each square in the grid, and actions up, down, right, left

    for i in range(grid_size):
        for j in range(grid_size):
            total_reward = 0
            for _ in range(n_sim):
                current_i, current_j = i, j
                trajectory_reward = 0
                steps = 0
                while True:
                    # Random action
                    action = np.random.randint(0, 4)  # 0: up, 1: down, 2: right, 3: left

                    next_i, next_j = current_i, current_j
                    if action == 0:
                        next_i = max(0, current_i - 1)
                    elif action == 1:
                        next_i = min(grid_size - 1, current_i + 1)
                    elif action == 2:
                        next_j = min(grid_size - 1, current_j + 1)
                    elif action == 3:
                        next_j = max(0, current_j - 1)

                    trajectory_reward -= movement_cost

                    # Check for reward
                    for k in range(len(reward_locations)):
                        if next_i == reward_locations[k][0] and next_j == reward_locations[k][1]:
                            trajectory_reward += reward_sizes[k]
                            break

                    current_i, current_j = next_i, next_j
                    steps +=1

                    if steps > 1000: # prevent infinite loops
                        break

                    if trajectory_reward != -movement_cost * steps:
                        break # reward found or we hit a wall

                total_reward += trajectory_reward

            q_table[i, j, :] = total_reward / n_sim # average reward for all actions in that state
    return q_table


def plot_qtable(q_table, plotname, show_plots, state, title, reward_locations):
    fig = plt.figure()
    Z = np.max(q_table, axis=2)
    im = plt.imshow(Z, cmap='viridis', origin='lower',vmin=0,vmax=1)
    y, x = state
    plt.plot(x, y, marker='s', markersize=15, color='black')

    for reward_loc in reward_locations:
        plt.plot(reward_loc[1], reward_loc[0], marker='o', markersize=15, color='black')

    fig.colorbar(im)
    plt.xlabel('X Coordinate')
    plt.ylabel('Y Coordinate')
    plt.title(title)
    mpl.rcParams['pdf.fonttype'] = 42
    plt.savefig(plotname)
    if show_plots:
        plt.show()


state = (4, 4)
reward_locations = [(5,5),(4,5)]
second_reward_sizes_incs = np.linspace(-1, 1, 10)
all_reward_sizes = [[1, second_reward_size] for second_reward_size in second_reward_sizes_incs]
importances = []
for i, reward_sizes in enumerate(all_reward_sizes):
    q_table = calculate_true_q_values(reward_locations, reward_sizes, grid_size, movement_cost, 1000)
    if i == 1 or i == 9:
        plot_qtable(q_table, f'Q-table, Reward Sizes {reward_sizes}.pdf', show_plots, state,
                    f'Q-table, Reward Sizes {reward_sizes}',reward_locations)
    importances.append(calculate_importance(q_table, state))

plt.figure(figsize=(8, 6))
plt.plot(second_reward_sizes_incs, importances, '-o')
plt.xlabel('size of both offers')
plt.ylabel('importance of state (4,4)')
mpl.rcParams['pdf.fonttype'] = 42
plt.savefig('Plot4.pdf')
if show_plots:
    plt.show()

all_possible_reward_locations = [(random.randint(0,9),random.randint(0,9)) for _ in range(10)]
all_possible_reward_sizes = [random.random()*2-1 for _ in range(10)]
all_reward_locations = [all_possible_reward_locations[:i] for i in range(len(all_possible_reward_locations))]
all_reward_sizes = [all_possible_reward_sizes[:i] for i in range(len(all_possible_reward_sizes))]

importances = []
for i, (reward_locations, reward_sizes) in enumerate(zip(all_reward_locations, all_reward_sizes)):
    q_table = calculate_true_q_values(reward_locations, reward_sizes, grid_size, movement_cost, 1000)
    # plot_qtable(q_table, grid_size, f'Q-table, Reward Locations {reward_locations}.pdf', show_plots, state,
    #             f'Q-table, Reward Locations {reward_locations}',reward_locations)
    importances.append(calculate_importance(q_table, state))

plt.figure(figsize=(8, 6))
plt.plot(range(len(all_reward_locations)), importances, '-o')
plt.xlabel('number of offers')
plt.ylabel('av. state importance')
mpl.rcParams['pdf.fonttype'] = 42
plt.savefig('Plot5.pdf')
if show_plots:
    plt.show()

reward_locations = [(5, 5)]
reward_sizes = [1]
q_table = calculate_true_q_values(reward_locations, reward_sizes, grid_size, movement_cost, 1000)
importances = [calculate_importance(q_table, state, n_dims=0),
               calculate_importance(q_table, state, n_dims=1),
               calculate_importance(q_table, state, n_dims=2)]

plt.figure(figsize=(8, 6))
plt.plot(range(3), importances, '-o')
plt.xlabel('environmental dimensions')
plt.ylabel('importance of state (4,4)')
mpl.rcParams['pdf.fonttype'] = 42
plt.savefig('Plot6.pdf')
if show_plots:
    plt.show()

state = (4, 4)
importances = []
for q_table in q_tables_per_episode:
    importances.append(calculate_importance(q_table, state))

plt.figure(figsize=(8, 6))
plt.plot(range(100), importances[:100], '-o')
plt.xlabel('episode #')
plt.ylabel('importance of state (4,4)')
mpl.rcParams['pdf.fonttype'] = 42
plt.savefig('Plot7.pdf')
if show_plots:
    plt.show()
