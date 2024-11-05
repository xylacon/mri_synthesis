function SNR = calcSNR(B0, BW, TE, T1, T2, alpha)
    % B0    = Magnetic field strength (arbitrary units)
    % BW    = Bandwidth (arbitrary units)
    % TE    = Echo time (seconds)
    % T1    = Longitudinal relaxation time (seconds)
    % T2    = Transverse relaxation time (seconds)
    % alpha = Flip angle (radians)

    SNR = (B0 * 1e3 / sqrt(BW * TE)) * sin(alpha) * exp(-TE / T2) * (1 - exp(-TR / T1)) / (1 - cos(alpha) * exp(-TR / T1));
end