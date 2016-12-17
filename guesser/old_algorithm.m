%% Simulate guessing for 100 trials

% We have 28 days and 15 athletes.
% Our model citizen is athlete 7.

load('data/meta.mat', 'athletes', 'NUM_ATHLETES');

%MINIMUM_SAMPLE_DAYS = 31;
SAMPLE_DAYS = 24;
GAP = 1;
WEEKDAY_PREFERENCE = 1.2;
HOLE_PENALTY = 1.1;

days = 33;
subjects = NUM_ATHLETES;

% Stats for trial
successes;
tries;
guess_number; % Array of n where observed subject was the nth guess.
subject_holes;

for trialnum=1:1000

subject = 1;
is_blank = true;
while is_blank

    subject = randi([1, subjects]);
    observation = randi([SAMPLE_DAYS + 1 + GAP, days]);
    
    compliance = get_window(observation, subject, 'c');
    is_blank = size(compliance, 1) == 0;
end

% Attempt to assign based on sum similarity

% Situation: We have all samples up to the day of the observation, but we
% do not know the subject the sample came from.

%SAMPLE_DAYS =  %(observation - 1);
trials = zeros(subjects, 1);
trial_holes = zeros(subjects, 1);

for trial_subject = 1:subjects
    
    % Keep track of total distance, holes
    dist_tot = 0.0;
    weighted_dist_tot = 0.0;
    holes = 0;
    weighted_holes = 0;
    
    for trial_day = 1:SAMPLE_DAYS
        
        % Weight similarities on weekdays that are the same
        weight = 1.0;
        if mod(trial_day - observation, 7) == 0
            weight = WEEKDAY_PREFERENCE;
        end
        
        
        [dist, conf] = day_dist(trial_day, trial_subject, observation, subject);
        
        if conf == 0
            holes = holes + 1;
            if weight ~= 1.0
                weighted_holes = weighted_holes + 1;
            end
        else
            dist_tot = dist_tot + dist;
            weighted_dist_tot = weighted_dist_tot + dist * weight;
        end
    end
    
    % Correct for holes
    avg_day_dist = dist_tot / (SAMPLE_DAYS - holes);
    weighted_dist_tot = weighted_dist_tot + HOLE_PENALTY * avg_day_dist * ((holes - weighted_holes) + weighted_holes * WEEKDAY_PREFERENCE);
    
    % Trial complete
    trials(trial_subject, 1) = weighted_dist_tot;
    trial_holes(trial_subject, 1) = holes;
end


% See who is most similar
names = athletes;
[mins, min_athletes] = sort(trials);

sub_name = names(subject);
guess = min_athletes(1);
guess_name = names(guess);
guess_holes = trial_holes(subject);

tries = tries + 1;

fprintf('Missing %i days in the data of guessed person.\n\n', guess_holes);
fprintf('Sample is the data of %s on day %i. Guess was %s.\n', sub_name, observation, guess_name);

tries

if guess ~= subject
    fprintf('Second guess was %s, third was %s, fourth was %s\n', names(min_athletes(2)), names(min_athletes(3)), names(min_athletes(4)))
else
    fprintf('Correct!\n')
    successes = successes + 1;
end

    
% Determine index of guess and number of holes
for i=1:subjects
    if subject == min_athletes(i)
        guess_number = [guess_number; i];
        break;
    end
end

subject_holes = [subject_holes; guess_holes];
guess_athlete = [guess_athlete; guess];
subject_athlete = [subject_athlete; subject];


end

%% Results plot accuracy distribution

subjects = 10;

P_correct = zeros(1, 9);

P_correct(1) = successes ./ tries;

for i = 2:(subjects - 1)
    prob_i = size(guess_number(guess_number == i), 1) ./ tries
    P_correct(1, i) = P_correct(1, i - 1) + prob_i;
end

figure;

area(P_correct);
grid on

xticks(linspace(1,10,10));
title 'Probability that the answer is one of the first x guesses';

%% Holes - Plot holes in guess vs performance

clc; figure;

max_holes = max(subject_holes);
guess_nums = NaN(size(subject_holes)); % ordered by holes

for i = 1:size(subject_holes)
    guess_nums(i) = guess_number(i);
end
    
scatter(subject_holes, guess_nums)
title('Number of holes in data of answer vs Number of guesses t')

% Best fit
%coeffs = polyfit(subject_holes, guess_nums, 1);
% Get fitted values
%fittedX = linspace(min(x), max(x), 200);
%fittedY = polyval(coeffs, fittedX);
% Plot the fitted line
%hold on;
%plot(fittedX, fittedY, 'r-', 'LineWidth', 2);
%hold off;

%% Zero-hole performance

zero_indices = find(~subject_holes);
close_tries_no_holes = guess_nums(zero_indices);
tries_no_holes = size(close_tries_no_holes, 1);

P_correct_nh = zeros(1, 9);

for i = 1:(subjects - 1)
    prob_i = size(close_tries_no_holes(close_tries_no_holes == i), 1) ./ tries_no_holes;
    if i ~= 1
        P_correct_nh(1, i) = P_correct_nh(1, i - 1) + prob_i;
    else
        P_correct_nh(1, i) = prob_i;
    end
end

clc; figure;

plot(P_correct_nh);
hold on;
plot(P_correct, 'r');
hold off;

grid on
legend('No holes','Holes')
xticks(linspace(1,10,10));
title 'Number of guesses vs. Probability being correct';

%% Performance by individual

G_ind = zeros(1, subjects);

for subject = 1:subjects
    
    % Get indices of tries with subject
    try_inds = find(~(guess_athlete - subject));
    
    guess_number = guess_number(try_inds);
    G_ind(subject) = mean(guess_number);
end

bar(G_ind)

%% Ranking of uniqueness by individual

[sorted, uniqueness_ranks] = sort(G_ind);
names = get_athlete_names();

rankings = strings(subjects, 1);
for rank = 1:size(uniqueness_ranks, 2)
    subject = uniqueness_ranks(rank);
    rankings(rank) = names(subject);
end