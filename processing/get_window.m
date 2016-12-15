function [output] = get_window(day, athlete, type)

    % Default type used
    if nargin < 3
        type = 'p';
    end

    processed = evalin('base','eval(''processed'',''dataset_not_loaded'')');
    processed_norm = evalin('base','eval(''processed_norm'',''dataset_not_loaded'')');
    compliances = evalin('base','eval(''compliances'',''dataset_not_loaded'')');

    switch type
        case {'p', 'processed'}
            output = processed(:, day, athlete);
        case {'n', 'normalized'}
            output = processed_norm(:, day, athlete);
        case {'c', 'comp', 'compliance'}
            nan_set = compliances(:, day, athlete);
            output = nan_set(~isnan(nan_set));
    end
end

