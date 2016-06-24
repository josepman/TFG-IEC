
function [eeg,eeg_avg,channel] = SeeSEPs_nofilt(eeg_nofilt,trg,trg_locs,taux,freq,freq_resamp, type_SEP)
    warning off;  
    display('¿Quieres canales seguidos o sueltos?');
    prompt = ('1=Todos seguidos 2=Canales sueltos    ');
    opcion = input(prompt);
    [channel] = canales(eeg_nofilt, opcion);
    
    prompt = ('Quieres ver los epochs individuales 1=si, 2=no    ');
    eleccion = input(prompt);
                
    % Representamos los canales
    switch opcion
        
    %canales seguidos
        case 1  
            first = channel(1);      last = channel(end);
            number = last-first+1;
            eeg = zeros(size(eeg_nofilt));  
            eeg(first:last,:) = eeg_nofilt(first:last,:);
            for ii=first:last                 
              eeg_avg_nf = [];
              epoch_nofilt = [];

            % For each stimulus
                for jj=1:length(trg_locs)-1
                   % eeg_aux_nf = eeg_nofilt(ii,trg_locs(jj)+.008*freq_resamp:trg_locs(jj)+.2*freq_resamp);
                    eeg_aux_nf = eeg_nofilt(ii,trg_locs(jj)+.008*freq_resamp:trg_locs(jj)+type_SEP*freq_resamp);
                    
                   % eeg_aux_nf = eeg_aux_nf-mean(eeg_aux_nf(.001*freq_resamp:.15*freq_resamp));
                    eeg_aux_nf = eeg_aux_nf-mean(eeg_aux_nf(.001*freq_resamp:(type_SEP-0.01)*freq_resamp));
                    
                    eeg_avg_nf = [eeg_avg_nf;eeg_aux_nf];       % todos los epochs
                end;

                    epoch_nofilt = eeg_avg_nf;

                % Remove lowest and highest (to avoid noise and artifacts)
                [~,I]         = sort(max(abs(eeg_avg_nf(:,50:end)),[],2));
                eeg_avg_nf       = eeg_avg_nf(I,:);
                eeg_avg_nf       = eeg_avg_nf(100:end-100,:); %quito 100 primeros y 100 ultimos 
                % Get the average SEPs
                eeg_avg_nf       = mean(eeg_avg_nf,1);      %y promedio
                eeg_avg(ii,:) =  eeg_avg_nf;

                % Plot single trials
                a = ii-(first-1);
                rows = round(number/5)+1;
                figure(1), subplot(rows,5,a), plot(taux(1:length(eeg_avg_nf')),eeg_avg_nf'), hold on,
                title('Nofilt');            % Resultado señal promediada
                
                
             % Epochs individuales (para visualizar posibles artefactos)

                switch(eleccion)
                case 1
                    rows = round(number/2)+1;
                    for tt=1:50 
                        figure(4), subplot(rows,2,a), plot(taux(1:length(eeg_aux_nf')),epoch_nofilt(tt,:));
                        title('epochs individuales');       % Para ver artefactos que estropeen avg
                        hold on;
                    end

                end
                 
            end
    
   
   %canales sueltos
         case 2       
            eeg = zeros(size(eeg_nofilt));  
            for kk = 1:length(channel)
                ii = channel(kk);  
                eeg(ii,:) = eeg_nofilt(ii,:);
                eeg_avg_nf = [];
                epoch_nofilt = [];

            % For each stimulus
                for jj=1:length(trg_locs)-1
                    eeg_aux_nf = eeg_nofilt(ii,trg_locs(jj)+.008*freq_resamp:trg_locs(jj)+.4*freq_resamp);
                    eeg_aux_nf = eeg_aux_nf-mean(eeg_aux_nf(.001*freq_resamp:.3*freq_resamp));
                    eeg_avg_nf = [eeg_avg_nf;eeg_aux_nf];       % todos los epochs
                end;

                    epoch_nofilt = eeg_avg_nf;

                % Remove lowest and highest (to avoid noise and artifacts)
                [~,I]         = sort(max(abs(eeg_avg_nf(:,50:end)),[],2));
                eeg_avg_nf       = eeg_avg_nf(I,:);
                eeg_avg_nf       = eeg_avg_nf(10:end-10,:); %quito 100 primeros y 100 ultimos 
                % Get the average SEPs
                eeg_avg_nf       = mean(eeg_avg_nf,1);      %y promedio
                eeg_avg(ii,:) = eeg_avg_nf;

                % Plot single trials
                rows = round(length(channel)/5)+1;
                figure(1), subplot(rows,5,kk), plot(taux(1:length(eeg_avg_nf')),eeg_avg_nf'), hold on,
                title('Nofilt');            % Resultado señal promediada 
                    
                
            % Epochs individuales (para visualizar posibles artefactos)
                switch(eleccion)
                case 1
                    rows = round(length(channel)/2);
                    for tt=1:50 
                        figure(4), subplot(rows,2,kk), plot(taux(1:length(eeg_aux_nf')),epoch_nofilt(tt,:));
                        title('epochs individuales');       % Para ver artefactos que estropeen avg
                        hold on;
                    end

                end
                
             end
    end
    

end



