function timestamp = InverseTimestampConverter(timestamp_seconds)

    hh = floor(timestamp_seconds / 3600);
    mm = floor((timestamp_seconds - hh * 3600) / 60);
    ss = mod(timestamp_seconds, 60);

    hh_str = sprintf('%02d', hh);
    mm_str = sprintf('%02d', mm);

    if ss < 10
        ss_str = strcat('0',sprintf('%.2f', ss));
    else
        ss_str = sprintf('%.2f', ss);
    end

    timestamp = [hh_str, mm_str, ss_str];
end
