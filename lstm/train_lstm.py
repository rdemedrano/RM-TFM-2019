import os
import random
import json
from collections import defaultdict, OrderedDict

import configargparse
from tqdm import trange

import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
import torch.backends.cudnn as cudnn


from datasets import dataset_factory
from utils import DotDict, Logger, rmse
from lstm import LSTM


#######################################################################################################################
# Options - CUDA - Random seed
#######################################################################################################################
p = configargparse.ArgParser()
# -- data
p.add('--datadir', type=str, help='path to dataset', default='data')
p.add('--dataset', type=str, help='dataset name', default='crash')
# -- xp
p.add('--outputdir', type=str, help='path to save xp', default='output')
p.add('--xp', type=str, help='xp name', default='lstm')
# -- model
p.add('--hidden_size', type=int, help='number of features in the hidden size', default=1)
p.add('--num_layers', type=int, help='number of recurrent layers', default=1)
p.add('--bias', type=bool, help='wether the model uses bias weights or not', default=True)
p.add('--batch_first', type=bool, help='wether i and o tensors are provided as (batch, seq, feature)', default=False)
p.add('--dropout', type=float, help='lstm dropout', default=.0)
p.add('--bidirectional', type=bool, help='wether the model is bidirectional or not', default=False)
# -- optim
p.add('--lr', type=float, help='learning rate', default=3e-3)
p.add('--beta1', type=float, default=.0, help='adam beta1')
p.add('--beta2', type=float, default=.999, help='adam beta2')
p.add('--eps', type=float, default=1e-9, help='adam eps')
p.add('--wd', type=float, help='weight decay', default=1e-6)
p.add('--l2_z', type=float, help='l2 between consecutives latent factors', default=0.)
# -- learning
#p.add('--batch_size', type=int, default=1000, help='batch size')
p.add('--patience', type=int, default=150, help='number of epoch to wait before trigerring lr decay')
p.add('--nepoch', type=int, default=500, help='number of epochs to train for')
# -- gpu
p.add('--device', type=int, default=-1, help='-1: cpu; > -1: cuda device id')
# -- seed
p.add('--manualSeed', type=int, help='manual seed')

# parse
opt = DotDict(vars(p.parse_args()))
opt.mode = opt.mode if opt.mode in ('refine', 'discover') else None

# cudnn
if opt.device > -1:
    os.environ["CUDA_VISIBLE_DEVICES"] = str(opt.device)
    device = torch.device('cuda:0')
else:
    device = torch.device('cpu')
# seed
if opt.manualSeed is None:
    opt.manualSeed = random.randint(1, 10000)
random.seed(opt.manualSeed)
torch.manual_seed(opt.manualSeed)
if opt.device > -1:
    torch.cuda.manual_seed_all(opt.manualSeed)


#######################################################################################################################
# Data
#######################################################################################################################
# -- load data
# Se cargan los datos y se vuelcan en tensores. Todavía no tengo muy claro para que sirve el asunto del to(device)
# pero me parece que es un asunto meramente técnico. Yo al menos no veo diferencias.   
setup, (train_data, test_data) = dataset_factory(opt.datadir, opt.dataset)
train_data = train_data.to(device)
test_data = test_data.to(device)
for k, v in setup.items():
    opt[k] = v

# -- train inputs
# Esto devuelve tensores con los índices temporales y espaciales. Es decir, en el tiempo tantos 0s como espacios haya
# en la primera fila, luego tantos 1s y así. Mientras que en x_idx devuelve tantas filas como tiempos haya, y todas
# las filas son una secuencia de 0 a nx.    
t_idx = torch.arange(opt.nt_train, out=torch.LongTensor()).unsqueeze(1).expand(opt.nt_train, opt.nx).contiguous()
x_idx = torch.arange(opt.nx, out=torch.LongTensor()).expand_as(t_idx).contiguous()
# dynamic
# Esto devuelve un tensor de [2, (nt-1)*nx], que es como repetir las zonas espaciales para cada tiempo.
idx_dyn = torch.stack((t_idx[1:], x_idx[1:])).view(2, -1).to(device)
nex_dyn = idx_dyn.size(1)
# decoder
# Igual que el anterior pero de [2, nt*nx]
idx_dec = torch.stack((t_idx, x_idx)).view(2, -1).to(device)
nex_dec = idx_dec.size(1)

#######################################################################################################################
# Model
#######################################################################################################################
model = LSTM(opt.nx, opt.hidden_size, opt.nbatch, opt.nx, opt.num_layers).to(device)


#######################################################################################################################
# Optimizer
#######################################################################################################################

optimizer = optim.Adam(model.parameters(), lr=opt.lr, betas=(opt.beta1, opt.beta2), eps=opt.eps, weight_decay=opt.wd)
if opt.patience > 0:
    lr_scheduler = optim.lr_scheduler.ReduceLROnPlateau(optimizer, patience=opt.patience)


#######################################################################################################################
# Logs
#######################################################################################################################
#logger = Logger(opt.outputdir, opt.xp, 100)
#with open(os.path.join(opt.outputdir, opt.xp, 'config.json'), 'w') as f:
#    json.dump(opt, f, sort_keys=True, indent=4)


#######################################################################################################################
# Training
#######################################################################################################################
lr = opt.lr
pb = trange(opt.nepoch)
loss_fn = torch.nn.MSELoss(size_average=False)
model.train()
for e in pb:
    # Clear stored gradient
    model.zero_grad()
    
    # Forward pass
    out, hidden = model(train_data)

    loss = loss_fn(out, train_data)
    if e % 100 == 0:
        print("Epoch ", e, "MSE: ", loss.item())

    # Zero out gradient, else they will accumulate between epochs
    optimizer.zero_grad()

    # Backward pass
    loss.backward()

    # Update parameters
    optimizer.step()

#logger.save(model)
