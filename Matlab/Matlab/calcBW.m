function BW = calcBW(TE)
    % TE = Echo time (seconds)

    DeadTime = 3e-3;
    BW = 1 / (2 * TE - DeadTime);

    if BW < 0
        error('Invalid TE value');
    end
end