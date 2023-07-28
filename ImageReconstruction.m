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

%% Code to load pre-calibrated parameters and reconstruct images
% Or direct integrate events without calibration
% Input: pre-calibrated parameters, events, images, image timestamps
% Output: save reconstructed images
clear
close all

%% Method options:
% EventFrameCalib: event+frame calibration
% EventOnlyCalib: pure event calibration
% NoCalib: no calibration, direct integration using scale = 0.1, bias = 0
method = "EventFrameCalib"; 

%% Dataset options:
% Option 1: dynamic
% Option 2: box_translation
% Option 3: office
dataset = "box_translation";

%% Parameter initialization
% Log safety offset, depends on cameras and data
if strcmp(dataset, "dynamic")  
    logSafetyOffset = 40; 
elseif strcmp(dataset, "box_translation")
    logSafetyOffset = 100;
elseif  strcmp(dataset, "office")
    logSafetyOffset = 90;
end
mainDir = fullfile("./results", dataset);
% Default contrast threshold
ct_default = 0.1;
% Number of integrated events for each image reconstruction
eventCountEachReconst = 5e5;

% Create new folders if needed
if strcmp(method, "NoCalib")
    folderCreate = fullfile(mainDir, "NoCalib");
    if ~exist(folderCreate, 'dir')
        mkdir(folderCreate);
    end
elseif strcmp(method, "EventFrameCalib")
    folderCreate = fullfile(mainDir, "EventFrameCalib");
    if ~exist(folderCreate, 'dir')
        mkdir(folderCreate);
    end
elseif strcmp(method, "EventOnlyCalib")
    folderCreate = fullfile(mainDir, "EventOnlyCalib");
    if ~exist(folderCreate, 'dir')
        mkdir(folderCreate);
    end      
end

%% Read the first image and event data
imageFile = fopen(fullfile("./data", dataset, "images.txt"));
eventFile = fopen(fullfile("./data", dataset, "events.csv"));
outputFile = fopen(fullfile("./data/", dataset,"reconstructed.txt"),'w');
[imTime, im] = readImageLine(fgetl(imageFile), fullfile("./data", dataset));
[evTime,ev] = readEventLineCSV(fgetl(eventFile));

%% Set up display buffer
arrSize = size(im);
displayBuffer = log(double(im) + logSafetyOffset); 

%% Use default parameters (direct integration) or calibrated parameters
if strcmp(method, "NoCalib")
    onPixVal = ct_default * ones(arrSize); 
    offPixVal = -ct_default * ones(arrSize);
else
    bias = load(fullfile("./results", dataset, method, "/bias.csv"));
    scale = load(fullfile("./results", dataset, method, "/scale.csv"));  
    onPixVal =  (scale + bias); 
    offPixVal = (-scale + bias);
end

%% Read images and events
imageCount = 1;
eventCount = 0;
while(1)
    if ev.s == 1 % positive events
        displayBuffer(ev.y,ev.x) = displayBuffer(ev.y,ev.x) + onPixVal(ev.y,ev.x);
    else % negative events
        displayBuffer(ev.y,ev.x) = displayBuffer(ev.y,ev.x) + offPixVal(ev.y,ev.x);
    end
    eventCount = eventCount + 1;
    [evTime,ev] = readEventLineCSV(fgetl(eventFile));
    
    if (evTime > imTime)
        imLine = fgetl(imageFile);
        if (imLine == -1)
            return
        end
        [imTime, im] = readImageLine(imLine, fullfile("./data", dataset)); 
        imageCount = imageCount + 1;
    end
    
    %% Reset displayBuffer when event number for each reconstruction is reached
    if eventCount > eventCountEachReconst    
        % Display
        dispIm = uint8((exp(displayBuffer) - logSafetyOffset));
    
        % Save to file
        reconstFrameName = sprintf("%d.png", imageCount);
        fprintf(outputFile, reconstFrameName + '\n');
        if strcmp(method, "NoCalib")
            writeDir = fullfile(mainDir, "NoCalib", reconstFrameName);
        else
            writeDir = fullfile(mainDir, method, reconstFrameName);  
        end
        imwrite(dispIm, writeDir{1});

        % Reset
        displayBuffer = log(double(im) + logSafetyOffset);
        eventCount = 0;
    end
end

function [time, img] = readImageLine(line, dir)
    l = strsplit(line," ");
    time = str2num(l{1});
    nameDir = fullfile(dir, l{2});
    img = imread(nameDir{1});
end


function [time, event] = readEventLineCSV(eventLine)
    line = sscanf(eventLine, '%f,%d,%d,%d');
    time = line(1);
    event.x = line(2) + 1;
    event.y = line(3) + 1;
    event.s = line(4);
end
