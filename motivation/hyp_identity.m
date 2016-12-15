%% Test identity hypothesis for single pair of days

load('data/meta.mat', 'NUM_ATHLETES', 'NUM_DAYS', 'WINDOW_SAMPLES');

% Keep track of distances on same weekdays vs other days
dists_same_ident = []; % [dist, conf; dist, conf; etc]
dists_dif_ident = [];

TRIALS = 200;

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
load('data/meta.mat', 'NUM_ATHLETES', 'NUM_DAYS', 'WINDOW_SAMPLES');

% Plot
clc; figure;

VERT_SCALE = 1000;

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

% Gather sample moments (weighted)
x1 = dists_same_ident(:,1);
x1(isinf(x1)) = 0;
n1 = size(x1, 1);
w1 = dists_same_ident(:,2);
w1 = w1 / sum(w1) * n1;

m1 = sum(x1 .* w1) / sum(w1);
s1 = nanvar(x1, w1, 1);

x2 = dists_dif_ident(:,1);
x2(isinf(x2)) = 0;
n2 = size(x2, 1);
w2 = dists_dif_ident(:,2);
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


