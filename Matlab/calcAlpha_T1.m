function alpha = calcAlpha_T1(TR, T1_GM, T1_WM)
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
        contrast_values(i) = calcContrast(theta, TR, T1_GM, T1_WM);
    end

    % Find optimal alpha
    [maxContrast, maxIndex] = max(contrast_values);
    alpha = theta_values(maxIndex);

    % Print optimal alpha and display graph
    printOptimal(alpha, maxContrast, theta_values, contrast_values);
end

function contrast = calcContrast(theta, TR, T1_GM, T1_WM)
    % Convert to seconds
    TR = TR / 1000;
    T1_GM = T1_GM / 1000;
    T1_WM = T1_WM / 1000;
    
    % Compute intensities
    S_GM = (1 - exp(-TR ./ T1_GM)) .* sin(theta) ./ (1 - cos(theta) .* exp(-TR ./ T1_GM));
    S_WM = (1 - exp(-TR ./ T1_WM)) .* sin(theta) ./ (1 - cos(theta) .* exp(-TR ./ T1_WM));

    contrast = abs(S_GM - S_WM);
end

function printOptimal(alpha, maxContrast, theta_values, contrast_values)
    % Display optimal alpha
    fprintf('Optimal alpha: %.2f ms\n', alpha);
    fprintf('Maximum Contrast: %.4f\n', maxContrast);

    % Plot contrast vs alpha
    figure;
    plot(theta_values, contrast_values, '-b', 'LineWidth', 2);
    xlabel('alpha (degrees)');
    ylabel('Contrast (C_{theta})');
    title('Contrast (C_{theta}) vs alpha');
    grid on;

    % Highlight optimal alpha in plot
    hold on;
    plot(alpha, maxContrast, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
    text(alpha, maxContrast, sprintf('  alpha_{optimal} = %.2f ms', alpha), 'VerticalAlignment', 'bottom');
    hold off;
end