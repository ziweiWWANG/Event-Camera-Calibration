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
clear
close all

%% Code to evaluate the calibration performance
% Input: reconstructed images
% Output: average PSNR, RMSE and SSIM

%% Method options:
% EventFrameCalib, event+frame calibration
% EventOnlyCalib, pure event calibration
% NoCalib: no calibration, direct integration using scale = 0.1, bias = 0
method = "EventFrameCalib"; 
%% Dataset options:
% Option 1: dynamic
% Option 2: office
% Option 3: box_translation
dataset = "box_translation";
results_path = fullfile("./results", dataset, method);
gt_path = fullfile("./data/", dataset, "/images");
files = dir(fullfile(results_path, '*.png')); 

PSNR_avg = 0;
RMSE_avg = 0;
SSIM_avg = 0;
for i=1:length(files)
    im_results = imread(fullfile(results_path, files(i).name));
    im_gt = imread(fullfile(gt_path, files(i).name));
    PSNR_avg = PSNR_avg + computePSNR(double(im_results), double(im_gt));
    RMSE_avg = RMSE_avg + computeRMSE(double(im_results), double(im_gt));
    SSIM_avg = SSIM_avg + computeSSIM(double(im_results), double(im_gt));
end 

%% Print evaluation
PSNR_avg = PSNR_avg / length(files)
RMSE_avg = RMSE_avg / length(files)
SSIM_avg = SSIM_avg / length(files)

function PSNR = computePSNR(im1, im2)
    assert(all(size(im1) == size(im2)));
    num = size(im1,1)*size(im1,2);
    MSE = 1/num * sum(sum((im1 - im2).^2));
    MAXI2 = 255^2;
    PSNR = 20*log10(MAXI2 ./ MSE);
end

function RMSE = computeRMSE(im1, im2)
    assert(all(size(im1) == size(im2)));
    num = size(im1,1) * size(im1,2);
    RMSE = sqrt(1/num .* sum(sum((im1-im2).^2)));
end

function SSIM = computeSSIM(im1, im2)
    assert(all(size(im1) == size(im2)));
    k1 = 0.01;
    k2 = 0.03;
    L = 255;
    c1 = (k1*L)^2;
    c2 = (k2*L)^2;
    mu1 = mean(im1);
    mu2 = mean(im2);
    sig = cov(im1, im2);
    sig11 = sig(1,1);
    sig12 = sig(1,2);
    sig22 = sig(2,2);

    SSIM = (2.*mu1.*mu2 + c1) .* (2.*sig12 + c2) / ...
            ( (mu1.^2 + mu2.^2 + c1) .* (sig11 + sig22 + c2));
end