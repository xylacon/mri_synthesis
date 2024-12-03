function visualize_signal_intensity(B0, SI)
    % Visualizes Signal Intensity (SI) vs B0 for each tissue
    %
    % Inputs:
    %   B0 - Array of B0 values (T)
    %   SI - Signal Intensity matrix [B0 x Tissues]

    figure;
    plot(B0, SI(:, 1), '-r', 'LineWidth', 2); hold on;
    plot(B0, SI(:, 2), '-g', 'LineWidth', 2);
    plot(B0, SI(:, 3), '-b', 'LineWidth', 2);
    xlabel('Magnetic Field Strength (B_0) [T]');
    ylabel('Signal Intensity (SI)');
    title('Signal Intensity (SI) vs Magnetic Field Strength');
    legend('White Matter (WM)', 'Gray Matter (GM)', 'Cerebrospinal Fluid (CSF)', 'Location', 'NorthWest');
    grid on;
end
