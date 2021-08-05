clear;

% rwy reference points' coordinate
icnLat = 372745;    % ICN center (reference pt)
icnLon = 1262621;   % ICN center (reference pt)
icnLat = floor(icnLat/10000) + floor(mod(icnLat, 10000)/100)/60 + mod(icnLat, 100)/3600;
icnLon = floor(icnLon/10000) + floor(mod(icnLon, 10000)/100)/60 + mod(icnLon, 100)/3600;

rwyName = {'33L', '33R', 34, '15R', '15L', 16};   % 34R/16L
rwyThrLat = [372715.21, 372722.97, 372636.29, 372854.44, 372902.20, 372822.11];          % rwy threshold
rwyThrLon = [1262739.08, 1262752.82, 1262630.22, 1262610.82, 1262624.56, 1262456.06];    % rwy threshold
rwyThrLat = floor(rwyThrLat/10000) + floor(mod(rwyThrLat, 10000)/100)/60 + mod(rwyThrLat, 100)/3600;
rwyThrLon = floor(rwyThrLon/10000) + floor(mod(rwyThrLon, 10000)/100)/60 + mod(rwyThrLon, 100)/3600;

[arclen, az] = distance(icnLat, icnLon, rwyThrLat, rwyThrLon, wgs84Ellipsoid);
rwyX = arclen.*sin(az/180*pi);    % X coordinate (m) from ICN center
rwyY = arclen.*cos(az/180*pi);    % Y coordinate (m) from ICN center




% load data
DATAfolder = '../input/';
FPfolder = [DATAfolder, 'ICN ACDM 2019/'];    % 한상혁 수정
load([DATAfolder, 'IIS_Arr_2019.mat']);       % 한상혁 수정
load([DATAfolder, 'IIS_Dep_2019.mat']);       % 한상혁 수정
MLATfolder = [DATAfolder, 'MLAT/'];           % 한상혁 수정
MLATlist = dir([MLATfolder, '*.csv']);




% global init
onAC = {};    % Wheel-on (Arr) AC type
onLat = [];   % Wheel-on (Arr) latitude
onLon = [];   % Wheel-on (Arr) longitude
onRwy = [];   % Wheel-on (Arr) runway
onDist = [];  % Wheel-on (Arr) distance from runway threshold
offAC = {};   % Wheel-off (Dep) AC type
offLat = [];  % Wheel-off (Dep) latitude
offLon = [];  % Wheel-off (Dep) longitude
offRwy = [];  % Wheel-off (Dep) runway
offDist = []; % Wheel-off (Dep) distance from runway threshold




for fID = 1:length(MLATlist)        % 시간별로
    disp(['(', datestr(now), ') ', MLATlist(fID).name]);
    
    % 데이터 하나씩 불러오기 + BAlt에 있는 NaN, ---- 를 처리
    MLATdata = readtable([MLATfolder, MLATlist(fID).name], 'HeaderLines', 1, 'ReadVariableNames', 1, 'VariableNamingRule', 'preserve');
    if isnumeric(MLATdata.BAlt)
        indNaN = find(isnan(MLATdata.BAlt));
    else
        indNaN = find(strcmp(MLATdata.BAlt, '----'));
    end
    MLATdata(indNaN, :) = [];

    
    
    % Flight ID, Datetime , Latitude, Longitude, FL
    FltDT = datetime(MLATdata.TimeGet, 'InputFormat', 'yyyy.MM.dd HH:mm:ss.SSSSSS') + hours(9); % KST = UTC + 9
    FltID = MLATdata.ModeSIdent;    % callsign
    uniID = unique(FltID);            
    FltLat = MLATdata.Latitude;
    FltLon = MLATdata.Longitude;
    FltFL = MLATdata.BAlt;    % Flight level in meter
    if ~isnumeric(FltFL)
        FltFL = cellfun(@str2num, FltFL);    % FL이 숫자가 아니면 숫자로 바꿈
    end

    
    
    % init in for loop
    FltOps = -1*ones(size(uniID));          % 0: dep, 1: arr, -1: N/A
    FltRwyDist = -1000*ones(size(uniID));   % Distance (m) from rwy threshold to take-off/landing point
    FltRwyID = zeros(size(uniID));
    FltRwyLat = zeros(size(uniID));         % Latitude of take-off/landing point
    FltRwyLon = zeros(size(uniID));         % Longitude of take-off/landing point
    FltAC = cell(size(uniID));              % AC type

    
    
    % 
    for i=1:length(uniID)    % 한시간동안의 항적에서 각각의 c/s별로
        
        % 각각의 unique c/s에 맞는 데이터 가져오기 / indID는 c/s에 해당하는 데이터들의 index
        indID = find(strcmp(uniID(i), FltID));    % strcmp = Compare strings
        [~, indSort] = sort(FltDT(indID));        % Ascending order of FltDT (flight datetime)
        indID = indID(indSort);
        
        % departure인지 N/A인지 판단
        bDep = 0;
        if (abs(FltFL(indID(1))-FltFL(indID(end))) < 30) || (min(FltFL(indID))>100) || (max(FltFL(indID))<100) %|| sum((FltLat(indID)>rwyThrLat(1) & FltLat(indID)<rwyThrLat(6) & FltLon(indID)>rwyThrLon(6) & FltLon(indID)<rwyThrLon(1)))==0  % Not a departure/arrival
            % 처음과 끝의 고도차이가 30미만   or   최저고도가 100이상   or   최대고도가 100이하 -->> N/A
            continue;
        elseif FltFL(indID(1)) < FltFL(indID(end))  % Departure
            bDep = 1;
        end

        
        % Departure
        if bDep   
            
            % T/O의 index 찾아 데이터 넣기
            % indTO = find(FltFL(indID) < FltFL(indID(1))+10, 1, 'last');   % First time to lift off
            indTO = find((diff(smooth(FltFL(indID))) == 0) & (smooth(FltFL(indID(1:end-1)))<100), 1, 'last') + 1;   % Smoothing FltFL for departure and calculate differences
            %T/O의 index = c/s에 해당하는 고도데이터(smooth)의 차이가 0 + 고도데이터가 100이하 + ~
            if isempty(indTO) || length(indID) < indTO+10 % Not a full track
                continue;
            end
            FltRwyLat(i) = FltLat(indID(indTO));
            FltRwyLon(i) = FltLon(indID(indTO));
            
            % 
            [arclen, az] = distance(icnLat, icnLon, FltRwyLat(i), FltRwyLon(i), wgs84Ellipsoid);
            toX = arclen*sin(az/180*pi);
            toY = arclen*cos(az/180*pi);
            rwyDist = zeros(3, 1);
            for r=1:3
                rwyDist(r) = norm(cross([rwyX(r+3)-rwyX(r), rwyY(r+3)-rwyY(r), 0], [toX-rwyX(r), toY-rwyY(r), 0]))/norm([rwyX(r+3)-rwyX(r), rwyY(r+3)-rwyY(r), 0]);
            end
            [minDist, indMinDist] = min(rwyDist);
            if minDist > 100
                continue;
            end
            
            [~, az] = distance(FltLat(indID(indTO)), FltLon(indID(indTO)), FltLat(indID(indTO+10)), FltLon(indID(indTO+10)), wgs84Ellipsoid);
            if (az < 90) || (az > 270) % North flow
                depRwyID = indMinDist;
            else    % South flow
                depRwyID = indMinDist+3;
            end

            indFP = intersect(find(strcmp(uniID(i), IIS_Dep.FLIGHT_3)), find(strcmp(datestr(FltDT(indID(indTO)), 'yyyy-mm-dd'), IIS_Dep.SDT)));
            if length(indFP)>1
                disp(['[DEP] ', uniID{i}, ' - multiple info in FP']);
            else
                if isempty(indFP)
                    disp(['[DEP] ', uniID{i}, ' - no info in FP']);
                elseif ~strcmp(IIS_Dep.RWY(indFP), rwyName(depRwyID))
                    if isnumeric(IIS_Dep.RWY{indFP}) && isnumeric(rwyName{depRwyID})
                        if IIS_Dep.RWY{indFP}~=rwyName{depRwyID}
                            disp(['[DEP] ', uniID{i}, ' - ', num2str(rwyName{depRwyID}), ' - FP ', num2str(IIS_Dep.RWY{indFP})]);
                        end
                    else
                        disp(['[DEP] ', uniID{i}, ' - ', rwyName{depRwyID}, ' - FP ', IIS_Dep.RWY{indFP}]);
                        
%                         figure;
%                         geoplot(FltLat(indID), FltLon(indID));
%                         hold on;
%                         geoplot(FltLat(indID(indTO)), FltLon(indID(indTO)), 'r*');
%                         text(FltLat(indID(indTO)), FltLon(indID(indTO)), ['Dep ', uniID{i}]);
                    end
                end

                FltRwyDist(i) = distance(rwyThrLat(depRwyID), rwyThrLon(depRwyID), FltLat(indID(indTO)), FltLon(indID(indTO)), wgs84Ellipsoid);
                FltOps(i) = 0;
                FltRwyID(i) = depRwyID;
                if ~isempty(indFP)
                    FltAC{i} = IIS_Dep.TYP{indFP};
                end
            end
        
            
            
            
        % Arrival
        else
            indLD = find(FltFL(indID) == FltFL(indID(end)), 1);   % First time to touch down
            if isempty(indLD) || length(indID) < indLD+10 % Not a full track
                continue;
            end
            FltRwyLat(i) = FltLat(indID(indLD));
            FltRwyLon(i) = FltLon(indID(indLD));
            
            [arclen, az] = distance(icnLat, icnLon, FltRwyLat(i), FltRwyLon(i), wgs84Ellipsoid);
            ldX = arclen*sin(az/180*pi);
            ldY = arclen*cos(az/180*pi);
            rwyDist = zeros(3, 1);
            for r=1:3
                rwyDist(r) = norm(cross([rwyX(r+3)-rwyX(r), rwyY(r+3)-rwyY(r), 0], [ldX-rwyX(r), ldY-rwyY(r), 0]))/norm([rwyX(r+3)-rwyX(r), rwyY(r+3)-rwyY(r), 0]);
            end
            [minDist, indMinDist] = min(rwyDist);
            if minDist > 100
                continue;
            end
            
            [~, az] = distance(FltLat(indID(indLD)), FltLon(indID(indLD)), FltLat(indID(indLD+10)), FltLon(indID(indLD+10)), wgs84Ellipsoid);
            if (az < 90) || (az > 270) % North flow
                arrRwyID = indMinDist;
            else
                arrRwyID = indMinDist+3;
            end

            indFP = intersect(find(strcmp(uniID(i), IIS_Arr.FLIGHT_3)), find(strcmp(datestr(FltDT(indID(indLD)), 'yyyy-mm-dd'), IIS_Arr.SDT)));
            if length(indFP)>1
                disp(['[ARR] ', uniID{i}, ' - multiple info in FP']);
            else
                if isempty(indFP)
                    disp(['[ARR] ', uniID{i}, ' - no info in FP']);
                elseif ~strcmp(IIS_Arr.RWY(indFP), rwyName(arrRwyID))
                    if isnumeric(IIS_Arr.RWY{indFP}) && isnumeric(rwyName{arrRwyID})
                        if IIS_Arr.RWY{indFP}~=rwyName{arrRwyID}
                            disp(['[ARR] ', uniID{i}, ' - ', num2str(rwyName{arrRwyID}), ' - FP ', num2str(IIS_Arr.RWY{indFP})]);
                        end
                    else
                        disp(['[ARR] ', uniID{i}, ' - ', rwyName{arrRwyID}, ' - FP ', IIS_Arr.RWY{indFP}]);
                        
%                         figure;
%                         geoplot(FltLat(indID), FltLon(indID));
%                         hold on;
%                         geoplot(FltLat(indID(indLD)), FltLon(indID(indLD)), 'r*');
%                         text(FltLat(indID(indLD)), FltLon(indID(indLD)), ['Arr ', uniID{i}]);
                    end
                end
                FltRwyDist(i) = distance(rwyThrLat(arrRwyID), rwyThrLon(arrRwyID), FltLat(indID(indLD)), FltLon(indID(indLD)), wgs84Ellipsoid);
                FltOps(i) = 1;
                FltRwyID(i) = arrRwyID;
                if ~isempty(indFP)
                    FltAC{i} = IIS_Arr.TYP{indFP};
                end
            end
        end
    end
    
    
    
    % 데이터 추가
    indDep = find(FltOps == 0);
    indArr = find(FltOps == 1);
    onAC = [onAC; FltAC(indArr)];
    onLat = [onLat; FltRwyLat(indArr)];
    onLon = [onLon; FltRwyLon(indArr)];
    onRwy = [onRwy; FltRwyID(indArr)];
    onDist = [onDist; FltRwyDist(indArr)];
    offAC = [offAC; FltAC(indDep)];
    offLat = [offLat; FltRwyLat(indDep)];
    offLon = [offLon; FltRwyLon(indDep)];
    offRwy = [offRwy; FltRwyID(indDep)];
    offDist = [offDist; FltRwyDist(indDep)];
end





% plot1 Northflow
figure;
geoplot(rwyThrLat, rwyThrLon, 'gd');
hold on;
for i=1:3
    indOnRwy = find(onRwy==i);  % Arrival on runway i
    if ~isempty(indOnRwy)
        geoplot(onLat(indOnRwy), onLon(indOnRwy), 'r*');
    end
    indOffRwy = find(offRwy==i);    % Departure on runway i
    if ~isempty(indOffRwy)
        geoplot(offLat(indOffRwy), offLon(indOffRwy), 'b*');
    end
end
title('North flow');
legend('RWY Threshold', 'Arrival', 'Departure');





% plot2 Southflow
figure;
geoplot(rwyThrLat, rwyThrLon, 'gd');
hold on;
for i=4:6
    indOnRwy = find(onRwy==i);  % Arrival on runway i
    if ~isempty(indOnRwy)
        geoplot(onLat(indOnRwy), onLon(indOnRwy), 'r*');
    end
    indOffRwy = find(offRwy==i);    % Departure on runway i
    if ~isempty(indOffRwy)
        geoplot(offLat(indOffRwy), offLon(indOffRwy), 'b*');
    end
end
title('South flow');
legend('RWY Threshold', 'Arrival', 'Departure');





% others...?
for i=1:6
    indOnRwy = find(onRwy==i);  % Arrival on runway i
    if ~isempty(indOnRwy)
        figure;
        histogram(onDist(indOnRwy), floor(min(onDist(indOnRwy))):1:ceil(max(onDist(indOnRwy))));
        title(['On distance (m) from ', rwyName{i}, ' threshold']);
    end
    indOffRwy = find(offRwy==i);    % Departure on runway i
    if ~isempty(indOffRwy)
        figure;
        histogram(offDist(indOffRwy), floor(min(offDist(indOffRwy))):1:ceil(max(offDist(indOffRwy))));
        title(['Off distance (m) from ', rwyName{i}, ' threshold']);
    end
end