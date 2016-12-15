function [output] = get_window(day, athlete, type)

    % Default type used
    if nargin < 3
        type = 'n';
    end

    processed = evalin('base','eval(''processed'',''defaultVar'')');
    processed_norm = evalin('base','eval(''processed_norm'',''defaultVar'')');
    compliances = evalin('base','eval(''compliances'',''defaultVar'')');

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

