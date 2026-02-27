function data = remove_tiemstamp(data,missing_indices)

    % Remove entries based on missing_indices
    keep_indices = true(length(data.timestamp), 1);
    keep_indices(missing_indices) = false;

    % Update data fields using logical indexing
    data.timestamp = data.timestamp(keep_indices);
    data.latitude = data.latitude(keep_indices);
    data.longitude = data.longitude(keep_indices);
    data.speed = data.speed(keep_indices);
    data.heading = data.heading(keep_indices);
end