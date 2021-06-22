% 
% JAVIER LOPEZ INIESTA DIAZ DEL CAMPO
% FERNANDO GARCIA GUTIERREZ
% 
% ENTREGABLE 2 SECO
% 
% REALIZA LA MEDIA DE LOS FICHEROS DE DATOS
% 

TensionVector=[1 2 3 4 5 6 7 8 9 10 11 12];
TensionVectorL=length(TensionVector);
QRepeticionesVector = [1 2 3 4 5 6 7 8 9 10];
QRepeticionesVectorL = length(QRepeticionesVector);

for i=1:TensionVectorL
    
    Tension=num2str(TensionVector(i));
    nombre_carpeta=strcat('./', Tension, 'V_0ms600ms600ms_T1ms/');
    media = zeros(1201,QRepeticionesVectorL);

    for j=1:QRepeticionesVectorL
        rep=num2str(QRepeticionesVector(j));
        nombre_fichero = strcat('exp', Tension, 'V_rep', rep, '.txt');
        nombre_ruta = strcat(nombre_carpeta, nombre_fichero);
        formatSpec = '%f %f';
        sizeA = [2 Inf];
        fidLectura = fopen(nombre_ruta,'r');
        file = fscanf(fidLectura,formatSpec,sizeA);
        fclose(fidLectura);
        file=file';
        Tiempo=file(:,1);
        Pulsos=file(:,2);
        media(:,j) = Pulsos(:,1);
    end
    
    media_pulsos = mean(media, 2);
    ruta_nueva = strcat('trap', Tension, 'V_0ms600ms600ms_T1ms_ST.mean');
    fichero_nuevo = [Tiempo media_pulsos];
    formatSpec_out = '%f %f\n';
   	fidEscritura = fopen(ruta_nueva,'w');
    fprintf(fidEscritura,'%f %f\r\n',fichero_nuevo');
    fclose(fidEscritura);
end

