clear; clc;

% step 1 model setting
class_names = "adipocyte";
input_size = [1024 1024 3];

%start with the light model for a faster baseline
%later if needed can switch to "resnet50-coco"
detector_name = "light-resnet18-coco";


% step 2 create SOLOv2 network configured for out class 
net = solov2(detector_name, class_names, inputSize=input_size);

% step 3 okay show me some
disp(net)
fprintf("Model name : %s\n", net.ModelName);
fprintf("Class name : %s\n", net.ClassNames{1});
fprintf("Input size : [%d %d %d]\n", net.InputSize(1), net.InputSize(2), net.InputSize(3));
disp("Grid sizes:");
disp(net.GridSizes);