%% Compares two windows for similarity
% This function is off by a slight amount with the current dataset -
% underestimates.

function output = day_dist(day1, athlete1, day2, athlete2)

    % Warp no more than 6 hours to match features
    MAX_WARP_MINUTES = 360;

    % day1 = 1; day2 = 1; athlete1 = 1; athlete2 = 2;

    load('data/meta.mat', 'NUM_ATHLETES', 'NUM_DAYS', 'WINDOW_SAMPLES');

    % DTW
    ts1 = heartrate_read(day1, athlete1);
    ts2 = heartrate_read(day2, athlete2);
    [dist, i1, i2] = dtw(ts1, ts2);

    %{
    clc;
    hold on
    plot(ts1);
    plot(ts2);
    hold off;

    clc;
    plot(i1,i2,'o-',[i1(1) i1(end)],[i2(1) i2(end)]);
    end
    %}
        
    output = dist;
%end