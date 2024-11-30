function contrast = calculate_contrast(TE, T2_GM, T2_WM)
    % Calculate the contrast based on the difference in signal intensities between GM and WM
    TE = TE / 1000;  % Convert TE to seconds
    T2_GM = T2_GM / 1000;  % Convert T2 to seconds
    T2_WM = T2_WM / 1000;  % Convert T2 to seconds

    S_GM = exp(-TE / T2_GM);
    S_WM = exp(-TE / T2_WM);

    contrast = abs(S_GM - S_WM);
end
