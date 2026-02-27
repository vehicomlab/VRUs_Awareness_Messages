function [VAMtrace, Mixed_info] = GenerateVAMs(RMC_data,GST_data,thresholds,NewAlgorithm)

    format long

    TriggerTypes = ["Distance" "Heading" "Speed" "Timeout" "Mixed"];

    timestamp_vec = [];
    T_VAM_vec = [];
    latitude_vec = [];
    longitude_vec = [];
    TriggerType_vec = string([]);

    timestamp_vec_Mixed_info = [];
    distance_flag_vec = [];
    heading_flag_vec = [];
    speed_flag_vec = [];
    timeout_flag_vec = [];

    accuracy = 0;

    temporary_array = zeros(1,length(RMC_data.timestamp));
    for i=1:length(RMC_data.timestamp)
      temporary_array(i) = TimestampConverter(RMC_data.timestamp(i));
    end
    RMC_data.timestamp = temporary_array;
   
    % Extract data using the first valid index
    last_VAM_RMC_timestamp = RMC_data.timestamp(1);
    last_VAM_lat = RMC_data.latitude(1);
    last_VAM_lon = RMC_data.longitude(1);
    last_VAM_speed = RMC_data.speed(1);
    last_VAM_heading = RMC_data.heading(1);

    for i = 2:length(RMC_data.timestamp)
        current_timestamp = RMC_data.timestamp(i);
        delta_distance = HaversineDistance_Computation(last_VAM_lat,last_VAM_lon,RMC_data.latitude(i),RMC_data.longitude(i));
        delta_heading = abs(RMC_data.heading(i)-last_VAM_heading);
        if (delta_heading > 180)
            delta_heading = 360 - delta_heading;
        end
        delta_speed = abs(RMC_data.speed(i)-last_VAM_speed);
        delta_timestamp = round((current_timestamp-last_VAM_RMC_timestamp)*1000);
    
        if NewAlgorithm == true
            index = find(GST_data.timestamp == InverseTimestampConverter(RMC_data.timestamp(i)));
            if index
                accuracy = max([GST_data.latitude_error(index) GST_data.longitude_error(index)]);
            end
        end
        
        if ((delta_distance >= thresholds.distance) || ((delta_heading >= thresholds.heading) && (delta_distance >= accuracy)) || (delta_speed >= thresholds.speed) || (delta_timestamp >= 5000))
                
            % Every time that a VAM is generated these parameters need to be uploaded (ETSI TS 103 300-3 V2.2.1)
            T_VAM = delta_timestamp;
            last_VAM_RMC_timestamp = current_timestamp;
            last_VAM_lat = RMC_data.latitude(i);
            last_VAM_lon = RMC_data.longitude(i);
            last_VAM_speed = RMC_data.speed(i);
            last_VAM_heading = RMC_data.heading(i);
                
            % Which is/are the variable/variables that trigger the VAM generation?
            distance_flag = false;
            if (delta_distance >= thresholds.distance)
                distance_flag = true;
            end
            heading_flag = false;
            if (delta_heading >= thresholds.heading)
                heading_flag = true;
            end
            speed_flag = false;
            if (delta_speed >= thresholds.speed)
                speed_flag = true;
            end
            timeout_flag = false;
            if (delta_timestamp >= 5000)
                timeout_flag = true;
            end
            
            timestamp_vec(end+1) = RMC_data.timestamp(i);
            T_VAM_vec(end+1) = round(T_VAM);
            latitude_vec(end+1) = last_VAM_lat;
            longitude_vec(end+1) = last_VAM_lon;
        
            triggers = [distance_flag heading_flag speed_flag timeout_flag];
            TriggerIndex = find(triggers);      % returns a vector containing the linear indices of each nonzero element in array triggers.
        
            if length(TriggerIndex) > 1
                TriggerType_vec(end+1) = "Mixed";
                timestamp_vec_Mixed_info(end+1) = RMC_data.timestamp(i);
                distance_flag_vec(end+1) = distance_flag;
                heading_flag_vec(end+1) = heading_flag;
                speed_flag_vec(end+1) = speed_flag;
                timeout_flag_vec(end+1) = timeout_flag;
            else
                TriggerType_vec(end+1) = TriggerTypes(TriggerIndex);
            end
        end
    end

    temporary_array = string([]);
    for i=1:length(timestamp_vec)
      temporary_array(end+1) = InverseTimestampConverter(timestamp_vec(i));
    end
    timestamp_vec = temporary_array;

    temporary_array = string([]);
    for i=1:length(timestamp_vec_Mixed_info)
      temporary_array(end+1) = InverseTimestampConverter(timestamp_vec_Mixed_info(i));
    end
    timestamp_vec_Mixed_info = temporary_array;

    % VAM trace struct
    VAMtrace = struct;
    VAMtrace.timestamp = timestamp_vec;
    VAMtrace.T_VAM = T_VAM_vec;
    VAMtrace.latitude = latitude_vec;
    VAMtrace.longitude = longitude_vec;
    VAMtrace.TriggerType = TriggerType_vec;

    % TriggerType Mixed info
    Mixed_info = struct;
    Mixed_info.timestamp = timestamp_vec_Mixed_info;
    Mixed_info.distance = distance_flag_vec;
    Mixed_info.heading = heading_flag_vec;
    Mixed_info.speed = speed_flag_vec;
    Mixed_info.timeout = timeout_flag_vec;

end