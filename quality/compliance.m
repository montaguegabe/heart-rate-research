%% Calculate percentage of data available over time

load('data/meta.mat', 'NUM_ATHLETES', 'NUM_DAYS', 'WINDOW_SAMPLES');

compliance_data = zeros(NUM_DAYS, NUM_ATHLETES); % (day, athlete)

% Iterate through days
for day = 1:NUM_DAYS
    
    % Iterate through athletes
    for athlete = 1:NUM_ATHLETES
        
        % Get raw data
        raw_data = heartrate_read(day, athlete, 'raw');
        
        if ~isempty(raw_data)
            mins = raw_data(:, 1);
            day_compliance = size(mins, 1) / WINDOW_SAMPLES;
            compliance_data(day, athlete) = day_compliance;
        end
    end
end

save('quality/compliance.mat', 'compliance_data');

%% Plot findings

load('quality/compliance.mat', 'compliance_data');

clc;
hold on;

for athlete = 1:NUM_ATHLETES
    subplot(NUM_ATHLETES, 1, athlete);
    compliance_ts = compliance_data(:, athlete);
    plot(compliance_ts, 'LineWidth', 3);
    axis([0, NUM_DAYS, 0, 1.05])
end

hold off;
