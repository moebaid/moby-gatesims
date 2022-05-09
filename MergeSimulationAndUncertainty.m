%% Calculate relative uncertainty for VOI
% See Chetty et al.
%% Merge dose images 
clear all; close all; clc; restoredefaultpath; tic
prompt = "Give source organ: ";
sourceorgan = input(prompt, 's');

path = [sourceorgan, '/'];
addpath(path);
addpath([path, '/data/']);
addpath([path, '/output/']);


% Load patient specific total accumulated activity of whole image:
Total_Acc=importdata(['TotalAccA_', sourceorgan, '.txt']);  % units of voxels in organ 


% Give number of simulation splits
prompt='Give no. of splits: ';
no_splits=input(prompt);

% Number of primary, independent histories 
prompt='Give no. of total events: ';
totalevents=input(prompt); 
no_events_split=totalevents/no_splits;

listDosesquared_images = dir([sourceorgan, '/output/*-Dose-Squared.raw']);  % dir-command loads all files with ending -Dose.raw
listofDosesquared_images = {listDosesquared_images.name};
listDose_images = dir([sourceorgan, '/output/*-Dose.raw']);  % dir-command loads all files with ending -Dose.raw
listofDose_images = {listDose_images.name};
listEdep_images = dir([sourceorgan, '/output/*-Edep.raw']);  % dir-command loads all files with ending -Dose.raw
listofEdep_images = {listEdep_images.name};
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

Volume_voxel=xsize*ysize*zsize/1000; % to convert from mm^3 to ccm=ml

% Total_Acc=Total_Acc*Volume_voxel; 

for i=1:no_splits
    Dosesquared{i} = zeros(xdim,ydim,zdim); 
    Dose{i} = zeros(xdim,ydim,zdim); 
    Edep{i} = zeros(xdim,ydim,zdim); 
end

for i=1:no_splits
%% Import raw dose squared image (mhd format) [Gy^2] per certain no. of events/primaries simulated
fid = fopen(listofDosesquared_images{i});
data = fread(fid,size_image,'float','l');
fclose(fid);
image = reshape(data, [xdim, ydim, zdim]);

Dosesquared{i}=image;

%% Import raw dose image (mhd format) [Gy] per certain no. of events/primaries simulated
fid2 = fopen(listofDose_images{i});
data2 = fread(fid2,size_image,'float','l');
fclose(fid2);
image2 = reshape(data2, [xdim, ydim, zdim]);

%% Scale image
% Unit [Gy*(simulated events)] per voxel --> needed for weighted average
Dose{i}=image2*no_events_split;

%% Import raw Edep image (mhd format) [MeV] per certain no. of events/primaries simulated
fid3 = fopen(listofEdep_images{i});
data3 = fread(fid3,size_image,'float','l');
fclose(fid3);
image3 = reshape(data3, [xdim, ydim, zdim]);

%% Scale image
% Unit [MeV*(simulated events)] per voxel --> needed for weighted average
Edep{i}=image3*no_events_split;
end

% Unit [Gy^2] and [Gy*(simulated events)]
Dosesquared_merged=zeros(xdim,ydim,zdim);
Dose_merged=zeros(xdim,ydim,zdim);
Edep_merged=zeros(xdim,ydim,zdim);
for i=1:no_splits
Dosesquared_merged = Dosesquared_merged+Dosesquared{i};
Dose_merged = Dose_merged+Dose{i};
Edep_merged = Edep_merged+Edep{i};
end

% weighted average is kind of the merging of all splitted MC simulations to one
Dose_weightedaverage = Dose_merged/totalevents;
Edep_weightedaverage = Edep_merged/totalevents;

% this weighted average of all splits needs to be divided by the number of events of one split
Dose_all=Dose_weightedaverage/no_events_split;
Edep_all=Edep_weightedaverage/no_events_split;

Dose_total = Dose_all;
% Unit [Gy]
% Dose_total=Dose_all*Total_Acc;
% Unit [MeV]
Edep_total=Edep_all*Total_Acc;


%% Compute statistical uncertainty per voxel
% Dose_all is matrix with deposited dose per total number of primaries in
% each voxel (merged from splitted simulations via weighted average); needs
% to be squared elementwise (means per voxel), not whole matrix squared!!!
% sqrt gives root in each voxel
stat_uncertainty_voxel = sqrt((1/(totalevents-1))*(Dosesquared_merged/totalevents - (Dose_all).^2));

rel_uncertainty = stat_uncertainty_voxel./Dose_all*100;
rel_uncertainty(isnan(rel_uncertainty)) = 100;

% Save to files

%% Save to interfile format 
name_dose_total=sprintf([sourceorgan, '/Dose_total(', sourceorgan, ').img']);
fileID = fopen(name_dose_total,'w');
fwrite(fileID,Dose_total,'float','l');
fclose(fileID);

%% Write header
header=fileread('Test.hdr');

%% Change Text in header
% name of raw image file
new_header = strrep(header,'TEST.img',name_dose_total);
% number of voxels in x,y,z (also number of slices,...)
new_header = strrep(new_header,'11111',num2str(xdim));
new_header = strrep(new_header,'22222',num2str(ydim));
new_header = strrep(new_header,'999',num2str(zdim));
% size of voxels in x,y,z 
new_header = strrep(new_header,'12345',num2str(xsize));
new_header = strrep(new_header,'54321',num2str(ysize));
new_header = strrep(new_header,'55555',num2str(zsize));
% unit
new_header = strrep(new_header,'HU','Gy');

%% Save to header textfile
name_headerDK = sprintf([sourceorgan, '/Dose_total(', sourceorgan, ').hdr']);
fileID=fopen(name_headerDK,'w');
fprintf(fileID,new_header);
fclose(fileID);

%% Save to interfile format 
name_rel_uncertainty=sprintf([sourceorgan, '/Rel_uncertainty(', sourceorgan, ').img']);
fileID = fopen(name_rel_uncertainty,'w');
fwrite(fileID,rel_uncertainty,'float','l');
fclose(fileID);

%% Write header
header=fileread('Test.hdr');

%% Change Text in header
% name of raw image file
new_header = strrep(header,'TEST.img',name_rel_uncertainty);
% number of voxels in x,y,z (also number of slices,...)
new_header = strrep(new_header,'11111',num2str(xdim));
new_header = strrep(new_header,'22222',num2str(ydim));
new_header = strrep(new_header,'999',num2str(zdim));
% size of voxels in x,y,z 
new_header = strrep(new_header,'12345',num2str(xsize));
new_header = strrep(new_header,'54321',num2str(ysize));
new_header = strrep(new_header,'55555',num2str(zsize));
% unit
new_header = strrep(new_header,'HU','');

%% Save to header textfile
name_header = sprintf([sourceorgan, '/Rel_uncertainty(', sourceorgan, ').hdr']);
fileID=fopen(name_header,'w');
fprintf(fileID,new_header);
fclose(fileID);

%% Save to interfile format 
name_dose_total=sprintf([sourceorgan, '/Edep_total(', sourceorgan, ').img']);
fileID = fopen(name_dose_total,'w');
fwrite(fileID,Edep_total,'float','l');
fclose(fileID);

%% Write header
header=fileread('Test.hdr');

%% Change Text in header
% name of raw image file
new_header = strrep(header,'TEST.img',name_dose_total);
% number of voxels in x,y,z (also number of slices,...)
new_header = strrep(new_header,'11111',num2str(xdim));
new_header = strrep(new_header,'22222',num2str(ydim));
new_header = strrep(new_header,'999',num2str(zdim));
% size of voxels in x,y,z 
new_header = strrep(new_header,'12345',num2str(xsize));
new_header = strrep(new_header,'54321',num2str(ysize));
new_header = strrep(new_header,'55555',num2str(zsize));
% unit
new_header = strrep(new_header,'HU','MeV');

%% Save to header textfile
name_headerDK = sprintf([sourceorgan, '/Edep_total(', sourceorgan, ').hdr']);
fileID=fopen(name_headerDK,'w');
fprintf(fileID,new_header);
fclose(fileID);

toc