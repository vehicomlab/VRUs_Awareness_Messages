function heading_vector = Heading_Computation(lat, lon)

    heading_vector = [];
    
    for i=2:length(lat)
    
        % Convert coordinates from degrees to radians
        lat1 = deg2rad(lat(i-1));
        lon1 = deg2rad(lon(i-1));
        lat2 = deg2rad(lat(i));
        lon2 = deg2rad(lon(i));
    
        % Calculate the difference in longitude
        lon_diff = lon2 - lon1;
    
        % Calculate the initial bearing in radians
        heading = atan2(sin(lon_diff) * cos(lat2), cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lon_diff));
    
        % Convert initial bearing from radians to degrees
        heading = rad2deg(heading);
    
        % Adjust the heading to be between 0 and 360 degrees
        if heading < 0
            heading = heading + 360;
        end
    
        heading_vector(end+1) = heading;
        
    end
end