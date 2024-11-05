function T2 = calcT2(tissue, B0)
    % tissue = 'GM', 'WM', 'CSF'
    % B0     = Magnetic field strength (arbitrary units)

    switch tissue
        case 'GM'
            alpha = 0.064;
            beta = 0.132;
            delta = (1.5 * B0) * 0.001;
        case 'WM'
            alpha = 0.09;
            beta = 0.142;
            delta = (1.5 * B0) * 0.001;
        case 'CSF'
            alpha = 0.1;
            beta = 0;
            delta = 0.003;
        otherwise
            error('Invalid tissue type. Choose "GM", "WM", or "CSF".');
    end

    T2 = alpha * exp(-beta * B0) + delta;
end