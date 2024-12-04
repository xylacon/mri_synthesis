%Compute SNR for WM GM and CSF%

function SNR = compute_SNR(B0, T1, T2, TE, TR, BW, alpha)
    % Computes SNR for WM, GM, and CSF
    %
    % Inputs:
    %   B0 - Magnetic field strength (T)
    %   T1, T2 - Relaxation times (ms)
    %   TE, TR - Echo and repetition times (ms)
    %   BW - Bandwidth
    %   alpha - Flip angle (radians)
    %
    % Outputs:
    %   SNR - Signal-to-noise ratio for each tissue

    TE = TE * 1e-3;
    TR = TR * 1e-3;

    num_tissues = size(T1, 2);
    SNR = zeros(length(B0), num_tissues);

    for t = 1:num_tissues
        SNR(:, t) = (B0 * 1e3 ./ sqrt(BW)) .* sin(alpha) .* ...
                    exp(-TE ./ T2(:, t)) .* ...
                    (1 - exp(-TR ./ T1(:, t))) ./ ...
                    (1 - cos(alpha) .* exp(-TR ./ T1(:, t)));
    end
end
