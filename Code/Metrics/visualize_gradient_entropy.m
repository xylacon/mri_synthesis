function visualize_gradient_entropy(B0, gEn_values, patient_id, output_dir)
    % Visualizes Gradient Entropy trends for CSF, GM, and WM
    % Inputs:
    %   B0 - Array of magnetic field strengths (T)
    %   gEn_values - Matrix of Gradient Entropy values [B0 x Tissues]
    %   patient_id - Index of the patient for labeling
    %   output_dir - Directory where the plot will be saved

    figure;
    plot(B0, gEn_values(:, 1), '-r', 'LineWidth', 2); hold on;
    plot(B0, gEn_values(:, 2), '-g', 'LineWidth', 2);
    plot(B0, gEn_values(:, 3), '-b', 'LineWidth', 2);
    xlabel('B_0 (T)');
    ylabel('Gradient Entropy');
    title(['Gradient Entropy vs B_0 for Patient ', num2str(patient_id)]);
    legend('CSF', 'GM', 'WM');
    grid on;

    % Save the plot
    plot_path = fullfile(output_dir, sprintf('Patient%d_Gradient_Entropy.png', patient_id));
    saveas(gcf, plot_path);
    disp(['Gradient Entropy plot saved for Patient ', num2str(patient_id), ': ', plot_path]);
end
