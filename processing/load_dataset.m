%% Loads the entire dataset (except raw) into memory for faster access

load('data/meta.mat', 'NUM_DAYS', 'NUM_ATHLETES', 'WINDOW_SAMPLES')

processed = NaN(WINDOW_SAMPLES, NUM_DAYS, NUM_ATHLETES, 'double');
processed_norm = NaN(WINDOW_SAMPLES, NUM_DAYS, NUM_ATHLETES, 'double');
compliances = NaN(WINDOW_SAMPLES, NUM_DAYS, NUM_ATHLETES, 'double');

for day = 1:NUM_DAYS
    for athlete = 1:NUM_ATHLETES

        sig_processed = heartrate_read(day, athlete, 'processed');
        sig_processed_norm = heartrate_read(day, athlete, 'processed_norm');
        sig_compliance = heartrate_read(day, athlete, 'compliance');
        
        NUM_SAMPLES = size(sig_processed, 2);
        for sample = 1:NUM_SAMPLES
            processed(sample, day, athlete) = sig_processed(sample);
            processed_norm(sample, day, athlete) = sig_processed_norm(sample);
        end

        NUM_SAMPLES_COMP = min(size(sig_compliance, 1), WINDOW_SAMPLES);
        for sample = 1:NUM_SAMPLES_COMP
            compliances(sample, day, athlete) = sig_compliance(sample);
        end
    end
end

