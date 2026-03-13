%% dataset_audit.m
% Goal: pair image/mask files, verify they match, and inspect mask format.

clear; clc;

mtcImagesDir = "C:\Users\Admin.VIG\Desktop\MIA_DL_PROJECT\images\images\images MTC";   
mtcMasksDir  = "C:\Users\Admin.VIG\Desktop\MIA_DL_PROJECT\masks\masks\masks MTC";

tcgaImagesDir = "C:\Users\Admin.VIG\Desktop\MIA_DL_PROJECT\images\images\images TCGA";
tcgaMasksDir  = "C:\Users\Admin.VIG\Desktop\MIA_DL_PROJECT\masks\masks\masks TCGA";

% ==================

pairsMTC = build_pairs(mtcImagesDir, mtcMasksDir, ".tif", ".png");
pairsTCGA = build_pairs(tcgaImagesDir, tcgaMasksDir, ".tif", ".png");

T = [add_source(pairsMTC, "MTC"); add_source(pairsTCGA, "TCGA")];


%
fprintf("Total paired samples: %d\n", height(T));
disp(groupcounts(T,"Source"));

% Check that image and mask sizes match for a random subset
rng(0);
k = min(10, height(T));
idx=randperm(height(T),k);

sizeOK= true(k,1);
maskBinaryLikely=true(k,1);

for i = 1:k
    I = imread(T.imageFile(idx(i)));
    M = imread(T.maskFile(idx(i)));

    sizeOK(i) = isequal(size(I,1), size(M,1)) && isequal(size(I,2), size(M,2));

    % "Binary likely" test: number of unique values after >0 thresholding
    if ndims(M) == 3
        BW = any(M > 0, 3);
    else
        BW = M > 0;
    end
    maskBinaryLikely(i) = numel(unique(BW(:))) <= 2;
end

fprintf("Size match (random %d): %d/%d\n", k, sum(sizeOK), k);
fprintf("Binary-like masks (random %d): %d/%d\n", k, sum(maskBinaryLikely), k);

% Visualize one random paired example with mask overlay
j = idx(1);
I = imread(T.imageFile(j));
M = imread(T.maskFile(j));
BW = (ndims(M)==3) .* any(M>0,3) + (ndims(M)~=3) .* (M>0);
BW = BW > 0;

figure;
imshow(I); hold on;
h = imshow(cat(3, ones(size(BW)), zeros(size(BW)), zeros(size(BW))));
set(h, "AlphaData", 0.25 * BW);
title("Random sample: image with mask overlay");

save("pairedTable.mat","T");