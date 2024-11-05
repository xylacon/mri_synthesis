function T1 = calcT1(tissue, B0)
    % tissue = 'GM', 'WM', 'CSF'
    % B0     = Magnetic field strength (arbitrary units)

    gamma = 42.577e6;

    switch tissue
        case 'GM'
            alpha = 0.00116;
            beta = 0.376;
            delta = (5 * B0 + 54) * 0.001;
        case 'WM'
            alpha = 0.00071;
            beta = 0.382;
            delta = (2 * B0 + 18) * 0.001;
        case 'CSF'
            alpha = 4.329;
            beta = 0;
            delta = 200;
        otherwise
            error('Invalid tissue type. Choose "GM", "WM", or "CSF".');
    end

    T1 = alpha * (gamma * B0)^beta + delta;
end