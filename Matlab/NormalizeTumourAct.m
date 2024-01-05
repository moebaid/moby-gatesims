%% Load MOBY lesion (tumour) activity file, normalize and save
clc; clear; close all; clc; tic



%% Load
%Define image size
prompt='Give number of voxels in x: ';
xdim=input(prompt);
prompt='Give number of voxels in y: ';
ydim=input(prompt);
prompt='Give number of voxels in z: ';
zdim=input(prompt);

size_image = xdim*ydim*zdim;

%load image
if xdim == 140
    addpath('lesion-maps/25g-140x');
elseif xdim == 80
    addpath('lesion-maps/25g-80x');
end


tumour_sizes = 0.1:0.1:1.0;

for n = 1:numel(tumour_sizes)
    size = sprintf('%0.1f', tumour_sizes(n));
    
    f = strcat('lesion_', size, '-', string(xdim), '_act.raw');
    fid = fopen(f);
    
    source = fread(fid,size_image,'float','l');
    fclose(fid);
    
    source = reshape(source, [xdim, ydim, zdim]);
    
    lesion_res = strcat('lesion_', size, '-', string(xdim));
    path = strcat('lesions/', lesion_res, '/data/');
    
    name_source = strcat(path, 'Source_', lesion_res, '.raw');
    fileID = fopen(name_source,'w');
    fwrite(fileID,source,'float','l');
    fclose(fileID);
    
    % Normalize source for speed up simulation
    total_acc_A = sum(sum(sum(source)));
    source_normalized = source./total_acc_A;

    % now it's a unitless probability image
    name_source_normalized = strcat(path, 'Source_normalized_', lesion_res, '.raw');
    fileID = fopen(name_source_normalized, 'w');
    fwrite(fileID, source_normalized, 'float', 'l');
    fclose(fileID);

    name_total_acc = strcat(path, 'TotalAccA_', lesion_res, '.txt');
    fileID = fopen(name_total_acc, 'w');
    fprintf(fileID, '%.2f', total_acc_A);
    fclose(fileID);

    
end