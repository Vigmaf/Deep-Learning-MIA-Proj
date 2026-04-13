clear;clc;

projectRoot = "C:\Users\Admin.VIG\Desktop\MIA_DL_PROJECT";
load(fullfile(projectRoot, "folderSplit.mat"), "T_train", "T_val");

target_size = [1024 1024];
min_area = 200;

%Index datastores
ads_train=arrayDatastore((1:height(T_train))',"IterationDimension",1);%datastore for in memory format
ads_val=arrayDatastore((1:height(T_val))',"IterationDimension",1);

%this part transforms into solov2 format datastores
ds_train=transform(ads_train, @(idx) make_SOLOv2_cell(idx, T_train,target_size, min_area));
ds_val=transform(ads_val, @(idx) make_SOLOv2_cell(idx, T_val,target_size, min_area));

% check one sample from each datastore
sample_train=read(ds_train);
sample_val=read(ds_val);

disp("Train sample format: ");
disp(size(sample_train));
disp(class(sample_train{1})); %image
disp(size(sample_train{1}));
disp(size(sample_train{2})); %bboxes
disp(class(sample_train{3})); % labels
disp(size(sample_train{4}));% masks

disp("Validation sample format: ");
disp(size(sample_val));
disp(class(sample_val{1})); 
disp(size(sample_val{1}));
disp(size(sample_val{2})); 
disp(class(sample_val{3})); 
disp(size(sample_val{4}));

reset(ds_train);
reset(ds_val);