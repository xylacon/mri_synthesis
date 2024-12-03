function scanType = determine_scan_type(slice, GM, WM, CSF)
    GM_mask = (GM > 0.5);
    WM_mask = (WM > 0.5);
    CSF_mask = (CSF > 0.5);

    % Extract mean intensities for each tissue
    GM_intensity = mean(slice(GM_mask > 0));
    WM_intensity = mean(slice(WM_mask > 0));
    CSF_intensity = mean(slice(CSF_mask > 0));

    % Classify based on intensity relationships
    if CSF_intensity > WM_intensity && WM_intensity > GM_intensity
        scanType = 0; % T1-weighted
    elseif WM_intensity > GM_intensity && GM_intensity > CSF_intensity
        scanType = 1; % T2-weighted
    else
        scanType = -1;
    end
end