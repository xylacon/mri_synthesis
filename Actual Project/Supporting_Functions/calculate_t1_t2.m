function result = calculate_t1_t2(tissue, B0, mode)
    % Wrapper function to calculate T1 or T2 relaxation times
    if strcmp(mode, 'T1')
        result = calcT1(tissue, B0);
    elseif strcmp(mode, 'T2')
        result = calcT2(tissue, B0);
    else
        error('Invalid mode. Choose ''T1'' or ''T2''.');
    end
end

% Sub-function: Calculate T1
function T1 = calcT1(tissue, B0)
    gamma = 42.577e6;  % Gyromagnetic ratio (Hz/T)
    switch tissue
        case 'GM'
            alpha = 0.00116;
            beta = 0.376;
            delta = (5 * B0 + 54) * 0.001;
        case 'WM'
            alpha = 0.00071;
            beta = 0.382;
            delta = (2 * B0 + 18) * 0.001;
        case 'CSF'
            alpha = 4.329;
            beta = 0;
            delta = 200;
        otherwise
            error('Invalid tissue type. Choose ''GM'', ''WM'', or ''CSF''.');
    end
    T1 = alpha * (gamma * B0)^beta + delta;
end

% Sub-function: Calculate T2
function T2 = calcT2(tissue, B0)
    switch tissue
        case 'GM'
            alpha = 0.064;
            beta = 0.132;
            delta = (1.5 * B0) * 0.001;
        case 'WM'
            alpha = 0.09;
            beta = 0.142;
            delta = (1.5 * B0) * 0.001;
        case 'CSF'
            alpha = 0.1;
            beta = 0;
            delta = 0.003;
        otherwise
            error('Invalid tissue type. Choose ''GM'', ''WM'', or ''CSF''.');
    end
    T2 = alpha * exp(-beta * B0) + delta;
end
