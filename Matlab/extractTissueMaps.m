function [GM, WM, CSF] = extractTissueMaps(patient)
    GM = (patient == 1) | (patient == 2);
    WM = (patient == 3);
    CSF = (patient == 4);
end