function dispSNRvB0(B0, SNR_maps, patient_index)
    figure('Visible', 'off');
    plot(B0, SNR_maps(:, 1), '-o', 'DisplayName', 'GM');
    hold on;
    plot(B0, SNR_maps(:, 2), '-o', 'DisplayName', 'WM');
    plot(B0, SNR_maps(:, 3), '-o', 'DisplayName', 'CSF');
    xlabel('B0 (T)');
    ylabel('SNR');
    title(['SNR vs B0 for Patient '], patient_index);
    legend;
    grid on;

    % Save in Plots folder
    output_folder = '../Plots';
    output_filename = fullfile(output_folder, sprintf('Patient_%d_SNRvB0.png', patient_index));
    saveas(gcf, output_filename);
    close(gcf);
end