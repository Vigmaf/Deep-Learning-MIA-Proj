function [instMasks, labels, stats] = adipocyteInstances(maskFile, minArea)
% convert a binary adipocyte mask into per instance mask for SOLOv2
% instMasks: HxWxN logical, one slice per adipocyte instance
% labels   : Nx1 categorical ("adipocyte")
% stats    : regionprops table (Area, BoundingBox, etc.) for debugging/QA


if nargin < 2
    minArea = 200;
end
M=imread(maskFile);
%robust binarization (handles indexed/gray/RGB
if ndims(M) == 3
    BW = any(M > 0, 3);
else
    BW = M > 0;
end

%basic cleanup (help remove tiny artifacts)
BW=bwareaopen(BW,minArea);
BW=imfill(BW,"holes");

CC=bwconncomp(BW,8);
stats=regionprops(CC,"Area","BoundingBox","Centroid");

keep = find([stats.Area] >= minArea);
N=numel(keep);

[h,w] = size(BW);
instMasks = false(h,w,N);

for i =1:N
    k=keep(i);
    tmp=false(h,w);
    tmp(CC.PixelIdxList{k}) = true;
    instMasks(:,:,i) =tmp;
end
labels = categorical(repmat("adipocyte",N,1));


fprintf("Before filtering: %d, after filtering: %d\n", CC.NumObjects, N);

end