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

%% Code to calbirate scale and bias of an event camera using pure events 
% No frame is used in this event only calibration method
% Input 1: sumE (sum of event count between each frame timestamp)  
% Input 2: sumP(sum of polarity between each frame timestamp)
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
start_idx = 1;
if strcmp(dataset, "dynamic")
    end_idx = 1200;
elseif strcmp(dataset, "box_translation") 
    end_idx = 200;  
elseif strcmp(dataset, "office")
    end_idx = 230;
end
% Default contrast threshold
ct_default = 0.1;
% Frame height
height = 180;
% Frame width
width = 240;
% Linear regression coefficient 1
m = zeros(height,width);
% Linear regression coefficient 2
d = zeros(height,width);
% Root mean square error
r = zeros(height,width);

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



%% Refer to Section 4.3 in the paper
% https://ssl.linklings.net/conferences/acra/acra2019_proceedings/views/includes/files/pap135s1-file1.pdf
for i = 1:height
    for j = 1:width
        P = reshape(sumP(i,j,:),[1,end_idx-start_idx+1]);
        E = reshape(sumE(i,j,:),[1,end_idx-start_idx+1]);
        A = [E', ones(size(E))'];
        if (rcond(A'*A) < 1e-14) 
            r(i,j) = NaN;
        else
            coef = (A'*A)\A'*P';
            m(i,j) = coef(1);
            d(i,j) = coef(2);
            r(i,j) = sqrt(mean((P - (m(i,j) * E + d(i,j))).^2));
        end
    end
end

% Compute scale = median(r) / r, refer to Equation (11)
scale = median(ct_default * r(~isnan(r))) ./ r;
% Compute bias, refer to Equation (12)
bias = - scale .* m;
% Replaces NaN or unrealistically large scale values
replace_mask = (abs(scale) > 10 * ct_default) | isnan(r);
scale(replace_mask) = ct_default;
bias(replace_mask) = 0;

%% Save calibration parameters
folderCalibParam = ['./results/' + dataset + '/EventOnlyCalib/'];
if ~exist(folderCalibParam, 'dir')
    mkdir(folderCalibParam);
end

csvwrite(sprintf([folderCalibParam + '/scale.csv']),scale);
csvwrite(sprintf([folderCalibParam + '/bias.csv']),bias);