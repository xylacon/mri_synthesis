% plot Ctheta vs Theta %

function plot_flip_angle(theta, contrast, optimal_alpha)
    theta_deg = rad2deg(theta);
    figure;
    plot(theta_deg, contrast, '-b', 'LineWidth', 2);
    hold on; plot(optimal_alpha, max(contrast), 'ro', 'MarkerFaceColor', 'r');
    xlabel('\theta [degrees]'); ylabel('C_\theta'); title('Contrast vs Flip Angle');
    grid on; hold off;
end
