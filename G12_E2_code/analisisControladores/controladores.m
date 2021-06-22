% 
% JAVIER LOPEZ INIESTA DIAZ DEL CAMPO
% FERNANDO GARCIA GUTIERREZ
% 
% ENTREGABLE 2 SECO
% 

%% CONTROLADOR P

Kp_Vector=[1 3 5 10 20 50 100];
lugar_de_raices(Kp_Vector, 1);
respuesta(1);

% Pinta la señal de salida del controlador con los datos del RealLabo
% controladorP(Kp_Vector);

%% Controlador Proporcional Derivativo (PD)

Kp_Vector=[10 100];
td_Vector=[0.01 0.02 0.05 0.1 0.5];

lugar_de_raices(Kp_Vector, 2);
respuesta(2);

% Pinta la señal de salida del controlador con los datos del RealLabo
% controladorPD(Kp_Vector, td_Vector);

%% Controlador Proporcional Integral (PI)

Kp_Vector=[10 100];
ti_Vector=[0.005 0.05 0.5 1 2 5 10];

lugar_de_raices(Kp_Vector, 3);
respuesta(3);

% Pinta la señal de salida del controlador con los datos del RealLabo
% controladorPI(Kp_Vector, ti_Vector);

%% Controlador Proporcional Integral Derivativo (PID)

Kp_Vector=[100];
ti_Vector=[5];
td_Vector=[0.01];

lugar_de_raices(Kp_Vector, 4);
respuesta(4);

% Pinta la señal de salida del controlador con los datos del RealLabo
% controladorPID(Kp_Vector, ti_Vector, td_Vector);