

function [r,pearson_val] = SeeSEPs(eeg_nofilt,eeg_filt,trg,freq,freq_resamp)
   warning off; 
   close all;
   
   % Con 2 Hz podemos visualizar LSEPs
   if freq == 2
       prompt = ('¿Quieres ver SSEPs (1) o LSEPs (2)?  ');
       SEP = input(prompt);
       switch SEP
           case 1
               type_SEP = 0.2;  %type_SEP es el enventanado del epoch
           case 2
               type_SEP = 0.45;
       end
   else
           SEP = 1;
           type_SEP = 0.2;
   end
   
%% Variables initialization
        % Define default sampling frequency
        if ~exist('freq_resamp')
            freq_resamp = 2400;
        end;

        trg_locs    = find(trg>0);
     switch freq
         case 2
             taux = 0.00:1/freq_resamp:.500;  %epochs para 2 Hz
         case 4
             taux = 0.00:1/freq_resamp:.200;  %epochs para 4 Hz
         case 6
             taux = 0.00:1/freq_resamp:.167;  %epochs para 6 Hz
         otherwise
             display('Seleccione 2, 4 o 6 Hz')
     end
     
     
     
    %% ELECCION DE SEÑALES
    display('¿Con qué señal quieres trabajar?    ');
    prompt = ('1=sin filtrar, 2=filtrada, 3=notch, 4=todas   ');
    opcion = input(prompt);
    switch(opcion)
        case 1
            [eeg,eeg_avg,channel] = SeeSEPs_nofilt(eeg_nofilt,trg,trg_locs,taux,freq,freq_resamp,type_SEP);
        case 2   
            % me vale el mismo script, solo que cojo otra señal
            [eeg,eeg_avg,channel] = SeeSEPs_nofilt(eeg_filt,trg,trg_locs,taux,freq,freq_resamp, type_SEP);
        case 3
            [eeg,eeg_avg,channel] = SeeSEPs_notch(eeg_filt,trg,trg_locs,taux,freq,freq_resamp, type_SEP);
         case 4
             SeeSEPs_nofilt(eeg_nofilt,trg,trg_locs,taux,freq,freq_resamp,type_SEP);
             SeeSEPs_nofilt(eeg_filt,trg,trg_locs,taux,freq,freq_resamp, type_SEP);
             SeeSEPs_notch(eeg_filt,trg,trg_locs,taux,freq,freq_resamp, type_SEP);
        otherwise
            display('Seleccione correctamente una de las opciones')
    end
    eeg_avg = eeg_avg(13,:);
    save template_2_300 eeg_avg;
    s2_400 = promed(eeg,3,trg_locs,freq_resamp,taux,15, type_SEP);
   % close all;
    
    %% RE-REFERENCIAS
    prompt = ('Quieres re-referenciar? 1=si 2=no');
    reref = input(prompt);
    display('Recuerda, los canales tienen que pertenecer a los de antes');
    switch(reref)
        case 1
            prompt = ('¿Cuántas combinaciones X-Y serán?')
            num = input(prompt);
            for i=1:num
                prompt = ('Introduce canal ');
                canal = input(prompt);
                a = eeg_avg(canal,:);
                prompt = ('Introduce re-referencia');
                rereference = input(prompt);
                b = eeg_avg(rereference,:);
                figure(56), subplot(num,1,i), plot(taux(1:length(eeg_avg')),(a-b))
                title('Re-referencias');
            end
    end
    
    
    
    %% PROMEDIADOS
        %prompt = ('¿De cuánto quieres los promediados');
        %subgroup = input(prompt);
        %eeg_avg2 = promediados(eeg,subgroup,trg_locs,freq_resamp,taux,channel);   
        
        principals = pca(eeg_avg);
        
        
    %% STATISTICS
    trainer = {};
    trainer_diff = {};
  
   % prompt = ('cuantos canales quieres comprobar?')
   % num = input(prompt);
   % for jj = 1:num
        prompt = ('para que canal?');
        chann = input(prompt);
        G = eeg_avg(chann,:);

        if SEP == 1
            G = (G(1:0.07*freq_resamp));
        end

        prompt = ('cuantos calculos?');
        cant = input(prompt);

        % Y comparamos con los promediados
        for ii = 1:cant;
           prompt = ('¿Cuantos promediados?  ');
           subgroups = input(prompt);
           [x, x_diff] = correlation(eeg,eeg_avg,subgroups,trg_locs,freq_resamp,taux,chann, SEP, type_SEP);
           trainer{end+1} = x;
           trainer_diff{end+1} = x_diff;
        end

       [int_autocorr, int_corr] = plotStats(G, trainer, trainer_diff, chann, cant, taux)
       
       % int_corr e int_autocorr son las integrales bajo la curva de las
       % correlaciones, un valor entero que me permite comparar "cuánto se
       % parecen" (la integral la calculo con metodo trapezoidal)
       
   %    chan_stats{end+1} = int_corr;
   % end
close all;
            figure(1), subplot(1,4,1), title('Sin promediar'), plot(data.eeg_nofilt(15,:));
            
            
    
    %% Pattern Recog
%    pause(20);
end
