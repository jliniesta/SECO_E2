%%%%%%%%%%%%%%%
%% LECTURA
%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AUTOR: Felix Monasterio-Huelin
% FECHA: 5 de marzo de 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  [TiempoV,PulsosV]=LecturaExperimentoMultiV(Tension,NomFicheroLectura,Periodo)
	formatSpec = '%f %f';
	sizeA = [2 Inf];
	fidLectura= fopen(NomFicheroLectura,'r');
	tP = fscanf(fidLectura,formatSpec,sizeA);
	fclose(fidLectura);
	tP=tP';
	TiempoV=tP(:,1)*Periodo;% segundos
	PulsosV=tP(:,2);
end% function

