function [SPAN_RMC_data,SPAN_GST_data] = read_SPAN_file(fid)
    
    SPAN_timestamp = string([]);
    SPAN_latitude = [];
    SPAN_longitude = [];
    SPAN_speed_x = [];
    SPAN_speed_y = [];
    SPAN_speed = [];
    SPAN_heading = [];
    SPAN_SD_latitude = [];
    SPAN_SD_longitude = [];
    SPAN_SD_heading = [];
    SPAN_SD_speed_x = [];
    SPAN_SD_speed_y = [];
    
    for i = 1:4
        tline = fgetl(fid);
    end

    while ischar(tline)
        data = regexp(tline, '\s+', 'split');
    
        SPAN_timestamp(end+1) = erase(data(2),":");
        SPAN_latitude(end+1) = str2double(data(11));
        SPAN_longitude(end+1) = str2double(data(12));
        SPAN_speed_x(end+1) = str2double(data(14));
        SPAN_speed_y(end+1) = str2double(data(15));
        SPAN_speed(end+1) = sqrt((str2double(data(14)))^2+(str2double(data(15)))^2);
        if str2double(data(18)) < 0
            SPAN_heading(end+1) = str2double(data(18))+360;
        else
            SPAN_heading(end+1) = str2double(data(18));
        end
        SPAN_SD_latitude(end+1) = str2double(data(19));
        SPAN_SD_longitude(end+1) = str2double(data(20));
        SPAN_SD_heading(end+1) = str2double(data(21));
        SPAN_SD_speed_x(end+1) = str2double(data(22));
        SPAN_SD_speed_y(end+1) = str2double(data(23));
    
        tline = fgetl(fid);   % get the first line
    end
        
    SPAN_RMC_data = struct;
    SPAN_RMC_data.timestamp = SPAN_timestamp;
    SPAN_RMC_data.latitude = SPAN_latitude;
    SPAN_RMC_data.longitude = SPAN_longitude;
    SPAN_RMC_data.speed_x = SPAN_speed_x;
    SPAN_RMC_data.speed_y = SPAN_speed_y;
    SPAN_RMC_data.speed = SPAN_speed;
    SPAN_RMC_data.heading = SPAN_heading;
    
    SPAN_GST_data = struct;
    SPAN_GST_data.timestamp = SPAN_timestamp;
    SPAN_GST_data.latitude_SD = SPAN_SD_latitude;
    SPAN_GST_data.longitude_SD = SPAN_SD_longitude;
    SPAN_GST_data.heading_SD = SPAN_SD_heading;
    SPAN_GST_data.speed_x_SD = SPAN_SD_speed_x;
    SPAN_GST_data.speed_y_SD = SPAN_SD_speed_y;

end
