function generate_relaxation_report(B0, T1, T2, patient_id, output_dir)
    % Generate a report summarizing T1 and T2* findings for a patient
    %
    % Inputs:
    %   B0 - Magnetic field strengths (T)
    %   T1 - T1 relaxation times [B0 x Tissues]
    %   T2 - T2* relaxation times [B0 x Tissues]
    %   patient_id - ID of the patient
    %   output_dir - Directory to save the report

    % Open file for writing
    report_path = fullfile(output_dir, sprintf('Patient%d_Relaxation_Report.txt', patient_id));
    fid = fopen(report_path, 'w');

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

    fclose(fid);
    disp(['Relaxation report saved for Patient ', num2str(patient_id), ': ', report_path]);
end
