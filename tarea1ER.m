%tarea1 ER
%% pregunta 1. datos
futa=readtable('agrometeorologia-20240506164140.csv');
%eliminar filas
futa(1:5,:)=[];
futa(366:371,:)=[];
%separar datos en velocidad y direcccion 
velocidad=table2array(futa(:,2));
velocidad=velocidad*(1000/3600); %de km/h a m/s
direccion=table2array(futa(:,3));

%% rosa de los vientos 
%definimos velocidades y direcciones especificas para los meses de invierno
%y verano 
invierno=velocidad(53:144,:);
verano=velocidad(236:326,:);
dirinvierno=direccion(53:144,:);
dirverano=direccion(236:326,:);

figure
histogram(verano) %para ver como son las velocidades de cada estación
hold on
histogram(invierno)

WindRose(dirverano,verano,'Verano')
WindRose(dirinvierno,invierno,'Invierno')

%% vector progresivo 
%obtenemos las componentes x e y del viento
Vx=-velocidad.*sin(direccion*pi/180);
Vy=-velocidad.*cos(direccion*pi/180);

x=cumsum([0; Vx*86400]); %pasamos de m/s a m/dia
y=cumsum([0; Vy*86400]);

figure(2)
plot(x/1000,y/1000,'m-','linewidth',3) %dividimos por mil para pasar de m a km
xlabel('Distancia zonal [km]','FontSize',12)
ylabel('Distancia meridional [km]','FontSize',12)
title('Diagrama vector progresivo','FontSize',15)
grid on
axis tight

%% distribucion de weibull 
figure()
histogram(velocidad,5)
xlabel('m/s')
ylabel('Numero de datos')
title('Histograma velocidad')

% ecuacion de weibull; variable estandarizada
velocidad_ordenada=sort(velocidad); % Ordenamos los datos 
V_norm=velocidad_ordenada/mean(velocidad); % estandarizacion de los datos
desv=std(velocidad); 
media=mean(velocidad);
k=(desv/media)^(-1.0983); %Parametro de forma
c=1/gamma(1+1/k);%parametro de escala 
%variables de weibull
A=k/c;
B=(V_norm/c).^(k-1);
D=exp(-V_norm/c).^k;
weibull=A.*B.*D; % calculo de la distribución de weibull

figure()
plot(V_norm,weibull,'-','color',[0.3010 0.7450 0.9330],'linewidth',2)
xlabel('v/v_{media}','FontSize',12)
ylabel('Probabilidad','FontSize',12)
title('Distribución de weibull','FontSize',15)

% otra forma de calcular weibull con dimensiones de m/s
velocidad=sort(velocidad);
c=media/gamma(1+1/k);
A=k/c;
B=(velocidad/c).^(k-1);
D=exp(-velocidad/c).^k;
weibull=A.*B.*D; 

figure()
plot(velocidad,weibull,'-','color',[0.4940 0.1840 0.5560],'linewidth',2)
xlabel('Velocidad del viento [m/s]','FontSize',12)
ylabel('Probabilidad','FontSize',12)
title('Distribución de weibull','FontSize',15)

%coloamos distribucion de weibull normalizada y en m/s en una sola figura 
figure()
subplot(1,2,1)
plot(V_norm,weibull,'-','color',[0.3010 0.7450 0.9330],'linewidth',2)
xlabel('v/v_{media}')
ylabel('Probabilidad')
title('Distribución de weibull')
subplot(1,2,2)
plot(velocidad,weibull,'-','color',[0.4940 0.1840 0.5560],'linewidth',2)
xlabel('Velocidad del viento [m/s]')
ylabel('Probabilidad')
title('Distribución de weibull')

%% Pregunta 2. datos
load('caudalrionegro.mat');
tiempo=datevec(time);

%% pregunta 2 a)
%caudales promedios diarios 
% buscamos la posicion para todos los primeros de enero
c=0;
for i=1:12
    mes=i;
    for j=1:31
        dia=j;
        k=tiempo(:,2)==mes & tiempo(:,3)==dia; % creamos una matriz de 0 y 1, donde los 1 corresponderán al dia en especifico que buscamos en cada ciclo
        x=mean(value(k)); % value(k) tendrá los valores de caudal de todos los años de un dia especifico
        c=c+1; % creamos un contador para ir guardando las variables
        media_diaria(c)=x;
    end 
end 
%Ahora quitamos los NaN y nos queda un vector de 366 días 
i=isnan(media_diaria);
media_diaria(i)=[];
%como tenemos un vector de 366 buscamos un año bisiesto para graficar así
%ambos tienen el mismo largo, y en el eje x aparezcan los mese de cualquier
%año 
%elegimos un año bisiesto, como nuestros datos van de 1996 a 2020 podemos
%elegir 1996-2000-2004-2008-2012-2016-2020
year=2012;
i=find(tiempo(:,1)==year);
fechas=datetime(tiempo(i,:));

figure()
plot(datenum(fechas),media_diaria,'Color',[0.3010 0.7450 0.9330],'LineWidth',2)
datetick('x','mmm')
xlabel('Fecha [meses]','FontSize',14,'FontWeight','bold')
ylabel('Caudal (m3/s)','FontSize',14,'FontWeight','bold')
title('Caudal promedio diario','FontSize',16,'FontWeight','bold')
axis tight
grid on

%caudal clasificado 30 años 
Qclasi=sort(media_diaria,'descend');

%por conveniencia creamos una figura con graficos de caudal promedio diario
%y caudal clasificado
figure()
subplot(1,2,1)
plot(datenum(fechas),media_diaria,'Color',[0.3010 0.7450 0.9330],'LineWidth',2)
datetick('x','mmm')
xlabel('Fecha [meses]','FontSize',14,'FontWeight','bold')
ylabel('Caudal (m3/s)','FontSize',14,'FontWeight','bold')
title(['Caudal promedio diario'],'FontSize',16,'FontWeight','bold')
axis tight
grid on
subplot(1,2,2)
plot(Qclasi,'color',[0.3010 0.7450 0.9330],'LineWidth',2)
title(['Caudales clasificados para 30 años'],'FontSize',16,'FontWeight','bold')
xlabel('N° de dias que se supera el caudal','FontSize',14,'FontWeight','bold')
ylabel('Caudal (m3/s)','FontSize',14,'FontWeight','bold')
axis tight
grid on

% caudal clasificado para un año en especifico 
aa=2002;
dosmildos=find(tiempo(:,1)==2002); %buscamos las posiciones de todos los datos del año 2002
fechasdois=datetime(tiempo(dosmildos,:)); %eztraemos las fechas para ese año
dosmildois=tiempo(dosmildos,:); % en una nueva matriz agregamos las fechas extraidas 
dosmildois(:,7)=value(dosmildos); %agregamos en nuestra matriz del año 2002 los valores de caudal


Qclasidosmildos=sort(dosmildois(:,7),'descend'); %calculamos caudal clasificado 

%en una figura graficamos caudal promedio diario del año 2002 y en otro
%grafico su caudal clasificado 
figure()
subplot(1,2,1)
plot(fechasdois,dosmildois(:,7),'color',[0.4940 0.1840 0.5560],'LineWidth',2)
xlabel('Fechas [Meses]','FontSize',14,'FontWeight','bold')
ylabel('Caudal [m3/s]','FontSize',14,'FontWeight','bold')
title('Caudal para el año 2002','FontSize',16,'FontWeight','bold')
axis tight
grid on
subplot(1,2,2)
plot(Qclasidosmildos,'color',[0.4940 0.1840 0.5560],'LineWidth',2)
title(['Caudales clasificados para el año 2002'],'FontSize',16,'FontWeight','bold')
xlabel('N° de dias que se supera el caudal','FontSize',14,'FontWeight','bold')
ylabel('Caudal (m3/s)','FontSize',14,'FontWeight','bold')
axis tight
grid on


%% Pegunta 2 b)
Qecologico= mean(value)*0.1; % Caudal ecologico, minimo de caudal que debe circular por el rio
Q=media_diaria - Qecologico; 

Q=sort(Q,'descend');
figure(3)
plot(Q,'Color',[0.4660 0.6740 0.1880],'LineWidth',2)
xlabel('N° de dias que se supera el caudal','FontSize',14,'FontWeight','bold')
ylabel('Caudal (m3/s)','FontSize',14,'FontWeight','bold')
title('Caudal de equipamiento','FontSize',16,'FontWeight','bold')
line([0 366], [Qecologico Qecologico])
line([366-80 366-80], [0 max(Q)])
line([366-100 366-100], [0 max(Q)])
axis tight
ylim([0 max(Q)])
text(15,18,'Caudal ecologico')
text((366-75),150,'Q80')
text((366-95),145,'Q100')
grid off

%% Pregunta 2 c)
% Para calculo de la potencia hidromotriz usamos 
Qequipamiento=(Q(366-80)+Q(366-100))/2; 

%Para calculo del potencial hidromotriz 
%H será nuestra pendiente, ocupando google earth calculamos penidnete
%minima y maxima. Hmin= 39m y Hmax= 42 m, restamos max - min para obtener H
H=3;  
Potencia=8.2*Qequipamiento*H; % en Kw
