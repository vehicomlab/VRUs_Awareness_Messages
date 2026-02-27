function [false_pos,false_neg] = false_identifier(SPAN_VAMs,data_VAMs,max_delta)

    tolerance = 1e-10;

    false_pos = struct;
    false_pos.distance = 0;
    false_pos.heading = 0;
    false_pos.speed = 0;

    false_neg = struct;
    false_neg.distance = 0;
    false_neg.heading = 0;
    false_neg.speed = 0;

    % Timestamp conversion
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%
    temporary_array = [];
    for i=1:length(SPAN_VAMs.distance_timestamp)
      temporary_array(end+1) = TimestampConverter(SPAN_VAMs.distance_timestamp(i));
    end
    SPAN_VAMs.distance_timestamp = temporary_array;

    temporary_array = [];
    for i=1:length(SPAN_VAMs.heading_timestamp)
      temporary_array(end+1) = TimestampConverter(SPAN_VAMs.heading_timestamp(i));
    end
    SPAN_VAMs.heading_timestamp = temporary_array;

    temporary_array = [];
    for i=1:length(SPAN_VAMs.speed_timestamp)
      temporary_array(end+1) = TimestampConverter(SPAN_VAMs.speed_timestamp(i));
    end
    SPAN_VAMs.speed_timestamp = temporary_array;

    temporary_array = [];
    for i=1:length(data_VAMs.distance_timestamp)
      temporary_array(end+1) = TimestampConverter(data_VAMs.distance_timestamp(i));
    end
    data_VAMs.distance_timestamp = temporary_array;

    temporary_array = [];
    for i=1:length(data_VAMs.heading_timestamp)
      temporary_array(end+1) = TimestampConverter(data_VAMs.heading_timestamp(i));
    end
    data_VAMs.heading_timestamp = temporary_array;

    temporary_array = [];
    for i=1:length(data_VAMs.speed_timestamp)
      temporary_array(end+1) = TimestampConverter(data_VAMs.speed_timestamp(i));
    end
    data_VAMs.speed_timestamp = temporary_array;
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%


    % Identifying common VAMs of distance, heading, and speed
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%

    % Distance
    common_VAMs_d = [];
    for i = 1:length(data_VAMs.distance_timestamp)
        if ~isempty(find(SPAN_VAMs.distance_timestamp == data_VAMs.distance_timestamp(i)))
            common_VAMs_d(end+1) = data_VAMs.distance_timestamp(i);
        end
    end
    % fprintf("Number of perfectly matched VAMs (distance): %d\n",length(common_VAMs_d))

    % Heading
    common_VAMs_h = [];
    for i = 1:length(data_VAMs.heading_timestamp)
        if ~isempty(find(SPAN_VAMs.heading_timestamp == data_VAMs.heading_timestamp(i)))
            common_VAMs_h(end+1) = data_VAMs.heading_timestamp(i);
        end
    end
    % fprintf("Number of perfectly matched VAMs (heading): %d\n",length(common_VAMs_h))

    % Speed
    common_VAMs_s = [];
    for i = 1:length(data_VAMs.speed_timestamp)
        if ~isempty(find(SPAN_VAMs.speed_timestamp == data_VAMs.speed_timestamp(i)))
            common_VAMs_s(end+1) = data_VAMs.speed_timestamp(i);
        end
    end
    % fprintf("Number of perfectly matched VAMs (speed): %d\n\n",length(common_VAMs_s))

    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%


    % Identifying false negative VAMs of distance, heading, and speed
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%

    % Distance
    match_VAMs_d = [];
    for i = 1:length(SPAN_VAMs.distance_timestamp)
        found = false;
        for delta = 0.1:0.1:(max_delta*0.1)
            if ~found
                k_0 = SPAN_VAMs.distance_timestamp(i) - delta;
                k_end = SPAN_VAMs.distance_timestamp(i) + delta;
                timestamps = k_0:0.1:k_end;
                for l = 1:length(data_VAMs.distance_timestamp)
                    if length(match_VAMs_d) < (length(SPAN_VAMs.distance_timestamp)-length(common_VAMs_d))
                        if any(abs(timestamps - data_VAMs.distance_timestamp(l)) < tolerance) && isempty(find(match_VAMs_d == data_VAMs.distance_timestamp(l), 1)) && isempty(find(common_VAMs_d == data_VAMs.distance_timestamp(l), 1))
                            match_VAMs_d(end+1) = data_VAMs.distance_timestamp(l);
                            found = true;
                        end
                    end
                end
            end
        end
    end
    false_neg.distance = length(SPAN_VAMs.distance_timestamp) - length(common_VAMs_d) - length(match_VAMs_d);

    % Heading
    match_VAMs_h = [];
    for i = 1:length(SPAN_VAMs.heading_timestamp)
        found = false;
        for delta = 0.1:0.1:(max_delta*0.1)
            if ~found
                k_0 = SPAN_VAMs.heading_timestamp(i) - delta;
                k_end = SPAN_VAMs.heading_timestamp(i) + delta;
                timestamps = k_0:0.1:k_end;
                for l = 1:length(data_VAMs.heading_timestamp)
                    if length(match_VAMs_h) < (length(SPAN_VAMs.heading_timestamp)-length(common_VAMs_h))
                        if any(abs(timestamps - data_VAMs.heading_timestamp(l)) < tolerance) && isempty(find(match_VAMs_h == data_VAMs.heading_timestamp(l), 1)) && isempty(find(common_VAMs_h == data_VAMs.heading_timestamp(l), 1))
                            match_VAMs_h(end+1) = data_VAMs.heading_timestamp(l);
                            found = true;
                        end
                    end
                end
            end
        end
    end
    false_neg.heading = length(SPAN_VAMs.heading_timestamp) - length(common_VAMs_h) - length(match_VAMs_h);

    % Speed
    match_VAMs_s = [];
    for i = 1:length(SPAN_VAMs.speed_timestamp)
        found = false;
        for delta = 0.1:0.1:(max_delta*0.1)
            if ~found
                k_0 = SPAN_VAMs.speed_timestamp(i) - delta;
                k_end = SPAN_VAMs.speed_timestamp(i) + delta;
                timestamps = k_0:0.1:k_end;
                for l = 1:length(data_VAMs.speed_timestamp)
                    if length(match_VAMs_s) < (length(SPAN_VAMs.speed_timestamp)-length(common_VAMs_s))
                        if any(abs(timestamps - data_VAMs.speed_timestamp(l)) < tolerance) && isempty(find(match_VAMs_s == data_VAMs.speed_timestamp(l), 1)) && isempty(find(common_VAMs_s == data_VAMs.speed_timestamp(l), 1))
                            match_VAMs_s(end+1) = data_VAMs.speed_timestamp(l);
                            found = true;
                        end
                    end
                end
            end
        end
    end
    false_neg.speed = length(SPAN_VAMs.speed_timestamp) - length(common_VAMs_s) - length(match_VAMs_s);

    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%


    % Identifying false positives VAMs of distance, heading, and speed
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%

    % Distance
    match_VAMs_d = [];
    for i = 1:length(data_VAMs.distance_timestamp)
        found = false;
        for delta = 0.1:0.1:(max_delta*0.1)
            if ~found
                k_0 = data_VAMs.distance_timestamp(i) - delta;
                k_end = data_VAMs.distance_timestamp(i) + delta;
                timestamps = k_0:0.1:k_end;
                for l = 1:length(SPAN_VAMs.distance_timestamp)
                    if length(match_VAMs_d) < (length(data_VAMs.distance_timestamp)-length(common_VAMs_d))
                        if any(abs(timestamps - SPAN_VAMs.distance_timestamp(l)) < tolerance) && isempty(find(match_VAMs_d == SPAN_VAMs.distance_timestamp(l), 1)) && isempty(find(common_VAMs_d == SPAN_VAMs.distance_timestamp(l), 1))
                            match_VAMs_d(end+1) = SPAN_VAMs.distance_timestamp(l);
                            found = true;
                        end
                    end
                end
            end
        end
    end
    false_pos.distance = length(data_VAMs.distance_timestamp) - length(common_VAMs_d) - length(match_VAMs_d);
    
    % Heading
    match_VAMs_h = [];
    for i = 1:length(data_VAMs.heading_timestamp)
        found = false;
        for delta = 0.1:0.1:(max_delta*0.1)
            if ~found
                k_0 = data_VAMs.heading_timestamp(i) - delta;
                k_end = data_VAMs.heading_timestamp(i) + delta;
                timestamps = k_0:0.1:k_end;
                for l = 1:length(SPAN_VAMs.heading_timestamp)
                    if length(match_VAMs_h) < (length(data_VAMs.heading_timestamp)-length(common_VAMs_h))
                        if any(abs(timestamps - SPAN_VAMs.heading_timestamp(l)) < tolerance) && isempty(find(match_VAMs_h == SPAN_VAMs.heading_timestamp(l), 1)) && isempty(find(common_VAMs_h == SPAN_VAMs.heading_timestamp(l), 1))
                            match_VAMs_h(end+1) = SPAN_VAMs.heading_timestamp(l);
                            found = true;
                        end
                    end
                end
            end
        end
    end
    false_pos.heading = length(data_VAMs.heading_timestamp) - length(common_VAMs_h) - length(match_VAMs_h);
    
    % Speed
    match_VAMs_s = [];
    for i = 1:length(data_VAMs.speed_timestamp)
        found = false;
        for delta = 0.1:0.1:(max_delta*0.1)
            if ~found
                k_0 = data_VAMs.speed_timestamp(i) - delta;
                k_end = data_VAMs.speed_timestamp(i) + delta;
                timestamps = k_0:0.1:k_end;
                for l = 1:length(SPAN_VAMs.speed_timestamp)
                    if length(match_VAMs_s) < (length(data_VAMs.speed_timestamp)-length(common_VAMs_s))
                        if any(abs(timestamps - SPAN_VAMs.speed_timestamp(l)) < tolerance) && isempty(find(match_VAMs_s == SPAN_VAMs.speed_timestamp(l), 1)) && isempty(find(common_VAMs_s == SPAN_VAMs.speed_timestamp(l), 1))
                            match_VAMs_s(end+1) = SPAN_VAMs.speed_timestamp(l);
                            found = true;
                        end
                    end
                end
            end
        end
    end
    false_pos.speed = length(data_VAMs.speed_timestamp) - length(common_VAMs_s) - length(match_VAMs_s);

    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%

end