#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue May 28 16:26:37 2019

Ejemplo de uso de la lstm con un ejemplo más sencillo para aclararnos

@author: rodrigo
"""

import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
import torch.backends.cudnn as cudnn

import numpy as np
from utils import DotDict, Logger, rmse
from lstm import LSTM

"""
DATOS
"""

"Sin secuencilizar"
#data = np.array([
#    [0.0,0.1],
#    [0.1,0.2],
#    [0.2,0.3],
#    [0.3,0.4],
#    [0.4,0.5],
#    [0.5,0.6],
#    [0.6,0.7],
#    [0.7,0.8],
#    [0.8, 0.9],
#    [0.9, 1.0]
#])
#
## Tamaño del batch
#batch_size = 10
#
## Cuidado con el tamaño del batch
#X = torch.tensor(data[:,0], dtype=torch.float32).view(int(len(data[:,0])/batch_size), batch_size, -1)
#Y = torch.tensor(data[:,1], dtype=torch.float32).view(int(len(data[:,0])/batch_size), batch_size, -1)


"Creyendo que secuencializaba"
#data = np.array([
#    [0.0,0.1,0.2, 0.3],
#    [0.1,0.2,0.3, 0.4],
#    [0.2,0.3,0.4, 0.5],
#    [0.3,0.4,0.5, 0.6],
#    [0.4,0.5,0.6, 0.7],
#    [0.5,0.6,0.7, 0.8],
#    [0.6,0.7,0.8, 0.9],
#    [0.7,0.8,0.9, 1.0],
#    [0.8,0.9,1.0, 1.1],
#    [0.9,1.0,1.1, 1.2]
#])
#
#
##data = np.array([
##    [0.0,0.1,0.2, 0.3,0.4],
##    [0.1,0.2,0.3, 0.4,0.5],
##    [0.2,0.3,0.4, 0.5,0.6],
##    [0.3,0.4,0.5, 0.6,0.7],
##    [0.4,0.5,0.6, 0.7,0.8],
##    [0.5,0.6,0.7, 0.8,0.9],
##    [0.6,0.7,0.8, 0.9,1.0],
##    [0.7,0.8,0.9, 1.0,1.1],
##    [0.8,0.9,1.0, 1.1,1.2],
##    [0.9,1.0,1.1, 1.2,1.3]
##])
#
## Tamaño del batch
#batch_size = 1
#
## Cuidado con el tamaño del batch
#X = torch.tensor(data[:,:3], dtype=torch.float32).view(int(len(data[:,0])/batch_size), batch_size, -1)
#Y = torch.tensor(data[:,3:], dtype=torch.float32).view(int(len(data[:,0])/batch_size), batch_size, -1)


"Secuencializando"
X = torch.tensor([
    [0.0,0.1,0.2],
    [0.1,0.2,0.3],
    [0.2,0.3,0.4],
    [0.3,0.4,0.5],
    [0.4,0.5,0.6],
    [0.5,0.6,0.7],
    [0.6,0.7,0.8],
    [0.7,0.8,0.9],
    [0.8,0.9,1.0],
    [0.9,1.0,1.1]
]).view(10,3,-1)

Y = torch.tensor([
    [0.3],
    [0.4],
    [0.5],
    [0.6],
    [0.7],
    [0.8],
    [0.9],
    [1.0],
    [1.1],
    [1.2]
]).view(-1,1)

"""
MODELO
"""
# Número de variables
input_dim = 1
# Tamaño del espacio oculto
hidden_dim = 5
# Tamaño del batch
#batch_size = 3
# Tamaño de la secuencia de salida
output_dim = 1
# Número de capas LSTM
num_layers = 5

model = LSTM(input_dim, hidden_dim, output_dim, num_layers)


"""
OPTIMIZADOR
"""
learning_rate = 3e-3
loss_fn = torch.nn.MSELoss(size_average=False)
optimizer = torch.optim.Adam(model.parameters(), lr=learning_rate)

"""
ENTRENAMIENTO
"""
num_epochs = 500
hist = np.zeros(num_epochs)

for t in range(num_epochs):  
    model.train()
    for x,y in zip(X,Y):
        optimizer.zero_grad()
        x = x.view(3,1,1)
        y_pred = model(x)
        loss = loss_fn(y_pred, y)
        loss.backward()
    
        optimizer.step()
    
    if t % 50 == 0:
        print("Epoch ", t, "MSE: ", loss.item())
        
    hist[t] = loss.item()