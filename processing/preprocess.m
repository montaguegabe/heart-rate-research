%% Pre-preprocessing: remove duplicate timestamps from files
load('data/meta.mat', 'athletes', 'NUM_ATHLETES', 'NUM_DAYS', 'WINDOW_SAMPLES');

for athlete = 1:NUM_ATHLETES
    
    for day = 1:NUM_DAYS
        
        day_raw = heartrate_read(day, athlete, 'raw');
        NUM_ENTRIES = size(day_raw, 1);
        day_raw_nodup = [];
        
        if isempty(day_raw)
            continue
        end
        
        minute_max = -100;
        for row = 1:NUM_ENTRIES
            
            row_data = day_raw(row, :);
            min = row_data(1);
            
            % If a minute is logged that has already been included, skip it
            if min > minute_max
                day_raw_nodup = [day_raw_nodup;row_data];
            end
            
            minute_max = max(min, minute_max);
        end
        
        % Rewrite data
        heartrate_write(day_raw_nodup, day, athlete, 'raw');
    end

end

%% Raw signal moments calculation

load('data/meta.mat', 'athletes', 'NUM_ATHLETES', 'NUM_DAYS', 'WINDOW_SAMPLES');

moments_mean = NaN(NUM_ATHLETES, 1);
moments_std = NaN(NUM_ATHLETES, 1);

% Computes athlete moments for normalization
for athlete = 1:NUM_ATHLETES
    
    signal = [];
    
    for day = 1:NUM_DAYS
        
        % Stitch together days
        day_raw = heartrate_read(day, athlete, 'raw');
        
        if isempty(day_raw)
            continue
        end
        
        day_signal = day_raw(:,2);
        if ~isempty(day_signal)
            signal = [signal; day_signal];
        end
        
    end
    
    moments_mean(athlete) = mean(signal);
    moments_std(athlete) = std(signal);
    
end

save('data/raw_moments.mat', 'moments_mean', 'moments_std');

%% Preprocesses data and saves as .MAT

% Load mapping from index to name
load('data/meta.mat', 'athletes', 'NUM_ATHLETES', 'NUM_DAYS', 'WINDOW_SAMPLES');
load('data/raw_moments.mat', 'moments_mean', 'moments_std');

% Iterate through days
for day = 1:NUM_DAYS
    
    % Iterate through athletes
    for athlete = 1:NUM_ATHLETES
        
        % Get raw data
        raw_data = heartrate_read(day, athlete, 'raw');
        
        if ~isempty(raw_data)
            
            mins = raw_data(:,1);
            hrs = raw_data(:,2);

            % Fill holes
            x_query = linspace(1, WINDOW_SAMPLES, WINDOW_SAMPLES);
            hr_ts_noisy = interp1(mins, hrs, x_query, 'linear', 'extrap');

            % Noise reduce with Wavelets
            hr_ts = wden(hr_ts_noisy, 'sqtwolog', 's', 'sln', 5, 'haar');

            % Normalize data
            m1 = mean(hr_ts); % OR moments_mean(athlete)
            m2 = std(hr_ts); % OR moments_std(athlete)
            hr_ts_norm = (hr_ts - m1) ./ m2;
            
        else
            
            % No data for the whole day.
            hr_ts = [];
            hr_ts_norm = [];
            mins = [];
        
        end
        
        % Write out both normalized and unnormalized
        heartrate_write(hr_ts, day, athlete, 'processed');
        heartrate_write(hr_ts_norm, day, athlete, 'processed_norm');
        heartrate_write(mins, day, athlete, 'compliance');
    end
    
end
    
        