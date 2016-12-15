%% Test identity hypothesis for single pair of days

load('data/meta.mat', 'NUM_ATHLETES', 'NUM_DAYS', 'WINDOW_SAMPLES');

% Keep track of distances on same weekdays vs other days
dists_same_ident = []; % [dist, conf; dist, conf; etc]
dists_dif_ident = [];

TRIALS = 100;

for trial = 1:TRIALS

    % We choose two days, and compare athletes for them
    sprintf('Days to compare:');
    day1 = 0;
    day2 = 0;
    while day1 == day2
        day1 = randi([1, NUM_DAYS]);
        day2 = randi([1, NUM_DAYS]);
    end

    for athlete1 = 1:NUM_ATHLETES
        for athlete2 = 1:NUM_ATHLETES

            [dist, conf] = day_dist(day1, athlete1, day2, athlete2);

            % Update tallies
            row = [dist, conf];

            if athlete1 == athlete2
                dists_same_ident = [dists_same_ident; row];
            else
                dists_dif_ident = [dists_dif_ident; row];
            end
        end
    end
end

save('motivation/hyp_identity.mat', 'dists_same_ident', 'dists_dif_ident');

%% Plot distribution of similarities

load('motivation/hyp_identity.mat', 'dists_same_ident', 'dists_dif_ident');

% Plot
clc; figure;

VERT_SCALE = 300;

subplot(2,1,1);

values1 = dists_same_ident(:,1);
values1(isinf(values1)) = 0;
weights1 = dists_same_ident(:,2);
[histw1, intervals] = histwc(values1, weights1, 100);
bar(intervals, histw1, 1,'FaceColor',[0,0,1],...
                     'EdgeColor',[0,0,1]);
axis([50, 1800, 0, VERT_SCALE / NUM_ATHLETES]);
title('Difference distribution between same identities.')

                 
subplot(2,1,2);
values1 = dists_dif_ident(:,1);
values1(isinf(values1)) = 0;
weights1 = dists_dif_ident(:,2);
[histw2, intervals] = histwc(values1, weights1, 100);
bar(intervals, histw2, 1,'FaceColor',[0,0.6,0],...
                     'EdgeColor',[0,0.6,0]);
axis([50, 1800, 0, VERT_SCALE]);
title('Difference distribution different identities.')

%% Statistics

load('motivation/hyp_identity.mat', 'dists_same_ident', 'dists_dif_ident');

values1 = dists_same_ident(:,1);
values1(isinf(values1)) = 0;
weights1 = dists_same_ident(:,2);
mean_same_ident = sum(values1 .* weights1) / sum(weights1);
std_same_ident = sqrt(var(values1, weights1));

values2 = dists_dif_ident(:,1);
values2(isinf(values2)) = 0;
weights2 = dists_dif_ident(:,2);
mean_dif_ident = sum(values2 .* weights2) / sum(weights2);
std_dif_ident = sqrt(var(values2, weights2));

mean_same_ident
std_same_ident

mean_dif_ident
std_dif_ident

% h = 1 signifies null hypothesis rejected at 5%
[h,p] = ttest2(values1, values2)


