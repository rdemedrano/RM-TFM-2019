import os

import numpy as np
import torch

from utils import DotDict, normalize


def dataset_factory(data_dir, name):
    # get dataset
    if name[:5] == 'crash':
        opt, data = crash(data_dir, '{}.csv'.format(name))
    else:
        raise ValueError('Non dataset named `{}`.'.format(name))
#    if name[:8] == 'crash_ex':
#        opt, data, relations = crash_ex(data_dir, '{}.csv'.format(name))
#    else:
#        raise ValueError('Non dataset named `{}`.'.format(name))
#    if name[:4] == 'heat':
#        opt, data, relations = heat(data_dir, '{}.csv'.format(name))
#    else:
#        raise ValueError('Non dataset named `{}`.'.format(name))
#    if name[:6] == 'prueba':
#        opt, data, relations = prueba(data_dir, '{}.csv'.format(name))
#    else:
#        raise ValueError('Non dataset named `{}`.'.format(name))
    # make k hop
    # split train / test
#    train_data = data[:opt.nt_train, :, :opt.nd]
#    test_data = data[opt.nt_train:, :, :opt.nd]
    train_data = data[:opt.nt_train, :]
    test_data = data[opt.nt_train:, :]
    return opt, (train_data, test_data)


def crash(data_dir, file='crash.csv'):
    # dataset configuration
    opt = DotDict()
    opt.nt = 365
    opt.nt_train = 355
    opt.nx = 49
    opt.nbatch = 1
    opt.periode = opt.nt
    # loading data
    data = torch.Tensor(np.genfromtxt(os.path.join(data_dir, file))).view(opt.nt, opt.nbatch ,opt.nx)
    return opt, data

def crash_ex(data_dir, file='crash_ex.csv'):
    # dataset configuration
    opt = DotDict()
    opt.nt = 1128
    opt.nt_train = 1080
    opt.nx = 49
    opt.periode = opt.nt
    # loading data
    data = torch.Tensor(np.genfromtxt(os.path.join(data_dir, file))).view(opt.nt, opt.nx)
    return opt, data


def heat(data_dir, file='heat.csv'):
    # dataset configuration
    opt = DotDict()
    opt.nt = 200
    opt.nt_train = 100
    opt.nx = 41
    opt.np = 0
    opt.nd = 1
    opt.periode = opt.nt
    # loading data
    data = torch.Tensor(np.genfromtxt(os.path.join(data_dir, file))).view(opt.nt, opt.nx, opt.np + opt.nd)
    # load relations
    relations = torch.Tensor(np.genfromtxt(os.path.join(data_dir, 'heat_relations.csv')))
    relations = normalize(relations).unsqueeze(1)
    return opt, data, relations


def prueba(data_dir, file='prueba.csv'):
    # dataset configuration
    opt = DotDict()
    opt.nt = 5
    opt.nt_train = 3
    opt.nx = 4
    opt.np = 2
    opt.nd = 1
    opt.periode = opt.nt
    # loading data
    data = torch.Tensor(np.genfromtxt(os.path.join(data_dir, file))).view(opt.nt, opt.nx, opt.np + opt.nd)
    # La propia serie temporal sería: data[:,:,0:opt.nd]
    # load relations
    relations = torch.Tensor(np.genfromtxt(os.path.join(data_dir, 'prueba_relations.csv')))
    relations = normalize(relations).unsqueeze(1)
    return opt, data, relations
