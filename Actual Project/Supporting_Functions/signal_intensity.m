function S = signal_intensity(A, T1, T2, TR, TE)
    % Compute the signal intensity based on MRI physics equation
    S = A * (1 - exp(-TR / T1)) * exp(-TE / T2);
end
