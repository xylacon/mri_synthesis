function dispSNRvB0(B0, slice, slice_index, patient_index)
    figure('Visible', 'off');
    plot(B0, slice(:, 1), '-o', 'DisplayName', 'GM');
    hold on;
    plot(B0, slice(:, 2), '-o', 'DisplayName', 'WM');
    plot(B0, slice(:, 3), '-o', 'DisplayName', 'CSF');
    xlabel('B0 (T)');
    ylabel('SNR');
    title(['SNR vs B0 for Slice ', num2str(slice_index)]);
    legend;
    grid on;

    % Save in Plots folder
    output_folder = '../Plots';
    output_filename = fullfile(output_folder, sprintf('Patient_%d_slice_%d_SNRvB0.png', patient_index, slice_index));
    saveas(gcf, output_filename);
    close(gcf);
end