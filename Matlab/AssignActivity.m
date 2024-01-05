clear; close all; tic


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
% if size_image == 6553600
    path = 'mouse-maps/25g-128x/';
    fid = fopen([path,'mousemap-128-25g.bin']);
elseif size_image == 1007584
    path = 'mouse-maps/25g-74x/';
    fid = fopen([path,'mousemap-74-25g.bin']);
end

data = fread(fid,size_image,'float','l');
fclose(fid);

%reshape to 3D! Otherwise your data is only 1D array
map = reshape(data, [xdim, ydim, zdim]);
% This command below is only needed for visualization in Matlab
% imagesc(map(:,:,zdim/2));


organs = {'heart'; 'liver'; 'lungs'; 'stomach-wall'; 'pancreas'; 
    'kidneys'; 'spleen'; 'small-intestine'; 'large-intestine'; 
    'bladder'; 'testes'; 'brain'; 'thyroid'; 'body'; 'ribs'; 'spine'; 
    'skull'; 'humerus'; 'radius'; 'ulna'; 'femur'; 'fibula'; 'tibia'; 
    'patella'; 'bones'; 'BM'};

targetMapval = find(ismember(organs, sourceorgan));

source = zeros(xdim, ydim, zdim);

source(map == targetMapval) = 1; 

organres = strcat(sourceorgan, '-', string(xdim));
path = strcat('organs/', organres, '/data/');


name_source = sprintf(strcat(path, 'Source_', organres, '.img'));
fileID = fopen(name_source, 'w');
fwrite(fileID, source,'float','l');
fclose(fileID);


% Normalize source to speed up simulation
total_acc_A = sum(sum(sum(source)));
source_normalized = source./total_acc_A;

% now it's a unitless probability image
name_source_normalized = sprintf(strcat(path, 'Source_normalized_', organres, '.raw'));
fileID = fopen(name_source_normalized, 'w');
fwrite(fileID, source_normalized, 'float', 'l');
fclose(fileID);

name_total_acc = sprintf(strcat(path, 'TotalAccA_', organres, '.txt'));
fileID = fopen(name_total_acc, 'w');
fprintf(fileID, '%.2f', total_acc_A);
fclose(fileID);

toc