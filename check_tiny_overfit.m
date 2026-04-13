clear;clc;
projectRoot = "C:\Users\Admin.VIG\Desktop\MIA_DL_PROJECT";
%load traine detector
load(fullfile(projectRoot, "trainedSOLOV2_small_overfit.mat"), "detector_small");

%load tiny subset used for that training 
load(fullfile(projectRoot, "tiny_overfit_split.mat"),"T_train_small");

target_size=[1024 1024];
min_area=50;
thresholds=[0.50 0.20 0.10 0.05 0.01];

rng(2);
idx=randperm(height(T_train_small),min(3, height(T_train_small)));
for n = 1:numel(idx)
    i = idx(n);

    % Read image and build resized ground truth
    I = read_and_resize_img(T_train_small.imageFile(i), target_size);

    [~, ~, ~, gt_masks] = prepare_sample_for_solov2( ...
        T_train_small.imageFile(i), ...
        T_train_small.maskFile(i), ...
        target_size, ...
        min_area);

    fprintf("\nsmall TRAIN sample %d\n", n);
    fprintf("Image file: %s\n", T_train_small.imageFile(i));
    fprintf("GT count: %d\n", size(gt_masks,3));

    figure;
    tiledlayout(1,numel(thresholds)+1,"Padding","compact","TileSpacing","compact");

    %groud truth img
    nexttile;
    imshow(insertObjectMask(I,gt_masks));
    title(sprintf("GT | %d",size(gt_masks,3)));

    %prediciton at different thersh
    for t = 1:numel(thresholds)
        thr = thresholds(t);

        [pred_masks, ~, pred_scores] = segmentObjects( ...
            detector_small, I, ...
            Threshold = thr, ...
            MaskThreshold = 0.30, ...
            SelectStrongest = false);

        fprintf("thr=%.2f -> predicted=%d", thr, size(pred_masks,3));
        if ~isempty(pred_scores)
            fprintf(" | max score=%.4f\n", max(pred_scores));
        else
            fprintf(" | no scores\n");
        end

        nexttile; 
        if isempty(pred_masks)
            imshow(I);
        else
            imshow(insertObjectMask(I,pred_masks));
        end
        title(sprintf("thr=%.2f | %d",thr,size(pred_masks,3)));
    end
end

