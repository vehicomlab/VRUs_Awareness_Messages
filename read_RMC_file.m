function U7_RMC_data = read_RMC_file(fid)
    
    Previous_RMC_timestamp = 0;

    RMC_timestamp = string([]);
    RMC_latitude = [];
    RMC_longitude = [];
    RMC_speed = [];
    RMC_heading = [];
    
    tline = fgetl(fid);     % get the first line
    while tline ~= -1       % Parse the whole file
        tline_split = strsplit(tline, ',', 'CollapseDelimiters',false);
        if tline_split{1} == '$GPRMC'
            if Previous_RMC_timestamp == 0 || Previous_RMC_timestamp < str2double(tline_split{2})   % check for duplicated timestamps
                Previous_RMC_timestamp = str2double(tline_split{2});
                % latitude and longitude processing
                %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%
                latitude_str = tline_split{4};   % extract the latitude part
                latitude_dir = tline_split{5};   % extract the direction part for latitude (N or S)
                longitude_str = tline_split{6};  % extract the longitude part
                longitude_dir = tline_split{7};  % extract the direction part for longitude (E or W)
                %  convert latitude and longitude from DDMM.mmmmm format to decimal degrees
                latitude_deg = str2double(latitude_str(1:2)) + str2double(latitude_str(3:end)) / 60;
                if latitude_dir == 'S'
                    latitude_deg = -latitude_deg; % if in the Southern hemisphere, negate the value
                end
                longitude_deg = str2double(longitude_str(1:3)) + str2double(longitude_str(4:end)) / 60;
                if longitude_dir == 'W'
                    longitude_deg = -longitude_deg; % if in the Western hemisphere, negate the value
                end
                %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%
                % speed conversion factor
                %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%
                % be careful speed is measured in knots
                % 1 knot = 1 nautical mile per hour = 1852 meters per hour
                % in one hour there are 3600 seconds
                ConvFactor = 1852/3600;
                %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%
                RMC_timestamp(end+1) = cell2mat(tline_split(2));              % RMC timestamp
                RMC_latitude(end+1) = latitude_deg;                           % RMC latitude
                RMC_longitude(end+1) = longitude_deg;                         % RMC longitude
                RMC_speed(end+1) = str2double(tline_split{8})*ConvFactor;     % RMC speed
                RMC_heading(end+1) = str2double(tline_split{9});              % RMC heading
            end
            tline = fgetl(fid);
            tline = fgetl(fid);
        else    % other log header (e.g. GPGST, GPTXT)
            tline = fgetl(fid);
            tline = fgetl(fid);
        end
    end

    U7_RMC_data = struct;
    U7_RMC_data.timestamp = RMC_timestamp;
    U7_RMC_data.latitude = RMC_latitude;
    U7_RMC_data.longitude = RMC_longitude;
    U7_RMC_data.speed = RMC_speed;
    U7_RMC_data.heading = RMC_heading;

end
