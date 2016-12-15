%% Compares two windows for similarity
% This function is off by a slight amount with the current dataset -
% underestimates.

function [output, weight] = day_dist(day1, athlete1, day2, athlete2)    
    % day1 = 1; day2 = 1; athlete1 = 1; athlete2 = 2;
    
    % Warp no more than 6 hours to match features
    MAX_WARP_MINUTES = 360;
    
    weight = compliance_match(day1, athlete1, day2, athlete2);
    
    % DTW
    ts1 = get_window(day1, athlete1);
    ts2 = get_window(day2, athlete2);
    
    if weight ~= 0
        %[dist, i1, i2] = dtw(ts1, ts2);
        dist = dtw(ts1, ts2);
    else
        dist = Inf;
    end
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