%% Build one master paired table from ALL main datset folders

clear; clc;

projectRoot = "C:\Users|Admin.VIG\Desktop\MIA_DL_PROJECT";
imagesRoot = fullfile(projectRoot, "images", "images");
masksRoot= fullfile(projectRoot, "masks","masks");

% ---- Define (image folder -> mask folder) mapping explicilty ----
sources = [
    struct("name","blood_vessels", ...
        "imgDir", fullfile(imagesRoot, "images blood vessels"), ...
        "maskDir", fullfile(masksRoot, "masks blood vessels"))

    struct("name","MTC", ...
        "imgDir", fullfile(imagesRoot, "images MTC"), ...
        "maskDir", fullfile(masksRoot, "masks MTC"))

    struct("name","MTC2", ...
        "imgDir", fullfile(imagesRoot, "images MTC2"), ...
        "maskDir", fullfile(masksRoot, "masks MTC2"))
    struct("name","TCGA", ...
        "imgDir", fullfile(imagesRoot, "images TCGA"), ...
        "maskDir", fullfile(masksRoot, "masks TCGA"))

    struct("name","omental_1", ...
        "imgDir", fullfile(imagesRoot, "images omental part 1"), ...
        "maskDir", fullfile(masksRoot, "masks omental mets part 1"))

    struct("name","omental_2", ...
        "imgDir", fullfile(imagesRoot, "images omental part 2"), ...
        "maskDir", fullfile(masksRoot, "masks omental mets part 2"))

    struct("name", "GTX", ...
    "imgDir", fullfile(imagesRoot, "images GTX"), ...
    "maskDir",fullfile(masksRoot,"masks unet GTX"))

    struct("name","GTX_1024", ...
        "imgDir", fullfile(imagesRoot, "images GTX 1024"), ...
        "maskDir", fullfile(masksRoot, "masks unet GTX 1024"))
];
% building the actual master table
TALL  = table();

for s = 1:numel(sources)
    src = sources(s);

    assert(isfolder(src.imgDir), "Missing images folder "+src.imgDir);
    assert(isfolder(src.maskDir), "Missing masks folder: " + src.maskDir);
    P=build_pairs(src.imgDir, src.maskDir, ".tif", ".png");
    P=addSource(P,src.name);

    fprintf("%-15s -> paired: %d\n", src.name, height(P));
    TAll = [TAll; P];
end

fprintf("\nTOTAL paired samples: %d\n", height(TAll));
disp(groupcounts(TAll,"Source"));


% quick checks random subset
rng(0);
k=min(20, height(TALL));
idx=randperm(height(TALL),k);

sizeOK = true(k,1);
binaryLikely=true(k,1);
for i = 1:k
    I = imread(TAll.imageFile(idx(i)));
    M = imread(TAll.maskFile(idx(i)));

    sizeOK(i) = isequal(size(I,1), size(M,1)) && isequal(size(I,2), size(M,2));

    if ndims(M) == 3
        BW = any(M > 0, 3);
    else
        BW = M > 0;
    end
    binaryLikely(i) =numel(unique(BW(:))) <=2;
end

fprintf("Size match (random %d): %d/%d\n", k, sum(sizeOK), k);
fprintf("Binary-like masks (random %d): %d/%d\n", k, sum(binaryLikely), k);

% ---- Save  ----
save(fullfile(projectRoot, "TAll.mat"), "TAll", "sources");
disp("Saved: TAll.mat");