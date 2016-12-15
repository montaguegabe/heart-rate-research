function heartrate_write(signal, day, athlete, type)
    
    % Transform day and athlete into heart rate
    load('data/meta.mat', 'athletes', 'NUM_ATHLETES', 'NUM_DAYS');

    name = athletes(athlete);
    date = datetime(2016, 9, 13) + days(day - 1);
    date_string = datestr(date, 'mm-dd-YYYY');
    filename = strcat('data/', type,'/', date_string, '_', name, '.csv');
    
    csvwrite(char(filename), signal);
end

