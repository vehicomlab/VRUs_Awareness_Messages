function data = change_sampling_interval(data,sampling_interval)
    
    for i=1:1:length(data.timestamp)
        if isnan(data.heading(i))
            data.heading(i) = 1000;     % set the NaN of the original dataset to a value larger than 360
        end
    end

    jump = sampling_interval/100-1;
    count = 0;
    if jump ~= count
        for i=2:1:length(data.timestamp)
            if jump ~= count
                data.timestamp(i) = NaN;
                data.latitude(i) = NaN;
                data.longitude(i) = NaN;
                data.speed_x(i) = NaN;
                data.speed_y(i) = NaN;
                data.speed(i) = NaN;
                data.heading(i) = NaN;
                count = count+1;
            else
                count = 0;
            end
        end
    end

    data.timestamp = data.timestamp(~ismissing(data.timestamp));
    data.latitude = data.latitude(~isnan(data.latitude));
    data.longitude = data.longitude(~isnan(data.longitude));
    data.speed_x = data.speed_x(~isnan(data.speed_x));
    data.speed_y = data.speed_y(~isnan(data.speed_y));
    data.speed = data.speed(~isnan(data.speed));
    data.heading = data.heading(~isnan(data.heading));

    for i=1:1:length(data.timestamp)
        if data.heading(i) == 1000
            data.heading(i) = NaN;     % restore the NaN of the original dataset
        end
    end
end