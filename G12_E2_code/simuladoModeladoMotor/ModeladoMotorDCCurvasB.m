% - Este programa permite trazar cinco curvas:  de varianza y polo en funcion del intervalo de tiempo; de velocidad angular en funcion del tiempo y de los polinomios de interpolación Veq-V y V-Veq.
% - Utiliza las funciones externas ModeladoMotorDCCurvasPolo.m, ModeladoMotorDCCurvasVelAng.m, ModeladoMotorDCCurvasPoli.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ENTRADA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	- opCurvas=[a b c] donde a,b y c son numeros, tales que si son igual a 1 se trazan curvas, y para cualquier otro numero no se trazan:
%		a=1:  curvas de varianza y polo en función del intervalo de tiempo
%		b=1:  curvas de velocidad angular en función del tiempo
%		c=1:  curvas de los polinomios de interpolación Veq-V y V-Veq
%	- las restantes entradas se explican en ModeladoMotorDCVelAngPoloBucleB.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% AUTOR: Felix Monasterio-Huelin
% FECHA: 30 de marzo de 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function  ModeladoMotorDCCurvasB(opCurvas,DuracionSubida,TensionVector,NomFicheroLecturaPolo,Tiempo,PulsosRad,PS,PB,KS,KB,PSB,KSB,VeqV,pM,KM,a,b,TensionVectorP,VeqVP)
%%%%%%%%%%%%%%%%%%%%%%%
delete(findall(0,'Type','figure')) % cierra todas las figuras
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CURVAS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
% lectura fichero .polo y figuras de polos y desviaciones típicas en cada intervalo (eje x)
%%%%%%%%%%%%%%%%%%%%
if opCurvas(1)==1
	ModeladoMotorDCCurvasPolo(TensionVector,NomFicheroLecturaPolo);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% trazado curvas de velocidad angular
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if opCurvas(2)==1
	ModeladoMotorDCCurvasVelAng(DuracionSubida,TensionVector,Tiempo,PulsosRad,PS,PB,KS,KB,PSB,KSB,VeqV,pM,KM);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% trazado curvas de polinomios de interpolación
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if opCurvas(3)==1
	ModeladoMotorDCCurvasPoli(a,b,TensionVectorP,VeqVP);
end
end% function

