function [int_autocorr, int_corr] = plotStats(G, trainer, trainer_diff, chann, cant, taux)

%% Gold Standard

int_corr = []; 
figure(512), title('AVG');
subplot(2,4,1), plot(taux(1:length(G')),G');
    [R,LAG] = xcorr(G);
    R_norm = norm(R);
    
    [R_diff, LAG_diff] = xcorr(diff(G));
    R_diff_norm = norm(R_diff);
    
    figure(513), title('COrrelations')
    subplot(2,4,1), stem(LAG,R), hold on
    
    figure(514), title('Diff Correlations'),subplot(2,4,1), stem(LAG_diff, R_diff);
    
    int_autocorr = trapz(R./R_norm);
    
 % Distintos valores de promediados
 rows = round(cant/4);
 if mod(cant, rows)== 0
     col = round(cant/rows);
 else
     col = round(cant/rows)+1;
 end
 
 %% Para los distintos promediados
 % Ploteamos su avg, correlation con GS, y diff_corr con GS
 for ii=1:cant
     x1 = trainer{ii}; 

        %Escogemos un trial de avg aleatorio para asegurar uniformidad
        r = round(1 + (length(x1(:,1)-1)).*rand(1,1))-1;
        x1 = x1(r,:);

        figure(512);
        subplot(2,4,ii+1), plot(taux(1:length(x1)),x1');
        [R,LAG] = xcorr(x1,G);
        R_norm = norm(R);

        [R_diff, LAG_diff] = xcorr(diff(x1),diff(G));
        R_diff_norm = norm(R_diff);

        figure(513), subplot(2,4,ii+1), stem(LAG,R), hold on

        figure(514), subplot(2,4,ii+1), stem(LAG_diff, R_diff);
        
        int_corr_aux = trapz(R./R_norm);
        int_corr(end+1) = int_corr_aux;
 end

    
    
end