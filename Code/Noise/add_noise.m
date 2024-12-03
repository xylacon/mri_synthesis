function noisy_images = add_noise(patients, slice_num, sigma_n, patient_id)
    % Adds Gaussian noise to an MRI slice for all B0 values

    % Access the 3D data from the 'data' field
    patient_data = patients{patient_id}.data;

    % Check if slice_num is within bounds
    if slice_num > size(patient_data, 3)
        error('slice_num exceeds the number of slices for the given patient.');
    end

    % Extract the specified slice and convert to double
    num_B0 = length(sigma_n); % Number of B0 values
    original_slice = double(patient_data(:, :, slice_num)); % Convert to double
    noisy_images = zeros(num_B0, size(original_slice, 1), size(original_slice, 2)); % Preallocate

    % Compute the intensity range of the original slice
    slice_range = max(original_slice(:)) - min(original_slice(:));
    if slice_range == 0
        slice_range = 1; % Prevent division by zero for uniform slices
    end

    for b = 1:num_B0
        % Scale noise to a fraction of the slice intensity range
        noise_scale = sigma_n(b) * (slice_range / 100); % Adjust factor
        noise = normrnd(0, noise_scale, size(original_slice)); % Generate noise
        noisy_image = original_slice + noise; % Add noise to slice

        % Clip noisy image values to the valid range of the original slice
        noisy_image = max(min(noisy_image, max(original_slice(:))), min(original_slice(:)));

        noisy_images(b, :, :) = noisy_image; % Store clipped noisy image
    end

    % Debug output
    disp('Range of original slice:');
    disp([min(original_slice(:)), max(original_slice(:))]);

    disp('Range of noise:');
    disp([min(noise(:)), max(noise(:))]);

    disp('Range of noisy image:');
    disp([min(noisy_images(:)), max(noisy_images(:))]);
end
