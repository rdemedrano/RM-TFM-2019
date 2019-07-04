import torch
import torch.nn as nn

class LSTM(nn.Module):

    def __init__(self, input_dim, hidden_dim, output_dim,
                    num_layers):
        super(LSTM, self).__init__()
        self.input_dim = input_dim
        self.hidden_dim = hidden_dim
        self.output_dim = output_dim
        self.num_layers = num_layers

        # Define the LSTM layer
        self.lstm = nn.LSTM(self.input_dim, self.hidden_dim, self.num_layers)

        # Define the output layer
        self.linear = nn.Linear(self.hidden_dim, output_dim)

    def init_hidden(self, input):
        # This is what we'll initialise our hidden state as
        return (torch.zeros(self.num_layers, input.size(1), self.hidden_dim),
                torch.zeros(self.num_layers, input.size(1), self.hidden_dim))

    def forward(self, input):
        h0, c0 = self.init_hidden(input)
#        print(h0)
        out, (hn, cn) = self.lstm(input, (h0,c0))
        y_pred = self.linear(out[:,-1,:])
        return y_pred
    
#    def forward(self, input):
#        # Forward pass through LSTM layer
#        # shape of lstm_out: [input_size, batch_size, hidden_dim]
#        # shape of self.hidden: (a, b), where a and b both 
#        # have shape (num_layers, batch_size, hidden_dim).
##        A MI ME PARECE QUE TAL Y COMO METEMOS LOS DATOS, NO HACE NADA LO DEL INPUT.VIEW
##        ES COMO SI METIESEMOS NUESTROS DATOS SIN MAS.
##        COMPROBADO QUE LA OPERACIÓN ENTERA DA LO MISMO ENTRE COMO ENTRE
##        ESO ERA PORQUE METIAS LOS DATOS YA EN EL MISMO FORMATO. SI LOS METES COMO
##        EN LA STNN POR EJEMPLO, ESO AYUDA A COLOCARLOS COMO LA LSTM DE PYTORCH QUIERE
#        out, (hn, cn) = self.lstm(input)
##        lstm_out, self.hidden = self.lstm(input.view(int(len(input)/self.batch_size), self.batch_size, -1))
#        
#        # Only take the output from the final timestep
#        # Can pass on the entirety of lstm_out to the next layer if it is a seq2seq prediction
##        y_pred = self.linear(out)
#        y_pred = self.linear(out[:,-1,:])
#        return y_pred