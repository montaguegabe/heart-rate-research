%% Compares two windows for similarity
% This function is off by a slight amount with the current dataset -
% underestimates.

function dist = day_sim(athlete_number1, day_number1, athlete_number2, day_number2, plot_out)
    
    COMPLETE_THRESHOLD = 0.5;

    if nargin < 3
        plot_out = false;
    end

    dist = 0;

    athlete_names = get_athlete_names();
    
    name1 = athlete_names(athlete_number1);
    name2 = athlete_names(athlete_number2);
    date1 = datetime(2016,9,13) + days(day_number1 - 1);
    date2 = datetime(2016,9,13) + days(day_number2 - 1);
    date_string1 = datestr(date1,'mm-dd-YYYY');
    date_string2 = datestr(date2,'mm-dd-YYYY');
    
    filename1 = strcat('data/', date_string1, '_', name1, '.csv');
    filename2 = strcat('data/', date_string2, '_', name2, '.csv');
    
    hr1 = [];
    hr2 = [];
    try
        hr1 = csvread(filename1);
        hr2 = csvread(filename2);
    catch
        %warning('Comparing days with no data.');
    end
    
    if (size(hr1, 1) / 1440.0) < COMPLETE_THRESHOLD || (size(hr2, 1) / 1440.0) < COMPLETE_THRESHOLD
        dist = -1;
    else

        % Filter in minutes
        hr1 = medfilt1(hr1, 60);
        hr2 = medfilt1(hr2, 60);

        % Normalize
        mean1 = mean(hr1);
        std1 = std(hr1);
        hr1 = (hr1 - mean1) / std1;

        mean2 = mean(hr2);
        std2 = std(hr2);
        hr2 = (hr2 - mean2) / std2;

        % Plot filtered signals
        if plot_out
            clc;
            figure
            t = linspace(1, 1439, 1439);
            plot(t, hr1)
            hold on;
            plot(t, hr2)
            hold off;
        end

        % DTW
        dist = dtw(hr1, hr2);
    end
end