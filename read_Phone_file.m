function [Phone_RMC_data,Phone_GST_data] = read_Phone_file(fid)

    Phone_timestamp = string([]);
    Phone_latitude = [];
    Phone_longitude = [];
    Phone_heading = [];
    Phone_speed = [];
    Phone_AccuracyMeters = [];

    for i = 1:3
        tline = fgetl(fid);
    end
    while tline ~= -1       % Parse the whole file
        data = strsplit(tline, ',', 'CollapseDelimiters',false);
        UNIX_Time = str2double(data(9));
        UTC_Time = datetime(UNIX_Time/1000, 'ConvertFrom', 'posixtime', 'TimeZone', 'UTC');
        hours = hour(UTC_Time);
        minutes = minute(UTC_Time);
        seconds = second(UTC_Time);
        UTC_Time_str = sprintf('%02d%02d%02d.00', hours, minutes, seconds);
        Phone_timestamp(end+1) = UTC_Time_str;
        Phone_latitude(end+1)  = str2double(data(3));
        Phone_longitude(end+1) = str2double(data(4));
        Phone_speed(end+1)     = str2double(data(6));
        if str2double(data(8)) < 0
            Phone_heading(end+1) = str2double(data(8))+360;
        else
            Phone_heading(end+1) = str2double(data(8));
        end
        Phone_AccuracyMeters(end+1) = str2double(data(7));
        tline = fgetl(fid);
    end

    Phone_RMC_data           = struct;
    Phone_RMC_data.timestamp = Phone_timestamp;
    Phone_RMC_data.latitude  = Phone_latitude;
    Phone_RMC_data.longitude = Phone_longitude;
    Phone_RMC_data.speed     = Phone_speed;
    Phone_RMC_data.heading   = Phone_heading;

    Phone_GST_data = struct;
    Phone_GST_data.timestamp = Phone_timestamp;
    Phone_GST_data.latitude_error = Phone_AccuracyMeters;
    Phone_GST_data.longitude_error = Phone_AccuracyMeters;

end
