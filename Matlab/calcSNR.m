function SNR = calcSNR(patientID, B0, isT2Weighted)
    % tissue = GM, WM, or CSF
    % B0     = Magnetic field strength (arbitrary units)
    % BW     = Bandwidth (arbitrary units)
    % TE     = Echo time (seconds)
    % T1     = Longitudinal relaxation time (seconds)
    % T2     = Transverse relaxation time (seconds)
    % alpha  = Flip angle (radians)
    
     % Default to T1-weighted
    if nargin < 5
        isT2Weighted = false;
    end

    T1 = {calcT1('GM', B0), calcT1('WM', B0), calcT1('CSF', B0)};
    T2 = {calcT2('GM', B0), calcT2('WM', B0), calcT2('CSF', B0)};

    if isT2Weighted
        % Use T2-weighted functions
        TE = calcTE_T2(T2{1}, T2{2}, patientID, B0);
        TR = calcTR(TE);
        BW = calcBW(TE);
        alpha = calcAlpha_T2(TR, T1, patientID, B0);
    else
        % Use T1-weighted functions
        TE = calcTE_T1(T2{2});
        TR = calcTR(TE);
        BW = calcBW(TE);
        alpha = calcAlpha_T1(TR, T1{1}, T1{2}, patientID, B0);
    end

    SNR = zeros(1, 3);
    for i = 1 : 3
        SNR(i) = calculate(B0, T1{i}, T2{i}, TE, TR, BW, alpha);
    end
end
function SNR = calculate(B0, T1, T2, TE, TR, BW, alpha)
    SNR = (B0 * 1e3 / sqrt(BW * TE)) * sin(alpha) * exp(-TE / T2) * (1 - exp(-TR / T1)) / (1 - cos(alpha) * exp(-TR / T1));
end

function T1 = calcT1(tissue, B0)
    % tissue = 'GM', 'WM', 'CSF'
    % B0     = Magnetic field strength (arbitrary units)

    gamma = 42.577e6;

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
            error('Invalid tissue type. Choose "GM", "WM", or "CSF".');
    end

    T1 = alpha * (gamma * B0)^beta + delta;
end

function T2 = calcT2(tissue, B0)
    % tissue = 'GM', 'WM', 'CSF'
    % B0     = Magnetic field strength (arbitrary units)

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
            error('Invalid tissue type. Choose "GM", "WM", or "CSF".');
    end

    T2 = alpha * exp(-beta * B0) + delta;
end

function TE = calcTE_T1(T2_WM)
    % T2_WM = T2 relaxation time (WM) (milliseconds)
    
    TE = T2_WM / 8;
end

function TE = calcTE_T2(T2_GM, T2_WM, patientID, B0)
    % T2_GM = T2 relaxation time (GM) (milliseconds)
    % T2_WM = T2 relaxation time (WM) (milliseconds)
    
    % Variate TE by increments of 0.4 from 0 to 200
    TE_values = 0:0.4:200;
    
    % Calculate contrast values
    contrast_values = zeros(size(TE_values));
    for i = 1 : length(TE_values)
        TE = TE_values(i);
        contrast_values(i) = calcContrast_TE(TE, T2_GM, T2_WM);
    end

    % Find optimal TE value
    [maxContrast, maxIndex] = max(contrast_values);
    TE = TE_values(maxIndex);

    % Print optimal TE and display graph
    printOptimal_TE(TE, maxContrast, TE_values, contrast_values, patientID, B0);
end
function contrast = calcContrast_TE(TE, T2_GM, T2_WM)
    % Convert to seconds
    TE = TE / 1000;
    T2_GM = T2_GM / 1000;
    T2_WM = T2_WM / 1000;
    
    % Compute intensities
    S_GM = exp(-TE / T2_GM);
    S_WM = exp(-TE / T2_WM);

    contrast = abs(S_GM - S_WM);
end

function TR = calcTR(TE)
    TR = 2 * TE;
end

function BW = calcBW(TE)
    % TE = Echo time (seconds)

    DeadTime = 3e-3;
    BW = 1 / (2 * TE - DeadTime);

    if BW < 0
        error('Invalid TE value');
    end
end

function alpha = calcAlpha_T1(TR, T1_GM, T1_WM, patientID, B0)
    % TR    = Repetition time
    % T1_GM = T1 relaxation time (GM) (milliseconds)
    % T1_WM = T1 relaxation time (WM) (milliseconds)
    
    % Angles between 0-180 in 0.2 increments
    theta_range = 0:0.2:180;
    theta_values = deg2rad(theta_range);

    % Calculate contrast values
    contrast_values = zeros(size(theta_values));
    for i = 1 : length(theta_values)
        theta = theta_values(i);
        contrast_values(i) = calcContrast_alpha(theta, TR, T1_GM, T1_WM);
    end

    % Find optimal alpha
    [maxContrast, maxIndex] = max(contrast_values);
    alpha = theta_values(maxIndex);

    % Print optimal alpha and display graph
    printOptimal_alpha(alpha, maxContrast, theta_values, contrast_values, patientID, B0);
end
function contrast = calcContrast_alpha(theta, TR, T1_GM, T1_WM)
    % Convert to seconds
    TR = TR / 1000;
    T1_GM = T1_GM / 1000;
    T1_WM = T1_WM / 1000;
    
    % Compute intensities
    S_GM = (1 - exp(-TR ./ T1_GM)) .* sin(theta) ./ (1 - cos(theta) .* exp(-TR ./ T1_GM));
    S_WM = (1 - exp(-TR ./ T1_WM)) .* sin(theta) ./ (1 - cos(theta) .* exp(-TR ./ T1_WM));

    contrast = abs(S_GM - S_WM);
end

function alpha = calcAlpha_T2(TR, T1, patientID, B0)
    % TR = Repetition time
    % T1 = T1 relaxation time (milliseconds)

    % Convert T1 from cell arr to mat arr
    T1 = cell2mat(T1);
    
    % Calculate Earnst Angle
    EarnstAngle = acos(exp(-TR ./ T1));
    alpha = rad2deg(EarnstAngle);

    % Display graph
    print(alpha, T1, patientID, B0);
end

% Print functions
function printOptimal_TE(TE, maxContrast, TE_values, contrast_values, patientID, B0)
    % For a T2-weighted scan

    % Plot contrast vs TE
    figure('Visible', 'off');
    plot(TE_values, contrast_values, '-b', 'LineWidth', 2);
    xlabel('TE (ms)');
    ylabel('Contrast (C_{TE})');
    title(sprintf('Optimal TE: %.2f ms, Maximum Contrast: %.4f', TE, maxContrast));
    grid on;

    % Highlight optimal TE in plot
    hold on;
    plot(TE, maxContrast, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
    text(TE, maxContrast, sprintf('  TE_{optimal} = %.2f ms', TE), 'VerticalAlignment', 'bottom');
    hold off;

    % Save in Plots folder
    output_folder = '../Plots'; % Folder directory; adjust if needed
    B0_1 = sprintf('%.1f', B0); % Format B0 with one decimal place
    output_filename = fullfile(output_folder, sprintf('Patient_%d_B0_%s_contrast_TE.png', patientID, B0_1));
    saveas(gcf, output_filename); % Saves as png
    close(gcf);
end
function printOptimal_alpha(alpha, maxContrast, theta_values, contrast_values, patientID, B0)
    % For a T1-weighted scan

    % Plot contrast vs alpha
    figure('Visible', 'off');
    plot(theta_values, contrast_values, '-b', 'LineWidth', 2);
    xlabel('alpha (degrees)');
    ylabel('Contrast (C_{theta})');
    title(sprintf('Optimal alpha: %.2f ms, Maximum Contrast: %.4f', alpha, maxContrast));
    grid on;

    % Highlight optimal alpha in plot
    hold on;
    plot(alpha, maxContrast, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
    text(alpha, maxContrast, sprintf('  alpha_{optimal} = %.2f ms', alpha), 'VerticalAlignment', 'bottom');
    hold off;

    % Save in Plots folder
    output_folder = '../Plots'; % Folder directory; adjust if needed
    B0_1 = sprintf('%.1f', B0); % Format B0 with one decimal place
    output_filename = fullfile(output_folder, sprintf('Patient_%d_B0_%s_contrast_alpha.png', patientID, B0_1));
    saveas(gcf, output_filename); % Saves as png
    close(gcf);
end
function print(alpha, T1, patientID, B0)
    % For a T2-weighted scan

    % Plot alpha vs T1_tissue
    figure('Visible', 'off');
    plot(T1, alpha, '-b', 'LineWidth', 2);
    xlabel('T1_{tissue} (ms)');
    ylabel('\alpha (degrees)');
    title('\alpha vs T1_{tissue}');
    grid on;

    % Save in Plots folder
    output_folder = '../Plots'; % Folder directory; adjust if needed
    B0_1 = sprintf('%.1f', B0); % Format B0 with one decimal place
    output_filename = fullfile(output_folder, sprintf('Patient_%d_B0_%s_T1_alpha.png', patientID, B0_1));
    saveas(gcf, output_filename); % Saves as png
    close(gcf);
end