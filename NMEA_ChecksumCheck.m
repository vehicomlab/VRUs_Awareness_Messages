function counter = NMEA_ChecksumCheck(fid)

    FirstTime = true;
    counter = 0;
    NMEA_string = fgetl(fid);
    
    while NMEA_string ~= -1       % Parse the whole file
    
        checksum = 0;
        NO_CS_string = strtok(NMEA_string,'*');     % return the first part of the string using the '*' character as a delimiter
        NO_CS_NMEA_string = double(NO_CS_string);   % convert characters in string to double values
        for i = 2:length(NO_CS_NMEA_string)                     % since checksum calculation ignores $ the for loop starts from 2
            checksum = bitxor(checksum,NO_CS_NMEA_string(i));   % checksum calculation
            checksum = uint16(checksum);                        % make sure that checksum is unsigned int16
        end
        % convert checksum to hex value
        checksum = dec2hex(double(checksum));
        % add leading zero to checksum if it is a single digit, e.g. 4 has a 0 added so that the checksum is 04
        if length(checksum) == 1
            checksum = strcat('0',checksum);
        end
        NMEA_string_split = strsplit(NMEA_string, '*');
        if strtrim(string(checksum)) ~= strtrim(string(cell2mat(NMEA_string_split(2))))
            if FirstTime
                fprintf("Corrupted strings:\r\n");
                FirstTime = false;
            end
            fprintf("   NMEA_string = %s \r",NMEA_string);
            fprintf("   Computed checksum = %s \r\n",string(checksum));
            counter = counter+1;
        end
        NMEA_string = fgetl(fid);
        NMEA_string = fgetl(fid);
    end
    
    if ~FirstTime
        fprintf("\nPlease remove the corrupted strings from the .txt file");
    
    end
end