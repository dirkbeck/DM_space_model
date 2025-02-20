import matplotlib.pyplot as plt
import numpy as np
import matplotlib as mpl


fig = plt.figure(figsize=(12, 6))

# Low importance
ax1 = fig.add_subplot(121, projection='3d')
x = np.arange(-5, 5, 0.25)
y = np.arange(-5, 5, 0.25)
x, y = np.meshgrid(x, y)
r = np.sqrt(x**2 + y**2)
z1 = x+y
z2 = 2*x+y
z3 = x+2*y
z4 = 2*x+2*y

# Define colors for each surface
colors = ['red', 'green', 'blue', 'purple']

surf1 = ax1.plot_surface(x, y, z1, color=colors[0], alpha=0.5)
surf2 = ax1.plot_surface(x, y, z2, color=colors[1], alpha=0.5)
surf3 = ax1.plot_surface(x, y, z3, color=colors[2], alpha=0.5)
surf4 = ax1.plot_surface(x, y, z4, color=colors[3], alpha=0.5)

ax1.set_title('Low Importance')
ax1.set_xticks([])
ax1.set_yticks([])
ax1.set_zticks([])
ax1.set_xlabel('X-Location')
ax1.set_ylabel('Y-location')
ax1.set_zlabel('Q-value')


# High importance
ax2 = fig.add_subplot(122, projection='3d')
x = np.arange(-5, 5, 0.1)
y = np.arange(-5, 5, 0.1)
x, y = np.meshgrid(x, y)

# Create z1, z2, z3, z4 for high importance case
z1 = x + y + 2 * np.sin(x * np.pi / 2) * np.cos(y * np.pi / 2) + 2 * np.random.rand(*x.shape)
z2 = x - y + 2 * np.sin(x * np.pi / 2) * np.cos(y * np.pi / 2) + 2 * np.random.rand(*x.shape)
z3 = -x + y + 2 * np.sin(x * np.pi / 2) * np.cos(y * np.pi / 2) + 2 * np.random.rand(*x.shape)
z4 = -x - y + 2 * np.sin(x * np.pi / 2) * np.cos(y * np.pi / 2) + 2 * np.random.rand(*x.shape)

surf5 = ax2.plot_surface(x, y, z1, color=colors[0], alpha=0.5)
surf6 = ax2.plot_surface(x, y, z2, color=colors[1], alpha=0.5)
surf7 = ax2.plot_surface(x, y, z3, color=colors[2], alpha=0.5)
surf8 = ax2.plot_surface(x, y, z4, color=colors[3], alpha=0.5)

ax2.set_title('High Importance')
ax2.set_xticks([])
ax2.set_yticks([])
ax2.set_zticks([])
ax2.set_xlabel('X-Location')
ax2.set_ylabel('Y-location')
ax2.set_zlabel('Q-value')

# Create a single legend for all subplots
handles, labels = ax1.get_legend_handles_labels()
fig.legend(handles, ['action 1', 'action 2', 'action 3', 'action 4'])

plt.savefig('importance_cartoon.pdf')
mpl.rcParams['pdf.fonttype'] = 42
plt.show()
