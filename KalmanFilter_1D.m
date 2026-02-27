function [data_vector] = KalmanFilter_1D(data,Q_i,R_i)

    data_vector = [];
    
    % Inizializzazione delle variabili persistenti al primo avvio
    persistent A H Q R
    persistent x P
    persistent firstRun
    
    if isempty(firstRun)
        firstRun = 1;
    
        % Definizione delle matrici di transizione di stato e di misura
        A = 1;
        H = 1;
    
        % Definizione delle matrici di covarianza dei rumori di processo e di misura
        Q = Q_i;
        R = R_i;
    
        % Definizione del vettore di stato iniziale e dell'errore di covarianza iniziale
        x = data(1);
        P = 5;
    end
    
    for i=1:length(data)
    
        % Algoritmo del filtro di Kalman
        %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%
        % Predizione dello stato
        xp = A * x;
        Pp = A * P * A' + Q;
        
        % Calcolo del guadagno di Kalman
        K = Pp * H' * inv(H * Pp * H' + R);
        
        % Aggiornamento dello stato
        z = data(i);
        x = xp + K * (z - H * xp);
        P = Pp - K * H * Pp;
        
        % Restituzione delle coordinate stimate
        data_vector(end+1) = x;
        %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%
    
    end

end