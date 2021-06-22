% - Este programa permite trazar cinco curvas:  de varianza y polo en funcion del intervalo de tiempo; de velocidad angular en funcion del tiempo y de los polinomios de interpolación Veq-V y V-Veq.
% - Debe introducirse manualmente:
%	- TensionVector: vector de tensión
%	- DuracionSubida: duración en segundos del escalón de subida
%	- Periodo: periodo de muestreo de captura en segundos
%	- CPR: pulsos/vuelta
%	- z1:  ponderación de los polos de subida y bajada
%	- el nombre de los ficheros:
%			NomFicheroLecturaMean{i} para cada tensión; i:índice en el vector de tensión
%			NomFicheroEscrituraPolo{i} para cada tensión; i:índice en el vector de tensión
%			NomFicheroEscrituraResumen para el conjunto de tensiones
%			NomFicheroEscrituraPoli para el conjunto de tensiones
%	- opCurvas=[a b c] donde a,b y c son números, tales que si son igual a 1 se trazan curvas, y para cualquier otro número no se trazan:
%		a=1:  curvas de varianza y polo en función del intervalo de tiempo
%		b=1:  curvas de velocidad angular en función del tiempo
%		c=1:  curvas de los polinomios de interpolación Veq-V y V-Veq
% - Utiliza las funciones externas LecturaExperimentoMultiV.m, ModeladoMotorDCVelAngPoloB.m, InterpolacionPolinomioSimetrico.m y ModeladoMotorDCCurvasB.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SALIDAS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - pM: polo de la parte lineal G(s)=KM/(s+pM)
% - KM: parte lineal  G(s)=KM/(s+pM)
% - Gzero=KM/pM: ganancia a bajas frecuencias  G(s)=KM/(s+pM)
% - J: función de error para el cálculo de K/p
% - VeqV: vector de tensiones equivalentes
% - a: vector de parámetros  Veq-V de la parte no lineal (polinomio simétrico)
% - b: vector de parámetros V-Veq de la parte no lineal invertida (polinomio simétrico)
% - fichero .poli de 4 filas de números, todos ellos multiplicados por 1e+20:
%		fila 1: vector de tension
%		fila 2: vector de tension equivalente
%		fila 3: vector de parámetros "a" Veq-V
%		fila 4: vector de parámetros "b" V-Veq
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AUTOR: Félix Monasterio-Huelin
% FECHA: 30 de marzo de 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  [pM, KM, Gzero,J,VeqV, a,b]=ModeladoMotorDCVelAngPoloBucleB
%%%%%%%%%%%%%%%%%%%%%%%
TensionVector=[1 2 3 4 5 6 7 8 9 10 11 12];
TensionVectorL=length(TensionVector);
DuracionSubida=0.6;% segundos
Periodo=0.001;% en segundos
CPR=48;% pulsos/vuelta
z1=0.5;% ponderación de los polos de subida y bajada
opCurvas=[1 1 1];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ejemplo NOMBRE DE FICHEROS: 
%% 	- con extensiones .mean, .resumen, .polo y .poli, que se leen o se escriben en el subdirectorio ./PololuModeladoDat
%% 	- ficheros de datos: 
%		./PololuModeladoDat/trapXV_0ms600ms600ms_T1ms_ST.mean, donde X es la tensión en {1,2,...,9} 
%% 	- restantes ficheros: 
%		./PololuModeladoDat/MotorDCPololu.V_0ms600ms600ms_T1ms_ST.XV.polo, donde X es la tensión en {1,2,...,9}
%		./PololuModeladoDat/MotorDCPololu.V_0ms600ms600ms_T1ms_ST.resumen
%		./PololuModeladoDat/MotorDCPololu.V_0ms600ms600ms_T1ms_ST.poli
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PrefNomMeanA='./PololuModeladoDat/trap';
PrefNomMeanB='0ms600ms600ms_T1ms_ST.mean';
PrefNomFicheroEscritura='./PololuModeladoDat/MotorDCPololu';
PrefNomFichero2=strcat(PrefNomFicheroEscritura,'.',PrefNomMeanB);
NomFicheroEscrituraResumen=strcat(PrefNomFichero2,'.resumen');
NomFicheroEscrituraPoli=strcat(PrefNomFichero2,'.poli');
NomFicheroLecturaResumen=NomFicheroEscrituraResumen;
for i=1:TensionVectorL
	Tension=TensionVector(i);
	NTension=num2str(Tension);
	NomFicheroEscrituraPolo{i}=strcat(PrefNomFichero2,'.',NTension,'V.polo');
	NomFicheroLecturaMean{i}=strcat(PrefNomMeanA,NTension,'V_',PrefNomMeanB);
end
NomFicheroLecturaPolo=NomFicheroEscrituraPolo;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LECTURA datos
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	for i=1:TensionVectorL
		Tension=TensionVector(i);
		[Tiempo,Pulsos{i}]=LecturaExperimentoMultiV(Tension,NomFicheroLecturaMean{i},Periodo);
	end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
% ModeladoMotorDCVelAngPoloB
%%%%%%%%%%%%%%%%%%%%
%if opVectorPK==0
	for i=1:TensionVectorL
		Tension=TensionVector(i);
		ModeladoMotorDCVelAngPoloB(i,Tension,CPR,Periodo,Tiempo,Pulsos{i},NomFicheroEscrituraResumen,NomFicheroEscrituraPolo{i});
	end
%end
%%%%%%%%%%%%%%%%%%%%
%% lectura pS_j, KS_j, pB_j, KB_j y VelAngMedia del fichero .resumen
%%%%%%%%%%%%%%%%%%%%
formatSpec=[];
for i=1:5
	formatSpec=strcat(formatSpec,'%f ');
end
sizeA = [5 TensionVectorL];
fidLecturaResumen= fopen(NomFicheroLecturaResumen,'r');
PK = fscanf(fidLecturaResumen,formatSpec,sizeA);
fclose(fidLecturaResumen);
PK=PK';
PS=PK(:,1)'/1e+20;% polo subida, pS_j
KS=PK(:,2)'/1e+20;% K subida, KS_j
PB=PK(:,3)'/1e+20;% polo bajada, pB_j
KB=PK(:,4)'/1e+20;% K bajada, KB_j
VAS=PK(:,5)'/1e+20;% VelAngMedia en rad/s
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% error cuadratico, pM, KM, VeqV, PSB, KSB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
a2=0;
a3=0;
a4=0;
VeqV=[];
PSB=[];
for i=1:TensionVectorL
	a2=a2+VAS(i)^2;
	a3=a3+VAS(i)*TensionVector(i);
	poloMedia=z1*PS(i)+(1-z1)*PB(i);
	a4=a4+VAS(i)*TensionVector(i)/poloMedia;
	PSB=[PSB poloMedia];% vector de polos p_j asociado al intervalo de varianza minima
end
Gzero=a2/a3;% G(0)=K/p en rad/(V*s)
pM=a3/a4;% p en s^{-1}
KM=Gzero*pM;% K en rad/(V*s^2)
errorVeq2=0;
KSB=[];
for i=1:TensionVectorL
	Veq=VAS(i)/Gzero;% VAS(i)*p/K
	VeqV=[VeqV Veq];
	errorVeq2=errorVeq2+(Veq-TensionVector(i))^2;
	KSB1=Gzero*PSB(i);
	KSB=[KSB KSB1];% vector de K_j asociado al intervalo de varianza minima
end
J=errorVeq2/2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Polinomios de interpolacion: a, b, TensionVectorP, VeqVP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TensionVectorP=TensionVector;
VeqVP=VeqV;
%%%%%%%%%%%%%%%
%% Si se hace con un polinomio extendido: por ejemplo,
% V9=[9.4 9.6 9.8]
% TensionVectorP=[TensionVectorP V9];
% VeqVP=[VeqVP V9];
% %%%%%%%%%%%%%%%
[a,aR]=InterpolacionPolinomioSimetrico(VeqVP,TensionVectorP);% f
[b,bR]=InterpolacionPolinomioSimetrico(TensionVectorP,VeqVP);% f^{-1}
% escritura .poli con precisión 1e+20
fidEscrituraPoli=fopen(NomFicheroEscrituraPoli,'w');
for i=1:length(TensionVectorP)%
	fprintf(fidEscrituraPoli,'%f ',TensionVectorP(i)*1e+20);
end
fprintf(fidEscrituraPoli,'\n');
for i=1:length(TensionVectorP)%
	fprintf(fidEscrituraPoli,'%f ',VeqVP(i)*1e+20);
end
fprintf(fidEscrituraPoli,'\n');
for i=1:length(TensionVectorP)%
	fprintf(fidEscrituraPoli,'%f ',a(i)*1e+20);
end
fprintf(fidEscrituraPoli,'\n');
for i=1:length(VeqVP)
	fprintf(fidEscrituraPoli,'%f ',b(i)*1e+20);
end
fprintf(fidEscrituraPoli,'\n');
fclose(fidEscrituraPoli);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CURVAS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:length(TensionVector)
	PulsosRad{i}=Pulsos{i}*(2*pi/CPR);
end
ModeladoMotorDCCurvasB(opCurvas,DuracionSubida,TensionVector,NomFicheroLecturaPolo,Tiempo,PulsosRad,PS,PB,KS,KB,PSB,KSB,VeqV,pM,KM,a,b,TensionVectorP,VeqVP);
end% function

