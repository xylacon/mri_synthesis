%compute the optimal flip angle and Contrast%

function [optimal_alpha, theta, contrast] = compute_flip_angle(TR, T1_WM, T1_GM)
    % Computes the optimal flip angle and contrast vs. flip angle
    %
    % Inputs:
    %   TR - Repetition time (ms)
    %   T1_WM - T1 relaxation time for WM (ms)
    %   T1_GM - T1 relaxation time for GM (ms)
    %
    % Outputs:
    %   optimal_alpha - Optimal flip angle (degrees)
    %   theta - Flip angles tested (degrees)
    %   contrast - Contrast values (C_theta)

    % Define flip angles
    theta = deg2rad(0:0.2:180);
    contrast = zeros(size(theta));

    % Compute contrast
    for i = 1:length(theta)
        S_WM = ((1 - exp(-TR / T1_WM)) * sin(theta(i))) / ...
               (1 - cos(theta(i)) * exp(-TR / T1_WM));
        S_GM = ((1 - exp(-TR / T1_GM)) * sin(theta(i))) / ...
               (1 - cos(theta(i)) * exp(-TR / T1_GM));
        contrast(i) = abs(S_WM - S_GM);
    end

    % Find optimal flip angle
    [~, max_idx] = max(contrast);
    optimal_alpha = rad2deg(theta(max_idx));
end
