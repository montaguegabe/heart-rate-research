%% Simulate guessing for 100 trials

load('data/meta.mat', 'athletes', 'NUM_ATHLETES', 'NUM_DAYS', 'WINDOW_SAMPLES');
load('quality/compliance.mat', 'compliance_data');

%TRAINING_DAYS = uint16(NUM_DAYS * 0.90);
TRAINING_DAYS = uint16(NUM_DAYS * 0.35);
WEEKDAY_DISCOUNT = 0.93063; % Based on probability ratio

% Data stored between each trial
guess_numbers = []; % Number of the guess that was actually correct
guesses = []; % [1st, 2nd, 3rd guess, ...; 1st 2nd, 3rd guess, ...; etc]
guess_confidences = []; % Confidences for each athlete (ORDERED BY ATHLETE)
answers = []; % Who was being guessed
samples_given = [];
training_proximity = []; % How close to the training data the samples were

NUM_TRIALS = 1;
NUM_SAMPLE_WINDOWS = 3;
COMPLIANCE_DISCARD = 0.66;

for trial = 1:NUM_TRIALS

    % Randomly select athlete to be guessed
    athlete = randi([1, NUM_ATHLETES]);
    
    % Randomly select windows from the classification portion of the data
    sample_windows = [];
    for i = 1:20
        window = randi([TRAINING_DAYS + 1, NUM_DAYS]);
        
        % Check amount of data
        compliance = compliance_data(window, athlete);
        
        if all(sample_windows ~= window) && compliance > COMPLIANCE_DISCARD
            sample_windows = [sample_windows; window];
            if size(sample_windows, 1) == 3
                break;
            end
        end
    end
    
    % New athlete if not enough data to find windows
    if isempty(sample_windows)
        continue
    end
    
    % Keep track of total distance
    distances = zeros(NUM_ATHLETES, TRAINING_DAYS, NUM_SAMPLE_WINDOWS); % Unweighted
    confs = zeros(NUM_ATHLETES, TRAINING_DAYS, NUM_SAMPLE_WINDOWS);
    weights = ones(NUM_ATHLETES, TRAINING_DAYS, NUM_SAMPLE_WINDOWS); % Based on weekday or not
    
    % Add up the distances with each candidate
    for candidate = 1:NUM_ATHLETES

        for compare_day = 1:TRAINING_DAYS

            for sample_day = 1:NUM_SAMPLE_WINDOWS
                
                weight = 1.0;
                
                % Weight similarities on weekdays that are the same
                if mod(compare_day - sample_day, 7) == 0
                    weight = WEEKDAY_DISCOUNT;
                end

                [dist, conf] = day_dist(compare_day, candidate, athlete, sample_day);
                
                % Correct infinite case
                if isinf(dist)
                    fprintf('SHOULDNT HAPPEN\n');
                end
                
                % Record
                distances(candidate, compare_day, sample_day) = dist;
                weights(candidate, compare_day, sample_day) = weight;
                confs(candidate, compare_day, sample_day) = conf;
            end 
        end
    end
    
    % Sum up all the weighted distances and confidences for each athlete
    athlete_distances = zeros(NUM_ATHLETES, 1);
    athlete_confidences = zeros(NUM_ATHLETES, 1);
    
    for current_athlete = 1:NUM_ATHLETES
        total_score = 0;
        total_confidence = 0;
        
        % Add up score
        for compare_day = 1:TRAINING_DAYS
            for sample_day = 1:NUM_SAMPLE_WINDOWS
                score = distances(current_athlete, compare_day, sample_day) * ...
                        weights(current_athlete, compare_day, sample_day);
                confidence = confs(current_athlete, compare_day, sample_day);
                     
                total_score = total_score + score;
                total_confidence = total_confidence + confidence;
            end
        end
        
        athlete_distances(current_athlete) = total_score;
        athlete_confidences(current_athlete) = total_confidence ./ double(TRAINING_DAYS * NUM_SAMPLE_WINDOWS);
        
    end
    
    % See who is most similar with the safest comparisons
    athlete_scores = athlete_distances + (1 - athlete_confidences) * 100000;
    
    [mins, min_athletes] = sort(athlete_scores);
    guess = min_athletes(1);
    
    answer_name = athletes(athlete);
    guess_name = athletes(guess);
    guess_number = -1;
    
    % Determine index of guess
    for athlete_rank = 1:NUM_ATHLETES
        if athlete == min_athletes(athlete_rank)
            guess_number = athlete_rank;
            break;
        end
    end
    
    fprintf('Sample is the data of %s on day %i. Guess was %s.\n', answer_name, sample_windows(1), guess_name);

    if guess ~= athlete
        fprintf('Got it on the %ith guess.\n', guess_number);
        fprintf('Had %i percent of necessary data.\n', uint8(athlete_confidences(athlete) * 100));
    else
        fprintf('Correct!\n')
    end
    
    % Record for posterity
    answers = [answers; athlete];
    samples_given = [samples_given; sample_windows'];
    guess_numbers = [guess_numbers; guess_number]; % Number of the guess that was actually correct
    guesses = [guesses; min_athletes]; % [1st, 2nd, 3rd guess, ...; 1st 2nd, 3rd guess, ...; etc]
    guess_confidences = [guess_confidences; athlete_confidences]; % Confidences for each athlete
    
end


