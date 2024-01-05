%% Load MOBY mouse map and lesion attenuation files, merge, convert to CT and save
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
    addpath('lesion-maps/25g-140x')
    fid_atn = fopen('map-140_atn.bin');
    fid_act = fopen('map-140_act.bin');
    vox_size = 0.029; % cm
elseif xdim == 80
    addpath('lesion-maps/25g-80x')
    fid_atn = fopen('map-80_atn.bin');
    fid_act = fopen('map-80_act.bin');
    vox_size = 0.0625; % cm
end

% Read attentuation mouse map
data = fread(fid_atn,size_image,'float','l');
fclose(fid_atn);

%reshape to 3D! Otherwise your data is only 1D array
mouse_map_atn = reshape(data, [xdim, ydim, zdim]);

% Read activity mouse map
data = fread(fid_act,size_image,'float','l');
fclose(fid_act);

%reshape to 3D! Otherwise your data is only 1D array
mouse_map_act = reshape(data, [xdim, ydim, zdim]);


tumour_sizes = 0.1:0.1:1.0;

for n = 1:numel(tumour_sizes)
    
    tumour_size = sprintf('%0.1f', tumour_sizes(n));
    
    lesion_res = strcat('lesion_', tumour_size, '-', string(xdim));
    lesion_path = strcat('lesions/', lesion_res, '/data/');
    
    map_name = strcat('lesion_', tumour_size, '-', string(xdim), '_atn.raw');
    fid_atn = fopen(map_name);
    
    data = fread(fid_atn,size_image,'float','l');
    fclose(fid_atn);
    
    lesion_map_atn = reshape(data, [xdim, ydim, zdim]);
    
    att_map = mouse_map_atn;
    
    att_map(lesion_map_atn ~= 0) = lesion_map_atn(lesion_map_atn ~= 0);
    
    % Save merged attenuation map in units of 1/pixel
    % name_attmap = strcat('lesion-maps/25g-', string(xdim), 'x/atn_map_', lesion_res, '.raw');
    % fileID = fopen(name_attmap,'w');
    % fwrite(fileID,att_map,'float','l');
    % fclose(fileID);
    
    
    att_map = att_map./vox_size; % convert from 1/pixel to 1/cm
    CT = zeros(xdim, ydim, zdim);
    
    for i=1:xdim
        for j=1:ydim
            for k=1:zdim
                if att_map(i,j,k)>= 0.151 % positive slope of HU-mu curve
                    CT(i,j,k)=(att_map(i,j,k)-0.151941)/0.000108;
                else
                    CT(i,j,k)=(att_map(i,j,k)-0.150689)/0.000153;
                end
            end
        end
    end
    
    % Save merged attenuation map in units of HU
    name_CT = strcat(lesion_path, 'CT_', lesion_res, '.raw');
    fileID = fopen(name_CT,'w');
    fwrite(fileID,CT,'float','l');
    fclose(fileID);
    
    
    map_name = strcat('lesion_', tumour_size, '-', string(xdim), '_act.raw');
    fid_act = fopen(map_name);

    data = fread(fid_act,size_image,'float','l');
    fclose(fid_act);

    lesion_map_act = reshape(data, [xdim, ydim, zdim]);

    act_map = mouse_map_act;

    act_map(lesion_map_act ~= 0) = lesion_map_act(lesion_map_act~=0);
    
    
    % Save merged activity map
    name_actmap = strcat('lesion-maps/25g-', string(xdim), 'x/act_map_', lesion_res, '.raw');
    fileID = fopen(name_actmap,'w');
    fwrite(fileID,act_map,'float','l');
    fclose(fileID);
    
    tumour_voxels = size(lesion_map_act(lesion_map_act~=0), 1);
    m = tumour_voxels*vox_size^3;

    fprintf(strcat('Tumour mass: ', string(m), '\n'));

end

    