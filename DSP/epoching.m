function xxx = epoching(eeg_nofilt,trg)
trg_locs    = find(trg>0);
freq_resamp=1200;
%taux = 0.00:1/1200:.200;
taux = 0.00:1/1200:.167;  %epochs para 6 Hz
 eeg_avg_nf = [];
for jj=10:length(trg_locs)-10
                    eeg_aux_nf = eeg_nofilt(1,trg_locs(jj)+.008*freq_resamp:trg_locs(jj)+.12*freq_resamp);
                    eeg_aux_nf = eeg_aux_nf-mean(eeg_aux_nf(.001*freq_resamp:.11*freq_resamp));
                    eeg_avg_nf = [eeg_avg_nf;eeg_aux_nf];       % todos los epochs
                end;
                
                xxx= eeg_avg_nf;
                xxx = mean(xxx(1:800,:),1);
                plot(xxx);
end