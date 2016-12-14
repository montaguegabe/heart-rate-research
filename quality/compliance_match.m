%% Compares two windows for overlapping compliance.
% This function is off by a slight amount with the current dataset -
% underestimates.

function [output] = compliance_match(day1, athlete1, day2, athlete2)

    %{
    % Testing
    day1 = 4;
    day2 = 4;
    athlete1 = 9;
    athlete2 = 6;
    %}

    load('data/meta.mat', 'WINDOW_SAMPLES');

    % Read both windows
    minutes1 = heartrate_read(day1, athlete1, 'compliance');
    minutes2 = heartrate_read(day2, athlete2, 'compliance');

    common = intersect(minutes1, minutes2);

    output = size(common, 1) / WINDOW_SAMPLES

end