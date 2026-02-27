function [KU7_RMC_data] = KalmanFilter_RMC_GNSS(U7_RMC_data,Q_i,R_i)

    latitude = [];
    longitude = [];
    
    % Inizializzazione delle variabili persistenti al primo avvio
    persistent A H Q R
    persistent x P
    persistent firstRun
    
    if isempty(firstRun)
        firstRun = 1;
    
        % Definizione delle matrici di transizione di stato e di misura
        A = [1 0 ; 0 1];
        H = [1 0 ; 0 1];
    
        % Definizione delle matrici di covarianza dei rumori di processo e di misura
        Q = [Q_i 0 ; 0 Q_i];
        R = [R_i 0 ; 0 R_i];
    
        % Definizione del vettore di stato iniziale e dell'errore di covarianza iniziale
        x = [U7_RMC_data.latitude(1) U7_RMC_data.longitude(1)]';
        P = 5 * eye(2);
    end
    
    for i=1:length(U7_RMC_data.timestamp)
    
        % Algoritmo del filtro di Kalman
        %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%
        % Predizione dello stato
        xp = A * x;
        Pp = A * P * A' + Q;
        
        % Calcolo del guadagno di Kalman
        K = Pp * H' * inv(H * Pp * H' + R);
        
        % Aggiornamento dello stato
        z = [U7_RMC_data.latitude(i); U7_RMC_data.longitude(i)];
        x = xp + K * (z - H * xp);
        P = Pp - K * H * Pp;
        
        % Restituzione delle coordinate stimate
        latitude(end+1) = x(1);
        longitude(end+1) = x(2);
        %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%
    
    end
    
    KU7_RMC_data = struct;
    KU7_RMC_data.timestamp = U7_RMC_data.timestamp;
    KU7_RMC_data.latitude = latitude;
    KU7_RMC_data.longitude = longitude;
    KU7_RMC_data.speed = U7_RMC_data.speed;

end