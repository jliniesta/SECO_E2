% Coeficientes de un polinomio simetrico interpolado C*a=b
% Polinomio de terminos impares 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% ENTRADAS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% b vector fila tal que C*a=b
% c vector fila para construir la matriz C

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SALIDAS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% a=(a1,a3,a5,...,aN-1) % coeficientes impares de un polinomio de grado N par; vector fila; length(a)=N/2
% aR=(a1,0,a3,0,a5,...,aN-1,0) % N par; vector fila; length(aR)=N
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% AUTOR: Felix Monasterio-Huelin
% FECHA: 6 de marzo de 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [a,aR]=IdentificacionPolinomioSimetricoPar(b,c)
	Lc=length(c); %Q
	C=[];
	for i=1:Lc
		C1=[];
		for j=1:Lc
			C1=[C1 c(i).^(2*j-1)];
		end
		C=[C;C1];% Matriz V (3.51c)
	end
	a=inv(C)*b'; % columna (3.52)
	a=a';% coeficientes ''a'' del polinomio de grado 2*Lc-1 en forma de fila
	%% vector ''aR'' de longitud 2*Lc con coeficientes pares nulos
	aR=[];
	for j=1:Lc
		aR=[aR a(i)]; % (3.54)
		aR=[aR 0];
	end
end
