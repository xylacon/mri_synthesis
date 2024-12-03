%compute echo times (TE), repetition time (TR), and bandwidth (BW)%

function [TE, TR, BW] = compute_TE_TR_BW(T2_WM, B0)
    % Computes TE, TR, and BW
    %
    % Inputs:
    %   T2_WM - T2 relaxation times for white matter (ms)
    %   B0 - Array of magnetic field strengths (T)
    %
    % Outputs:
    %   TE - Echo time (ms)
    %   TR - Repetition time (ms)
    %   BW - Bandwidth (arbitrary units)

    % Dead time constant (s)
    DeadTime = 3e-3;

    % TE and TR computation
    TE = T2_WM / 8; % Use T2 for WM
    TR = 2 * TE;

    % Bandwidth computation
    BW = 1 ./ (2 * TE * 1e-3 - DeadTime); % Convert TE to seconds
end
