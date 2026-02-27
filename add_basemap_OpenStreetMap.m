function add_basemap_OpenStreetMap()

    % This function is used to add Basemap from OpenStreetMap

    % Assigned Name
    basemapName = "openstreetmap";
    % URL template for fetching tiles from OpenStreetMap
    url = "a.tile.openstreetmap.org/${z}/${x}/${y}.png";
    % Create the copyright symbol © using its unicode representation
    copyright = char(uint8(169));
    % Construct the attribution text for OpenStreetMap contributors
    attribution = copyright + "OpenStreetMap contributors";
    % Add the custom basemap to the list of basemaps available for use with mapping functions
    addCustomBasemap(basemapName, url, "Attribution", attribution);
    
end
