import numpy as np
from matplotlib import pyplot as plt


a = []
for i in range(3):
    a.append(np.random.random((2,5)))
print(a)
b = np.reshape(a, (-1,5))
print(b[:,[2,3]])
print(b)
print(f'the shape is: {np.shape(b)} and the length is {np.ndim(b)}')
print(f'the mean is : {np.mean(b, axis=0)}')
# print(np.concatenate(a,[[]],axis=0))