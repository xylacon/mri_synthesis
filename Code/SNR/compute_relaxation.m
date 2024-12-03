function [T1, T2] = compute_relaxation(B0)
    % Initialize relaxation times
    num_B0 = length(B0);
    T1 = zeros(num_B0, 3); % WM, GM, CSF
    T2 = zeros(num_B0, 3); % WM, GM, CSF

    % T1 relaxation times (ms)
    T1(:, 1) = 900 + 300 * log(B0);    % WM
    T1(:, 2) = 1200 + 400 * log(B0);   % GM
    T1(:, 3) = 2000 + 500 * log(B0);   % CSF

    % T2 relaxation times (ms)
    T2(:, 1) = 80 - 5 * B0;  % WM
    T2(:, 2) = 100 - 6 * B0; % GM
    T2(:, 3) = 300 - 20 * B0; % CSF
end
