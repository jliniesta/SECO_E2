% - Este programa traza curvas de velocidad angular en funcion del tiempo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AUTOR: Felix Monasterio-Huelin
% FECHA: 30 de marzo de 2016; modificado 11 de febrero de 2017 para no utilizar '-DynamicLegend'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  ModeladoMotorDCCurvasVelAng(DuracionSubida,TensionVector,Tiempo,PulsosRad,PS,PB,KS,KB,PSB,KSB,VeqV,pM,KM)
TensionVectorL=length(TensionVector);
hRPM=figure;
hold all
figure(hRPM);

xlabel('$$\mathbf{t \; (segundos)}$$','Interpreter','latex','FontSize',13)
ylabel('$$\mathbf{Velocidad  \; angular \; (rad/s)}$$','Interpreter','latex','FontSize',13)
title('$$\mathbf{Respuesta  \; del  \; motor  \; a  \; una  \; entrada \;  cuadrada}$$','Interpreter','latex','FontSize',13)

%%%%%%%%%%%%%%%%%%%
% 0: Medidas
%%%%%%%%%%%%%%%%%%%
LTiempo=length(Tiempo);
for i=1:TensionVectorL
	for jj=2:LTiempo
		VelAng(jj)=(PulsosRad{i}(jj)-PulsosRad{i}(jj-1))/(Tiempo(jj)-Tiempo(jj-1));% rad/s
	end
 	LeyendaB=strcat('Medida;V_j=',num2str(TensionVector(i)));
% 	LeyendaBB{i}=LeyendaB;% general sin leyenda dinámica y sin 'DisplayName'
% 	plot(Tiempo,VelAng,'Color','green','LineWidth',1)
 	plot(Tiempo,VelAng,'Color','green','LineWidth',1,'DisplayName',LeyendaB)
		%%%%%%%%%%%%%%%%%%
		% Con leyenda dinámica, que se ha probado que funciona con Matlab R2013a
		%http://undocumentedmatlab.com/blog/legend-semi-documented-feature
		%	if i==1	
		%		legend('-DynamicLegend');% con Matlab R2013a
		%	end
		% -Para habilitar leyenda dinámica con Matlab R2013a:
		%  set(legendAxListener,'Enable','on');
		% -Para deshabilitar leyenda dinámica con Matlab R2013a:
		%  legendListeners = get(gca,'ScribeLegendListeners');
		%  legendAxListener = legendListeners.childadded;
		%  set(legendAxListener,'Enable','off');
		%%%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%
% 1: subida de la señal cuadrada con pS_j
%%%%%%%%%%%%%%%%%%
for i=1:TensionVectorL
	sys=tf([KS(i)*TensionVector(i)],[1 PS(i)]);
	LeyendaA=strcat('V_j=',num2str(TensionVector(i)),';pS_j=',num2str(PS(i)),';KS_j=',num2str(KS(i)),';pB_j=',num2str(PB(i)),';KB_j=',num2str(KB(i)),';p_j=',num2str(PSB(i)),';K_j=',num2str(KSB(i)));
% 	LeyendaBB{i+TensionVectorL}=LeyendaA;% general sin leyenda dinámica y sin 'DisplayName'
	[escalon,Paramt]=step(sys,DuracionSubida);
% 	plot(Paramt,escalon,'color','blue','LineWidth',2')
 	plot(Paramt,escalon,'color','blue','LineWidth',2','DisplayName',LeyendaA)
end
%%%%%%%%%%%%%%%%%%%
% 2: subida de la señal cuadrada con  KM,pM 
%%%%%%%%%%%%%%%%%%%
for i=1:TensionVectorL
	VeqS=num2str(VeqV(i));
	sys=tf([KM*VeqV(i)],[1 pM]);
	LeyendaC=strcat('p=',num2str(pM),';K=',num2str(KM),';V_{eq,j}=',VeqS);
% 	LeyendaBB{i+TensionVectorL+TensionVectorL}=LeyendaC;% general sin leyenda dinámica y sin 'DisplayName'
	[escalon,Paramt]=step(sys,DuracionSubida);
% 	plot(Paramt,escalon,'color','red','LineWidth',2)
 	plot(Paramt,escalon,'color','red','LineWidth',2,'DisplayName',LeyendaC)
end
%%%%%%%%%%%%%%%%%
%%%%%%%%%% LEYENDA
%%%%%%%%%%%%%%%%%
% legend(LeyendaBB);% general, sin leyenda dinámica y sin 'DisplayName'; debe comentarse si se utiliza legend('-DynamicLegend');
 legend show;% general, alternativa que necesita 'DisplayName'; debe comentarse si se utiliza legend('-DynamicLegend');
	%%%% NOTA:si se utiliza leyenda dinámica, debe deshabilitarse, además de comentar la línea anterior:
	%legendListeners = get(gca,'ScribeLegendListeners');
	%legendAxListener = legendListeners.childadded;
	%set(legendAxListener,'Enable','off');
	%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%
% 3: bajada de la senal cuadrada con pB_j
%%%%%%%%%%%%%%%%%%%
for i=1:TensionVectorL
	sys=tf([KB(i)*TensionVector(i)],[1 PB(i)]);
	[escalon,Paramt]=step(sys,DuracionSubida);
	ParamtBV=[];
	escalonBV=[];
	ParamtL=length(Paramt);
	for j=1:ParamtL
		ParamtB=Paramt(j)+DuracionSubida;
		ParamtBV=[ParamtBV ParamtB];
		if mod(ParamtL,2)==0% ParamtL par
			escalonB=escalon(round(1+ParamtL/2))-escalon(j);
		else
			escalonB=escalon(round(1+(ParamtL-1)/2))-escalon(j);
		end
		escalonBV=[escalonBV escalonB];
	end
	ParamtBV=ParamtBV';
	escalonBV=escalonBV';
	plot(ParamtBV,escalonBV,'color','blue','LineWidth',2)
end

%%%%%%%%%%%%%%%%%%%%
% 4: bajada de la senal cuadrada con  KM,pM 
%%%%%%%%%%%%%%%%%%%
for i=1:TensionVectorL
	sys=tf([KM*VeqV(i)],[1 pM]);
	[escalon,Paramt]=step(sys,DuracionSubida);
	VeqS=num2str(VeqV(i));
	ParamtB=Paramt+DuracionSubida;
	escalonB=KM*VeqV(i)/pM-escalon;
	plot(ParamtB,escalonB,'color','red','LineWidth',2)
end
end% function

