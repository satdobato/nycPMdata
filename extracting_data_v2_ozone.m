%% Import data from text file.
%
%    /Users/macuser/Dropbox/CCNY/o3NAZMI/NYdata09_a.csv
%
% Created by Nabin Malakar
%Date 2014/04/06 11:31:09

%% Initialize variables.
clear all
% filename = '/Users/macuser/Dropbox/CCNY/o3NAZMI/NYdata09_a.csv';
filename = '/Users/macuser/Dropbox/CCNY/o3NAZMI/NYCozone09_a.csv';

delimiter = ',';
startRow = 2;

%% Format string for each line of text:
%   column1: double (%f)
%	column2: double (%f)
%   column3: date strings (%s)
%	column4: date strings (%s)
%   column5: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%f%f%s%s%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Convert the contents of column with dates to serial date numbers using date format string (datenum).
dataArray{3} = datenum(dataArray{3}, 'mm/dd/yy');
dataArray{4} = datenum(dataArray{4}, 'HH:MM');

%% Allocate imported array to column variable names
Latitude = dataArray{:, 1};
Longitude = dataArray{:, 2};
DateLocal = dataArray{:, 3};
TimeLocal = dataArray{:, 4};
SampleMeasurement = dataArray{:, 5};

%% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans;


%% Now Processing

% /Users/macuser/Dropbox/CCNY/o3NAZMI

dateVector = datevec(DateLocal, '');

timeVector = datevec(TimeLocal);

NewDate = [dateVector(:,1:3), timeVector(:,4:6)];

matlabDate = datenum(NewDate); % for easy access

%% find summer
iwant = find(NewDate(:,2)==6 | NewDate(:,2)==7 |  NewDate(:,2)==8);

% idata2 = [matlabDate(iwant,:) NewDate(iwant, :) Latitude(iwant) Longitude(iwant) SampleMeasurement(iwant) ];
idata = [matlabDate(iwant,:) Latitude(iwant) Longitude(iwant) SampleMeasurement(iwant) ];


% plot the lat long
uLat = unique(idata(:,2));
uLon = unique(idata(:,3));

for jj =1:length(uLat)
    iwant = find(uLat(jj)==idata(:,2) );
    saveLatLon(jj,:) = [uLat(jj), idata(iwant(1), 3)];
    
end
%% Plot to see the locations
close all
latlim = [40, 45];
lonlim = [-80,-73];

figure
ax = worldmap(latlim, lonlim);
states = shaperead('usastatehi','UseGeoCoords', true, 'BoundingBox', [lonlim', latlim']);
geoshow(ax, states, 'Facecolor', [1 1 0.9]);

for jj = 1:length(uLat)
    
    plotm(saveLatLon(jj,1),saveLatLon(jj,2), jj,'o', 'MarkerEdgeColor','k','MarkerSize',10);
    
    hold on
    textm(saveLatLon(jj,1),saveLatLon(jj,2), sprintf('%.1d', jj))
    
end

% Figure shows that 17 is OK to cut off for NYC region.
numstationWant = 10;
%%
clear saveData
iwant = find(NewDate(:,2)==6 | NewDate(:,2)==7 |  NewDate(:,2)==8);
idata2 = [matlabDate(iwant,:) NewDate(iwant, :) Latitude(iwant) Longitude(iwant) SampleMeasurement(iwant) ];

% idataset = mat2dataset(idata2);
% save the data in following format
% 2009 6 1 1 0 0 Lat Lon PM
% 30 31 31 june july august are the days of month

% make calendar

daymm = [30 31 31];
count =1;

for station = 1:numstationWant%17
    
    for jj = 1:3 % cycle month
        for kk = 1:daymm(jj) % cycle days in month
            for hours = 1:24
                
                saveDate(count,:)= [2009, jj+5, kk hours station]; % added 5 for june jul aug
                
                iwa = find(uLat(station)==idata2(:,8) & idata2(:,3)==jj+5 & idata2(:,4)==kk & idata2(:,5)==hours) ;
                
                
                if   ~isempty(iwa)
                    saveData(count, :) = [2009, jj+5, kk hours  idata2(iwa(1),8) idata2(iwa(1),9) idata2(iwa(1),10) station];
                    
                else
                    % add NaN
                    saveData(count, :) = [2009, jj+5, kk hours  NaN NaN NaN station];
                    
                end
                
                count = count+1;
            end
        end
    end
    
    
end

%% only data in columnar view

dataM = []

for jj =1:numstationWant
    
    iwant = find(saveData(:,8)==jj );
    iData = saveData(iwant, 7);
    
    dataM = [dataM, iData];
    
    
end

dataM(dataM<=0)=NaN;
 

meanD = nanmean(dataM,2); % this will be the average background PM2.5
stdD = nanstd(dataM')';

% Now with date

iwantst1 = find(saveData(:,8)==1 );

saveDatabase = [saveData(iwantst1,1:end-4) meanD stdD];
saveRawDatabase = [saveData(iwantst1,1:end-4) dataM];

'The saveDatabase has the following arrangement:'
'YYYY MM DD HH Lat Lon PMmean PMstd'

'The saveRawDatabase has the following arrangement:'
'YYYY MM DD HH Lat Lon dataM from 17 stations in NYC'

% save NYC2009_mean.mat saveDatabase saveRawDatabase saveData
save NYCozone2009_mean.mat saveDatabase saveRawDatabase saveData

% 






