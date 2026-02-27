function distance = HaversineDistance_Computation(lat1,lon1,lat2,lon2)

    R = 6378.0;                         % Earth radius at the equator

    % Convert coordinates from degrees to radians
    dlat = deg2rad(lat2-lat1);
    dlon = deg2rad(lon2-lon1);
    lat1 = deg2rad(lat1);
    lat2 = deg2rad(lat2);
    
    % Compute the distance between two coordinates
    a = (sin(dlat/2)^2 + cos(lat1) * cos(lat2) * sin(dlon/2)^2);
    distance = 2 * R * asin(sqrt(a));
    distance = distance * 1000;         % return the distance in meters

end

