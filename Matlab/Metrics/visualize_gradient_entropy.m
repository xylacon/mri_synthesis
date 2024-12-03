function visualize_gradient_entropy(B0, gEn_values)
    % Visualizes Gradient Entropy trends for CSF, GM, and WM
    %
    % Inputs:
    %   B0 - Array of magnetic field strengths (T)
    %   gEn_values - Matrix of Gradient Entropy values [B0 x Tissues]

    figure;
    plot(B0, gEn_values(:, 1), '-r', 'LineWidth', 2); hold on;
    plot(B0, gEn_values(:, 2), '-g', 'LineWidth', 2);
    plot(B0, gEn_values(:, 3), '-b', 'LineWidth', 2);
    xlabel('B_0 (T)');
    ylabel('Gradient Entropy');
    title('Gradient Entropy vs. B_0');
    legend('CSF', 'GM', 'WM');
    grid on;

    % Save the plot
    saveas(gcf, './Output/gradient_entropy_plot.png');
    disp('Gradient Entropy plot saved.');
end
