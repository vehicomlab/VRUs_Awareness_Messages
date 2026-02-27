function VAMcoordinates = VAMTraceProcessor(VAMtrace,Mixed_info,label)

    VAMcoordinates = struct;
    VAMcoordinates.label = label;
    VAMcoordinates.distance_timestamp = string([]);
    VAMcoordinates.distance_lat = [];
    VAMcoordinates.distance_lon = [];
    VAMcoordinates.heading_timestamp = string([]);
    VAMcoordinates.heading_lat = [];
    VAMcoordinates.heading_lon = [];
    VAMcoordinates.speed_timestamp = string([]);
    VAMcoordinates.speed_lat = [];
    VAMcoordinates.speed_lon = [];

    TypeVector = ["Distance" "Heading" "Speed"];
    for Type = TypeVector
        VAMtrace_timestamp = string([]);
        VAMtrace_latitude = [];
        VAMtrace_longitude = [];
        for i = 1:length(VAMtrace.T_VAM)
            if VAMtrace.TriggerType(i) == Type
                VAMtrace_timestamp(end+1) = VAMtrace.timestamp(i);
                VAMtrace_latitude(end+1) = VAMtrace.latitude(i);
                VAMtrace_longitude(end+1) = VAMtrace.longitude(i);
            end
            if VAMtrace.TriggerType(i) == "Mixed"
                index = find(Mixed_info.timestamp == VAMtrace.timestamp(i));
                if index
                    if (Mixed_info.distance(index) && Type == "Distance") || (Mixed_info.heading(index) && Type == "Heading") || (Mixed_info.speed(index) && Type == "Speed")
                        VAMtrace_timestamp(end+1) = VAMtrace.timestamp(i);
                        VAMtrace_latitude(end+1) = VAMtrace.latitude(i);
                        VAMtrace_longitude(end+1) = VAMtrace.longitude(i);
                    end
                end
            end
        end

        if Type == "Distance"
            VAMcoordinates.distance_timestamp = VAMtrace_timestamp;
            VAMcoordinates.distance_lat = VAMtrace_latitude;
            VAMcoordinates.distance_lon = VAMtrace_longitude;
        end
        if Type == "Heading"
            VAMcoordinates.heading_timestamp = VAMtrace_timestamp;
            VAMcoordinates.heading_lat = VAMtrace_latitude;
            VAMcoordinates.heading_lon = VAMtrace_longitude;
        end
        if Type == "Speed"
            VAMcoordinates.speed_timestamp = VAMtrace_timestamp;
            VAMcoordinates.speed_lat = VAMtrace_latitude;
            VAMcoordinates.speed_lon = VAMtrace_longitude;
        end
    end

end