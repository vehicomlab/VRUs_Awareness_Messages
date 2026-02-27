function speed_vector = Speed_Computation(data)

    speed_vector = [];

    for i=2:length(data.timestamp)

        distance = HaversineDistance_Computation(data.latitude(i-1),data.longitude(i-1),data.latitude(i),data.longitude(i));
        time = TimestampConverter(data.timestamp(i))-TimestampConverter(data.timestamp(i-1));
        speed_vector(end+1) = (distance/time);

    end

end