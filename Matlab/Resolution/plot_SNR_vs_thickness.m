function plot_SNR_vs_thickness(slice_thicknesses, SNR_values, resolutions, contrast_values)
    % Plots SNR vs slice thickness for different resolutions
    % slice_thicknesses: Array of slice thickness values
    % SNR_values: Matrix of SNR values [resolutions x slice_thicknesses]
    % resolutions: Cell array of resolutions (e.g., {[1 1], [2 2]})
    % contrast_values: Matrix of contrast values [resolutions x slice_thicknesses]

    figure;
    hold on;
    for r = 1:size(SNR_values, 1)
        plot(slice_thicknesses, SNR_values(r, :), '-o', 'LineWidth', 2, 'DisplayName', ...
             sprintf('%dx%d mm', resolutions{r}(1), resolutions{r}(2)));
        % Annotate contrast values
        for t = 1:length(slice_thicknesses)
            text(slice_thicknesses(t), SNR_values(r, t), sprintf('C=%.2f', contrast_values(r, t)), ...
                'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center');
        end
    end
    xlabel('Slice Thickness (mm)');
    ylabel('SNR');
    title('SNR vs Slice Thickness for Different Resolutions');
    legend('show');
    grid on;

    % Save the plot
    saveas(gcf, './Output/SNR_vs_Slice_Thickness.png');
end
