%% FALTA
% FILTROS OSF Y RE-REFERENCIACION
% AÑADIR GRAFICAS EN FRECUENCIA
% OBTENER PLOTS QUE QUERAMOS PARA LA MEMORIA

%% El codigo es bastante infumable, pero hay mucho bloque repetido. Basicamente:

% Trabajo todo el rato con dos tipos de señales, resampleada a 1200 Hz
% (_1200_) y resampleada a 600 Hz (_600_Hz)
% Poco a poco, voy generado nuevas señales segun las voy filtrando,
% promediando, etc. 
% Todas ellas las guardo en un struct data1200.XX o data1600.XX. Ejemplo:
% data600.avg, data1200..epochs, etc.

% FASES:
% 1º) Resampleo los datos a 1200 y 600 Hz (estan a 2400Hz). Todo el rato
% trabajare con señales distintas a 600 y 1200 Hz

% 2º) Genero los triggers para ambos (para poder hacer los epochs)

% 3º) Divido los datos en dos mitades: 
%   - 1º mitad (epochs 1 al 500): datos validacion   --> Hago epochs
%   - 2º mitad (epochs 501 al 1000):Hago epochs y promedio las
%               500 muestras --> Genero el template para 600 y 1200 Hz

% A partir de este punto, solo trabajare con los primeros 500 epochs:
% 4º) Filtrado temporal (passband y notch) (linea 214 aprox.)

% 5º) Filtrado espacial (de las muestras ya filtradas en tiempo):
% CAR,SLAP,LLAP (linea 254 aprox.)

% 6º) Hago distintos grupos de promedios (3,4,5,25,50...) de epochs aleatorios. Además, tambien
% guardo una version de estos datos normalizados y con smooth. (linea 303
% aprox.)

% 7º) Calculo correlacion entre template y los distintos grupos de
% promedios. (linea 751 aprox.)

% 8º) Pinto correlaciones (linea 890 aprox.). Cada subplot representa para
% una frecuencia y un nº de promediados dado, los resultados para los
% distintos filtros.

% Cabe decir que la correlación no la pinto del pico de interés en
% concreto, si no de toda la muestra (los 400 ms). ¿Introduzco en el script la
% xcorr y así justifico también los picos que mejor detecto?

% Por ultimo, faltaria un ultimo plot. En este plot pintaria el que mejor
% resultado haya dado en cada uno de los plots anteriores para decidir el
% optimo y comparar el efecto de los distintos promediados

%% PROBLEMAS
% LOS AVERAGES DEBEN ESTAR MAL HECHOS
% Asi, las correlaciones que saco son ridiculas. Ademas, no siguen una
% sucesion logica (no sigue: si mas promediados -> mas correlacion, por ejemplo)

% Falta el OSF y el re-reference





%% RECORD PARA 2 Hz, 300 usecs y C3
clear all
% close all
load('JOSE_SS2_PW300_FR2_12mA');
data = data(2:29,:);
%data(14,:) = data(14,:)-mean(data(1:end,:),1);
%data(13,:) = (data(13,:)-mean(data([7 12 14 19],:)));
%data(13,:) = (data(13,:)-mean(data([2 15],:)));

% Tuve que hacer esto, los 15 primeros canales estan desfasados 
% date = []
% for ii=1:17
%     date(end+1,:) = data(ii,521.5:end);
% end
% date2 = []
% for ii=18:32
%     date2(end+1,:) = data(ii,1:end-520.5);
% end
% 
% data = [date;date2];
% plot(data(14,:)), hold on, plot(data(26,:),'r');
warning off;

%% 1º) RESAMPLEO

        % Los triggers estan clavadisimos!!!!!
        % Si cambio datos, hay que hacer que la primera muestra de los datos
        % coincida con la primera del trigger.
        
        
        % RESAMPLEO LOS 32 CANALES Y LOS GUARDO EN UN STRUCT
        eeg_1200 = [];
        data1200.samples = {};
        for ii=1:28
            eeg_1200(ii,:) = downsample(data(ii,34613:123e4),2);
            eeg_1200(ii,:) = eeg_1200(ii,:) - mean(eeg_1200(ii,:));
        end
        data1200.samples = eeg_1200;
      
        eeg_600 = [];
        data600.samples = {};
        for ii=1:28
            eeg_600(ii,:) = downsample(data(ii,36948:123e4),4); 
            eeg_600(ii,:) = eeg_600(ii,:) - mean(eeg_600(ii,:));
        end   
        data600.samples = eeg_600;
        
        % Para el template
%          ref=ref-mean(ref); %la centramos
%         [pks,locs] = findpeaks(ref,'minpeakdistance', 1205); 
%         [pks,locs] = findpeaks(pks,'minpeakheight', 400);
%         v = round(min(pks))-1;
%         k = ref>v;  init=find(k,1);
%         inter = 1207.857;
%         trigger = zeros(1,size(x(30574.5:1201600),2));
%         trigger(init+40:inter:end)= max(ref)*3/4;
        


%% 2º) GENERO EL TRIGGER PARA AMBAS FRECUENCIAS
        % Para 1200
        x_12 = eeg_1200(14,:);
        [pks,locs] = findpeaks(x_12,'minpeakdistance', 602); 
        [pks,locs] = findpeaks(pks,'minpeakheight', 400);
        v = round(min(pks))-1;
        k = x_12>v;  init=find(k,1);
        inter = 1207.857/2;
        trigger_1200 = zeros(1,size(x_12,2));
        trigger_1200(init+40:inter:end)= max(x_12)*3/4;

        
        % Para 600
        x_6 = eeg_600(14,:);
        [pks,locs] = findpeaks(x_6,'minpeakdistance', 300); 
        [pks,locs] = findpeaks(pks,'minpeakheight', 400);
        v = round(min(pks))-1;
        k = x_12>v;  init=find(k,1);
        inter = 1207.859/4;
        trigger_600 = zeros(1,size(x_6,2));
        trigger_600(init+40:inter:end)= max(x_12)*3/4;

        clear init inter ii k locs pks v x_12 x_6;

%         plot(trigger_600), hold on, plot(data600.samples(12,:),'r');
% figure(2), plot(trigger_1200), hold on, plot(data1200.samples(12,:),'r');

   %   trg_locs         = find(trigger>0);     
       trg_locs_600     = find(trigger_600>0);
       trg_locs_1200    = find(trigger_1200>0);
       template_600 = [];
       template_1200 = [];
       
       
%% 3º) EPOCHING

        % HAGO EPOCHS DEL TEMPLATE:
        % Saco el template con los 500 ultimos epochs 
         x=[];
         %for jj = trg_locs_1200(round(length(trg_locs_1200)/2)):trg_locs_1200(end) -1
          for jj=round(length(trg_locs_1200)/2)-2:round(length(trg_locs_1200))-1
                    %eeg_aux_nf = eeg_1200(13,jj+.004*1200:jj+0.4*1200);
                    eeg_aux_nf = eeg_1200(13,trg_locs_1200(jj)+.006*1200:trg_locs_1200(jj)+0.4*1200);
                    eeg_aux_nf = eeg_aux_nf-mean(eeg_aux_nf(.001*1200:0.039*1200));                  
                    template_1200(end+1, :) = eeg_aux_nf;       % todos los epochs
           end;
       
       
          x=[];
         % for jj = trg_locs_600(round(length(trg_locs_600)/2)):trg_locs_600(end) -1
            for jj=round(length(trg_locs_600)/2)-2:round(length(trg_locs_600))-1
                    eeg_aux_nf = eeg_600(13,trg_locs_600(jj)+.006*600:trg_locs_600(jj)+0.4*600);
                    eeg_aux_nf = eeg_aux_nf-mean(eeg_aux_nf(.001*600:0.039*600));                  
                    template_600(end+1, :) = eeg_aux_nf;       % todos los epochs
           end;
                 
       
    % OBTENGO EL GOLD STANDARD (promediando)
       x = template_600(1,:);
       for ii=2:length(template_600(1,:))-1
           x = x + template_600(ii,:);
       end
       data600.template = x./ii;
       % Y tambien saco el smooth normalizado para la correlacion:
       template_600_sm = (smooth(smooth(smooth(x/ii))))';
       data600.template_sm = template_600_sm./norm(template_600_sm);
       data600.Xtemplate = data600.template_sm (70:150);
       
       x = template_1200(1,:);
       for ii=2:length(template_1200(1,:))-1
           x = x + template_1200(ii,:);
       end
        data1200.template = x./ii;
        % Y tambien saco el smooth normalizado para la correlacion:
        template_1200_sm = smooth(smooth(smooth(x/ii)))';
        data1200.template_sm = template_1200_sm./norm(template_1200_sm);
        data1200.Xtemplate = data1200.template_sm (70:150);
        
        
        % HAGO EPOCHS DE  500 PRIMEROS TRIALS PARA CADA CANAL
       % data600.epochs y data 1200.epochs contienen todos los epochs de todos
       % los canales: 
       % - data600.epochs{1,1}: n_epochs x n_samples del canal 1
       % - data600.epochs{1,2}: n_epochs x n_samples del canal 2
       %(...)
       
        % Para 1200
        data1200.epochs = {};
        x=[];
       for ii=1:28
           x = [];
           for jj=1:round(length(trg_locs_1200)/2)-1
                    eeg_aux_nf = eeg_1200(ii,trg_locs_1200(jj)+.0035*1200:trg_locs_1200(jj)+0.4*1200);
                    eeg_aux_nf = eeg_aux_nf-mean(eeg_aux_nf(.001*1200:0.039*1200));                  
                    x(end+1, :) = eeg_aux_nf;       % todos los epochs
           end;
           data1200.epochs{end+1} = x;      %Los guardo en el struct
       end;
       
       % Para 600
       data600.epochs = {};
       x=[];
       for ii=1:28
        x = [];
           for jj=1:round(length(trg_locs_600)/2)-1
                    eeg_aux_nf = [];
                    eeg_aux_nf = eeg_600(ii,trg_locs_600(jj)+.0035*600:trg_locs_600(jj)+0.4*600);
                    eeg_aux_nf = eeg_aux_nf-mean(eeg_aux_nf(.001*600:0.039*600));                  
                    x(end+1, :) = eeg_aux_nf;       % todos los epochs
           end;
           data600.epochs{end+1} = x;
       end;






%% 4º) FILTRO TEMPORAL de 1 a 1000 Hz (probar distintos filtros?)
       
       % FILTRO PASABANDA PARA TODOS LOS CANALES
       [b1200,a1200] = butter(2,[2 90]/600);
       [b600,a600] = butter(2,[2 90]/300);
       
       data1200.Filt = {};
       data600.Filt = {};
       for ii=1:28
           data1200.Filt{end+1} = filtfilt(b1200, a1200, data1200.epochs{:,ii}); %Filtramos todos los epochs de un canal
           data600.Filt{end+1} = filtfilt(b600, a600, data600.epochs{:,ii});        
       end
           
       % FILTRO NOTCH PARA TODOS LOS CANALES
       for ii=1:28
           for ff=50:50:200
               Wo = ff/(1200/2);  BW = Wo/15;        %C=50/15
               [bnotch,anotch] = iirnotch(Wo,BW);
               data1200.Filt{1,ii} = filtfilt(b1200,a1200,data1200.Filt{1,ii});
           end
       end
       
       for ii=1:28
           for ff=50:50:200
               Wo = ff/(600/2);  BW = Wo/15;        %C=50/15
               [bnotch,anotch] = iirnotch(Wo,BW);
               data600.Filt{1,ii} = filtfilt(b600,a600,data600.Filt{1,ii});  
           end
       end
     

       
       

       
       
%% 5º) FILTROS ESPACIALES
       % Todos estos filtros los aplico sobre la señal ya filtrada en el
       % tiempo (notch y passband)
       
% ----> Common Average Reference (CAR)
% Para 1200
       x_1200_filt_CAR = data1200.Filt{1,1};
       for ii=2:28
          x_1200_filt_CAR =  x_1200_filt_CAR + data1200.Filt{1,ii};
       end
       x_1200_filt_CAR = x_1200_filt_CAR./32;
       x_1200_filt_CAR = data1200.Filt{1,13} - x_1200_filt_CAR; 

%        XX = mean(data1200.Filt{:,1},1);
%        for ii=2:28
%          XX =  XX + mean(data1200.Filt{:,ii},1);
%        end
% x_1200_filt_CAR = mean(data1200.Filt{1,13}) - XX; 

% Para 600
        x_600_filt_CAR = data600.Filt{1,1};
       for ii=2:28
           x_600_filt_CAR =  x_600_filt_CAR + data600.Filt{1,ii};
       end
        x_600_filt_CAR = x_600_filt_CAR./32; 
        x_600_filt_CAR = data600.Filt{1,13} - x_600_filt_CAR;
 
%         media = mean(data600.Filt{1,1},1);
%        for ii=2:28
%          media =  media + mean(data600.Filt{1,ii},1);
%        end
%         
%         x_600_filt_CAR = mean(data600.Filt{1,13}) - media; 


       clear ii jj x  x_1200 x_600 x_1200_filt x_600_filt x_6 x_12 eeg_aux_nf;
       
       
% ----> SHORT LAPLACIANO 
       s_channels1200 = (data1200.Filt{1,7}+data1200.Filt{1,14}+data1200.Filt{1,12}+data1200.Filt{1,19})./4;      
       s_channels600 = (data600.Filt{1,7}+data600.Filt{1,14}+data600.Filt{1,12}+data600.Filt{1,19})./4; 
       
       x_1200_filt_SLAP = data1200.Filt{1,13} - s_channels1200; 
       x_600_filt_SLAP = data600.Filt{1,13} - s_channels600;

       
       % -----> LONG LAPLACIANO        
       s_channels1200 = (data1200.Filt{1,2}+data1200.Filt{1,15}+data1200.Filt{1,24})./3;      
       s_channels600 = (data600.Filt{1,2}+data600.Filt{1,15}+data600.Filt{1,24})./3; 
       
       x_1200_filt_LLAP = data1200.Filt{1,13} - s_channels1200; 
       x_600_filt_LLAP = data600.Filt{1,13} - s_channels600;


       
   clear a1200 b1200 a600 b600 ff bnotch anotch BW Wo type_SEP;%s_channels1200;
   %clear s_channels600;
       
       
       
       
       
       
   
%% 6º) GRUPOS DE PROMEDIADOS
     % Cada data.avg contiene 8 cells, cada una de ellas con distintos
     % promediados. Los epochs son seleccionados aleatoriamente de entre 
     % los 1500 primeros epochs:
     % - Celda 1: 3 promediados
     % - Celda 2: 4 promediados
     % - Celda 3: 5 promediados ...
     
     % La primera fila son los avgs normalizados.
     % La segunda fila son los avgs con smooth y normalizados
     
        data600.avg = {};
    [data600.avg{1,1}, data600.avg{2,1}, data600.avg{3,1}] = calculo_promedios(data600.epochs{1,13},3, data600.Xtemplate);  
    [data600.avg{1,2}, data600.avg{2,2}, data600.avg{3,2}] = calculo_promedios(data600.epochs{1,13},4, data600.Xtemplate);
    [data600.avg{1,3}, data600.avg{2,2}, data600.avg{3,3}] = calculo_promedios(data600.epochs{1,13},5, data600.Xtemplate);
    [data600.avg{1,4}, data600.avg{2,4}, data600.avg{3,4}] = calculo_promedios(data600.epochs{1,13},10, data600.Xtemplate);   
    [data600.avg{1,5}, data600.avg{2,5}, data600.avg{3,5}] = calculo_promedios(data600.epochs{1,13},25, data600.Xtemplate);    
    [data600.avg{1,6}, data600.avg{2,6}, data600.avg{3,6}] = calculo_promedios(data600.epochs{1,13},50, data600.Xtemplate);
    [data600.avg{1,7}, data600.avg{2,7}, data600.avg{3,7}] = calculo_promedios(data600.epochs{1,13},150, data600.Xtemplate);
    [data600.avg{1,8}, data600.avg{2,8}, data600.avg{3,8}] = calculo_promedios(data600.epochs{1,13},400, data600.Xtemplate);
 
    
            data1200.avg = {};
    [data1200.avg{1,1}, data1200.avg{2,1}, data1200.avg{3,1}] = calculo_promedios(data1200.epochs{1,13},3, data1200.Xtemplate);  
    [data1200.avg{1,2}, data1200.avg{2,2}, data1200.avg{3,2}] = calculo_promedios(data1200.epochs{1,13},4, data1200.Xtemplate);
    [data1200.avg{1,3}, data1200.avg{2,2}, data1200.avg{3,3}] = calculo_promedios(data1200.epochs{1,13},5, data1200.Xtemplate);
    [data1200.avg{1,4}, data1200.avg{2,4}, data1200.avg{3,4}] = calculo_promedios(data1200.epochs{1,13},10, data1200.Xtemplate);   
    [data1200.avg{1,5}, data1200.avg{2,5}, data1200.avg{3,5}] = calculo_promedios(data1200.epochs{1,13},25, data1200.Xtemplate);    
    [data1200.avg{1,6}, data1200.avg{2,6}, data1200.avg{3,6}] = calculo_promedios(data1200.epochs{1,13},50, data1200.Xtemplate);
    [data1200.avg{1,7}, data1200.avg{2,7}, data1200.avg{3,7}] = calculo_promedios(data1200.epochs{1,13},150, data1200.Xtemplate);
    [data1200.avg{1,8}, data1200.avg{2,8}, data1200.avg{3,8}] = calculo_promedios(data1200.epochs{1,13},400, data1200.Xtemplate);
 
    
    
    % Filtro notch y pasabanda
           data600.avgFilt = {};
    [data600.avgFilt{1,1}, data600.avgFilt{2,1}, data600.avgFilt{3,1}] = calculo_promedios(data600.Filt{1,13},3, data600.Xtemplate);  
    [data600.avgFilt{1,2}, data600.avgFilt{2,2}, data600.avgFilt{3,2}] = calculo_promedios(data600.Filt{1,13},4, data600.Xtemplate);
    [data600.avgFilt{1,3}, data600.avgFilt{2,2}, data600.avgFilt{3,3}] = calculo_promedios(data600.Filt{1,13},5, data600.Xtemplate);
    [data600.avgFilt{1,4}, data600.avgFilt{2,4}, data600.avgFilt{3,4}] = calculo_promedios(data600.Filt{1,13},10, data600.Xtemplate);   
    [data600.avgFilt{1,5}, data600.avgFilt{2,5}, data600.avgFilt{3,5}] = calculo_promedios(data600.Filt{1,13},25, data600.Xtemplate);    
    [data600.avgFilt{1,6}, data600.avgFilt{2,6}, data600.avgFilt{3,6}] = calculo_promedios(data600.Filt{1,13},50, data600.Xtemplate);
    [data600.avgFilt{1,7}, data600.avgFilt{2,7}, data600.avgFilt{3,7}] = calculo_promedios(data600.Filt{1,13},150, data600.Xtemplate);
    [data600.avgFilt{1,8}, data600.avgFilt{2,8}, data600.avgFilt{3,8}] = calculo_promedios(data600.Filt{1,13},400, data600.Xtemplate);
 
    
            data1200.avgFilt = {};
    [data1200.avgFilt{1,1}, data1200.avgFilt{2,1}, data1200.avgFilt{3,1}] = calculo_promedios(data1200.Filt{1,13},3, data1200.Xtemplate);  
    [data1200.avgFilt{1,2}, data1200.avgFilt{2,2}, data1200.avgFilt{3,2}] = calculo_promedios(data1200.Filt{1,13},4, data1200.Xtemplate);
    [data1200.avgFilt{1,3}, data1200.avgFilt{2,2}, data1200.avgFilt{3,3}] = calculo_promedios(data1200.Filt{1,13},5, data1200.Xtemplate);
    [data1200.avgFilt{1,4}, data1200.avgFilt{2,4}, data1200.avgFilt{3,4}] = calculo_promedios(data1200.Filt{1,13},10, data1200.Xtemplate);   
    [data1200.avgFilt{1,5}, data1200.avgFilt{2,5}, data1200.avgFilt{3,5}] = calculo_promedios(data1200.Filt{1,13},25, data1200.Xtemplate);    
    [data1200.avgFilt{1,6}, data1200.avgFilt{2,6}, data1200.avgFilt{3,6}] = calculo_promedios(data1200.Filt{1,13},50, data1200.Xtemplate);
    [data1200.avgFilt{1,7}, data1200.avgFilt{2,7}, data1200.avgFilt{3,7}] = calculo_promedios(data1200.Filt{1,13},150, data1200.Xtemplate);
    [data1200.avgFilt{1,8}, data1200.avgFilt{2,8}, data1200.avgFilt{3,8}] = calculo_promedios(data1200.Filt{1,13},400, data1200.Xtemplate);
    
 
    
    
    
    % Filtro CAR
                  data600.avgCAR = {};
    [data600.avgCAR{1,1}, data600.avgCAR{2,1}, data600.avgCAR{3,1}] = calculo_promedios(x_600_filt_CAR,3, data600.Xtemplate);  
    [data600.avgCAR{1,2}, data600.avgCAR{2,2}, data600.avgCAR{3,2}] = calculo_promedios(x_600_filt_CAR,4, data600.Xtemplate);
    [data600.avgCAR{1,3}, data600.avgCAR{2,2}, data600.avgCAR{3,3}] = calculo_promedios(x_600_filt_CAR,5, data600.Xtemplate);
    [data600.avgCAR{1,4}, data600.avgCAR{2,4}, data600.avgCAR{3,4}] = calculo_promedios(x_600_filt_CAR,10, data600.Xtemplate);   
    [data600.avgCAR{1,5}, data600.avgCAR{2,5}, data600.avgCAR{3,5}] = calculo_promedios(x_600_filt_CAR,25, data600.Xtemplate);    
    [data600.avgCAR{1,6}, data600.avgCAR{2,6}, data600.avgCAR{3,6}] = calculo_promedios(x_600_filt_CAR,50, data600.Xtemplate);
    [data600.avgCAR{1,7}, data600.avgCAR{2,7}, data600.avgCAR{3,7}] = calculo_promedios(x_600_filt_CAR,150, data600.Xtemplate);
    [data600.avgCAR{1,8}, data600.avgCAR{2,8}, data600.avgCAR{3,8}] = calculo_promedios(x_600_filt_CAR,400, data600.Xtemplate);
 
    
            data1200.avgCAR = {};
    [data1200.avgCAR{1,1}, data1200.avgCAR{2,1}, data1200.avgCAR{3,1}] = calculo_promedios(x_1200_filt_CAR,3, data1200.Xtemplate);  
    [data1200.avgCAR{1,2}, data1200.avgCAR{2,2}, data1200.avgCAR{3,2}] = calculo_promedios(x_1200_filt_CAR,4, data1200.Xtemplate);
    [data1200.avgCAR{1,3}, data1200.avgCAR{2,2}, data1200.avgCAR{3,3}] = calculo_promedios(x_1200_filt_CAR,5, data1200.Xtemplate);
    [data1200.avgCAR{1,4}, data1200.avgCAR{2,4}, data1200.avgCAR{3,4}] = calculo_promedios(x_1200_filt_CAR,10, data1200.Xtemplate);   
    [data1200.avgCAR{1,5}, data1200.avgCAR{2,5}, data1200.avgCAR{3,5}] = calculo_promedios(x_1200_filt_CAR,25, data1200.Xtemplate);    
    [data1200.avgCAR{1,6}, data1200.avgCAR{2,6}, data1200.avgCAR{3,6}] = calculo_promedios(x_1200_filt_CAR,50, data1200.Xtemplate);
    [data1200.avgCAR{1,7}, data1200.avgCAR{2,7}, data1200.avgCAR{3,7}] = calculo_promedios(x_1200_filt_CAR,150, data1200.Xtemplate);
    [data1200.avgCAR{1,8}, data1200.avgCAR{2,8}, data1200.avgCAR{3,8}] = calculo_promedios(x_1200_filt_CAR,400, data1200.Xtemplate);
    
    
    
    
    % Filtro SLAP
       data600.avgSLAP = {};
    [data600.avgSLAP{1,1}, data600.avgSLAP{2,1}, data600.avgSLAP{3,1}] = calculo_promedios(x_600_filt_SLAP,3, data600.Xtemplate);  
    [data600.avgSLAP{1,2}, data600.avgSLAP{2,2}, data600.avgSLAP{3,2}] = calculo_promedios(x_600_filt_SLAP,4, data600.Xtemplate);
    [data600.avgSLAP{1,3}, data600.avgSLAP{2,2}, data600.avgSLAP{3,3}] = calculo_promedios(x_600_filt_SLAP,5, data600.Xtemplate);
    [data600.avgSLAP{1,4}, data600.avgSLAP{2,4}, data600.avgSLAP{3,4}] = calculo_promedios(x_600_filt_SLAP,10, data600.Xtemplate);   
    [data600.avgSLAP{1,5}, data600.avgSLAP{2,5}, data600.avgSLAP{3,5}] = calculo_promedios(x_600_filt_SLAP,25, data600.Xtemplate);    
    [data600.avgSLAP{1,6}, data600.avgSLAP{2,6}, data600.avgSLAP{3,6}] = calculo_promedios(x_600_filt_SLAP,50, data600.Xtemplate);
    [data600.avgSLAP{1,7}, data600.avgSLAP{2,7}, data600.avgSLAP{3,7}] = calculo_promedios(x_600_filt_SLAP,150, data600.Xtemplate);
    [data600.avgSLAP{1,8}, data600.avgSLAP{2,8}, data600.avgSLAP{3,8}] = calculo_promedios(x_600_filt_SLAP,400, data600.Xtemplate);
 
    
            data1200.avgSLAP = {};
    [data1200.avgSLAP{1,1}, data1200.avgSLAP{2,1}, data1200.avgSLAP{3,1}] = calculo_promedios(x_1200_filt_SLAP,3, data1200.Xtemplate);  
    [data1200.avgSLAP{1,2}, data1200.avgSLAP{2,2}, data1200.avgSLAP{3,2}] = calculo_promedios(x_1200_filt_SLAP,4, data1200.Xtemplate);
    [data1200.avgSLAP{1,3}, data1200.avgSLAP{2,2}, data1200.avgSLAP{3,3}] = calculo_promedios(x_1200_filt_SLAP,5, data1200.Xtemplate);
    [data1200.avgSLAP{1,4}, data1200.avgSLAP{2,4}, data1200.avgSLAP{3,4}] = calculo_promedios(x_1200_filt_SLAP,10, data1200.Xtemplate);   
    [data1200.avgSLAP{1,5}, data1200.avgSLAP{2,5}, data1200.avgSLAP{3,5}] = calculo_promedios(x_1200_filt_SLAP,25, data1200.Xtemplate);    
    [data1200.avgSLAP{1,6}, data1200.avgSLAP{2,6}, data1200.avgSLAP{3,6}] = calculo_promedios(x_1200_filt_SLAP,50, data1200.Xtemplate);
    [data1200.avgSLAP{1,7}, data1200.avgSLAP{2,7}, data1200.avgSLAP{3,7}] = calculo_promedios(x_1200_filt_SLAP,150, data1200.Xtemplate);
    [data1200.avgSLAP{1,8}, data1200.avgSLAP{2,8}, data1200.avgSLAP{3,8}] = calculo_promedios(x_1200_filt_SLAP,400, data1200.Xtemplate);

       
    
    % Filtro LLAP
                      data600.avgLLAP = {};
    [data600.avgLLAP{1,1}, data600.avgLLAP{2,1}, data600.avgLLAP{3,1}] = calculo_promedios(x_600_filt_LLAP,3, data600.Xtemplate);  
    [data600.avgLLAP{1,2}, data600.avgLLAP{2,2}, data600.avgLLAP{3,2}] = calculo_promedios(x_600_filt_LLAP,4, data600.Xtemplate);
    [data600.avgLLAP{1,3}, data600.avgLLAP{2,2}, data600.avgLLAP{3,3}] = calculo_promedios(x_600_filt_LLAP,5, data600.Xtemplate);
    [data600.avgLLAP{1,4}, data600.avgLLAP{2,4}, data600.avgLLAP{3,4}] = calculo_promedios(x_600_filt_LLAP,10, data600.Xtemplate);   
    [data600.avgLLAP{1,5}, data600.avgLLAP{2,5}, data600.avgLLAP{3,5}] = calculo_promedios(x_600_filt_LLAP,25, data600.Xtemplate);    
    [data600.avgLLAP{1,6}, data600.avgLLAP{2,6}, data600.avgLLAP{3,6}] = calculo_promedios(x_600_filt_LLAP,50, data600.Xtemplate);
    [data600.avgLLAP{1,7}, data600.avgLLAP{2,7}, data600.avgLLAP{3,7}] = calculo_promedios(x_600_filt_LLAP,150, data600.Xtemplate);
    [data600.avgLLAP{1,8}, data600.avgLLAP{2,8}, data600.avgLLAP{3,8}] = calculo_promedios(x_600_filt_LLAP,400, data600.Xtemplate);
 
    
            data1200.avgLLAP = {};
    [data1200.avgLLAP{1,1}, data1200.avgLLAP{2,1}, data1200.avgLLAP{3,1}] = calculo_promedios(x_1200_filt_LLAP,3, data1200.Xtemplate);  
    [data1200.avgLLAP{1,2}, data1200.avgLLAP{2,2}, data1200.avgLLAP{3,2}] = calculo_promedios(x_1200_filt_LLAP,4, data1200.Xtemplate);
    [data1200.avgLLAP{1,3}, data1200.avgLLAP{2,2}, data1200.avgLLAP{3,3}] = calculo_promedios(x_1200_filt_LLAP,5, data1200.Xtemplate);
    [data1200.avgLLAP{1,4}, data1200.avgLLAP{2,4}, data1200.avgLLAP{3,4}] = calculo_promedios(x_1200_filt_LLAP,10, data1200.Xtemplate);   
    [data1200.avgLLAP{1,5}, data1200.avgLLAP{2,5}, data1200.avgLLAP{3,5}] = calculo_promedios(x_1200_filt_LLAP,25, data1200.Xtemplate);    
    [data1200.avgLLAP{1,6}, data1200.avgLLAP{2,6}, data1200.avgLLAP{3,6}] = calculo_promedios(x_1200_filt_LLAP,50, data1200.Xtemplate);
    [data1200.avgLLAP{1,7}, data1200.avgLLAP{2,7}, data1200.avgLLAP{3,7}] = calculo_promedios(x_1200_filt_LLAP,150, data1200.Xtemplate);
    [data1200.avgLLAP{1,8}, data1200.avgLLAP{2,8}, data1200.avgLLAP{3,8}] = calculo_promedios(x_1200_filt_LLAP,400, data1200.Xtemplate);
       
    
    

%% 8º) CORRELACIONES TEMPLATE - AVERAGES (con SMOOTH y NORMALIZATION)
       %% 3 averages:
  % - 600
       r_600_3 = corr(data600.Xtemplate',data600.avg{3,1}');
       r_600_filt_3 = corr(data600.Xtemplate',data600.avgFilt{3,1}');
       r_600_filt_slap_3 = corr(data600.Xtemplate',data600.avgSLAP{3,1}');
       r_600_filt_llap_3 = corr(data600.Xtemplate',data600.avgLLAP{3,1}');
       r_600_filt_CAR_3 = corr(data600.Xtemplate',data600.avgCAR{3,1}');

   

     % - 1200
       r_1200_3 = corr(data1200.Xtemplate',data1200.avg{3,1}');
       r_1200_filt_3 = corr(data1200.Xtemplate',data1200.avgFilt{3,1}');
       r_1200_filt_slap_3 = corr(data1200.Xtemplate',data1200.avgSLAP{3,1}');
       r_1200_filt_llap_3 = corr(data1200.Xtemplate',data1200.avgLLAP{3,1}');
       r_1200_filt_CAR_3 = corr(data1200.Xtemplate',data1200.avgCAR{3,1}');


    %% 4 AVERAGES
     % - 600
       r_600_4 = corr(data600.Xtemplate',data600.avg{3,2}');
       r_600_filt_4 = corr(data600.Xtemplate',data600.avgFilt{3,2}');
       r_600_filt_slap_4 = corr(data600.Xtemplate',data600.avgSLAP{3,2}');
       r_600_filt_llap_4 = corr(data600.Xtemplate',data600.avgLLAP{3,2}');
       r_600_filt_CAR_4 = corr(data600.Xtemplate',data600.avgCAR{3,2}');

     % - 1200
       r_1200_4 = corr(data1200.Xtemplate',data1200.avg{3,2}');
       r_1200_filt_4 = corr(data1200.Xtemplate',data1200.avgFilt{3,2}');
       r_1200_filt_slap_4 = corr(data1200.Xtemplate',data1200.avgSLAP{3,2}');
       r_1200_filt_llap_4 = corr(data1200.Xtemplate',data1200.avgLLAP{3,2}');
       r_1200_filt_CAR_4 = corr(data1200.Xtemplate',data1200.avgCAR{3,2}');


    %% 5 AVERAGES
     % - 600
     tic
       r_600_5 = corr(data600.Xtemplate',data600.avg{3,3}');
       r_600_filt_5 = corr(data600.Xtemplate',data600.avgFilt{3,3}');
       r_600_filt_slap_5 = corr(data600.Xtemplate',data600.avgSLAP{3,3}');
       r_600_filt_llap_5 = corr(data600.Xtemplate',data600.avgLLAP{3,3}');
       r_600_filt_CAR_5 = corr(data600.Xtemplate',data600.avgCAR{3,3}');

     % - 1200
       r_1200_5 = corr(data1200.Xtemplate',data1200.avg{3,3}');
       r_1200_filt_5 = corr(data1200.Xtemplate',data1200.avgFilt{3,3}');
       r_1200_filt_slap_5 = corr(data1200.Xtemplate',data1200.avgSLAP{3,3}');
       r_1200_filt_llap_5 = corr(data1200.Xtemplate',data1200.avgLLAP{3,3}');
       r_1200_filt_CAR_5 = corr(data1200.Xtemplate',data1200.avgCAR{3,3}');

    %% 10 AVERAGES
     % - 600
       r_600_10 = corr(data600.Xtemplate',data600.avg{3,4}');
       r_600_filt_10 = corr(data600.Xtemplate',data600.avgFilt{3,4}');
       r_600_filt_slap_10 = corr(data600.Xtemplate',data600.avgSLAP{3,4}');
       r_600_filt_llap_10 = corr(data600.Xtemplate',data600.avgLLAP{3,4}');
       r_600_filt_CAR_10 = corr(data600.Xtemplate',data600.avgCAR{3,4}');

       
     % - 1200
       r_1200_10 = corr(data1200.Xtemplate',data1200.avg{3,4}');
       r_1200_filt_10 = corr(data1200.Xtemplate',data1200.avgFilt{3,4}');
       r_1200_filt_slap_10 = corr(data1200.Xtemplate',data1200.avgSLAP{3,4}');
       r_1200_filt_llap_10 = corr(data1200.Xtemplate',data1200.avgLLAP{3,4}');
       r_1200_filt_CAR_10 = corr(data1200.Xtemplate',data1200.avgCAR{3,4}');


           %% 25 AVERAGES
     % - 600
       r_600_25 = corr(data600.Xtemplate',data600.avg{3,5}');
       r_600_filt_25 = corr(data600.Xtemplate',data600.avgFilt{3,5}');
       r_600_filt_slap_25 = corr(data600.Xtemplate',data600.avgSLAP{3,5}');
       r_600_filt_llap_25 = corr(data600.Xtemplate',data600.avgLLAP{3,5}');
       r_600_filt_CAR_25 = corr(data600.Xtemplate',data600.avgCAR{3,5}');
       
     % - 1200
       r_1200_25 = corr(data1200.Xtemplate',data1200.avg{3,5}');
       r_1200_filt_25 = corr(data1200.Xtemplate',data1200.avgFilt{3,5}');
       r_1200_filt_slap_25 = corr(data1200.Xtemplate',data1200.avgSLAP{3,5}');
       r_1200_filt_llap_25 = corr(data1200.Xtemplate',data1200.avgLLAP{3,5}');
       r_1200_filt_CAR_25 = corr(data1200.Xtemplate',data1200.avgCAR{3,5}');

       
       
           %% 50 AVERAGES
     % - 600
       r_600_50 = corr(data600.Xtemplate',data600.avg{3,6}');
       r_600_filt_50 = corr(data600.Xtemplate',data600.avgFilt{3,6}');
       r_600_filt_slap_50 = corr(data600.Xtemplate',data600.avgSLAP{3,6}');
       r_600_filt_llap_50 = corr(data600.Xtemplate',data600.avgLLAP{3,6}');
       r_600_filt_CAR_50 = corr(data600.Xtemplate',data600.avgCAR{3,6}');
       
     % - 1200
       r_1200_50 = corr(data1200.Xtemplate',data1200.avg{3,6}');
       r_1200_filt_50 = corr(data1200.Xtemplate',data1200.avgFilt{3,6}');
       r_1200_filt_slap_50 = corr(data1200.Xtemplate',data1200.avgSLAP{3,6}');
       r_1200_filt_llap_50 = corr(data1200.Xtemplate',data1200.avgLLAP{3,6}');
       r_1200_filt_CAR_50 = corr(data1200.Xtemplate',data1200.avgCAR{3,6}');
       
       
       
           %% 150 AVERAGES
     % - 600
       r_600_150 = corr(data600.Xtemplate',data600.avg{3,7}');
       r_600_filt_150 = corr(data600.Xtemplate',data600.avgFilt{3,7}');
       r_600_filt_slap_150 = corr(data600.Xtemplate',data600.avgSLAP{3,7}');
       r_600_filt_llap_150 = corr(data600.Xtemplate',data600.avgLLAP{3,7}');
       r_600_filt_CAR_150 = corr(data600.Xtemplate',data600.avgCAR{3,7}');
       
     % - 1200
       r_1200_150 = corr(data1200.Xtemplate',data1200.avg{3,7}');
       r_1200_filt_150 = corr(data1200.Xtemplate',data1200.avgFilt{3,7}');
       r_1200_filt_slap_150 = corr(data1200.Xtemplate',data1200.avgSLAP{3,7}');
       r_1200_filt_llap_150 = corr(data1200.Xtemplate',data1200.avgLLAP{3,7}');
       r_1200_filt_CAR_150 = corr(data1200.Xtemplate',data1200.avgCAR{3,7}');
       
       
           %% 400 AVERAGES
     % - 600
       r_600_400 = corr(data600.Xtemplate',data600.avg{3,8}');
       r_600_filt_400 = corr(data600.Xtemplate',data600.avgFilt{3,8}');
       r_600_filt_slap_400 = corr(data600.Xtemplate',data600.avgSLAP{3,8}');
       r_600_filt_llap_400 = corr(data600.Xtemplate',data600.avgLLAP{3,8}');
       r_600_filt_CAR_400 = corr(data600.Xtemplate',data600.avgCAR{3,8}');

       
     % - 1200
       r_1200_400 = corr(data1200.Xtemplate',data1200.avg{3,8}');
       r_1200_filt_400 = corr(data1200.Xtemplate',data1200.avgFilt{3,8}');
       r_1200_filt_slap_400 = corr(data1200.Xtemplate',data1200.avgSLAP{3,8}');
       r_1200_filt_llap_400 = corr(data1200.Xtemplate',data1200.avgLLAP{3,8}');
       r_1200_filt_CAR_400 = corr(data1200.Xtemplate',data1200.avgCAR{3,8}');      
       
       
       
       
       
       
       
  %% 8º) Pintar correlacion
       % Represento en cada plot todas las opciones para cada subgrupos de promediados. 
       % Después, pinto otra correlación con la mejor opcion de cada
       % plot de los anteriores para quedarme con el optimo. 
       
       %% 3 AVERAGES
            % 600 
%             figure(1);
% t = linspace(1,4150,length(r_600_3));  %% poner bien
% subplot(121);
% plot(t,r_600_3,'.',t,r_600_filt_3,'o',t,r_600_filt_slap_3,'x',t,r_600_filt_llap_3,'*',t,r_600_filt_CAR_3,'+');%t,r_600_filt_OSF,'--',t,r_600_filt_ref,'go');
% legend('600','filtrado','laplaciano','long laplaciano','CAR');%,'OSF','Re-referenced');
% title('600 Hz - avg'), hold on;
% 
%             % 1200
%        t = linspace(1,4150,length(r_1200_4));  %% poner bien
% subplot(122);
% plot(t,r_1200_4,'.',t,r_1200_filt_4,'o',t,r_1200_filt_slap_4,'x',t,r_1200_filt_llap_4,'*',t,r_1200_filt_CAR_4,'+');%t,r_1200_filt_OSF,'--',t,r_1200_filt_ref,'go');
% legend('1200','filtrado','laplaciano','long laplaciano','CAR');%,'OSF','Re-referenced');
% title('1200 Hz - 3 avg'), hold on;  
% 
% 
%        %% 4 AVERAGES
%             % 600 
%             figure(2);
% t = linspace(1,450,length(r_600_4));  %% poner bien
% subplot(121);
% plot(t,r_600_4,'.',t,r_600_filt_4,'o',t,r_600_filt_slap_4,'x',t,r_600_filt_llap_4,'*',t,r_600_filt_CAR_4,'+');%t,r_600_filt_OSF,'--',t,r_600_filt_ref,'go');
% legend('600','filtrado','laplaciano','long laplaciano','CAR');%,'OSF','Re-referenced');
% title('600 Hz - 4 avg'), hold on;
% 
%             % 1200
%        t = linspace(1,450,length(r_1200_4));  %% poner bien
% subplot(122);
% plot(t,r_1200_4,'.',t,r_1200_filt_4,'o',t,r_1200_filt_slap_4,'x',t,r_1200_filt_llap_4,'*',t,r_1200_filt_CAR_4,'+');%t,r_1200_filt_OSF,'--',t,r_1200_filt_ref,'go');
% legend('1200','filtrado','laplaciano','long laplaciano','CAR');%,'OSF','Re-referenced');
% title('1200 Hz - 4 avg'), hold on; 
% 
%        %% 5 AVERAGES
%             % 600 
%             figure(3);
% t = linspace(1,450,length(r_600_5));  %% poner bien
% subplot(121);
% plot(t,r_600_5,'.',t,r_600_filt_5,'o',t,r_600_filt_slap_5,'x',t,r_600_filt_llap_5,'*',t,r_600_filt_CAR_5,'+');%t,r_600_filt_OSF,'--',t,r_600_filt_ref,'go');
% legend('600','filtrado','laplaciano','long laplaciano','CAR');%,'OSF','Re-referenced');
% title('600 Hz - 5 avg'), hold on;
% 
%             % 1200
%        t = linspace(1,450,length(r_1200_5));  %% poner bien
% subplot(122);
% plot(t,r_1200_5,'.',t,r_1200_filt_5,'o',t,r_1200_filt_slap_5,'x',t,r_1200_filt_llap_5,'*',t,r_1200_filt_CAR_5,'+');%t,r_1200_filt_OSF,'--',t,r_1200_filt_ref,'go');
% legend('1200','filtrado','laplaciano','long laplaciano','CAR');%,'OSF','Re-referenced');
% title('1200 Hz - 5 avg'), hold on; 
% 
%        %% 10 AVERAGES
%             % 600 
%             figure(4);
% t = linspace(1,450,length(r_600_10));  %% poner bien
% subplot(121);
% plot(t,r_600_10,'.',t,r_600_filt_10,'o',t,r_600_filt_slap_10,'x',t,r_600_filt_llap_10,'*',t,r_600_filt_CAR_10,'+');%t,r_600_filt_OSF,'--',t,r_600_filt_ref,'go');
% legend('600','filtrado','laplaciano','long laplaciano','CAR');%,'OSF','Re-referenced');
% title('600 Hz- 10 avg'), hold on;
% 
%             % 1200
%        t = linspace(1,450,length(r_1200_10));  %% poner bien
% subplot(122);
% plot(t,r_1200_10,'.',t,r_1200_filt_10,'o',t,r_1200_filt_slap_10,'x',t,r_1200_filt_llap_10,'*',t,r_1200_filt_CAR_10,'+');%t,r_1200_filt_OSF,'--',t,r_1200_filt_ref,'go');
% legend('1200','filtrado','laplaciano','long laplaciano','CAR');%,'OSF','Re-referenced');
% title('1200 Hz - 10 avg'), hold on; 
% 
% 
%        %% 25 AVERAGES
%             % 600 
%             figure(5);
% t = linspace(1,450,length(r_600_25));  %% poner bien
% subplot(121);
% plot(t,r_600_25,'.',t,r_600_filt_25,'o',t,r_600_filt_slap_25,'x',t,r_600_filt_llap_25,'*',t,r_600_filt_CAR_25,'+');%t,r_600_filt_OSF,'--',t,r_600_filt_ref,'go');
% legend('600','filtrado','laplaciano','long laplaciano','CAR');%,'OSF','Re-referenced');
% title('600 Hz - 25 avg'), hold on;
% 
%             % 1200
%        t = linspace(1,450,length(r_1200_25));  %% poner bien
% subplot(122);
% plot(t,r_1200_25,'.',t,r_1200_filt_25,'o',t,r_1200_filt_slap_25,'x',t,r_1200_filt_llap_25,'*',t,r_1200_filt_CAR_25,'+');%t,r_1200_filt_OSF,'--',t,r_1200_filt_ref,'go');
% legend('1200','filtrado','laplaciano','long laplaciano','CAR');%,'OSF','Re-referenced');
% title('1200 Hz - 25 avg'), hold on; 
% 
% 
%        %% 50 AVERAGES
%             % 600 
%             figure(6);
% t = linspace(1,450,length(r_600_50));  %% poner bien
% subplot(121);
% plot(t,r_600_50,'.',t,r_600_filt_50,'o',t,r_600_filt_slap_50,'x',t,r_600_filt_llap_50,'*',t,r_600_filt_CAR_50,'+');%t,r_600_filt_OSF,'--',t,r_600_filt_ref,'go');
% legend('600','filtrado','laplaciano','long laplaciano','CAR');%,'OSF','Re-referenced');
% title('600 Hz- 50 avg'), hold on;
% 
%             % 1200
%        t = linspace(1,450,length(r_1200_50));  %% poner bien
% subplot(122);
% plot(t,r_1200_50,'.',t,r_1200_filt_50,'o',t,r_1200_filt_slap_50,'x',t,r_1200_filt_llap_50,'*',t,r_1200_filt_CAR_50,'+');%t,r_1200_filt_OSF,'--',t,r_1200_filt_ref,'go');
% legend('1200','filtrado','laplaciano','long laplaciano','CAR');%,'OSF','Re-referenced');
% title('1200 Hz - 50 avg'), hold on; 
% 
% 
%        %% 150 AVERAGES
%             % 600 
%             figure(7);
% t = linspace(1,450,length(r_600_150));  %% poner bien
% subplot(121);
% plot(t,r_600_150,'.',t,r_600_filt_150,'o',t,r_600_filt_slap_150,'x',t,r_600_filt_llap_150,'*',t,r_600_filt_CAR_150,'+');%t,r_600_filt_OSF,'--',t,r_600_filt_ref,'go');
% legend('600','filtrado','laplaciano','long laplaciano','CAR');%,'OSF','Re-referenced');
% title('600 Hz - 150 avg'), hold on;
% 
%             % 1200
% t = linspace(1,450,length(r_1200_150));  %% poner bien
% subplot(122);
% plot(t,r_1200_150,'.',t,r_1200_filt_150,'o',t,r_1200_filt_slap_150,'x',t,r_1200_filt_llap_150,'*',t,r_1200_filt_CAR_150,'+');%t,r_1200_filt_OSF,'--',t,r_1200_filt_ref,'go');
% legend('1200','filtrado','laplaciano','long laplaciano','CAR');%,'OSF','Re-referenced');
% title('1200 Hz - 150 avg'), hold on; 
% 
% 
%        %% 400 AVERAGES
%             % 600 
%             figure(8);
% t = linspace(1,450,length(r_600_400));  %% poner bien
% subplot(121);
% plot(t,r_600_400,'.',t,r_600_filt_400,'o',t,r_600_filt_slap_400,'x',t,r_600_filt_llap_400,'*',t,r_600_filt_CAR_400,'+');%t,r_600_filt_OSF,'--',t,r_600_filt_ref,'go');
% legend('600','filtrado','laplaciano','long laplaciano','CAR');%,'OSF','Re-referenced');
% title('600 Hz - 400 avg'), hold on;
% 
%             % 1200
%       t = linspace(1,450,length(r_1200_400));  %% poner bien
% subplot(122);
% plot(t,r_1200_400,'.',t,r_1200_filt_400,'o',t,r_1200_filt_slap_400,'x',t,r_1200_filt_llap_400,'*',t,r_1200_filt_CAR_400,'+');%t,r_1200_filt_OSF,'--',t,r_1200_filt_ref,'go');
% legend('1200','filtrado','laplaciano','long laplaciano','CAR');%,'OSF','Re-referenced');
% title('1200 Hz - 400 avg'), hold on; 

