%{
	This file is part of https://github.com/ziweiWWANG/Event-Camera-Calibration
	Event-Camera-Calibration is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	Event-Camera-Calibration is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	You should have received a copy of the GNU General Public License
	along with Event-Camera-Calibration.  If not, see <http://www.gnu.org/licenses/>.
%}

%% Code to calbirate scale and bias of an event camera using events + frames
% Input 1: sumE (sum of event count between each frame timestamp)  
% Input 2: sumP(sum of polarity between each frame timestamp)
% Input 3: frames
% Output: save calibration parameter scale and bias in .csv files
clear
close all

%% Parameter initialization
% Dataset to be calibrated
% Option 1: dynamic
% Option 2: box_translation
% Option 3: office
dataset = "box_translation";

% start_idx and end_idx define how many events are used in calibration
% Log safety offset depends on camera hardwares or camera settings etc
start_idx = 1;
if strcmp(dataset, "dynamic")
    end_idx = 1200;
    log_safety_offset = 40; 
elseif strcmp(dataset, "office")
    end_idx = 230;
    log_safety_offset = 90; 
elseif strcmp(dataset, "box_translation")
    end_idx = 200; 
    log_safety_offset = 100; 
end
% For each linear regression, use events between image i to i+sample_frame
sample_frame = 40;
% Frame height
height = 180;
% Frame width
width = 240;
% Default contrast threshold
ct_default = 0.1;
% Initialize scale and bias
scale = zeros(height,width);
bias = zeros(height,width);

%% Load sum of event count and sum of polarity
count = 1;
% Sum of event count and sum of polarity
sumE = zeros(height,width,end_idx - start_idx + 1);
sumP = zeros(height,width,end_idx - start_idx + 1);
for i=start_idx:end_idx
    idx = num2str(i);
	sumE(:,:,count) = load(['./data/' + dataset + '/sumE/data_event_' + idx + '.txt'],'%s','delimiter',',');
    sumP(:,:,count) = load(['./data/' + dataset + '/sumP/data_polarity_' + idx + '.txt'],'%s','delimiter',',');
    count = count + 1;
end
 
%% Load images
count = 1;
image = zeros(180,240,end_idx - start_idx + 1 - sample_frame);
for i=start_idx:end_idx
    image_filename = sprintf('./data/%s/images/%d.png', dataset, i);
    image(:,:,count) = imread(image_filename);  
    count = count + 1;
end
 
%% Compute difference between event count, sum of polarity and intensity
count = 1;
deltaL = zeros(180,240,end_idx - sample_frame);
deltaE = zeros(180,240,end_idx - sample_frame);
deltaP = zeros(180,240,end_idx - sample_frame);
for i=start_idx:(end_idx-sample_frame)
    % Difference of event count and sum of polarity
    deltaE(:,:,count) = sumE(:,:,count+sample_frame) - sumE(:,:,count);
    deltaP(:,:,count) = sumP(:,:,count+sample_frame) - sumP(:,:,count);
    % Intensity difference between each frame
    img2 = double(image(:,:,count+sample_frame)) + log_safety_offset;
    img1 = double(image(:,:,count)) + log_safety_offset;
    deltaL(:,:,count) = log(img2) - log(img1);
    count = count + 1;
end

%% Refer to Section 4.1 in the paper
% https://ssl.linklings.net/conferences/acra/acra2019_proceedings/views/includes/files/pap135s1-file1.pdf
for i = 1:180
    for j = 1:240
        P = deltaP(i,j,:);
        P = P(:,:);
        E = deltaE(i,j,:);
        E = E(:,:);
        L = deltaL(i,j,:);
        L = L(:,:)';
        A = [P' E'];
        if rcond(A'*A) < 1e-14
            scale(i,j) = ct_default;
            bias(i,j) = 0;
            parameters = [ct_default; 0];
        elseif ((sumE(i,j,end_idx) - sumE(i,j,start_idx)) > 0) && sum(L == 0) < numel(L) * 0.93
            % Least-squares approach
            parameters = 1*(A\L);
            scale(i,j) = parameters(1);
            bias(i,j) = parameters(2);
        else 
            scale(i,j) = ct_default;
            bias(i,j) = 0;
            parameters = [ct_default;0];         
        end
    end
end

%% Save calibration parameters
folderCalibParam = ['./results/' + dataset + '/EventFrameCalib/'];
if ~exist(folderCalibParam, 'dir')
    mkdir(folderCalibParam);
end

csvwrite(sprintf([folderCalibParam + '/scale.csv']),scale);
csvwrite(sprintf([folderCalibParam + '/bias.csv']),bias);