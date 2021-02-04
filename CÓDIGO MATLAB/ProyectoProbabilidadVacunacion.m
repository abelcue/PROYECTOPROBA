clear all; clc;close all;
tic
DATOSCOVID= readtable('General.csv');
ENFERMEDADES= readtable('Enfermedades.csv');
toc
% FECHA_ACT=(DATOSCOVID(:,1));
% EDAD=(DATOSCOVID(:,16));
% FECHA_DEFUNCION =(DATOSCOVID(:,13));

%% NÚMERO DE MUERTES CONFIRMADAS POR RANGO DE EDADES
NUM_MUERTOS = height(DATOSCOVID)- nnz(ismember(DATOSCOVID.FECHA_DEF, '9999-99-99'));
RANGO_EDADES={0:9,10:19,20:29,30:39,40:49,50:59,60:69,70:150};
NUM_MUERTOS_EDAD=zeros(1,length(RANGO_EDADES));
NUM_CONT_EDAD=zeros(1,length(RANGO_EDADES));

for i=1:length(RANGO_EDADES)
NUM_MUERTOS_EDAD(i)= nnz(ismember(DATOSCOVID.EDAD(ismember(DATOSCOVID.FECHA_DEF, '9999-99-99') == false), RANGO_EDADES{i}));
NUM_CONT_EDAD(i)= nnz(ismember(DATOSCOVID.EDAD,RANGO_EDADES{i}));
end
RE={'0-9','10-19','20-29','30-39','40-49','50-59','60-69','70+'};
Rangos_edad = categorical(RE,RE);
% f=figure('WindowState','fullscreen');
s1=subplot(2,2,1);
s2=subplot(2,2,2);
s3=subplot(2,2,[3 4]);
bar(s1,Rangos_edad,NUM_MUERTOS_EDAD,'k');
set(gca,'FontSize',20)
title(s1,'\fontsize{20}Muertes en la población mexicana');
%DENSIDAD DE MORTALIDAD POR COVID 19 SEGÚN RANGO DE EDADES
Poblacion_RE=[21523328,22000529,19918412,17540189,15023137,11002068,6877071,5559250];

bar(s2,Rangos_edad,Poblacion_RE,'k');
title(s2,'\fontsize{20}Población mexicana por rangos de edades');
set(gca,'FontSize',20)
Muertes_Densidad=NUM_MUERTOS_EDAD./Poblacion_RE;
bar(s3,Rangos_edad,Muertes_Densidad,'r');
set(gca,'FontSize',16)
title(s3,'\fontsize{20}Relación Letalidad/Población de COVID-19 en México por rango de edades');
% sgtitle('\bf{\fontsize{32}Estadisticas del COVID-19 en México}')

%% CURVA DE CONTAGIO POR DÍAS DE LA POBLACIÓN GENERAL

%EXTRACCIÓN DE VECTOR DE DÍAS DESDE EL PRIMER CONTAGIO AL ÚLTIMO REPORTADO
a = datenum({'27-Jan-2020 00:00:00';'24-Jan-2021 0:00:00'});
DIAS_CONTAGIO = datevec(a(1):a(2)); DIAS_CONTAGIO=DIAS_CONTAGIO(:,1:3);
DIAS_CONTAGIO = strcat(num2str(DIAS_CONTAGIO(:,1)),'-',num2str(DIAS_CONTAGIO(:,2)),'-',num2str(DIAS_CONTAGIO(:,3)));
DIAS_CONTAGIO = datetime(DIAS_CONTAGIO,'InputFormat','yyyy-MM-dd');

curva_Contagio=zeros(1,length(DIAS_CONTAGIO));

for cont=1:length(DIAS_CONTAGIO)
    curva_Contagio(cont)= nnz(ismember(DATOSCOVID.FECHA_SINTOMAS, DIAS_CONTAGIO(cont)));
end
%CURVA DE CONTAGIO GENERAL EN MÉXICO HASTA EL 29 DE SEPTIEMBRE DEL 2020
figure()
plot(DIAS_CONTAGIO,curva_Contagio);
%CURVA DE CONTAGIO ACUMULADO EN MÉXICO HASTA EL 29 DE SEPTIEMBRE DEL 2020
figure()
plot(DIAS_CONTAGIO,cumsum(curva_Contagio));

%% CURVAS DE CONTAGIO A TRAVÉS DEL TIEMPO POR EDADES
figure()

CURVA_EDADES_CELL={zeros(1,247),zeros(1,247),zeros(1,247),zeros(1,247),zeros(1,247),zeros(1,247),zeros(1,247),zeros(1,247),zeros(1,247),zeros(1,247),zeros(1,247),zeros(1,247),zeros(1,247),zeros(1,247),zeros(1,247),zeros(1,247),zeros(1,247),zeros(1,247)};
s1=subplot(2,1,1);
s2=subplot(2,1,2);
hold (s1, 'on')
hold (s2, 'on')
for c=1:length(RANGO_EDADES) 
    for cont=1:length(DIAS_CONTAGIO)
        CURVA_EDADES_CELL{c}(cont)= nnz(ismember(DATOSCOVID.FECHA_SINTOMAS(ismember(DATOSCOVID.EDAD,RANGO_EDADES{c}) == true), DIAS_CONTAGIO(cont)));
    end
    if(c==length(RANGO_EDADES))
        plot(s1,DIAS_CONTAGIO,CURVA_EDADES_CELL{c},'c','LineWidth',2);
    else
        plot(s1,DIAS_CONTAGIO,CURVA_EDADES_CELL{c},'LineWidth',2);
    end
    if(c==length(RANGO_EDADES))
        plot(s2,DIAS_CONTAGIO,cumsum(CURVA_EDADES_CELL{c}),'c','LineWidth',2);
    else
    plot(s2,DIAS_CONTAGIO,cumsum(CURVA_EDADES_CELL{c}),'LineWidth',2);
    end
end


leg=legend(Rangos_edad,'Location','EastOutside');

%% SISTEMA DE PUNTAJE PARA COMPLICACIONES DEL COVID-19 SEGÚN GRUPOS DE EDAD

    NEUMONIA= nnz(ismember(DATOSCOVID.NEUMONIA,1));
    NEUMONIA_MUERTE= nnz(ismember(DATOSCOVID.NEUMONIA(ismember(DATOSCOVID.FECHA_DEF,'9999-99-99') == false),1));
    INTUBADOS= nnz(ismember(DATOSCOVID.INTUBADO,1));
    INTUBADOS_MUERTE= nnz(ismember(DATOSCOVID.INTUBADO(ismember(DATOSCOVID.FECHA_DEF,'9999-99-99') == false),1));
    
    PERCENT_NEUMONIA=NEUMONIA_MUERTE/NEUMONIA;
    PERCENT_INTUBADO=INTUBADOS_MUERTE/INTUBADOS;
    
    PERCENT_TOTAL=PERCENT_INTUBADO+PERCENT_NEUMONIA;
    c=1;
    PUNTOS_NEUMONIA=(PERCENT_NEUMONIA/PERCENT_TOTAL)*c;
    PUNTOS_INTUBADO=(PERCENT_INTUBADO/PERCENT_TOTAL)*c;
    
    
    for c=1:length(RANGO_EDADES)
    NEUMONIA(c)= nnz(ismember(DATOSCOVID.NEUMONIA(ismember(DATOSCOVID.EDAD,RANGO_EDADES{c}) == true),1)) *PUNTOS_NEUMONIA;
    INTUBADOS(c)= nnz(ismember(DATOSCOVID.INTUBADO(ismember(DATOSCOVID.EDAD,RANGO_EDADES{c}) == true),1)) * PUNTOS_INTUBADO;

    PUNTOS_COMPLICACIONES(c)= NEUMONIA(c)+INTUBADOS(c);
    end
    
        s1=subplot(2,1,1);
        s2=subplot(2,1,2);

%     datacombined=[PUNTOS_COMPLICACIONES; NUM_CONT_EDAD/5];
%         sgtitle('Sistema de puntaje relativo para complicaciones del COVID-19')
        b2=bar(s2,Rangos_edad,NUM_CONT_EDAD,'r');
        ylabel(s2,'Número de contagios')
        b1=bar(s1,Rangos_edad,PUNTOS_COMPLICACIONES,'b');
        ylabel(s1,'Puntaje relativo')


%% SISTEMA DE PUNTAJE DE COMORBILIDADES SEGÚN GRUPOS DE EDAD
ASMA= nnz(ismember(ENFERMEDADES.ASMA,1));
    ASMA_MUERTE= nnz(ismember(ENFERMEDADES.ASMA(ismember(DATOSCOVID.FECHA_DEF,'9999-99-99') == false),1));
    
    CARD= nnz(ismember(ENFERMEDADES.CARDIOVASCULAR,1));
    CARD_MUERTE= nnz(ismember(ENFERMEDADES.CARDIOVASCULAR(ismember(DATOSCOVID.FECHA_DEF,'9999-99-99') == false),1));
    
    DIABETES= nnz(ismember(ENFERMEDADES.DIABETES,1));
    DIABETES_MUERTE= nnz(ismember(ENFERMEDADES.DIABETES(ismember(DATOSCOVID.FECHA_DEF,'9999-99-99') == false),1));  
    
    EPOC= nnz(ismember(ENFERMEDADES.EPOC,1));
    EPOC_MUERTE= nnz(ismember(ENFERMEDADES.EPOC(ismember(DATOSCOVID.FECHA_DEF,'9999-99-99') == false),1));
    
    HIPERTENSION= nnz(ismember(ENFERMEDADES.HIPERTENSION,1));
    HIPERTENSION_MUERTE= nnz(ismember(ENFERMEDADES.HIPERTENSION(ismember(DATOSCOVID.FECHA_DEF,'9999-99-99') == false),1));
    
    INMUSUPR= nnz(ismember(ENFERMEDADES.INMUSUPR,1));
    INMUSUPR_MUERTE= nnz(ismember(ENFERMEDADES.INMUSUPR(ismember(DATOSCOVID.FECHA_DEF,'9999-99-99') == false),1));
    
    OBESIDAD= nnz(ismember(ENFERMEDADES.OBESIDAD,1));
    OBESIDAD_MUERTE= nnz(ismember(ENFERMEDADES.OBESIDAD(ismember(DATOSCOVID.FECHA_DEF,'9999-99-99') == false),1));
    
    OTRA_COM= nnz(ismember(ENFERMEDADES.OTRA_COM,1));
    OTRA_COM_MUERTE= nnz(ismember(ENFERMEDADES.OTRA_COM(ismember(DATOSCOVID.FECHA_DEF,'9999-99-99') == false),1));
    
    RENAL= nnz(ismember(ENFERMEDADES.RENAL_CRONICA,1));
    RENAL_MUERTE= nnz(ismember(ENFERMEDADES.RENAL_CRONICA(ismember(DATOSCOVID.FECHA_DEF,'9999-99-99') == false),1));
    
    TABAQUISMO= nnz(ismember(ENFERMEDADES.TABAQUISMO,1));
    TABAQUISMO_MUERTE= nnz(ismember(ENFERMEDADES.TABAQUISMO(ismember(DATOSCOVID.FECHA_DEF,'9999-99-99') == false),1));
    
    PERCENT_ASMA=ASMA_MUERTE/ASMA;
    PERCENT_CARD=CARD_MUERTE/CARD;
    PERCENT_DIAB=DIABETES_MUERTE/DIABETES;
    PERCENT_EPOC=EPOC_MUERTE/EPOC;
    PERCENT_HIPERTENSION=HIPERTENSION_MUERTE/HIPERTENSION;
    PERCENT_INMUSUPR=INMUSUPR_MUERTE/INMUSUPR;
    PERCENT_OBESIDAD=OBESIDAD_MUERTE/OBESIDAD;
    PERCENT_OTRA_COM=OTRA_COM_MUERTE/OTRA_COM;
    PERCENT_RENAL=RENAL_MUERTE/RENAL;
    PERCENT_TABAQUISMO=TABAQUISMO_MUERTE/TABAQUISMO;
    
    PERCENT_TOTAL=PERCENT_ASMA+PERCENT_CARD+PERCENT_DIAB+PERCENT_EPOC+PERCENT_HIPERTENSION+PERCENT_INMUSUPR+PERCENT_OBESIDAD+PERCENT_OTRA_COM+PERCENT_RENAL+PERCENT_TABAQUISMO;
    c=1;
    PUNTOS_ASMA=(PERCENT_ASMA/PERCENT_TOTAL)*c;
    PUNTOS_CARD=(PERCENT_CARD/PERCENT_TOTAL)*c;
    PUNTOS_DIAB=(PERCENT_DIAB/PERCENT_TOTAL)*c;
    PUNTOS_EPOC=(PERCENT_EPOC/PERCENT_TOTAL)*c;
    PUNTOS_HIPERTENSION=(PERCENT_HIPERTENSION/PERCENT_TOTAL)*c;
    PUNTOS_INMUSUPR=(PERCENT_INMUSUPR/PERCENT_TOTAL)*c;
    PUNTOS_OBESIDAD=(PERCENT_OBESIDAD/PERCENT_TOTAL)*c;
    PUNTOS_OTRA_COMP=(PERCENT_OTRA_COM/PERCENT_TOTAL)*c;
    PUNTOS_RENAL=(PERCENT_RENAL/PERCENT_TOTAL)*c;
    PUNTOS_TABAQUISMO=(PERCENT_TABAQUISMO/PERCENT_TOTAL)*c;
    
    
    
    for c=1:length(RANGO_EDADES)
    ASMAP(c)= nnz(ismember(ENFERMEDADES.ASMA(ismember(DATOSCOVID.EDAD,RANGO_EDADES{c}) == true),1)) *PUNTOS_ASMA;
    CARDP(c)= nnz(ismember(ENFERMEDADES.CARDIOVASCULAR(ismember(DATOSCOVID.EDAD,RANGO_EDADES{c}) == true),1)) * PUNTOS_CARD;
    DIAB(c)= nnz(ismember(ENFERMEDADES.DIABETES(ismember(DATOSCOVID.EDAD,RANGO_EDADES{c}) == true),1)) *PUNTOS_DIAB;
    EPOCP(c)= nnz(ismember(ENFERMEDADES.EPOC(ismember(DATOSCOVID.EDAD,RANGO_EDADES{c}) == true),1)) *PUNTOS_EPOC;
    HIPER(c)= nnz(ismember(ENFERMEDADES.HIPERTENSION(ismember(DATOSCOVID.EDAD,RANGO_EDADES{c}) == true),1)) *PUNTOS_HIPERTENSION;
    INMU(c)= nnz(ismember(ENFERMEDADES.INMUSUPR(ismember(DATOSCOVID.EDAD,RANGO_EDADES{c}) == true),1)) *PUNTOS_INMUSUPR;
    OBESI(c)= nnz(ismember(ENFERMEDADES.OBESIDAD(ismember(DATOSCOVID.EDAD,RANGO_EDADES{c}) == true),1)) *PUNTOS_OBESIDAD;
    OTRA(c)= nnz(ismember(ENFERMEDADES.OTRA_COM(ismember(DATOSCOVID.EDAD,RANGO_EDADES{c}) == true),1)) *PUNTOS_OTRA_COMP;
    RENALP(c)= nnz(ismember(ENFERMEDADES.RENAL_CRONICA(ismember(DATOSCOVID.EDAD,RANGO_EDADES{c}) == true),1)) *PUNTOS_RENAL;
    TAB(c)= nnz(ismember(ENFERMEDADES.TABAQUISMO(ismember(DATOSCOVID.EDAD,RANGO_EDADES{c}) == true),1)) *PUNTOS_TABAQUISMO;

    PUNTOS_COMPLICACIONES(c)= ASMAP(c)+CARDP(c)+DIAB(c)+EPOCP(c)+HIPER(c)+INMU(c)+OBESI(c)+OTRA(c)+RENALP(c)+TAB(c);
    end
    
        s1=subplot(2,1,1);
        s2=subplot(2,1,2);

%     datacombined=[PUNTOS_COMPLICACIONES; NUM_CONT_EDAD/5];
        %sgtitle('Sistema de puntaje relativo para enfermedades del COVID-19')
        h=bar(s1,Rangos_edad,PUNTOS_COMPLICACIONES,'b');
        %xlabel(s1,'Rangos de edad en la población mexicana');
        ylabel(s1,'Puntaje relativo')
        h=bar(s2,Rangos_edad,NUM_CONT_EDAD,'r');
        xlabel(s2,'Rangos de edad en la población mexicana');
        ylabel('Número de contagiados')
%% MUESTREO SIN REPOSICIÓN PARA PROPUESTA DE VACUNACIÓN
Poblacion_TOTAL = sum(Poblacion_RE);
Probabilidad_muerte = NUM_MUERTOS_EDAD./NUM_CONT_EDAD;
MUERTOS_EDAD = round(Poblacion_RE.*Probabilidad_muerte);
MUERTES = {};
nmuest=0;
nmuest_edad=zeros(1,length(RANGO_EDADES));
    for c=1:length(RANGO_EDADES)
        MUERTES{c}=ones(1,Poblacion_RE(c));
    end

    for c=1:length(RANGO_EDADES)
        p0 = randperm(Poblacion_RE(c),MUERTOS_EDAD(c));
        MUERTES{c}(p0)=2;
    end

Poblacion_post = Poblacion_RE;

nvac=1000000;
    for c=1:length(RANGO_EDADES)
       try while(Probabilidad_muerte(c)>0.04)
           nmuest=nmuest+1;
           p1=randperm(length(MUERTES{c}),nvac);
           MUERTES{c}(p1)=[];
           NEWDEAD = nnz(ismember(MUERTES{c},2));
           Probabilidad_muerte(c) = NEWDEAD/Poblacion_RE(c);
           if(nvac<4000000)
              nvac=nvac+500000;  
           else
               nvac=4000000;
           end
           end
       end
       nmuest_edad(c)=nmuest;
       nmuest=0;
       nvac=500000;
    end

%NMUEST ES NUESTRO NÚMERO ESTIMADO DE MESES (NÚMERO DE MUESTREOS) DE VACUNACIÓN PARA LLEGAR A UNA
%MORTALIDAD EN 1% EN CADA RANGO DE EDAD.
