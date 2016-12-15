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

x1 = dists_same_weekday(:,1);
x1(isinf(x1)) = 0;
w1 = dists_same_weekday(:,2);
[histw1, intervals] = histwc(x1, w1, 100);
bar(intervals, histw1, 1,'FaceColor',[0,0,1],...
                     'EdgeColor',[0,0,1]);
axis([50, 1400, 0, 500 / 7]);
title('Difference distribution between same weekdays.')

                 
subplot(2,1,2);
x1 = dists_dif_weekday(:,1);
x1(isinf(x1)) = 0;
w1 = dists_dif_weekday(:,2);
[histw2, intervals] = histwc(x1, w1, 100);
bar(intervals, histw2, 1,'FaceColor',[0,0.6,0],...
                     'EdgeColor',[0,0.6,0]);
axis([50, 1400, 0, 500]);
title('Difference distribution different weekdays.')

%% Statistics

load('motivation/hyp_weekday.mat', 'dists_same_weekday', 'dists_dif_weekday');

% Gather sample moments (weighted)
x1 = dists_same_weekday(:,1);
x1(isinf(x1)) = 0;
n1 = size(x1, 1);
w1 = dists_same_weekday(:,2);
w1 = w1 / sum(w1) * n1;

m1 = sum(x1 .* w1) / sum(w1);
s1 = nanvar(x1, w1, 1);

x2 = dists_dif_weekday(:,1);
x2(isinf(x2)) = 0;
n2 = size(x2, 1);
w2 = dists_dif_weekday(:,2);
w2 = w2 / sum(w2) * n2;

m2 = sum(x2 .* w2) / sum(w2);
s2 = nanvar(x2, w2, 1);

% Perform a 2-sample T test on the datasets
stat = (m1 - m2) ./ sqrt((s1 .^ 2) ./ n1 + (s2 .^ 2) ./ n2);
numer = (((s1 .^ 2) ./ n1 + (s2 .^ 2) ./ n2) .^ 2);
denom = (((s1 .^ 2) ./ n1) .^ 2) ./ (n1 - 1) + ...
        (((s2 .^ 2) ./ n2) .^ 2) ./ (n2 - 1);
dfe = numer ./ denom;

p = tcdf(stat,dfe)
mean_same = m1
mean_different = m2
var_same = s1
var_different = s2

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

