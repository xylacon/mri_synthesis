function TE = calcTE_T2(T2_GM, T2_WM)
    % T2_GM = T2 relaxation time (GM) (milliseconds)
    % T2_WM = T2 relaxation time (WM) (milliseconds)
    
    % Variate TE by increments of 0.4 from 0 to 200
    TE_values = 0:0.4:200;
    
    % Calculate contrast values
    contrast_values = zeros(size(TE_values));
    for i = 1 : length(TE_values)
        TE = TE_values(i);
        contrast_values(i) = calcContrast(TE, T2_GM, T2_WM);
    end

    % Find optimal TE value
    [maxContrast, maxIndex] = max(contrast_values);
    TE = TE_values(maxIndex);

    % Print optimal TE and display graph
    printOptimal(TE, maxContrast, TE_values, contrast_values);
end

function contrast = calcContrast(TE, T2_GM, T2_WM)
    % Convert to seconds
    TE = TE / 1000;
    T2_GM = T2_GM / 1000;
    T2_WM = T2_WM / 1000;
    
    % Compute intensities
    S_GM = exp(-TE / T2_GM);
    S_WM = exp(-TE / T2_WM);

    contrast = abs(S_GM - S_WM);
end

function printOptimal(TE, maxContrast, TE_values, contrast_values)
    % Display optimal TE
    fprintf('Optimal TE: %.2f ms\n', TE);
    fprintf('Maximum Contrast: %.4f\n', maxContrast);

    % Plot contrast vs TE
    figure;
    plot(TE_values, contrast_values, '-b', 'LineWidth', 2);
    xlabel('TE (ms)');
    ylabel('Contrast (C_{TE})');
    title('Contrast (C_{TE}) vs TE');
    grid on;

    % Highlight optimal TE in plot
    hold on;
    plot(TE, maxContrast, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
    text(TE, maxContrast, sprintf('  TE_{optimal} = %.2f ms', TE), 'VerticalAlignment', 'bottom');
    hold off;
end