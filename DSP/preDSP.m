
function preDSP(data,freq,freq_sampl)

% preDSP(datos,freq,freq_sampl) 
%   datos = datos adquiridos
%   freq = freq de los estimulos (2, 4 o 6)
%   freq_sampl = a la que queremos resamplear (600)

close all
warning off;

    % El FES estimula a frecuencia constante pero no lo hace a 4 o 2 Hz
    % exactamente. Hay una pequeña deriva en frecuencia. 

    % A una frecuencia de muestreo Fs=2400Hz (4.1667e-4 seg/muestra)
        % Ts=1/Fs;      T_stimulus/Ts=triggers  
        % Ideal:
        %   Para 2HZ (1 pulso cada 500 ms) --> 1 trigger cada 1200 datos
        %   Para 4Hz (1 pulso cada 250 ms) --> 1 trigger cada 600 datos

        % Real:
        %   2 Hz --> 1.986935 Hz (1 stimulo cada 503.287 ms) --> cada 1205.3597
        %   datos
        %   4 Hz --> 3.97387178 Hz (1 stimulo cada 251.64375 ms) --> cada 603.945 datos

     %% RESAMPLEO
       display('Resampleando...')     
       n=2400/freq_sampl;     
       
       for i=1:34
            datos(i,:)=downsample(data(i,:),n);
       end
       
        %% SINCRO TRIGGER-SIGNAL
display('Calculando trigger');
   switch freq
        case 2
    % Para 2 Hz
        x = datos;
        ref = x(20,1000:end); ref=ref-mean(ref); %la centramos
        [pks,locs] = findpeaks(ref,'minpeakdistance', 1205); 
        [pks,locs] = findpeaks(pks,'minpeakheight', 400);
        v = round(min(pks))-1;
        k = ref>v;  init=find(k,1);
        inter = 1207.87/4;
        trigger = zeros(1,size(x,2));
        trigger(init:inter:end)= max(ref)*3/4;;

    %%
       case 4
    % Para 4 Hz
        x = datos; 
        ref = x(14,100:end); ref=ref-mean(ref); %la centramos
        [pks,locs] = findpeaks(ref,'minpeakdistance', 603); 
        [pks,locs] = findpeaks(pks,'minpeakheight', 1000);
        v = round(min(pks))-1;
        k = ref>v;  init=find(k,1);
        inter = 603.945/4;
        trigger = zeros(1,size(ref,2));
        trigger(init+206:inter:end) = max(ref)*3/4;;
        %-(27404-27397.4)
      
  %%
       case 6
   % Para 6 Hz
        x = datos; %eliminamos artefactos iniciales
        ref = x(15,1000:end); ref=ref-mean(ref); %la centramos
        [pks,locs] = findpeaks(abs(ref),'minpeakdistance', 399); 
        [pks,locs] = findpeaks(pks,'minpeakheight', 500);
        v = round(min(pks))-1;
        k = ref>v;  init=find(k,1);
        %inter = 401.0324/4;
        inter = 150.986;
        trigger = zeros(1,size(ref,2));
        trigger(init:inter:end) = max(ref)*3/4;;
   end
   

   display('Trigger calculado');
   
	%% REORDENAR MATRIZ (opcional)
        prompt = ('¿reordenamos la matriz? (1=si, 2=no) ');
        reordenar=input(prompt);
        
        if reordenar==1
%             eeg_nofilt = zeros(size(x)-1);
          %  trigger = trigger(:,end-1);
            q = x(1:17,1:end-99); w = x(19:end,1:end-99);    
            x = [q;w;trigger];
            %figure(1), plot(fran_x2(17,:)), hold on, plot(trigger,'r')
        end   
    close all;
    plot(ref), hold on, plot(trigger,'r');
    title('antes de resampleo')
    clear q w k v pks locs ref;
    

    
       %% ELIMINACION MUESTRAS INNECESARIAS
   
       % Eliminar muestras
           display('Eliminando muestras innecesarias');
           start=init-inter; 
           fin=init+500*inter;   %850 estimulos despues
           
       for j=1:34
        eeg_nofilt(j,:) = x(j,start:fin);
       end
       
   trigger = trigger(1,start+209:fin+209); %-173+431
   eeg_nofilt(34,:) = trigger;
   figure, plot(eeg_nofilt(20,:)), hold on, plot(trigger,'r');
   title('despues de resamplear y eliminar muestras')
   display('Hecho')
   clear m x;
   
      %% FILTERING (passband de 2 a 200Hz)
% Lo haremos con IIR en lugar de FIR porque el orden necesario es menor ->
% menos no linealidades:

      prompt = ('¿Quieres aplicar ya filtrado? (1=si, 2=no) ');
      answer=input(prompt);
  if answer == 1
        [b,a] = butter(2,[0.5 200]/300); 
        %filtfilt elimina no linealidades de la fase

        %figure(1), plot(eeg(:,14)), hold on, plot(trigger,'r')
        %t = 0:1/2400:(size(eeg,1)-1)/2400;
        %figure(2), plot(t,eeg(:,18)), hold on, plot(trigger,'r')

        % NOTCH  --> se lo hacemos en SeeSEPs
        %Wo = 50/(600/2);  BW = Wo/15;
        %[bnotch,anotch] = iirnotch(Wo,BW);
        %figure,  freqz(bnotch,anotch);
        %eeg = filtfilt(bnotch,anotch,(eeg_nofilt(1:end,:))');
        eeg = filtfilt(b,a,(eeg_nofilt(1:end,:))');
        eeg = eeg';
        figure, plot(eeg(22,:)), hold on, plot(trigger,'r'), title('filt')
      
  end
  
        data.eeg_nofilt = eeg_nofilt;
        data.eeg = eeg;
        data.trigger = trigger;
        data.labels = {'AFz','F3','F1','Fz','F2','F4','FC3','FC1','FCz','FC2','FC4','C5','C3','C1','Cz','C2','C4','C6','CP3','CP1','CPz','CP2','CP4','P3','P1','Pz','P2','P4'};
        save nuevo data;
        
    close all, hold off
    figure, plot(eeg_nofilt(17,:)), hold on, plot(trigger,'r'), title('nofilt')
    
end