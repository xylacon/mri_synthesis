function dispSlice(slice, slice_index, patient_index)
    figure('Name', sprintf('Patient %d', patient_index), 'NumberTitle', 'off', 'Visible', 'off');
    imshow(slice, []);
    title(['Slice ', num2str(slice_index)]);

    % Save in Slices folder
    output_folder = '../Slices';
    output_filename = fullfile(output_folder, sprintf('Patient_%d_slice_%d.png', patient_index, slice_index));
    saveas(gcf, output_filename);
    close(gcf);
end