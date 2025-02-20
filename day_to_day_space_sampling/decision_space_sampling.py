import numpy as np
import matplotlib.pyplot as plt
from scipy.special import comb
import matplotlib as mpl



# Define parameters
n_inc = 20
n_dim = 4
max_val = 5

sSPN = np.linspace(0, max_val, n_inc)
daSNC = np.linspace(0, max_val, n_inc)
LHb = np.linspace(0, max_val, n_inc)

prob_space = np.zeros((n_inc, n_inc, n_inc, 5))

for i in range(n_inc):
    for j in range(n_inc):
        for k in range(n_inc):
            p = 1 / (1 + np.exp(sSPN[i] - daSNC[j] + LHb[k]))
            for l in range(1 + n_dim):
                d = l - 1
                prob_space[i, j, k, l] = comb(n_dim, d) * (p ** d) * ((1 - p) ** (n_dim - d))

fig = plt.figure(figsize=(15, 10))
sm = plt.cm.ScalarMappable(cmap=plt.cm.viridis, norm=plt.Normalize(vmin=np.min(prob_space), vmax=np.max(prob_space)))
sm.set_array([])

for l in range(5):
    ax = fig.add_subplot(2, 3, l + 1, projection='3d')

    # Find maximum and minimum probability values and their indices
    max_prob = np.max(prob_space[:, :, :, l])
    min_prob = np.min(prob_space[:, :, :, l])
    max_indices = np.where(prob_space[:, :, :, l] == max_prob)
    min_indices = np.where(prob_space[:, :, :, l] == min_prob)

    # Extract coordinates for max/min points
    max_x = LHb[max_indices[0][0]]
    max_y = sSPN[max_indices[1][0]]
    max_z = daSNC[max_indices[2][0]]

    min_x = LHb[min_indices[0][0]]
    min_y = sSPN[min_indices[1][0]]
    min_z = daSNC[min_indices[2][0]]

    # XY
    slice_idxs = [0,-1]
    X, Y = np.meshgrid(LHb, sSPN)
    for slice_idx in slice_idxs:
        Z = np.full(X.shape, daSNC[slice_idx])
        ax.plot_surface(X, Y, Z, facecolors=plt.cm.viridis(prob_space[:, :, slice_idx, l]), edgecolor='none', shade=False, alpha=.5)

    # XZ
    slice_idxs = [0,-1]
    X, Z = np.meshgrid(LHb, daSNC)
    for slice_idx in slice_idxs:
        Y = np.full(X.shape, sSPN[slice_idx])
        ax.plot_surface(X, Y, Z, facecolors=plt.cm.viridis(prob_space[:, :, slice_idx, l]), edgecolor='none', shade=False, alpha=.5)

    # YZ
    slice_idxs = [0,-1]
    Y, Z = np.meshgrid(sSPN, daSNC)
    for slice_idx in slice_idxs:
        X = np.full(Y.shape, LHb[slice_idx])
        ax.plot_surface(X, Y, Z, facecolors=plt.cm.viridis(prob_space[:, :, slice_idx, l]), edgecolor='none', shade=False, alpha=.5)

    ax.scatter(max_x, max_y, max_z, color='red', marker='o', s=100, label='Maximum')
    ax.scatter(min_x, min_y, min_z, color='blue', marker='o', s=100, label='Minimum')

    ax.set_xlabel('LHb activity (arb. u.)')
    ax.set_ylabel('sSPN activity (arb. u.)')
    ax.set_zlabel('daSNC activity (arb. u.)')
    ax.set_title(f'Decision Space Dimension: {l}')

handles, labels = ax.get_legend_handles_labels()
fig.legend(handles, labels, loc='lower center', ncol=2) # Adjust 'loc' and 'ncol' as needed
fig.colorbar(sm, ax=fig.get_axes(), shrink=0.5, aspect=10, label='Probability')


mpl.rcParams['pdf.fonttype'] = 42
plt.savefig('decision_space_sampling.pdf')
