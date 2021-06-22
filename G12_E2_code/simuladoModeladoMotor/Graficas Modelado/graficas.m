% 
% JAVIER LOPEZ INIESTA DIAZ DEL CAMPO
% FERNANDO GARCIA GUTIERREZ
% 
% ENTREGABLE 2 SECO
% 
% REALIZA GRAFICAS
% 

TensionVector=[1 2 3 4 5 6 7 8 9 10 11 12];
TensionVectorL=length(TensionVector);

T = 0.001;
q = 48;

for i=1:TensionVectorL
    
    Tension=num2str(TensionVector(i));
    nombre_fichero=strcat('trap', Tension, 'V_0ms600ms600ms_T1ms_ST.mean');
    
    formatSpec = '%f %f';
    sizeA = [2 Inf];
    fidLectura = fopen(nombre_fichero,'r');
    file = fscanf(fidLectura,formatSpec,sizeA);
    fclose(fidLectura);
    file=file';
    Tiempo=file(:,1)./1000;
    Pulsos=file(:,2);
    hold all
    figure(1);
    set(gca,'XMinorTick','on');
    set(gca,'YMinorTick','on');
    time_text = '$$\mathbf{t(s)}$$';
    pulsos_text = '$$\mathbf{N(t) \; (pulsos)}$$';
    xlabel(time_text,'Interpreter','latex','FontSize',14)
    ylabel(pulsos_text,'Interpreter','latex','FontSize',14)
    plot(Tiempo,Pulsos,'LineWidth',1)
end
legend("1 V", "2 V", "3 V", "4 V", "5 V", "6 V", "7 V", "8 V", "9 V", "10 V", "11 V", "12 V", 'location', 'northeast');
hold off;
saveas(gcf,'Pulsos_time','epsc')

for i=1:TensionVectorL
    
    Tension=num2str(TensionVector(i));
    nombre_fichero=strcat('trap', Tension, 'V_0ms600ms600ms_T1ms_ST.mean');
    
    formatSpec = '%f %f';
    sizeA = [2 Inf];
    fidLectura = fopen(nombre_fichero,'r');
    file = fscanf(fidLectura,formatSpec,sizeA);
    fclose(fidLectura);
    file=file';
    Tiempo=file(:,1)./1000;
    Pulsos=file(:,2);
    
    Pulsos1 = Pulsos;
    Pulsos2 = [Pulsos(1) Pulsos(1:end-1)']';
    velocidad_angular = (2*pi*(Pulsos1 - Pulsos2))./(q*T);
    
    hold all
    figure(2);
    set(gca,'XMinorTick','on');
    set(gca,'YMinorTick','on');
    xlabel(time_text,'Interpreter','latex','FontSize',14)
    vel_angular_text = '$$\mathbf{\dot{\theta}(t) \; (rad/s)}$$';
    ylabel(vel_angular_text,'Interpreter','latex','FontSize',14)
    plot(Tiempo,velocidad_angular,'LineWidth',1)
end

legend("1 V", "2 V", "3 V", "4 V", "5 V", "6 V", "7 V", "8 V", "9 V", "10 V", "11 V", "12 V", 'location', 'northeast');
hold off;
saveas(gcf,'vel_angular','epsc')

for i=1:TensionVectorL
    
    Tension=num2str(TensionVector(i));
    nombre_fichero=strcat('trap', Tension, 'V_0ms600ms600ms_T1ms_ST.mean');
    
    formatSpec = '%f %f';
    sizeA = [2 Inf];
    fidLectura = fopen(nombre_fichero,'r');
    file = fscanf(fidLectura,formatSpec,sizeA);
    fclose(fidLectura);
    file=file';
    Tiempo=file(:,1)./1000;
    Pulsos=file(:,2).*((2*pi)/3600);
    hold all
    figure(3);
    set(gca,'XMinorTick','on');
    set(gca,'YMinorTick','on');
    ylim([0 (pi*(6/4) + 0.2)])
    yticks([0 pi/4 pi/2 pi*(3/4) pi pi*(5/4) pi*(6/4)])
    yticklabels({'0','\pi/4','\pi/2','3\pi/4','\pi','5\pi/4','3\pi/2'})
    time_text = '$$\mathbf{t(s)}$$';
    pulsos_text = '$$\mathbf{\theta(rad)}$$';
    xlabel(time_text,'Interpreter','latex','FontSize',14)
    ylabel(pulsos_text,'Interpreter','latex','FontSize',14)
    plot(Tiempo,Pulsos,'LineWidth',1)
end
legend("1 V", "2 V", "3 V", "4 V", "5 V", "6 V", "7 V", "8 V", "9 V", "10 V", "11 V", "12 V", 'location', 'northeast');
hold off;
saveas(gcf,'Pulsosrad_time','epsc')

tension_alto = 0:1:599;
tension_alto(1,1:end) = 5;
tension_bajo = 0:1:600;
tension_bajo(1,1:end) = 0;
tension = [tension_alto tension_bajo]';
figure(4);
ylim([0 6.2])
yticks([0 5])
set(gca,'XMinorTick','off');
set(gca,'YMinorTick','off');
yticklabels({'0','Vj'})
tension_text = '$$\mathbf{Tension \; de \; entrada \; (V)}$$';
xlabel(time_text,'Interpreter','latex','FontSize',13)
ylabel(tension_text,'Interpreter','latex','FontSize',12)
plot(Tiempo,tension,'-r','LineWidth',3)
hold off;
