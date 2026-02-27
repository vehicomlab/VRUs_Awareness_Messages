function data = select_round(data,StartPoint,EndPoint,bool_Trajectories,bool_Geo_plot)

    if bool_Trajectories
        for i=1:1:length(data.timestamp)
            if TimestampConverter(data.timestamp(i)) < TimestampConverter(StartPoint) || TimestampConverter(data.timestamp(i)) > TimestampConverter(EndPoint)
                data.timestamp(i) = NaN;
                data.latitude(i) = NaN;
                data.longitude(i) = NaN;
                data.speed(i) = NaN;
            end
        end
    end

    if bool_Geo_plot
        for i=1:1:length(data.distance_timestamp)
            if TimestampConverter(data.distance_timestamp(i)) < TimestampConverter(StartPoint) || TimestampConverter(data.distance_timestamp(i)) > TimestampConverter(EndPoint)
                data.distance_timestamp(i) = NaN;
                data.distance_lat(i) = NaN;
                data.distance_lon(i) = NaN;
            end
        end
        for i=1:1:length(data.heading_timestamp)
            if TimestampConverter(data.heading_timestamp(i)) < TimestampConverter(StartPoint) || TimestampConverter(data.heading_timestamp(i)) > TimestampConverter(EndPoint)
                data.heading_timestamp(i) = NaN;
                data.heading_lat(i) = NaN;
                data.heading_lon(i) = NaN;
            end
        end
        for i=1:1:length(data.speed_timestamp)
            if TimestampConverter(data.speed_timestamp(i)) < TimestampConverter(StartPoint) || TimestampConverter(data.speed_timestamp(i)) > TimestampConverter(EndPoint)
                data.speed_timestamp(i) = NaN;
                data.speed_lat(i) = NaN;
                data.speed_lon(i) = NaN;
            end
        end
    end

end