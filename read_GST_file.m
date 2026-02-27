function U7_GST_data = read_GST_file(fid)
    
    Previous_GST_timestamp = 0;

    GST_timestamp = string([]);
    GST_latitude_error = [];
    GST_longitude_error = [];
    
    tline = fgetl(fid);     % get the first line
    while tline ~= -1       % Parse the whole file
        tline_split = strsplit(tline, ',', 'CollapseDelimiters',false);
        if tline_split{1} == '$GPGST'
            if Previous_GST_timestamp == 0 || Previous_GST_timestamp < str2double(tline_split{2})   % check for duplicated timestamps
                Previous_GST_timestamp = str2double(tline_split(2));
                GST_timestamp(end+1) = cell2mat(tline_split(2));                      % GST timestamp
                GST_latitude_error(end+1) = str2double(cell2mat(tline_split(7)));     % GST latitude_error
                GST_longitude_error(end+1) = str2double(cell2mat(tline_split(8)));    % GST longitude_error
            end
            tline = fgetl(fid);
            tline = fgetl(fid);
        else    % other log header (e.g. GPRMC, GPTXT)
            tline = fgetl(fid);
            tline = fgetl(fid);
        end
    end

    U7_GST_data = struct;
    U7_GST_data.timestamp = GST_timestamp;
    U7_GST_data.latitude_error = GST_latitude_error;
    U7_GST_data.longitude_error = GST_longitude_error;

end
