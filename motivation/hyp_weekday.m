%% Test week-day hypothesis for single subject

load('data/meta.mat', 'NUM_ATHLETES', 'NUM_DAYS', 'WINDOW_SAMPLES');

% We will compare days with eachother
day_dists = NaN(NUM_DAYS);
day_confs = NaN(NUM_DAYS);

% Keep track of distances on same weekdays vs other days
dists_same_weekday = []; % [dist, conf; dist, conf; etc]
dists_dif_weekday = [];

athlete = 6;

INTERVAL = 1;
for day1 = 1:INTERVAL:NUM_DAYS
    for day2 = day1:INTERVAL:NUM_DAYS
        
        if day1 == day2
            continue;
        end
        
        [dist, conf] = day_dist(day1, athlete, day2, athlete);
        row = [dist, conf];
        
        % Update matrix
        day_dists(day1, day2) = dist;
        day_confs(day1, day2) = conf;
            
        if mod(day2 - day1, 7) == 0
            dists_same_weekday = [dists_same_weekday; row];
        else
            dists_dif_weekday = [dists_dif_weekday; row];
        end
    end
end


%% Distribution of similarities

values = reshape(day_dists, [NUM_DAYS * NUM_DAYS, 1]);
confs = reshape(day_confs, [NUM_DAYS * NUM_DAYS, 1]);

% Plot
clc; figure;
subplot(2,1,1);
histogram(values, NUM_DAYS);
title('Measured distances between days');
subplot(2,1,2);
histogram(confs, NUM_DAYS);
title('Measured confidences of distances between days');


%% Distribution of same vs different weekdays

weighted_sum = sum(dists_same_weekday(:,1) .* dists_same_weekday(:,2));
weights_sum = sum(dists_same_weekday(:,2));
mean_same_weekday = weighted_sum / weights_sum;

weighted_sum = sum(dists_dif_weekday(:,1) .* dists_dif_weekday(:,2));
weights_sum = sum(dists_dif_weekday(:,2));
mean_dif_weekday = weighted_sum / weights_sum;

mean_same_weekday
mean_dif_weekday

%% Visualization of similarities

mapped = zeros(NUM_DAYS, NUM_DAYS, 3);
SCALE = 600.0;

cutoff = (mean_same_weekday + mean_dif_weekday) / 2.0;

for day1 = 1:NUM_DAYS
    for day2 = 1:NUM_DAYS
        val = day_dists(day1, day2);
        val_plot = 1 - (val / SCALE);
        
        if isinf(val)
            mapped(day1, day2, 1) = 1.0;
        elseif val >= cutoff 
            mapped(day1, day2, 1) = val_plot;
            mapped(day1, day2, 2) = val_plot;
            mapped(day1, day2, 3) = val_plot;
            
        else
            mapped(day1, day2, 1) = val_plot;
            mapped(day1, day2, 2) = val_plot;
            mapped(day1, day2, 3) = val_plot;
        end
    end
end

image(mapped);
title 'Similarity between each of the 92 days'

