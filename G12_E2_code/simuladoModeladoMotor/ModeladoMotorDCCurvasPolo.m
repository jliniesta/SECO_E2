% - Este programa traza curvas de varianza y polo en funcion del intervalo de tiempo

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AUTOR: Felix Monasterio-Huelin
% FECHA: 30 de marzo de 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function  ModeladoMotorDCCurvasPolo(TensionVector,NomFicheroLecturaPolo)
hPoloDesvTip=figure;
hPolo=figure;
ColorL=['brmgbrmgbrmg'];
formatSpecB = '%f %f';
sizeB = [2 Inf];
TensionVectorL=length(TensionVector);
for i=1:TensionVectorL
% LECTURA
	NomFicheroLecturaV=NomFicheroLecturaPolo{i};
	fidLecturaV=fopen(NomFicheroLecturaV,'r');
	SigmaP = fscanf(fidLecturaV,formatSpecB,sizeB);
	fclose(fidLecturaV);
	SigmaP=SigmaP';
	poloDesvTipOptV=SigmaP(:,1)'/1e+20;
	poloOptV=SigmaP(:,2)'/1e+20;
    
% Eje x
	poloDesvTipOptVL=length(poloDesvTipOptV);
	Interv=1:1:poloDesvTipOptVL;
    
%
	figure(hPoloDesvTip);
	plot(Interv,poloDesvTipOptV,'Color',ColorL(i));
	hold all
    xlabel('$$\mathbf{Intervalos \; de \; tiempo}$$','Interpreter','latex','FontSize',13)
    ylabel('$$\mathbf{Varianza}$$','Interpreter','latex','FontSize',13)
    
%
	figure(hPolo);
	plot(Interv,poloOptV,'Color',ColorL(i));
	hold all
    xlabel('$$\mathbf{Intervalos \; de \; tiempo}$$','Interpreter','latex','FontSize',13)
    ylabel('$$\mathbf{Polo}$$','Interpreter','latex','FontSize',13)
end
end% function
