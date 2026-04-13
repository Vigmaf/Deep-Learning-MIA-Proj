clear; clc;

projectRoot = "C:\Users\Admin.VIG\Desktop\MIA_DL_PROJECT";

load(fullfile(projectRoot,"trainedSOLOV@_clean_baseline.mat"),"detector");
load(fullfile(projectRoot,"folderSplit_clean.mat"),"T_train_cl");

target_size = [1024 1024];
min_area = 50;
thresholds = [0.50 0.20 0.10 0.05 0.01];

rng(2);
idx = randperm(height(T_train_cl), min(3,height(T_train_cl)));

for n = 1:numel(idx)
    i = idx(n);

    I = read_and_resize_img(T_train_cl.imageFile(i), target_size);
    [~,~,~,gt_masks] = prepare_sample_for_solov2( ...
        T_train_cl.imageFile(i), ...
        T_train_cl.maskFile(i), ...
        target_size, ...
        min_area);

    fprintf("\nTRAIN sample %d\n", n);
    fprintf("GT count: %d\n", size(gt_masks,3));

    for t = 1:numel(thresholds)
        thr = thresholds(t);
        [pred_masks,~,pred_scores] = segmentObjects( ...
            detector, I, ...
            Threshold=thr, ...
            MaskThreshold=0.30, ...
            SelectStrongest=false);

        fprintf("thr=%.2f -> predicted=%d", thr, size(pred_masks,3));
        if ~isempty(pred_scores)
            fprintf(" | max score=%.4f\n", max(pred_scores));
        else
            fprintf(" | no scores\n");
        end
    end
end