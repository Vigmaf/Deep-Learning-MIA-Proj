clear; clc;

% load your paired table T from the audit step (or rebuild it quickly)
load("pairedTable.mat","T");  % if saved

minArea = 200;
rng(1);
idx = randperm(height(T), 3);

for t=1:numel(idx)
    i=idx(t);
    I=imread(T.imageFile(i));
    [instMasks, labels, stats]=adipocyteInstances(T.maskFile(i), minArea);

    fprintf("[%s] %s -> instances: %d\n", T.Source(i), T.maskFile(i), size(instMasks,3));
    figure;
    imshow(I); hold on;

    % draw boun daries for the first ~30 instances
    K=min(30, size(instMasks,3));
    for k =1:K
        visboundaries(instMasks(:,:,k));
    end
    title(sprintf("Instance boundaries (first %d). Total=%d", K, size(instMasks,3)));
end

overlapCount = sum(sum(sum(instMasks,3) > 1));
fprintf("Overlapping pixels: %d\n", overlapCount); % should be 0
