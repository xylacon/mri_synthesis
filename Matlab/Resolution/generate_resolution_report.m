function generate_resolution_report(metrics, output_file)
    fid = fopen(output_file, 'w');
    fprintf(fid, 'Resolution Metrics Report\n');
    fprintf(fid, '--------------------------\n');
    fields = fieldnames(metrics);
    for i = 1:length(fields)
        metric = metrics.(fields{i});
        fprintf(fid, '%s:\n', fields{i});
        fprintf(fid, '  Image Quality: %.2f\n', metric.quality);
        fprintf(fid, '  Contrast: %.2f\n', metric.contrast);
        fprintf(fid, '  SNR: %.2f\n\n', metric.SNR);
    end
    fclose(fid);
end
