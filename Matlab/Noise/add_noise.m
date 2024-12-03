function noisy_images = add_noise(patients, slice_num, sigma_n, patient_id)
    % Adds Gaussian noise to an MRI slice for all B0 values
    %
    % Inputs:
    %   patients - Cell array of patient MRI data
    %   slice_num - Slice index to process
    %   sigma_n - Noise variance for each B0 value
    %   patient_id - Index of the patient
    %
    % Outputs:
    %   noisy_images - 3D array of noisy images [B0, x, y]

    num_B0 = length(sigma_n); % Number of B0 values
    original_slice = patients{patient_id}(:, :, slice_num); % Extract slice
    noisy_images = zeros(num_B0, size(original_slice, 1), size(original_slice, 2)); % Preallocate

    for b = 1:num_B0
        % Add Gaussian noise to the slice
        noise = normrnd(0, sigma_n(b), size(original_slice));
        noisy_images(b, :, :) = original_slice + noise;
    end
end
