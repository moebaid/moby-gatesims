clear; close all; clc; restoredefaultpath; tic

prompt = "Give source organ: ";
sourceorgan = input(prompt, 's');

% Number of primary, independent histories 
prompt='Give no. of total events: ';
totalevents=input(prompt);

if contains(sourceorgan, 'lesion')
    path = strcat('lesions/', sourceorgan);
    addpath('lesion-maps');
else 
    path = strcat('organs/', sourceorgan);
    addpath('mouse-maps');
end

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
voxel_volume=xsize*ysize*zsize;

doseImg = [path, '/Dose_total-', sourceorgan, '.img'];


doseUncImg = [path, '/Stat_uncertainty-', sourceorgan, '.img'];

%load image
if contains(sourceorgan, 'lesion')
    if xdim == 140
        mapPath = strcat('lesion-maps/25g-140x/act_map_', sourceorgan, '.raw');
    elseif xdim == 80
        mapPath = strcat('lesion-maps/25g-80x/act_map_', sourceorgan, '.raw');
    end
 else
    if xdim == 128
        mapPath = 'mouse-maps/25g-128x/mousemap-128-25g.bin';
    elseif xdim == 74
        mapPath = 'mouse-maps/25g-74x/mousemap-74-25g.bin';
    end
end

fMap = fopen(mapPath);
mapData = fread(fMap, size_image, 'float', 'l');
fclose(fMap);
mouseMap = reshape(mapData, [xdim, ydim, zdim]);

fDose = fopen(doseImg);
doseData = fread(fDose, size_image, 'float', 'l');
fclose(fDose);
doseData = reshape(doseData, [xdim, ydim, zdim]);

fDoseUnc = fopen(doseUncImg);
doseUncdata = fread(fDoseUnc, size_image, 'float', 'l');
fclose(fDoseUnc);
doseUnc = reshape(doseUncdata, [xdim, ydim, zdim]);

doseUncSq = doseUnc.^2;

% Initialize VOIs
doseVOI = zeros([xdim, ydim, zdim]);
doseUncVOI = zeros([xdim, ydim, zdim]);

Dose = zeros(26,1);
U = zeros(26,1);
S_U = zeros(26,1);
Vols = zeros(26,1);

for i = 1:27
    % Identify target organ
    targetMapval = i;
    
    % Voxels in VOI for target organ
    Nvox = size(mouseMap(mouseMap == targetMapval), 1);
    Vols(i) = Nvox;
    
    % Calculate mean dose in VOI
    totalDose = sum(doseData(mouseMap == targetMapval));
    Dose(i) = totalDose;
    
    % Calculate mean dose uncertainty in VOI
    totalDoseUnc = sum(doseUnc(mouseMap == targetMapval));
    U(i) = totalDoseUnc;

    % Calculate S uncertainty in VOI
    RMSDoseUnc = sqrt(sum(doseUncSq(mouseMap == targetMapval)));
    S_U(i) = RMSDoseUnc/Nvox;

    if (i==26) && (~contains(sourceorgan, 'lesion'))
        break
    end
end

% Define VOI of total skeleton
skeletonDoseVOI = doseData(mouseMap >= 15 & mouseMap <= 26);
skeletonDoseUncVOI = doseUnc(mouseMap >= 15 & mouseMap <= 26);
skeletonDoseUncSqVOI = doseUncSq(mouseMap >= 15 & mouseMap <= 26);

% Calculate size and statistics for skeleton VOI
skeletonVol = size(skeletonDoseVOI);
skeletonVol = skeletonVol(1);
StoSkeleton = sum(skeletonDoseVOI)/sum(skeletonVol);
skeletonDoseUnc = sum(skeletonDoseUncVOI)/skeletonVol;
StoSkeletonUnc = sqrt(sum(skeletonDoseUncSqVOI))/skeletonVol;

Stat_Uncertainty = U./Vols;
S = Dose./Vols;

Volume = Vols.*voxel_volume;
% skeletonVol = sum(Volume(15:26));

organs = {'Heart'; 'Liver'; 'Lungs'; 'Stomach wall'; 'Pancreas'; 
    'Kidneys'; 'Spleen'; 'Small intestine'; 'Large intestine'; 
    'Bladder'; 'Testes'; 'Brain'; 'Thyroid'; 'ROB'; 'Ribs'; 'Spine'; 
    'Skull'; 'Humerus'; 'Radius'; 'Ulna'; 'Femur'; 'Fibula'; 'Tibia'; 
    'Patella'; 'Remaining bones'; 'BM'; 'Skeleton'};

if contains(sourceorgan, 'lesion')
    organs{27} = 'Lesion';
    organs{28} = 'Skeleton';
    S(28) = StoSkeleton;
    Stat_Uncertainty(28) = skeletonDoseUnc;
    Volume(28) = skeletonVol*voxel_volume;
    S_U(28) = StoSkeletonUnc;
else 
    organs{27} = 'Skeleton';
    S(27) = StoSkeleton;
    Stat_Uncertainty(27) = skeletonDoseUnc;
    Volume(27) = skeletonVol*voxel_volume;
    S_U(27) = StoSkeletonUnc;
end

S_Uncertainty = S_U;
Rel_S_Uncertainty = 100*S_Uncertainty./S;
savefile = [sourceorgan, '-doses.csv'];

T = table(S, S_Uncertainty, Rel_S_Uncertainty, Stat_Uncertainty, Volume, 'RowNames', organs);
writetable(T, savefile, 'WriteRowNames',true)

toc