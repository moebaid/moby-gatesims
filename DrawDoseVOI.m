clear all; close all; clc; restoredefaultpath; tic

prompt = "Give source organ: ";
sourceorgan = input(prompt, 's');

% number of voxels
prompt='Give number of voxels in x: ';
xdim=input(prompt);
prompt='Give number of voxels in y: ';
ydim=input(prompt);
prompt='Give number of voxels in z: ';
zdim=input(prompt);


% voxel size in mm
prompt='Give voxel size in mm in x: ';
xsize=input(prompt);
prompt='Give voxel size in mm in y: ';
ysize=input(prompt);
prompt='Give voxel size in mm in z: ';
zsize=input(prompt);


size_image=xdim*ydim*zdim;

doseImg = [sourceorgan, '/Dose_total(', sourceorgan, ').img'];
doseUncImg = [sourceorgan, '/Rel_uncertainty(', sourceorgan, ').img'];

%load image
if size_image == 65536000
    mouseMap = 'mousemap-256.bin';
elseif size_image == 8192000
    mouseMap = 'mousemap-128.raw';
end

savefile = [sourceorgan, 'source.csv'];

fDose = fopen(doseImg);
doseData = fread(fDose, size_image, 'float', 'l');
fclose(fDose);
dose = reshape(doseData, [xdim, ydim, zdim]);

fDoseUnc = fopen(doseUncImg);
doseUncdata = fread(fDoseUnc, size_image, 'float', 'l');
fclose(fDoseUnc);
doseUnc = reshape(doseUncdata, [xdim, ydim, zdim]);



fMap = fopen(mouseMap);
mapData = fread(fMap, size_image, 'float', 'l');
fclose(fMap);
map = reshape(mapData, [xdim, ydim, zdim]);

% Initialize VOIs
doseVOI = zeros([xdim, ydim, zdim]);
doseUncVOI = zeros([xdim, ydim, zdim]);

S = zeros(26,1);
U = zeros(26,1);
Vols = zeros(26,1);

for i = 1:26
    % Identify target organ
    targetMapval = i;
    
    % Voxels in VOI for target organ
    Nvox = size(map(map == targetMapval));
    Nvox = Nvox(1);
    
    % Calculate mean dose in VOI
    totalDose = sum(dose(map == targetMapval));
    meanDose = totalDose/Nvox;
    S(i) = meanDose; 
    
    % Calculate mean dose uncertainty in VOI
    totalDoseUnc = sum(doseUnc(map == targetMapval));
    meanDoseUnc = totalDoseUnc/Nvox;
    U(i) = meanDoseUnc;
    
    % Calculate VOI volume in mm^3    
    VOIvol = Nvox*xsize*ysize*zsize; 
    Vols(i) = VOIvol;
end

Uncertainty = U;
Volume = Vols;
organs = {'Heart'; 'Liver'; 'Lungs'; 'Stomach wall'; 'Pancreas'; 
    'Kidneys'; 'Spleen'; 'Small intestine'; 'Large intestine'; 
    'Bladder'; 'Testes'; 'Brain'; 'Thyroid'; 'ROB'; 'Ribs'; 'Spine'; 
    'Skull'; 'Humerus'; 'Radius'; 'Ulna'; 'Femur'; 'Fibula'; 'Tibia'; 
    'Patella'; 'Remaining bones'; 'BM'};

T = table(S, Uncertainty, Volume, 'RowNames', organs);
writetable(T, savefile, 'WriteRowNames',true)


toc

