%% Load MOBY mouse map attenuation file, convert to CT and save
clc; clear all; close all; clc; tic



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
if size_image == 65536000
    path = 'mouse-maps/256x/';
    fid = fopen([path,'mousemap-256_atn_1.bin']);
    vox_size = 0.0145; % cm
elseif size_image == 6553600
    path = 'mouse-maps/128x/'; 
    fid = fopen([path,'mousemap-128_atn_1.bin']);
    vox_size = 0.029; % cm
elseif size_image == 1078000
    path = 'mouse-maps/70x/'; 
    fid = fopen([path, 'mousemap-70_atn_1.bin']);
    vox_size = 0.05; % cm
elseif size_image == 1007584
    path = 'mouse-maps/74x/'; 
    fid = fopen([path,'mousemap-74_atn_1.bin']);
    vox_size = 0.0625; % cm
end

data = fread(fid,size_image,'float','l');
fclose(fid);

%reshape to 3D! Otherwise your data is only 1D array
attmap = reshape(data, [xdim, ydim, zdim]); % unit is [1/pixel]

%This command below is only needed for visualization in Matlab
imagesc(attmap(:,:,floor(zdim/2)))
% attmap(:,:,500)
% max(max(max(attmap)))
% mean(mean(mean(attmap)))
% min(min(min(attmap)))

%% Convert
attmap = attmap./vox_size; % convert from 1/pixel to 1/cm

for i=1:xdim
    for j=1:ydim
        for k=1:zdim
            if attmap(i,j,k)>= 0.151 % positive slope of HU-mu curve
                CT(i,j,k)=(attmap(i,j,k)-0.151941)/0.000108;
            else
                CT(i,j,k)=(attmap(i,j,k)-0.150689)/0.000153;
            end
        end
    end
end
%% Save
% unit is

name_CT = sprintf(strcat(path,'CT-', string(xdim), '.raw'));
fileID = fopen(name_CT,'w');
fwrite(fileID,CT,'float','l');
fclose(fileID);


toc