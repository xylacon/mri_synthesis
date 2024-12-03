%plot T1 and T2* vs B0 %

function plot_relaxation_times(B0, T1, T2)
    figure;
    plot(B0, T1(:, 1), '-r', 'LineWidth', 2); hold on;
    plot(B0, T1(:, 2), '-g', 'LineWidth', 2);
    plot(B0, T1(:, 3), '-b', 'LineWidth', 2);
    xlabel('B_0 [T]'); ylabel('T1 [ms]'); title('T1 vs B0');
    legend('WM', 'GM', 'CSF'); grid on;

    figure;
    plot(B0, T2(:, 1), '-r', 'LineWidth', 2); hold on;
    plot(B0, T2(:, 2), '-g', 'LineWidth', 2);
    plot(B0, T2(:, 3), '-b', 'LineWidth', 2);
    xlabel('B_0 [T]'); ylabel('T2* [ms]'); title('T2* vs B0');
    legend('WM', 'GM', 'CSF'); grid on;
end
