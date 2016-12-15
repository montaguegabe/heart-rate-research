function [data] = heartrate_read(day, athlete, type)

    % Transform day and athlete into heart rate
    load('data/meta.mat', 'athletes', 'NUM_ATHLETES', 'NUM_DAYS', 'WINDOW_SAMPLES');
    
    name = athletes(athlete);
    date = datetime(2016, 9, 13) + days(day - 1);
    date_string = datestr(date, 'mm-dd-YYYY');
    filename = strcat('data/', type,'/', date_string, '_', name, '.csv');

    try
        data_defer = csvread(filename);
    catch ERROR
        
        data_defer = [];
    end
    
    data = data_defer;
end

