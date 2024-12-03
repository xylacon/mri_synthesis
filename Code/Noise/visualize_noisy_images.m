function visualize_noisy_images(noisy_images, B0, selected_B0)
    % Visualizes noisy MRI images for selected B0 values
    %
    % Inputs:
    %   noisy_images - 3D array of noisy images [B0, x, y]
    %   B0 - Array of B0 values (T)
    %   selected_B0 - Indices of B0 values to visualize

    figure;
    for i = 1:length(selected_B0)
        b_idx = selected_B0(i);
        subplot(ceil(sqrt(length(selected_B0))), ceil(sqrt(length(selected_B0))), i);
        imagesc(squeeze(noisy_images(b_idx, :, :))); colormap gray;
        title(sprintf('Noisy Image (B_0 = %.1f T)', B0(b_idx)));
        axis off;
    end
    sgtitle('Noisy MRI Images at Different B_0');
end
