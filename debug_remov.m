clear; clc;

projectRoot = "C:\Users\Admin.VIG\Desktop\MIA_DL_PROJECT";
load(fullfile(projectRoot, "folderSplit.mat"), "T_train", "T_val", "T_test");

% Pick one removed-looking sample from each split
trainMask = "C:\Users\Admin.VIG\Desktop\MIA_DL_PROJECT\masks\masks\masks MTC\C11-1181_3.png";
valMask   = "C:\Users\Admin.VIG\Desktop\MIA_DL_PROJECT\masks\masks\masks blood vessels\C11-088_10.png";
testMask  = "C:\Users\Admin.VIG\Desktop\MIA_DL_PROJECT\masks\masks\masks MTC2\MB-3387-Arek-May28-1st-002_1.tif";

maskFiles = [trainMask; valMask; testMask];
names = ["train example"; "val example"; "test example"];

areasToTry = [200 50 20 5 1];

for s = 1:numel(maskFiles)
    fprintf("\n===== %s =====\n", names(s));
    fprintf("Mask file: %s\n", maskFiles(s));

    M = imread(maskFiles(s));

    if ndims(M) == 3
        BW = any(M > 0, 3);
    else
        BW = M > 0;
    end

    fprintf("Original nonzero pixels: %d\n", nnz(BW));

    figure;
    imshow(BW);
    title(names(s) + " | raw binary mask");

    for a = 1:numel(areasToTry)
        min_area = areasToTry(a);
        [~, ~, masks] = adipocyte_annotations(maskFiles(s), min_area);
        fprintf("min_area = %d -> objects found = %d\n", min_area, size(masks, 3));
    end
end