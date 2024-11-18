function alpha = calcAlpha_T2(TR, T1)
    % TR = Repetition time
    % T1 = T1 relaxation time (milliseconds)

    % Convert T1 from cell arr to mat arr
    T1 = cell2mat(T1);
    
    % Calculate Earnst Angle
    EarnstAngle = acos(exp(-TR ./ T1));
    alpha = rad2deg(EarnstAngle);

    % Display graph
    print(alpha, T1);
end

function print(alpha, T1)
    % Plot alpha vs T1_tissue
    figure;
    plot(T1, alpha, '-b', 'LineWidth', 2);
    xlabel('T1_{tissue} (ms)');
    ylabel('\alpha (degrees)');
    title('\alpha vs T1_{tissue}');
    grid on;
end