% computes T1 and T2* relaxation times for WM, GM, and CSF%
function [T1, T2] = compute_relaxation(B0)
    % Computes T1 and T2 relaxation times for WM, GM, and CSF across B0 values
    %
    % Inputs:
    %   B0 - Array of magnetic field strengths (T)
    %
    % Outputs:
    %   T1 - T1 relaxation times (ms) [num_B0 x 3]
    %   T2 - T2 relaxation times (ms) [num_B0 x 3]

    % Relaxation parameters for T1
    T1_params = {...
        [0.00071, 0.382, @(B0) (2 * B0 + 18) * 0.001], ... % WM
        [0.00116, 0.376, @(B0) (5 * B0 + 54) * 0.001], ... % GM
        [4.329, 0, @(~) 200 * 0.001] ...                  % CSF
    };

    % Relaxation parameters for T2
    T2_params = {...
        [0.090, 0.142, @(B0) (1.5 * B0) * 0.001], ... % WM
        [0.064, 0.132, @(B0) (1.5 * B0) * 0.001], ... % GM
        [0.1, 0, @(~) 0.003] ...                     % CSF
    };

    num_B0 = length(B0);
    T1 = zeros(num_B0, 3);
    T2 = zeros(num_B0, 3);

    % Compute T1 and T2 for each tissue
    for t = 1:3
        % T1
        alpha = T1_params{t}(1);
        beta = T1_params{t}(2);
        delta_func = T1_params{t}(3);
        T1(:, t) = alpha * (42.577e6 * B0).^beta + delta_func(B0);

        % T2
        alpha = T2_params{t}(1);
        beta = T2_params{t}(2);
        delta_func = T2_params{t}(3);
        T2(:, t) = alpha * exp(-beta * B0) + delta_func(B0);
    end

    % Convert to milliseconds
    T1 = T1 * 1000;
    T2 = T2 * 1000;
end
