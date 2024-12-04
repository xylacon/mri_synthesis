function generate_relaxation_report(B0, T1, T2, optimal_alpha, slice_snr, patient_id, output_dir)
    % Generate a report summarizing T1, T2*, SNR, and flip angle findings for a patient
    %
    % Inputs:
    %   B0 - Magnetic field strengths (T)
    %   T1 - T1 relaxation times [B0 x Tissues]
    %   T2 - T2* relaxation times [B0 x Tissues]
    %   optimal_alpha - Optimal flip angles [B0 values]
    %   slice_snr - SNR values for the selected slice [B0 x Tissues]
    %   patient_id - ID of the patient
    %   output_dir - Directory to save the report

    % Open file for relaxation report
    report_path = fullfile(output_dir, sprintf('Patient%d_Relaxation_Report.txt', patient_id));
    fid = fopen(report_path, 'w');
    if fid == -1
        error('Could not open file for writing: %s', report_path);
    end

    % Write T1 and T2 findings
    fprintf(fid, 'Relaxation Time Report for Patient %d\n', patient_id);
    fprintf(fid, '--------------------------------------\n\n');
    fprintf(fid, 'T1 vs. B0 Observations:\n');
    fprintf(fid, 'White Matter (WM): T1 increases from %.2f ms at %.1f T to %.2f ms at %.1f T.\n', ...
        T1(1, 1), B0(1), T1(end, 1), B0(end));
    fprintf(fid, 'Gray Matter (GM): T1 increases from %.2f ms at %.1f T to %.2f ms at %.1f T.\n', ...
        T1(1, 2), B0(1), T1(end, 2), B0(end));
    fprintf(fid, 'Cerebrospinal Fluid (CSF): T1 remains constant at %.2f ms.\n\n', T1(1, 3));

    fprintf(fid, 'T2* vs. B0 Observations:\n');
    fprintf(fid, 'White Matter (WM): T2* decreases from %.2f ms at %.1f T to %.2f ms at %.1f T.\n', ...
        T2(1, 1), B0(1), T2(end, 1), B0(end));
    fprintf(fid, 'Gray Matter (GM): T2* decreases from %.2f ms at %.1f T to %.2f ms at %.1f T.\n', ...
        T2(1, 2), B0(1), T2(end, 2), B0(end));
    fprintf(fid, 'Cerebrospinal Fluid (CSF): T2* decreases from %.2f ms at %.1f T to %.2f ms at %.1f T.\n\n', ...
        T2(1, 3), B0(1), T2(end, 3), B0(end));

    % Include SNR vs. B0 Observations
    fprintf(fid, 'SNR vs. B0 Observations (Slice 90):\n');
    fprintf(fid, 'White Matter (WM): SNR increases from %.2f at %.1f T to %.2f at %.1f T.\n', ...
        slice_snr(1, 1), B0(1), slice_snr(end, 1), B0(end));
    fprintf(fid, 'Gray Matter (GM): SNR increases from %.2f at %.1f T to %.2f at %.1f T.\n', ...
        slice_snr(1, 2), B0(1), slice_snr(end, 2), B0(end));
    fprintf(fid, 'Cerebrospinal Fluid (CSF): SNR increases from %.2f at %.1f T to %.2f at %.1f T.\n\n', ...
        slice_snr(1, 3), B0(1), slice_snr(end, 3), B0(end));
    fclose(fid);
    disp(['Relaxation report saved for Patient ', num2str(patient_id), ': ', report_path]);

    % Open file for contrast findings report
    findings_report_path = fullfile(output_dir, sprintf('Patient%d_Contrast_Findings.txt', patient_id));
    fileID = fopen(findings_report_path, 'w');
    if fileID == -1
        error('Could not open file for writing: %s', findings_report_path);
    end

    % Write contrast findings
    fprintf(fileID, 'Findings for Contrast vs Flip Angle - Patient %d\n\n', patient_id);
    fprintf(fileID, '1. Flip Angle (\x03b8) Behavior:\n');
    fprintf(fileID, '- Contrast starts at zero at \x03b8 = 0° and increases to a peak.\n');
    fprintf(fileID, '- The optimal flip angle is observed for each B0 value:\n');
    for b_idx = 1:length(B0)
        fprintf(fileID, '  - B0 = %.1f T: Optimal Flip Angle = %.2f°\n', B0(b_idx), optimal_alpha(b_idx));
    end
    fprintf(fileID, '\n- On average, the optimal flip angle is %.2f°.\n\n', mean(optimal_alpha));

    fprintf(fileID, '2. Contrast Magnitude:\n');
    fprintf(fileID, '- Higher contrast is observed at lower B0 values.\n');
    fprintf(fileID, '- Contrast reduces at higher B0 values.\n\n');
    fprintf(fileID, '3. Recommendations:\n');
    fprintf(fileID, '- Use optimal flip angles to enhance image quality.\n');
    fprintf(fileID, '- Analyze specific tissue types (WM, GM, CSF) for further insights.\n');
    fclose(fileID);
    disp(['Findings for Contrast vs Flip Angle saved for Patient ', num2str(patient_id), ': ', findings_report_path]);
end
