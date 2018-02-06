import numpy as np
from matplotlib import pyplot as plt

fig, axs = plt.subplots(nrows=3, ncols=1)
axs = axs.ravel()
t= 0
cmap = plt.get_cmap('jet',64)
print(np.ndim(cmap))
for i in range(3):
    print(i)
    axs[t].plot(np.random.random(100), color=cmap(i*80))
    axs[t].set_title('o')
    t +=1
plt.show()