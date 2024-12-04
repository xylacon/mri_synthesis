function plot_flip_angle(theta, contrast, optimal_alpha)
    % Converts theta to degrees for plotting
    theta_deg = rad2deg(theta);
    figure;
    plot(theta_deg, contrast, '-b', 'LineWidth', 2); % Plot contrast vs flip angle
    hold on; plot(optimal_alpha, max(contrast), 'ro', 'MarkerFaceColor', 'r'); % Highlight optimal flip angle
    xlabel('\theta [degrees]');
    ylabel('C_\theta');
    title('Contrast vs Flip Angle');
    grid on;
    hold off;
end
