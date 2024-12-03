function visualize_sharpness_profiles(B0, sharpness_profiles)
    % Visualizes Sharpness Profile trends for CSF to WM transitions
    %
    % Inputs:
    %   B0 - Array of magnetic field strengths (T)
    %   sharpness_profiles - Array of sharpness profile values

    figure;
    plot(B0, sharpness_profiles, '-o', 'LineWidth', 2);
    xlabel('B_0 (T)');
    ylabel('Sharpness Profile (k)');
    title('Sharpness Profile vs. B_0');
    grid on;

    % Save the plot
    saveas(gcf, './Output/sharpness_profile_plot.png');
    disp('Sharpness Profile plot saved.');
end
