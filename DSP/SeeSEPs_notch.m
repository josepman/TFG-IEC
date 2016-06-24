function [eeg,eeg_avg,channel] = SeeSEPs_notch(eeg_filt,trg,trg_locs,taux,freq,freq_resamp,type_SEP);


    warning off;  
    display('¿Quieres canales seguidos o sueltos?');
    prompt = ('1=Todos seguidos 2=Canales sueltos    ');
    opcion = input(prompt);
    [channel] = canales(eeg_filt, opcion);
    
%     prompt = ('Quieres ver los epochs individuales 1=si, 2=no    ');
%     eleccion = input(prompt);
                
    % Representamos los canales
    switch opcion
        
    %canales seguidos
        case 1  
            first = channel(1);      last = channel(end);
            number = last-first+1;
            eeg = zeros(size(eeg_filt));  
            eeg(first:last,:) = eeg_filt(first:last,:);
       
            for ii=first:last                
            eeg_avg_notch = [];
            epoch_notch = [];
             
             %for each stimulus
             for jj=1:length(trg_locs)-1
            % Ajustar donde empieza el epoch para el notch.
                %eeg_filt_notch = eeg_filt(ii,trg_locs(jj)+.008*freq_resamp:trg_locs(jj)+.2*freq_resamp); %de 0 a 200ms
                eeg_filt_notch = eeg_filt(ii,trg_locs(jj)+.008*freq_resamp:trg_locs(jj)+type_SEP*freq_resamp); %de 0 a 200ms

                % NOTCH 
                % Para 50
                    Wo = 50/(freq_resamp/2);  BW = Wo/15;        %C=50/15
                    [bnotch,anotch] = iirnotch(Wo,BW);
                    %figure,  freqz(bnotch,anotch);
                    eeg_aux_notch = filtfilt(bnotch,anotch,(eeg_filt_notch(1:end,:)));
                
                % Para 100
                    Wo = 100/(freq_resamp/2);  BW = Wo/15;        %C=50/15
                    [bnotch,anotch] = iirnotch(Wo,BW);
                    eeg_aux_notch = filtfilt(bnotch,anotch,(eeg_aux_notch(1:end,:)));

                % Para 150
                    Wo = 150/(freq_resamp/2);  BW = Wo/15;        %C=50/15
                    [bnotch,anotch] = iirnotch(Wo,BW);
                    eeg_aux_notch = filtfilt(bnotch,anotch,(eeg_aux_notch(1:end,:)));

                % Para 200
                    Wo = 200/(freq_resamp/2);  BW = Wo/15;        %C=50/15
                    [bnotch,anotch] = iirnotch(Wo,BW);
                    eeg_aux_notch = filtfilt(bnotch,anotch,(eeg_aux_notch(1:end,:)));

                    eeg_aux_notch = eeg_aux_notch-mean(eeg_aux_notch(0.001*freq_resamp:(type_SEP-0.01)*freq_resamp)); %
                    %eeg_aux_notch = eeg_aux_notch-mean(eeg_aux_notch(0.001*freq_resamp:0.45*freq_resamp)); %
                    eeg_avg_notch = [eeg_avg_notch;eeg_aux_notch];
                end;

                % Remove lowest and highest
                [~,I_notch]         = sort(max(abs(eeg_avg_notch(:,50:end)),[],2));
                eeg_avg_notch       = eeg_avg_notch(I_notch,:);
                eeg_avg_notch       = eeg_avg_notch(100:end-100,:);
                % Get the average MEP
                eeg_avg_notch       = mean(eeg_avg_notch,1);
                eeg_avg(ii,:) = eeg_avg_notch;


                % Plot single trials
                a = ii-(first-1);
                rows = round(number/5)+1;
               % figure(1), subplot(rows,5,a), plot(taux(1:length(eeg_avg_notch')),eeg_avg_notch'), hold on,
              %  title('Nofilt');            % Resultado señal promediada
                
                % Epochs individuales (para visualizar posibles artefactos)

%                 switch(eleccion)
%                 case 1
%                     rows = round(number/2)+1;
%                     for tt=1:50 
%                         figure(4), subplot(rows,2,a), plot(taux(1:length(eeg_aux_notch')),epoch_notch(tt,:));
%                         title('epochs individuales');       % Para ver artefactos que estropeen avg
%                         hold on;
%                     end
%                 end
        end
    
       %canales sueltos
         case 2       
            eeg = zeros(size(eeg_filt));  
            for kk = 1:length(channel)
                ii = channel(kk);  
                eeg(ii,:) = eeg_filt(ii,:);
                eeg_avg_notch = [];
                epoch_notch = [];
    
        
         % For each stimulus
             for jj=1:length(trg_locs)-1
            % Ajustar donde empieza el epoch para el notch.
                   % eeg_filt_notch = eeg_filt(ii,trg_locs(jj)+.008*freq_resamp:trg_locs(jj)+.2*freq_resamp); %de 0 a 200ms
                    eeg_filt_notch = eeg_filt(ii,trg_locs(jj)+.008*freq_resamp:trg_locs(jj)+.45*freq_resamp); %de 0 a 200ms

                % NOTCH 
                % Para 50
                    Wo = 50/(freq_resamp/2);  BW = Wo/15;        %C=50/15
                    [bnotch,anotch] = iirnotch(Wo,BW);
                    %figure,  freqz(bnotch,anotch);
                    eeg_aux_notch = filtfilt(bnotch,anotch,(eeg_filt_notch(1:end,:)));
                
                % Para 100
                    Wo = 100/(freq_resamp/2);  BW = Wo/15;        %C=50/15
                    [bnotch,anotch] = iirnotch(Wo,BW);
                    eeg_aux_notch = filtfilt(bnotch,anotch,(eeg_aux_notch(1:end,:)));

                % Para 150
                    Wo = 150/(freq_resamp/2);  BW = Wo/15;        %C=50/15
                    [bnotch,anotch] = iirnotch(Wo,BW);
                    eeg_aux_notch = filtfilt(bnotch,anotch,(eeg_aux_notch(1:end,:)));

                % Para 200
                    Wo = 200/(freq_resamp/2);  BW = Wo/15;        %C=50/15
                    [bnotch,anotch] = iirnotch(Wo,BW);
                    eeg_aux_notch = filtfilt(bnotch,anotch,(eeg_aux_notch(1:end,:)));


                    eeg_aux_notch = eeg_aux_notch-mean(eeg_aux_notch(0.001*freq_resamp:0.15*freq_resamp)); %
                    eeg_avg_notch = [eeg_avg_notch;eeg_aux_notch];
                end;

                % Remove lowest and highest
                [~,I_notch]         = sort(max(abs(eeg_avg_notch(:,50:end)),[],2));
                eeg_avg_notch       = eeg_avg_notch(I_notch,:);
                eeg_avg_notch       = eeg_avg_notch(100:end-100,:);
                % Get the average MEP
                eeg_avg_notch       = mean(eeg_avg_notch,1);
                eeg_avg(ii,:) = eeg_avg_notch;

                
                % Plot single trials
                rows = round(length(channel)/5);
                figure(1), subplot(rows,5,kk), plot(taux(1:length(eeg_avg_notch')),eeg_avg_notch'), hold on,
                title('Nofilt');            % Resultado señal promediada 

                
                % Epochs individuales (para visualizar posibles artefactos)
%                 switch(eleccion)
%                 case 1
%                     rows = round(length(channel)/2)+1;
%                     for tt=1:50 
%                         figure(4), subplot(rows,2,kk), plot(taux(1:length(eeg_aux_notch')),epoch_notch(tt,:));
%                         title('epochs individuales');       % Para ver artefactos que estropeen avg
%                         hold on;
%                     end
%                 end
            end
    end
end