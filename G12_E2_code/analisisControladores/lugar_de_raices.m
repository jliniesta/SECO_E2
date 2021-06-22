% 
% JAVIER LOPEZ INIESTA DIAZ DEL CAMPO
% FERNANDO GARCIA GUTIERREZ
% 
% ENTREGABLE 2 SECO
% 
% CALCULO DEL LUGAR DE RAICES

function  lugar_de_raices(Kp, controlador)

    close all
    
    s=tf('s');
    r = 74.83;
    K = 1515.10;
    p = 33.54;

    G_motor = (K*r)/(s*(s+p));
    Kp_VectorL=length(Kp);
    
    if(controlador == 1)
        figure('name', 'Lugar de raices (controlador proporcional)','NumberTitle','off');
        hold all
        for i=1:Kp_VectorL
            G_c = Kp(i);
            sys = G_c * G_motor;
            rlocus(sys) 
        end
        title_text=strcat('$$\mathbf{Lugar \; de \; raices \; del \; controlador \; proporcional}$$');
        title(title_text,'Interpreter','latex','FontSize',14)
        %legend('$$Kp = 1$$', '$$Kp = 3$$', '$$Kp =5$$', '$$Kp =10$$','$$Kp =20$$', '$$Kp =50$$', '$$Kp =100$$','Interpreter','latex', 'location', 'southeast');
        hold off;
        
    elseif (controlador == 2)
        td_Vector=[0.001 0.01 0.02 0.05 0.1 0.5];
        td_VectorL=length(td_Vector);

        for i=1:Kp_VectorL
            figure('name', 'Lugar de raices (controlador proporcional derivativo)','NumberTitle','off');
            for j=1:td_VectorL
                G_c = Kp(i)*(1+(td_Vector(j)*s));
                sys = G_c * G_motor;
                hold all
                rlocus(sys) 
            end
            title_text=strcat('$$\mathbf{Lugar \; de \; raices \; del \; controlador \; P-D}$$');
            title(title_text,'Interpreter','latex','FontSize',14)
            legend('$$\tau d = 0.001$$','$$\tau d = 0.01$$', '$$\tau d = 0.02$$', '$$\tau d = 0.05$$', '$$\tau d = 0.1$$','$$\tau d = 0.5$$','Interpreter','latex', 'location', 'northwest');    
            hold off;
        end
    elseif (controlador == 3)
        ti_Vector=[0.5 1 2 5 10];
        ti_VectorL=length(ti_Vector);
        for i=1:Kp_VectorL
            figure('name', 'Lugar de raices (controlador proporcional integral)','NumberTitle','off');
            for j=1:ti_VectorL
                G_c = Kp(i)*(1+(1/(s*ti_Vector(j))));
                sys = G_c * G_motor;
                hold all
                rlocus(sys) 
            end
            title_text=strcat('$$\mathbf{Lugar \; de \; raices \; del \; controlador \; P-I}$$');
            title(title_text,'Interpreter','latex','FontSize',14)
            legend('$$\tau i = 0.5$$','$$\tau i = 1$$', '$$\tau i = 2$$', '$$\tau i = 5$$', '$$\tau i = 10$$','Interpreter','latex', 'location', 'northeast');    
            hold off;
        end 
    elseif (controlador == 4)
        ti_Vector=[1];
        ti_VectorL=length(ti_Vector);
        td_Vector=[0.05];
        td_VectorL=length(td_Vector);
        for i=1:Kp_VectorL
            figure('name', 'Lugar de raices (controlador PID)','NumberTitle','off');
            for j=1:td_VectorL
                    for l=1:ti_VectorL
                        G_c = Kp(i)*(1+(td_Vector(j)*s)+(1/(s*ti_Vector(l))));
                        sys = G_c * G_motor;
                        hold all
                        rlocus(sys) 
                    end
            end
            title_text=strcat('$$\mathbf{Lugar \; de \; raices \; del \; controlador \; PID}$$');
            title(title_text,'Interpreter','latex','FontSize',14)
%             legend('$$\tau d = 0.01 \; y \; \tau i = 1$$','$$\tau d = 0.01 \; y \; \tau i = 5$$', '$$\tau d = 0.05 \; y \; \tau i = 1$$','$$\tau d = 0.05 \; y \; \tau i = 5$$','Interpreter','latex', 'location', 'northeast');    
            hold off;
        end    
    end
end