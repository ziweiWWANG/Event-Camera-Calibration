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

%% Code to preprocess events
% Input: events
% Output 1: save sumE (sum of event count between each frame timestamp)  
% Output 2: save sumP(sum of polarity between each frame timestamp)

%% Dataset options
% Option 1: dynamic
% Option 2: box_translation
% Option 3: office
dataset = "box_translation";

folderCreate = fullfile("./data", dataset, "sumE");
if ~exist(folderCreate, 'dir')
    mkdir(folderCreate);
end
folderCreate = fullfile("./data", dataset, "sumP");
if ~exist(folderCreate, 'dir')
    mkdir(folderCreate);
end
%% Read the first image and event data
imageFile = fopen(fullfile("./data", dataset, "images.txt"));
eventFile = fopen(fullfile("./data", dataset, "events.csv"));
[imTime, im] = readImageLine(fgetl(imageFile), fullfile("./data", dataset));
[evTime,ev] = readEventLineCSV(fgetl(eventFile));
% Frame height
height = 180;
% Frame width
width = 240;
sumP = zeros(height, width);
sumE = zeros(height, width);
imageCount = 0;
eventCount = 0;
while(1)
    imLine = fgetl(imageFile);
    if (imLine == -1)
        return
    end
    % Read the next image and its timestamps
    [newImTime, newIm] = readImageLine(imLine,"./data/"+dataset); 
    imageCount = imageCount + 1;

    while(evTime < newImTime) % wait for new image
        % Event time should always larger than the old image timestamp
        if (evTime < imTime)
            evLine = fgetl(eventFile);
            if (evLine == -1)
                return
            end
            [evTime,ev] = readEventLineCSV(evLine);
            continue
        end  
        if ev.s == 1 % positive events
            sumP(ev.y,ev.x) = sumP(ev.y,ev.x) + 1;
            sumE(ev.y,ev.x) = sumE(ev.y,ev.x) + 1;
        else % negative events
            sumP(ev.y,ev.x) = sumP(ev.y,ev.x) - 1;
            sumE(ev.y,ev.x) = sumE(ev.y,ev.x) + 1;
        end
        eventCount = eventCount + 1;
        [evTime,ev] = readEventLineCSV(fgetl(eventFile));

    end 
    % Save sumE and sumP
    file_name = sprintf('./data/%s/sumE/data_event_%d.txt', dataset, imageCount);
    csvwrite(file_name, sumE);
    file_name = sprintf('./data/%s/sumP/data_polarity_%d.txt', dataset, imageCount);
    csvwrite(file_name, sumP);
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