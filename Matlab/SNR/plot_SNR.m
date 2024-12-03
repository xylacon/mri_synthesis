%plot SNR vs B0 for WM GM and CSF %

function plot_SNR(B0, SNR)
    figure;
    plot(B0, SNR(:, 1), '-r', 'LineWidth', 2); hold on;
    plot(B0, SNR(:, 2), '-g', 'LineWidth', 2);
    plot(B0, SNR(:, 3), '-b', 'LineWidth', 2);
    xlabel('B_0 [T]'); ylabel('SNR'); title('SNR vs B0');
    legend('WM', 'GM', 'CSF'); grid on;
end
