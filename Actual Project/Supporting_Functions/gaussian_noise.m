function noisy_image = gaussian_noise(image, noise_level)
    % Add Gaussian noise to an image
    noise = randn(size(image)) * noise_level;
    noisy_image = image + noise;
end
