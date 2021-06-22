% - Programa que permite calcular la velocidad angular media a partir de un fichero de datos. Calcula tambien los polos de subida y bajada estimados de una señal cuadrada. Todos estos datos se guardan en un fichero Resumen.
% - Se utilizara en un bucle de longitud el numero de valores de tension del escalon de entrada al motor
% - Requiere introducir manualmente los parametros:
%		IniS		Indice inicial subida
%		InfS		Indice final subida
%		InfB		Indice subida + bajada
%		kTs		Indice frontera regimen permanente subida (para el calculo de la velocidad angular media)
%		DeltatS		Deltat de subida (ver algoritmo de creación de intervalos en la funcion interna  PoloVarianzaMinEscalon) 
%		DnS		Dn de subida (ver algoritmo de creación de intervalos en la funcion interna PoloVarianzaMinEscalon)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ENTRADAS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 	indTension:			Indice del vector de tensiones, necesario para el fichero Resumen
%	Tension:			tension de entrada al motor  en voltios: escalon de subida
%	CPR:				pulsos/vuelta
%	Periodo:			muestreo en segundos
%	Tiempo:				vector de tiempo
%	Pulsos:				vector de pulsos
%	NomFicheroEscrituraResumen:	nombre del fichero Resumen
% 	NomFicheroEscrituraPolo:	nombre del fichero Polo

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SALIDAS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Las salidas son los ficheros de nombre NomFicheroEscrituraResumen y NomFicheroEscrituraPolo:
% 	- fichero RESUMEN. Hay un unico fichero Resumen para el conjunto de valores de tension. Cuando indTension=1 se crea un nuevo fichero Resumen, y cuando indTension>1 se adjuntan nuevas filas. Cada fila se corresponde con una Tension, cuyo formato es el siguiente:
%		poloMediaS*1e+20		: polo medio de varianza minima transitorio de subida
%		KS*1e+20			: valor de K para poloMediaS
%		poloMediaB*1e+20		: polo transitorio de bajada
%		KB*1e+20			: valor de K para poloMediaB
%		VelAngMediaS*1e+20*2*pi/CPR	: velocidad angular media en rad/s
%	- fichero POLO. Se crea un fichero por cada Tension. Es un fichero de texto de dos columnas de longitud el numero de intervalos de tiempo: la primera es la varianza y la segunda el polo para cada intervalo, multiplicados por 1e+20.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AUTOR: Felix Monasterio-Huelin
% FECHA: 30 de marzo de 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  ModeladoMotorDCVelAngPoloB(indTension,Tension,CPR,Periodo,Tiempo,Pulsos,NomFicheroEscrituraResumen,NomFicheroEscrituraPolo)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TCapturams=1;%1 ms, muestreo
%Periodo=TCapturams/1000;% en segundos
%CPR=12;% pulsos/vuelta
IniS=1;% inicial subida
InfS=601;% final subida
InfB=1201;% subida + bajada
kTs=401;% frontera régimen permanente subida
DeltatS=60;
DnS=2;%>=2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VelAngMedia SUBIDA: regimen permanente
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	VelAngMediaS=CalcVelAngMedia(kTs,InfS,Pulsos,Tiempo);%pulsos/s
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SUBIDA: escalon Vj
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	[poloMinDesvTipS,poloMediaS,poloDesvTipOptVS,poloOptVS]=PoloVarianzaMinEscalon(DeltatS,DnS,IniS+1,InfS,Pulsos,Tiempo,VelAngMediaS);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VelAngMedia BAJADA: toda la trayectoria de bajada
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	VelAngMediaB=CalcVelAngMedia(InfS+1,InfB,Pulsos,Tiempo);%pulsos/s
	poloInfVelAngMedia=VelAngMediaS/(InfS*Periodo*VelAngMediaB);
	poloMediaB=poloInfVelAngMedia;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
KS=(VelAngMediaS)*2*pi*poloMediaS/(CPR*Tension);
KB=(VelAngMediaS)*2*pi*poloMediaB/(CPR*Tension);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% escritura ficheros
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if indTension==1
	fidEscritura=fopen(NomFicheroEscrituraResumen,'w');
else
	fidEscritura=fopen(NomFicheroEscrituraResumen,'a');
end
fidEscrituraV=fopen(NomFicheroEscrituraPolo,'w');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
poloOptVA=[];
poloDesvTipOptVA=[];
for k=1:length(poloDesvTipOptVS)
poloDesvTipOptVA=[poloDesvTipOptVA ; poloDesvTipOptVS(k)];
poloOptVA=[poloOptVA poloOptVS(k)];
end
poloDesvTipOptV=poloDesvTipOptVA;
poloOptV=poloOptVA;
	fprintf(fidEscritura,'%f %f %f %f %f\n',poloMediaS*1e+20,KS*1e+20,poloMediaB*1e+20,KB*1e+20,VelAngMediaS*1e+20*2*pi/CPR);
	fclose(fidEscritura);
for i=1:length(poloDesvTipOptV)
	fprintf(fidEscrituraV,'%f %f\n',poloDesvTipOptV(i)*1e+20,poloOptV(i)*1e+20);
end
	fclose(fidEscrituraV);
end% function

%%%%%%%%%%%%%%%%%
% Funciones utilizadas
%%%%%%%%%%%%%%%%%

function VelAngMedia=CalcVelAngMedia(VelAngInicio,VelAngFin,Pulsos,Tiempo)% pulsos/s
	VelAngVector=[];
	for k=VelAngInicio:VelAngFin
		VelAng=(Pulsos(k)-Pulsos(k-1))/((Tiempo(k)-Tiempo(k-1)));
		VelAngVector=[VelAngVector VelAng];
	end
	VelAngMedia=mean(VelAngVector);
end

function [poloMinDesvTipS,poloMediaS,poloDesvTipOptVS,poloOptVS]=PoloVarianzaMinEscalon(Deltat,Dn,jjIm,InfS,Pulsos,Tiempo,VelAngMediaS)
jjIM=InfS-Dn*Deltat;%PImax
poloDesvTipOptVS=[];
poloOptVS=[];
for jjI=jjIm:jjIM
	jjFm=jjI+Deltat;
	jjFM=jjFm+(Dn-1)*Deltat;
	for jjF=jjFm:jjFM
		NPulsosPolo=jjF-jjI+1;
		poloMediaI=0.0;
		poloDesvTipica=0.0;
		for jj=jjI:jjF
			VelAng=(Pulsos(jj)-Pulsos(jj-1))/(Tiempo(jj)-Tiempo(jj-1));
			polo=VelAng/(VelAngMediaS*Tiempo(jj)-Pulsos(jj));
			poloMediaI=poloMediaI+polo;
			poloDesvTipica=poloDesvTipica +polo^2;
		end% for jj
		poloMediaI=poloMediaI/NPulsosPolo;
		poloDesvTipOpt=sqrt(poloDesvTipica/(NPulsosPolo-1)-(NPulsosPolo*poloMediaI^2)/(NPulsosPolo-1));
		poloDesvTipOptVS=[poloDesvTipOptVS ; poloDesvTipOpt];
		poloOptVS=[poloOptVS poloMediaI];
	end%  jjF
end% jjI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Polo medio a minima desviacion tipica de la secuencia de polos medios de cada intervalo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[poloMinDesvTipS,indS]=min(poloDesvTipOptVS);
poloMediaS=poloOptVS(indS);
end

