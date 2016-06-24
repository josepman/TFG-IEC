function [eeg_avg, eeg_avg_sm, Xeeg_avg_sm] = calculo_promedios(eeg,subgroup, template)
      %Calculo de distinto numeros de epochs promediados de un canal
    % La señal que le paso son 494 epochs de 240 samples a 600 Hz y 
    % 495 epochs de 479 samples a 1200 Hz.

    % Promediado
    eeg_avg = [];
    kk = 1;
                for jj=1:length(eeg(:,1))-1; 
                  eeg(jj,:) = eeg(jj,:)./norm(eeg(jj,:));
                end 
            
            for jj=1:subgroup:length(eeg(:,1))-subgroup; 
                  eeg_avg(kk,:) = mean(eeg([jj:jj+subgroup-1],:));
                  %eeg_avg(kk,:) = eeg_avg(kk,:)./norm(eeg_avg(kk,:));
                  kk = kk+1;
            end 
    
    % Smoothing
    eeg_avg_sm = [];
    kk = 1;
            for kk=1:length(eeg_avg(:,1))
                  eeg_avg_sm(kk,:) = smooth(smooth(smooth(eeg_avg(kk,:))))';
                  eeg_avg_sm(kk,:) = eeg_avg_sm(kk,:)./norm(eeg_avg_sm(kk,:));
            end 
            
            
    % CROSS-CORRELATION        
            % El template se debe meter ya cortado
    Xeeg_avg_sm = [];
            for ii=1:length(eeg_avg_sm(:,1))
                [c, lags] = xcorr(template, eeg_avg_sm(ii,:));
                Xeeg_avg_sm(ii,:) =  eeg_avg_sm(ii,max(lags)-length(template)+1:max(lags));
            end


end