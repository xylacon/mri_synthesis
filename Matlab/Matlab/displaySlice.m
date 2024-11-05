function displaySlice(slice, slice_index, patient_index)
    figure('Name', sprintf('Patient %d', patient_index), 'NumberTitle', 'off');
    imshow(slice, []);
    title(['Slice ', num2str(slice_index)]);
end