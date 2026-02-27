function timestamp = TimestampConverter(timestamp)

    comma_pos = strfind(timestamp, '.');
    if isempty(comma_pos)
        digits_before_comma = numel(timestamp);
    else
        digits_before_comma = comma_pos - 1;
    end
    if digits_before_comma == 5
        timestamp =  strcat('0',timestamp);
    end

    timestamp = char(timestamp);
    hh = string(timestamp(1:2));
    mm = string(timestamp(3:4));
    ss = string(timestamp(5:end));

    hh = str2double(hh)*3600;
    mm = str2double(mm)*60;
    ss = str2double(ss);

    timestamp = hh + mm + ss;
end

