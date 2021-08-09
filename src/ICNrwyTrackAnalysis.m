clear;

icnLat = 372745;    % ICN center (reference pt)
icnLon = 1262621;   % ICN center (reference pt)
icnLat = floor(icnLat/10000) + floor(mod(icnLat, 10000)/100)/60 + mod(icnLat, 100)/3600;
icnLon = floor(icnLon/10000) + floor(mod(icnLon, 10000)/100)/60 + mod(icnLon, 100)/3600;

rwyName = {'33L', '33R', 34, '15R', '15L', 16}; % 34R/16L
rwyThrLat = [372715.21, 372722.97, 372636.29, 372854.44, 372902.20, 372822.11]; % rwy threshold
rwyThrLon = [1262739.08, 1262752.82, 1262630.22, 1262610.82, 1262624.56, 1262456.06];   % rwy threshold
rwyThrLat = floor(rwyThrLat/10000) + floor(mod(rwyThrLat, 10000)/100)/60 + mod(rwyThrLat, 100)/3600;
rwyThrLon = floor(rwyThrLon/10000) + floor(mod(rwyThrLon, 10000)/100)/60 + mod(rwyThrLon, 100)/3600;

[arclen, az] = distance(icnLat, icnLon, rwyThrLat, rwyThrLon, wgs84Ellipsoid);
rwyX = arclen.*sin(az/180*pi);  % X coordinate (m) from ICN center
rwyY = arclen.*cos(az/180*pi);  % Y coordinate (m) from ICN center

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save data 한상혁 수정
DATAfolder = '../input/';
% FPfolder = [DATAfolder, 'ICN ACDM 2019/'];
% load([FPfolder, 'IIS_Arr_2019.mat']);
% load([FPfolder, 'IIS_Dep_2019.mat']);
% FPfolder = [DATAfolder, 'FOIS FPL/'];
icnFPLarr = readtable([DATAfolder, 'arr_fp_20191222-20191228.csv'], 'ReadVariableNames', 1, 'VariableNamingRule', 'preserve');
icnFPLdep = readtable([DATAfolder, 'dep_fp_20191222-20191228.csv'], 'ReadVariableNames', 1, 'VariableNamingRule', 'preserve');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

MLATfolder = [DATAfolder, 'MLAT/'];
MLATlist = dir([MLATfolder, '*.csv']);

onAC = {};  % Wheel-on (Arr) AC type
onLat = []; % Wheel-on (Arr) latitude
onLon = []; % Wheel-on (Arr) longitude
onRwy = []; % Wheel-on (Arr) runway
onDist = [];    % Wheel-on (Arr) distance from runway threshold
onROT = []; % Arrival runway occupancy time in datenum
offAC = {};  % Wheel-off (Dep) AC type
offLat = []; % Wheel-off (Dep) latitude
offLon = []; % Wheel-off (Dep) longitude
offRwy = []; % Wheel-off (Dep) runway
offDist = [];    % Wheel-off (Dep) distance from runway threshold
offROT = [];    % Departure runway occupancy time in datenum
onID = [];    % 한상혁 수정
offID = [];   % 한상혁 수정
onTime = {};  % 한상혁 수정
offTime = {}; % 한상혁 수정




removeID = {};  % FltID that was already processed

for fID = 1:length(MLATlist)
% for fID = 1
    disp(['(', datestr(now), ') ', MLATlist(fID).name]);
    MLATdata = readtable([MLATfolder, MLATlist(fID).name], 'HeaderLines', 1, 'ReadVariableNames', 1, 'VariableNamingRule', 'preserve');
    if isnumeric(MLATdata.BAlt)
        indNaN = find(isnan(MLATdata.BAlt));
    else
        indNaN = find(strcmp(MLATdata.BAlt, '----'));
    end
    MLATdata(indNaN, :) = [];

    FltDT = datetime(MLATdata.TimeGet, 'InputFormat', 'yyyy.MM.dd HH:mm:ss.SSSSSS') + hours(9); % KST = UTC + 9
    Flt_datetime = cellstr(FltDT);   % 한상혁 수정    
    FltID = MLATdata.ModeSIdent;    % callsign
    uniID = unique(FltID);
    uniID(ismember(uniID, removeID)) = [];  % Remove FltID of removeID
    removeID = {};
    FltLat = MLATdata.Latitude;
    FltLon = MLATdata.Longitude;
    [arclen, az] = distance(icnLat, icnLon, FltLat, FltLon, wgs84Ellipsoid);
    FltX = arclen.*sin(az/180*pi);  % X position (m) w.r.t. ICN center
    FltY = arclen.*cos(az/180*pi);  % X position (m) w.r.t. ICN center
    
    FltFL = MLATdata.BAlt;  % Flight level in meter
    if ~isnumeric(FltFL)
        FltFL = cellfun(@str2num, FltFL);
    end
    
    
    if fID~=length(MLATlist)    % Read next hour MLATdata
        MLATdataNext = readtable([MLATfolder, MLATlist(fID+1).name], 'HeaderLines', 1, 'ReadVariableNames', 1, 'VariableNamingRule', 'preserve');
        if isnumeric(MLATdataNext.BAlt)
            indNaN = find(isnan(MLATdataNext.BAlt));
        else
            indNaN = find(strcmp(MLATdataNext.BAlt, '----'));
        end
        MLATdataNext(indNaN, :) = [];
        FltDTNext = datetime(MLATdataNext.TimeGet, 'InputFormat', 'yyyy.MM.dd HH:mm:ss.SSSSSS') + hours(9); % KST = UTC + 9
        FltIDNext = MLATdataNext.ModeSIdent;    % callsign
        FltLatNext = MLATdataNext.Latitude;
        FltLonNext = MLATdataNext.Longitude;
        Flt_timeNext = cellstr(datetime(MLATdataNext.TimeGet, 'InputFormat', 'yyyy.MM.dd HH:mm:ss.SSSSSS') + hours(9)); % 한상혁수정
        [arclen, az] = distance(icnLat, icnLon, FltLatNext, FltLonNext, wgs84Ellipsoid);
        FltXNext = arclen.*sin(az/180*pi);  % X position (m) w.r.t. ICN center
        FltYNext = arclen.*cos(az/180*pi);  % X position (m) w.r.t. ICN center
    
        FltFLNext = MLATdataNext.BAlt;  % Flight level in meter
        if ~isnumeric(FltFLNext)
            FltFLNext = cellfun(@str2num, FltFLNext);
        end
    end

    FltOps = -1*ones(size(uniID));    % 0: dep, 1: arr, -1: N/A
    FltRwyDist = -1000*ones(size(uniID));   % Distance (m) from rwy threshold to take-off/landing point
    FltRwyID = zeros(size(uniID));
    FltRwyLat = zeros(size(uniID)); % Latitude of take-off/landing point
    FltRwyLon = zeros(size(uniID)); % Longitude of take-off/landing point
    FltAC = cell(size(uniID));  % AC type
    FltROT = zeros(length(uniID), 2);   % ROT in datenum
    Flt_time = cell(size(uniID));           % 한상혁 수정


    for i=1:length(uniID)
        indID = find(strcmp(uniID(i), FltID));
        [~, indSort] = sort(FltDT(indID));  % Ascending order of FltDT
        indID = indID(indSort);
        
        curLength = length(indID);  % Length of MLAT track
        curFL = FltFL(indID);   % FltFL of indID
        curLat = FltLat(indID); % FltLAT of indID
        curLon = FltLon(indID); % FltLon of indID
        curDT = FltDT(indID);   % FltDT of indID
        curX = FltX(indID); % FltX of indID
        curY = FltY(indID); % FltX of indID
        cur_time = Flt_datetime(indID);    % 한상혁수정  double로 바꿔야할 수도
        
        if fID~=length(MLATlist)
            indIDNext = find(strcmp(uniID(i), FltIDNext));
            [~, indSort] = sort(FltDTNext(indIDNext));  % Ascending order of FltDT
            indIDNext = indIDNext(indSort);
            if ~isempty(indIDNext)
                removeID = [removeID; uniID{i}];
                curLength = curLength + length(indIDNext);
                curFL = [curFL; FltFLNext(indIDNext)];
                curLat = [curLat; FltLatNext(indIDNext)];
                curLon = [curLon; FltLonNext(indIDNext)];
                curDT = [curDT; FltDTNext(indIDNext)];
                curX = [curX; FltXNext(indIDNext)];
                curY = [curY; FltYNext(indIDNext)];
                cur_time = [cur_time; Flt_timeNext(indIDNext)];
            end
        end
        
        bDep = 0;
        if (abs(curFL(1)-curFL(end)) < 30) || (min(curFL)>100) || (max(curFL)<100) %|| sum((FltLat(indID)>rwyThrLat(1) & FltLat(indID)<rwyThrLat(6) & FltLon(indID)>rwyThrLon(6) & FltLon(indID)<rwyThrLon(1)))==0  % Not a departure/arrival
            continue;
        elseif curFL(1) < curFL(end)  % Departure
            bDep = 1;
        end

        if bDep
            % indTO = find(FltFL(indID) < FltFL(indID(1))+10, 1, 'last');   % First time to lift off
            indTO = find((diff(smooth(curFL)) == 0) & (smooth(curFL(1:end-1))<100), 1, 'last') + 1;   % Smoothing FltFL for departure and calculate differences
            if isempty(indTO) || curLength < indTO+10 % Not a full track
                continue;
            end
            FltRwyLat(i) = curLat(indTO);
            FltRwyLon(i) = curLon(indTO);
            Flt_time(i) = cur_time(indTO);    % 한상혁 수정

            
            rwyDist = zeros(3, 1);
            for r=1:3
                rwyDist(r) = norm(cross([rwyX(r+3)-rwyX(r), rwyY(r+3)-rwyY(r), 0], [curX(indTO)-rwyX(r), curY(indTO)-rwyY(r), 0]))/norm([rwyX(r+3)-rwyX(r), rwyY(r+3)-rwyY(r), 0]);
            end
            [minDist, indMinDist] = min(rwyDist);
            if minDist > 100
                continue;
            end
            
            [~, az] = distance(curLat(indTO), curLon(indTO), curLat(indTO+10), curLon(indTO+10), wgs84Ellipsoid);
            if (az < 90) || (az > 270) % North flow
                depRwyID = indMinDist;
                [~, indROT1] = min(distance(rwyThrLat(depRwyID), rwyThrLon(depRwyID), curLat, curLon, wgs84Ellipsoid));
                [~, indROT2] = min(distance(rwyThrLat(depRwyID+3), rwyThrLon(depRwyID+3), curLat, curLon, wgs84Ellipsoid));
            else    % South flow
                depRwyID = indMinDist+3;
                [~, indROT1] = min(distance(rwyThrLat(depRwyID), rwyThrLon(depRwyID), curLat, curLon, wgs84Ellipsoid));
                [~, indROT2] = min(distance(rwyThrLat(depRwyID-3), rwyThrLon(depRwyID-3), curLat, curLon, wgs84Ellipsoid));
            end
            FltRwyDist(i) = distance(rwyThrLat(depRwyID), rwyThrLon(depRwyID), curLat(indTO), curLon(indTO), wgs84Ellipsoid);
            FltOps(i) = 0;
            FltRwyID(i) = depRwyID;
            FltROT(i, :) = [datenum(curDT(indROT1)), datenum(curDT(indROT2))];

            indFP = find(strcmp(uniID(i), icnFPLdep.FLT) & (year(curDT(indTO)) == year(icnFPLdep.SDT)) & (month(curDT(indTO)) == month(icnFPLdep.SDT)) & (day(curDT(indTO)) == day(icnFPLdep.SDT)) & (hour(curDT(indTO)) == floor(icnFPLdep.ATD/100)));
            % indFP = intersect(find(strcmp(uniID(i), IIS_Dep.FLIGHT_3)), find(strcmp(datestr(FltDT(indID(indTO)), 'yyyy-mm-dd'), IIS_Dep.SDT)));
            if length(indFP)>1
                disp(['[DEP] ', uniID{i}, ' - multiple info in FP']);
            else
                if isempty(indFP)
                    disp(['[DEP] ', uniID{i}, ' - no info in FP']);
%                 elseif ~strcmp(IIS_Dep.RWY(indFP), rwyName(depRwyID))
%                     if isnumeric(IIS_Dep.RWY{indFP}) && isnumeric(rwyName{depRwyID})
%                         if IIS_Dep.RWY{indFP}~=rwyName{depRwyID}
%                             disp(['[DEP] ', uniID{i}, ' - ', num2str(rwyName{depRwyID}), ' - FP ', num2str(IIS_Dep.RWY{indFP})]);
%                         end
%                     else
%                         disp(['[DEP] ', uniID{i}, ' - ', rwyName{depRwyID}, ' - FP ', IIS_Dep.RWY{indFP}]);
%                         
% %                         figure;
% %                         geoplot(FltLat(indID), FltLon(indID));
% %                         hold on;
% %                         geoplot(FltLat(indID(indTO)), FltLon(indID(indTO)), 'r*');
% %                         text(FltLat(indID(indTO)), FltLon(indID(indTO)), ['Dep ', uniID{i}]);
%                     end
                end

                if ~isempty(indFP)
                    % FltAC{i} = IIS_Dep.TYP{indFP};
                    FltAC{i} = icnFPLdep.TYP{indFP};
                end
            end
        else
            indLD = find(curFL == curFL(end), 1);   % First time to touch down
            if isempty(indLD) || curLength < indLD+10 % Not a full track
                continue;
            end
            FltRwyLat(i) = curLat(indLD);
            FltRwyLon(i) = curLon(indLD);
            Flt_time(i) = cur_time(indLD);   % Flt_datetime(indID(indLD));    % 한상혁 수정

            
            rwyDist = zeros(3, 1);
            for r=1:3
                rwyDist(r) = norm(cross([rwyX(r+3)-rwyX(r), rwyY(r+3)-rwyY(r), 0], [curX(indLD)-rwyX(r), curY(indLD)-rwyY(r), 0]))/norm([rwyX(r+3)-rwyX(r), rwyY(r+3)-rwyY(r), 0]);
            end
            [minDist, indMinDist] = min(rwyDist);
            if minDist > 100
                continue;
            end
            
            [~, az] = distance(curLat(indLD), curLon(indLD), curLat(indLD+10), curLon(indLD+10), wgs84Ellipsoid);
            rwyDist2 = zeros(curLength, 1);  % distance from arrival runway
            if (az < 90) || (az > 270) % North flow
                arrRwyID = indMinDist;
                [~, indROT1] = min(distance(rwyThrLat(arrRwyID), rwyThrLon(arrRwyID), curLat, curLon, wgs84Ellipsoid));
                for k=indLD:curLength   % After touch down
                    rwyDist2(k) = norm(cross([rwyX(arrRwyID+3)-rwyX(arrRwyID), rwyY(arrRwyID+3)-rwyY(arrRwyID), 0], [curX(k)-rwyX(arrRwyID), curY(k)-rwyY(arrRwyID), 0]))/norm([rwyX(arrRwyID+3)-rwyX(arrRwyID), rwyY(arrRwyID+3)-rwyY(arrRwyID), 0]);
                end
                indROT2 = find(rwyDist2>50, 1); % First point after touch down at which distance from arrival runway is larger than 50 m
            else
                arrRwyID = indMinDist+3;
                [~, indROT1] = min(distance(rwyThrLat(arrRwyID), rwyThrLon(arrRwyID), curLat, curLon, wgs84Ellipsoid));
                for k=indLD:curLength   % After touch down
                    rwyDist2(k) = norm(cross([rwyX(arrRwyID-3)-rwyX(arrRwyID), rwyY(arrRwyID-3)-rwyY(arrRwyID), 0], [curX(k)-rwyX(arrRwyID), curY(k)-rwyY(arrRwyID), 0]))/norm([rwyX(arrRwyID-3)-rwyX(arrRwyID), rwyY(arrRwyID-3)-rwyY(arrRwyID), 0]);
                end
                indROT2 = find(rwyDist2>50, 1); % First point after touch down at which distance from arrival runway is larger than 50 m
            end
            FltRwyDist(i) = distance(rwyThrLat(arrRwyID), rwyThrLon(arrRwyID), curLat(indLD), curLon(indLD), wgs84Ellipsoid);
            FltOps(i) = 1;
            FltRwyID(i) = arrRwyID;
            FltROT(i, :) = [datenum(curDT(indROT1)), datenum(curDT(indROT2))];

            indFP = find(strcmp(uniID(i), icnFPLarr.FLT) & (year(curDT(indLD)) == year(icnFPLarr.SDT)) & (month(curDT(indLD)) == month(icnFPLarr.SDT)) & (day(curDT(indLD)) == day(icnFPLarr.SDT)) & (hour(curDT(indLD)) == floor(icnFPLarr.ATA/100)));
            % indFP = intersect(find(strcmp(uniID(i), IIS_Arr.FLIGHT_3)), find(strcmp(datestr(FltDT(indID(indLD)), 'yyyy-mm-dd'), IIS_Arr.SDT)));
            if length(indFP)>1
                disp(['[ARR] ', uniID{i}, ' - multiple info in FP']);
            else
                if isempty(indFP)
                    disp(['[ARR] ', uniID{i}, ' - no info in FP']);
%                 elseif ~strcmp(IIS_Arr.RWY(indFP), rwyName(arrRwyID))
%                     if isnumeric(IIS_Arr.RWY{indFP}) && isnumeric(rwyName{arrRwyID})
%                         if IIS_Arr.RWY{indFP}~=rwyName{arrRwyID}
%                             disp(['[ARR] ', uniID{i}, ' - ', num2str(rwyName{arrRwyID}), ' - FP ', num2str(IIS_Arr.RWY{indFP})]);
%                         end
%                     else
%                         disp(['[ARR] ', uniID{i}, ' - ', rwyName{arrRwyID}, ' - FP ', IIS_Arr.RWY{indFP}]);
%                         
% %                         figure;
% %                         geoplot(FltLat(indID), FltLon(indID));
% %                         hold on;
% %                         geoplot(FltLat(indID(indLD)), FltLon(indID(indLD)), 'r*');
% %                         text(FltLat(indID(indLD)), FltLon(indID(indLD)), ['Arr ', uniID{i}]);
%                     end
                end
                
                if ~isempty(indFP)
                    % FltAC{i} = IIS_Arr.TYP{indFP};
                    FltAC{i} = icnFPLarr.TYP{indFP};
                end
            end
        end
    end

    indDep = find(FltOps == 0);
    indArr = find(FltOps == 1);
    onAC = [onAC; FltAC(indArr)];
    onLat = [onLat; FltRwyLat(indArr)];
    onLon = [onLon; FltRwyLon(indArr)];
    onRwy = [onRwy; FltRwyID(indArr)];
    onDist = [onDist; FltRwyDist(indArr)];
    onROT = [onROT; FltROT(indArr, :)];
    offAC = [offAC; FltAC(indDep)];
    offLat = [offLat; FltRwyLat(indDep)];
    offLon = [offLon; FltRwyLon(indDep)];
    offRwy = [offRwy; FltRwyID(indDep)];
    offDist = [offDist; FltRwyDist(indDep)];
    offROT = [offROT; FltROT(indDep, :)];
    onID = [onID ; uniID(indArr)];             % 한상혁 수정
    offID = [offID ; uniID(indDep)];           % 한상혁 수정
    onTime = [onTime ; Flt_time(indArr)];      % 한상혁 수정
    offTime = [offTime ; Flt_time(indDep)];    % 한상혁 수정
end

%%%%%%%%%%%%%%%%%%%%%%%%%% 1,2,3,4 가 아니라 1,2,4,5,가 되야할꺼같은디... %%%%%%%%%%%%%
totalROT = sort([onROT(find(sum(onRwy == [1, 2, 3, 4], 2)), :); offROT(find(sum(offRwy == [1, 2, 3, 4], 2)), :)]);
occupiedTime = totalROT(1, :);  % At least one of RWY 33R/15L, 33L/15R is occupied
nInterval = 1;
for i=2:length(totalROT)
    if occupiedTime(nInterval, 2) >= totalROT(i, 1)
        if occupiedTime(nInterval, 2) < totalROT(i, 2)
            occupiedTime(nInterval, 2) = totalROT(i, 2);
        end
    else
        nInterval = nInterval + 1;
        occupiedTime(nInterval, :) = totalROT(i, :);
    end
end
freeTimeDuration = zeros(nInterval-1, 1);   % Both RWY 33R/15L, 33L/15R are free (in s)
freeTimeDay = zeros(nInterval-1, 1);    % day
freeTimeHour = zeros(nInterval-1, 1);    % hour
for i=1:nInterval-1
    freeTimeDuration(i) = round((occupiedTime(i+1, 1)-occupiedTime(i, 2))*24*3600);  % in seconds
    freeTimeDay(i) = day(datetime(occupiedTime(i, 2), 'ConvertFrom', 'datenum'));
    freeTimeHour(i) = hour(datetime(occupiedTime(i, 2), 'ConvertFrom', 'datenum'));
end
freeTimeTot = zeros(24, max(freeTimeDay)-min(freeTimeDay)+1);   % Total free time of RWY 33R/15L, 33L/15R during 1 hour
freeTimeNum = zeros(24, max(freeTimeDay)-min(freeTimeDay)+1);   % # free time of RWY 33R/15L, 33L/15R during 1 hour
freeTimeMean = zeros(24, max(freeTimeDay)-min(freeTimeDay)+1);   % Mean free time of RWY 33R/15L, 33L/15R during 1 hour
freeTimeStd = zeros(24, max(freeTimeDay)-min(freeTimeDay)+1);   % Std free time of RWY 33R/15L, 33L/15R during 1 hour
freeTimeString = cell(24, max(freeTimeDay)-min(freeTimeDay)+1);
freeTimeNext = 0;
for j=min(freeTimeDay):max(freeTimeDay)
    for i=1:24
        % freeTimeString{i, j-min(freeTimeDay)+1} = ['Dec', num2str(j), '_', num2str(i-1), 'h'];
        freeTimeString{i, j-min(freeTimeDay)+1} = [num2str(i-1), 'h'];
        indFree = find(freeTimeDay==j & freeTimeHour==(i-1));
        freeTimeNum(i, j-min(freeTimeDay)+1) = length(indFree);
        if isempty(indFree)
            freeTimeNext = 0;
            continue;
        end
        if freeTimeNext~=0
            fT = [freeTimeNext; freeTimeDuration(indFree)];
            freeTimeNext = 0;
        else
            fT = freeTimeDuration(indFree);
        end
        if hour(datetime(occupiedTime(indFree(end)+1, 1), 'ConvertFrom', 'datenum'))~=i-1
            [y, m, d] = ymd(datetime(occupiedTime(indFree(end), 2), 'ConvertFrom', 'datenum'));
            freeTimeNext = fT(end) - round((datenum(y, m, d, i, 0, 0) - occupiedTime(indFree(end), 2))*24*3600);
            fT(end) = fT(end) - freeTimeNext;
        end
        
        freeTimeTot(i, j-min(freeTimeDay)+1) = sum(fT/60);
        freeTimeMean(i, j-min(freeTimeDay)+1) = mean(fT/60);
        freeTimeStd(i, j-min(freeTimeDay)+1) = std(fT/60);
    end
end

day = 4;
figure;
bar(freeTimeTot(day*24+1:day*24+24));
xticks(1:numel(freeTimeTot));
xticklabels(freeTimeString(day*24+1:day*24+24));
xtickangle(45);
ylabel('Free time of 33R/15L, 33L/15R (min)');
title(['Dec ', num2str(min(freeTimeDay)+day)]);
grid on;
saveas(gcf, '../result/matlab/ICNrwyFreeTotal');

figure;
bar(freeTimeMean(day*24+1:day*24+24));
grid on;
hold on;
errorbar(freeTimeMean(day*24+1:day*24+24), freeTimeStd(day*24+1:day*24+24), '.');
xticks(1:numel(freeTimeTot));
xticklabels(freeTimeString(day*24+1:day*24+24));
xtickangle(45);
ylabel('Free time of 33R/15L, 33L/15R (min)');
title(['Dec ', num2str(min(freeTimeDay)+day)]);
legend('Mean', 'Std');
saveas(gcf, '../result/matlab/ICNrwyFreeMean');

figure;
bar(freeTimeNum(day*24+1:day*24+24));
grid on;
xticks(1:numel(freeTimeTot));
xticklabels(freeTimeString(day*24+1:day*24+24));
xtickangle(45);
ylabel('# free of 33R/15L, 33L/15R');
title(['Dec ', num2str(min(freeTimeDay)+day)]);
saveas(gcf, '../result/matlab/ICNrwyFreeNum');



figure;
geoplot(rwyThrLat, rwyThrLon, 'gd');
hold on;
indOnRwy = [];
indOffRwy = [];
for i=1:3
    indOnRwy = [indOnRwy; find(onRwy==i)];  % Arrival on runway i
    indOffRwy = [indOffRwy; find(offRwy==i)];    % Departure on runway i
end
geoplot(onLat(indOnRwy), onLon(indOnRwy), 'r*');
geoplot(offLat(indOffRwy), offLon(indOffRwy), 'b*');
title('North flow');
legend('RWY Threshold', 'Arrival', 'Departure');
saveas(gcf, '../result/matlab/ICNrwyNorth');

figure;
geoplot(rwyThrLat, rwyThrLon, 'gd');
hold on;
indOnRwy = [];
indOffRwy = [];
for i=4:6
    indOnRwy = [indOnRwy; find(onRwy==i)];  % Arrival on runway i
    indOffRwy = [indOffRwy; find(offRwy==i)];    % Departure on runway i
end
geoplot(onLat(indOnRwy), onLon(indOnRwy), 'r*');
geoplot(offLat(indOffRwy), offLon(indOffRwy), 'b*');
title('South flow');
legend('RWY Threshold', 'Arrival', 'Departure');
saveas(gcf, '../result/matlab/ICNrwySouth');

for i=1:6
    indOnRwy = find(onRwy==i);  % Arrival on runway i
    % if ~isempty(indOnRwy)
    if length(indOnRwy) > 30
        figure;
        histogram(onDist(indOnRwy), floor(min(onDist(indOnRwy))):10:ceil(max(onDist(indOnRwy))));
        title(['On distance (m) from ', rwyName{i}, ' threshold']);
        grid on;
    end
    indOffRwy = find(offRwy==i);    % Departure on runway i
    % if ~isempty(indOffRwy)
    if length(indOffRwy) > 30
        figure;
        histogram(offDist(indOffRwy), floor(min(offDist(indOffRwy))):10:ceil(max(offDist(indOffRwy))));
        title(['Off distance (m) from ', rwyName{i}, ' threshold']);
        grid on;
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save data 한상혁 수정
arr_data = [num2cell(onTime), num2cell(onID), onAC, num2cell(onLat), num2cell(onLon), num2cell(onRwy), num2cell(onDist), num2cell(onROT)];
dep_data = [num2cell(offTime), num2cell(offID),offAC, num2cell(offLat), num2cell(offLon), num2cell(offRwy), num2cell(offDist), num2cell(offROT)];
freetime = [num2cell(freeTimeString), num2cell(freeTimeTot), num2cell(freeTimeNum), num2cell(freeTimeMean), num2cell(freeTimeStd)];
arr_t = cell2table(arr_data);
dep_t = cell2table(dep_data);
freetime_t = cell2table(freetime);
writetable(arr_t,'../input/arr_data.csv');
writetable(dep_t,'../input/dep_data.csv');
writetable(freetime_t,'../input/freetime.csv');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%