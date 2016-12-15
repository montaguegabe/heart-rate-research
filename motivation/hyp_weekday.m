%% Test week-day hypothesis for single subject

load('data/meta.mat', 'NUM_ATHLETES', 'NUM_DAYS', 'WINDOW_SAMPLES');

% We will compare days with eachother
day_dists = NaN(NUM_DAYS, NUM_DAYS, NUM_ATHLETES);
day_confs = NaN(NUM_DAYS, NUM_DAYS, NUM_ATHLETES);

% Keep track of distances on same weekdays vs other days
dists_same_weekday = []; % [dist, conf; dist, conf; etc]
dists_dif_weekday = [];

%for athlete = 1:NUM_ATHLETES
for athlete = 6:7

    INTERVAL = 1;
    for day1 = 1:INTERVAL:NUM_DAYS
        for day2 = day1:INTERVAL:NUM_DAYS

            if day1 == day2
                continue;
            end

            [dist, conf] = day_dist(day1, athlete, day2, athlete);

            % Update matrix
            day_dists(day1, day2, athlete) = dist;
            day_confs(day1, day2, athlete) = conf;

            
            % Update tallies
            row = [dist, conf];
            
            if mod(day2 - day1, 7) == 0
                dists_same_weekday = [dists_same_weekday; row];
            else
                dists_dif_weekday = [dists_dif_weekday; row];
            end
        end
    end

end

%save('motivation/hyp_weekday.mat', 'dists_same_weekday', 'dists_dif_weekday', 'day_dists', 'day_confs');

%% Plot distribution of similarities

load('motivation/hyp_weekday.mat', 'dists_same_weekday', 'dists_dif_weekday');

% Plot
clc; figure;

subplot(2,1,1);

values1 = dists_same_weekday(:,1);
values1(isinf(values1)) = 0;
weights1 = dists_same_weekday(:,2);
[histw1, intervals] = histwc(values1, weights1, 100);
bar(intervals, histw1, 1,'FaceColor',[0,0,1],...
                     'EdgeColor',[0,0,1]);
axis([50, 1400, 0, 500 / 7]);
title('Difference distribution between same weekdays.')

                 
subplot(2,1,2);
values1 = dists_dif_weekday(:,1);
values1(isinf(values1)) = 0;
weights1 = dists_dif_weekday(:,2);
[histw2, intervals] = histwc(values1, weights1, 100);
bar(intervals, histw2, 1,'FaceColor',[0,0.6,0],...
                     'EdgeColor',[0,0.6,0]);
axis([50, 1400, 0, 500]);
title('Difference distribution different weekdays.')

%% Statistics

load('motivation/hyp_weekday.mat', 'dists_same_weekday', 'dists_dif_weekday');

values1 = dists_same_weekday(:,1);
values1(isinf(values1)) = 0;
weights1 = dists_same_weekday(:,2);
mean_same_weekday = sum(values1 .* weights1) / sum(weights1);
std_same_weekday = sqrt(var(values1, weights1));

values2 = dists_dif_weekday(:,1);
values2(isinf(values2)) = 0;
weights2 = dists_dif_weekday(:,2);
mean_dif_weekday = sum(values2 .* weights2) / sum(weights2);
std_dif_weekday = sqrt(var(values2, weights2));

mean_same_weekday
std_same_weekday

mean_dif_weekday
std_dif_weekday

% h = 1 signifies null hypothesis rejected at 5%
[h,p] = ttest2(values1, values2)

%% Visualization of similarities

load('motivation/hyp_weekday.mat', 'day_dists', 'day_confs');


mapped = zeros(NUM_DAYS, NUM_DAYS, 3);
SCALE = 600.0;
ATHLETE = 6;

cutoff = (mean_same_weekday + mean_dif_weekday) / 2.0;

for day1 = 1:NUM_DAYS
    for day2 = 1:NUM_DAYS
        val = day_dists(day1, day2, ATHLETE);
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

