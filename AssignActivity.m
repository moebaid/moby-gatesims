clc; clear all; close all; tic


prompt = "Give source organ: ";
sourceorgan = input(prompt, 's');


%Define image size
prompt='Give number of voxels in x: ';
xdim=input(prompt);
prompt='Give number of voxels in y: ';
ydim=input(prompt);
prompt='Give number of voxels in z: ';
zdim=input(prompt);

size_image = xdim*ydim*zdim;

%load image
if size_image == 65536000
    fid = fopen('mousemap-256.bin');
elseif size_image == 8192000
    fid = fopen('mousemap-128.raw');
end

data = fread(fid,size_image,'float','l');
fclose(fid);

%reshape to 3D! Otherwise your data is only 1D array
map = reshape(data, [xdim, ydim, zdim]);
%This command below is only needed for visualization in Matlab
imagesc(map(:,:,500));

organs = {'heart'; 'liver'; 'lungs'; 'stomach wall'; 'pancreas'; 
    'kidneys'; 'spleen'; 'small intestine'; 'large intestine'; 
    'bladder'; 'testes'; 'brain'; 'thyroid'; 'body'; 'ribs'; 'spine'; 
    'skull'; 'humerus'; 'radius'; 'ulna'; 'femur'; 'fibula'; 'tibia'; 
    'patella'; 'bones'; 'BM'};

targetMapval = find(ismember(organs, sourceorgan));

source = zeros(xdim, ydim, zdim);

source(map == targetMapval) = 1; 

path = [sourceorgan, '/data/'];

% unit is
name_source = sprintf([path, 'Source_', sourceorgan, '.img']);
fileID = fopen(name_source, 'w');
fwrite(fileID, source,'float','l');
fclose(fileID);


% Normalize source for speed up simulation
total_acc_A = sum(sum(sum(source)));
source_normalized = source./total_acc_A;

% now it's a unitless probability image
name_source_normalized = sprintf([path, 'Source_normalized_', sourceorgan, '.raw']);
fileID = fopen(name_source_normalized, 'w');
fwrite(fileID, source_normalized, 'float', 'l');
fclose(fileID);

name_total_acc = sprintf([path, 'TotalAccA_', sourceorgan, '.txt']);
fileID = fopen(name_total_acc, 'w');
fprintf(fileID, '%.2f', total_acc_A);
fclose(fileID);

toc
