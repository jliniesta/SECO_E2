% 
% JAVIER LOPEZ INIESTA DIAZ DEL CAMPO
% FERNANDO GARCIA GUTIERREZ
% 
% ENTREGABLE 2 SECO
% 
% CALCULO DE LA RESPUESTA AL ESCALÓN UNIDAD

function  respuesta(controlador)

    close all
    
    s=tf('s');
    r = 74.83;
    K = 1515.10;
    p = 33.54;

    G_motor = (K*r)/(s*(s+p));
       
    if(controlador == 1) % CONTROLADOR PROPORCIONAL
        
        Kp_Vector=[1 10 50];
        Kp_VectorL=length(Kp_Vector);
        figure('name', 'Respuesta al escalon unidad (controlador proporcional)','NumberTitle','off');
        hold all
        for i=1:Kp_VectorL
            G_c = Kp_Vector(i);
            sys = G_c * G_motor;
            sys_cerrado = feedback (sys, 1);
            step(sys_cerrado)
            ylim([0 2])
%             xlim([0 0.35])
        end
        title('Respuestas al escalón unidad (Controlador proporcional)','FontSize',14)
        legend('$$Kp = 1$$','$$Kp =10$$', '$$Kp =50$$','Interpreter','latex', 'location', 'southeast');
        hold off;
        
    elseif (controlador == 2) % CONTROLADOR PROPORCIONAL DERIVATIVO
        Kp_Vector=[100];
        Kp_VectorL=length(Kp_Vector);

        td_Vector=[0.001 0.01 0.02 0.05 0.1 0.5];
        td_VectorL=length(td_Vector);

        for i=1:Kp_VectorL
            figure('name', 'Respuesta al escalon unidad (controlador proporcional derivativo)','NumberTitle','off');
            hold all
            for j=1:td_VectorL
                G_c = Kp_Vector(i)*(1+(td_Vector(j)*s));
                sys = G_c * G_motor;
                sys_cerrado = feedback (sys, 1);
                step(sys_cerrado)
                xlim([0 0.007])

            end
            title('Respuestas al escalón unidad (Controlador P-D)','FontSize',14)
            legend('$$\tau d = 0.001$$','$$\tau d = 0.01$$', '$$\tau d = 0.02$$', '$$\tau d = 0.05$$', '$$\tau d = 0.1$$','$$\tau d = 0.5$$','Interpreter','latex', 'location', 'southeast');    
            hold off;
        end
    elseif (controlador == 3) % CONTROLADOR PROPORCIONAL INTEGRAL
        Kp_Vector=[100];
        Kp_VectorL=length(Kp_Vector);
        
        ti_Vector=[0.5 1 2 5 10 100 1000];
        ti_VectorL=length(ti_Vector);

        for i=1:Kp_VectorL
            figure('name', 'Respuesta al escalon unidad (controlador proporcional integral)','NumberTitle','off');
            hold all
            for j=1:ti_VectorL
                G_c = Kp_Vector(i)*(1+(1/(s*ti_Vector(j))));
                sys = G_c * G_motor;
                sys_cerrado = feedback (sys, 1);
                step(sys_cerrado)
%                 xlim([0 0.007])
            end
            title('Respuestas al escalón unidad (Controlador P-I)','FontSize',14)
            legend('$$\tau i = 0.5$$','$$\tau i = 1$$', '$$\tau i = 2$$', '$$\tau i = 5$$', '$$\tau i = 10$$','Interpreter','latex', 'location', 'northeast');    
            hold off;
        end    
    elseif (controlador == 4) % CONTROLADOR PROPORCIONAL INTEGRAL DERIVATIVO
        Kp_Vector=[100];
        Kp_VectorL=length(Kp_Vector);
        ti_Vector=[1];
        ti_VectorL=length(ti_Vector);
        td_Vector=[0.05];
        td_VectorL=length(td_Vector);
        for i=1:Kp_VectorL
            figure('name', 'Respuesta al escalon unidad (controlador PID)','NumberTitle','off');
            hold all
            for j=1:td_VectorL
                    for l=1:ti_VectorL
                        G_c = Kp_Vector(i)*(1+(td_Vector(j)*s)+(1/(s*ti_Vector(l))));
                        sys = G_c * G_motor;
                        sys_cerrado = feedback (sys, 1);
                        step(sys_cerrado)
                    end
            end
            title('Respuestas al escalón unidad (Controlador PID)','FontSize',14)
%             legend('$$\tau d = 0.01 \; y \; \tau i = 1$$','$$\tau d = 0.01 \; y \; \tau i = 5$$', '$$\tau d = 0.05 \; y \; \tau i = 1$$','$$\tau d = 0.05 \; y \; \tau i = 5$$','Interpreter','latex', 'location', 'northeast');    
            hold off;
        end  
    end
end