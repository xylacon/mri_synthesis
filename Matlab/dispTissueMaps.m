function dispTissueMaps(tissue_maps, slice_index, patient_index)
    % tissue_maps = {GM, WM, CSF}

    figure('Name', sprintf('Patient %d', patient_index), 'NumberTitle', 'off', 'Visible', 'off');
    
    subplot(1, 3, 1);
    imshow(tissue_maps{1}(:, :, slice_index), []);
    title('Gray Matter (GM)');
    
    subplot(1, 3, 2);
    imshow(tissue_maps{2}(:, :, slice_index), []);
    title('White Matter (WM)');
    
    subplot(1, 3, 3);
    imshow(tissue_maps{3}(:, :, slice_index), []);
    title('Cerebrospinal Fluid (CSF)');

    % Save in Maps folder
    output_folder = '../Maps';
    output_filename = fullfile(output_folder, sprintf('Patient_%d.png', patient_index));
    saveas(gcf, output_filename);
    close(gcf);
end