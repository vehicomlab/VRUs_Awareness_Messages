function [U7_RMC_data,KU7_RMC_data,U7_GST_data,missing_indices] = data_analyzer_GNSS(varargin)

    if nargin == 0          % Handle case when no inputs are provided

        close all
        clear all
        clc

        sampling_interval = 100;                      % [100,1000] ms, multiple 100 ms
        RMC_file = "U7_RMC_12_03_2024_foot.txt";      % U7_RMC_11_03_2024_bike.txt, U7_RMC_12_03_2024_foot.txt, U7_RMC_12_03_2024_bike.txt
        GST_file = "U7_GST_12_03_2024_foot.txt";      % U7_GST_11_03_2024_bike.txt, U7_GST_12_03_2024_foot.txt, U7_GST_12_03_2024_bike.txt

    elseif nargin == 2

        close all
        clear all
        clc
        sampling_interval = 100;                 % [100,1000] ms, multiple 100 ms
        RMC_file = varargin{1};
        GST_file = varargin{2};

    elseif nargin == 3

        close all
        clear all
        clc
        RMC_file = varargin{1};
        GST_file = varargin{2};
        sampling_interval = varargin{3};

    else

        error("Invalid number of input arguments in data_analyzer_U7 function");
        
    end
        
    if RMC_file == "U7_RMC_11_03_2024_bike.txt"
        Round_start = ["154604.90" "154623.30" "151828.80" "155158.10" "155900.00" "152159.10"];    % to parse whole file use "150735.00"
        Round_end   = ["155316.10" "154738.40" "152031.60" "155316.90" "160526.60" "152313.10"];    % to parse whole file use "161330.90"
    end

    if RMC_file == "U7_RMC_12_03_2024_foot.txt"
        Round_start = ["92013.20" "92100.30" "90816.30"];   % to parse whole file use "85646.00"
        Round_end   = ["94015.50" "92516.30" "91519.10"];   % to parse whole file use "100129.90"
    end

    if RMC_file == "U7_RMC_12_03_2024_bike.txt"
        Round_start = ["102807.30" "102808.30" "103200.90" "103645.20" "102508.40"];    % to parse whole file use "101011.00"
        Round_end   = ["104258.00" "102939.40" "103438.90" "103756.60" "102645.40"];    % to parse whole file use "104811.90"
    end

    VectorIndex = 1;


    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+%
    %             SETTING PANEL START             %
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+%
    folderPath = "Field_Tests/";
    PlotFolder = "PLOT/U7/21_05_2024/Foot_11_03_2024";

    VAM_gen                  =   false;
    VAM_gen_H_thresh         =   false;
    VAM_gen_multi_thresh     =   false;
    VAM_gen_multi_si         =   true;

    Trajectories_plot        =   false;
    HeadingVariations_plot   =   false;
    Speed_plot               =   false;
    PMF_plot                 =   false;
    Geo_plot                 =   false;
    Geo_plot_H_thresh        =   false;
    Geo_plot_multi_thresh    =   false;
    Geo_plot_multi_si        =   false;
    
    SaveEN = true;
    
    format long;
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+%
    %              SETTING PANEL END              %
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+%


    % Check checksum errors in the GNSS messages
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%
    fid = fopen(folderPath + RMC_file);
    NMEA_ChecksumCheck(fid);
    fclose(fid);
    fid = fopen(folderPath + GST_file);
    NMEA_ChecksumCheck(fid);
    fclose(fid);
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%
    

    % Extract data from GNSS messages
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%
    fid = fopen(folderPath + RMC_file);
    U7_RMC_data = read_RMC_file(fid);
    fclose(fid);
    fid = fopen(folderPath + GST_file);
    U7_GST_data = read_GST_file(fid);
    fclose(fid);
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%
    
    
    % Missed GNSS messages
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%
    MissedGNSSmessages = 0;
    missing_indices = [];
    for i=2:length(U7_RMC_data.timestamp)
        diff = TimestampConverter(U7_RMC_data.timestamp(i))-TimestampConverter(U7_RMC_data.timestamp(i-1));
        if diff > 0.11
            MissedGNSSmessages = MissedGNSSmessages+1;
            missing_indices(end+1) = i-1;
        end
    end
    fprintf("--> Misssed GNSS messages: %d out of %d\r\n",MissedGNSSmessages,length(U7_RMC_data.timestamp));
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%


    % Kalman Filter on latitude and longitude
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%
    Q_i = 1;     % variances on the diagonal of the covariance matrix Q (account for system dynamics uncertainty)
    R_i = 100;    % variances on the diagonal of the covariance matrix R (account for measurement uncertainty)
    KU7_RMC_data = KalmanFilter_RMC_GNSS(U7_RMC_data,Q_i,R_i);
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%    

    % Heading and Speed computation
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%
    U7_heading_comp  = Heading_Computation(U7_RMC_data.latitude,U7_RMC_data.longitude);
    KU7_heading_comp = Heading_Computation(KU7_RMC_data.latitude, KU7_RMC_data.longitude);
    U7_speed_comp    = Speed_Computation(U7_RMC_data);
    KU7_speed_comp   = Speed_Computation(KU7_RMC_data);
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%

    
    % Processing on vectors and structures
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%
    % U7_RMC_data struct
    U7_RMC_data.timestamp = U7_RMC_data.timestamp(2:end);
    U7_RMC_data.latitude  = U7_RMC_data.latitude(2:end);
    U7_RMC_data.longitude = U7_RMC_data.longitude(2:end);
    U7_RMC_data.heading   = U7_RMC_data.heading(2:end);
    U7_RMC_data.speed     = U7_RMC_data.speed(2:end);

    % KU7_RMC_data struct
    KU7_RMC_data.timestamp = KU7_RMC_data.timestamp(2:end);
    KU7_RMC_data.latitude  = KU7_RMC_data.latitude(2:end);
    KU7_RMC_data.longitude = KU7_RMC_data.longitude(2:end);
    KU7_RMC_data.heading   = KU7_heading_comp;          % computed with "Heading_Computation" function
    KU7_RMC_data.speed     = U7_RMC_data.speed;         % already resized
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%

    
    % VAM generation
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%
    if VAM_gen
        thresholds = struct;
        thresholds.distance = 4;
        thresholds.heading  = 4;
        thresholds.speed    = 0.5;
   
        NewAlgorithm = false;
        [VAMtrace_U7,Mixed_info_U7]   = GenerateVAMs(U7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);
        [VAMtrace_KU7,Mixed_info_KU7] = GenerateVAMs(KU7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);
        NewAlgorithm = true;
        [VAMtrace_U7_NA,Mixed_info_U7_NA]   = GenerateVAMs(U7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);
        [VAMtrace_KU7_NA,Mixed_info_KU7_NA] = GenerateVAMs(KU7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);
    
        VAMcoordinates_U7     = VAMTraceProcessor(VAMtrace_U7,Mixed_info_U7,"ORIGINAL");
        VAMcoordinates_KU7    = VAMTraceProcessor(VAMtrace_KU7,Mixed_info_KU7,"KF");
        VAMcoordinates_U7_NA  = VAMTraceProcessor(VAMtrace_U7_NA,Mixed_info_U7_NA,"ERR\_EST");
        VAMcoordinates_KU7_NA = VAMTraceProcessor(VAMtrace_KU7_NA,Mixed_info_KU7_NA,"KF+ERR\_EST");
    end
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%

    
    % VAM generation multi H thresholds 
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%
    if VAM_gen_H_thresh
        thresholds = struct;
        thresholds.distance = 4;
        H_threshold = [4 7 10];
        thresholds.speed = 0.5;

        thresholds.heading = H_threshold(1);
        NewAlgorithm = false;
        [VAMtrace_U7_I,Mixed_info_U7_I]   = GenerateVAMs(U7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);
        [VAMtrace_KU7_I,Mixed_info_KU7_I] = GenerateVAMs(KU7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);
        NewAlgorithm = true;
        [VAMtrace_U7_NA_I,Mixed_info_U7_NA_I]   = GenerateVAMs(U7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);
        [VAMtrace_KU7_NA_I,Mixed_info_KU7_NA_I] = GenerateVAMs(KU7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);

        thresholds.heading = H_threshold(2);
        NewAlgorithm = false;
        [VAMtrace_U7_II,Mixed_info_U7_II]   = GenerateVAMs(U7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);
        [VAMtrace_KU7_II,Mixed_info_KU7_II] = GenerateVAMs(KU7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);
        NewAlgorithm = true;
        [VAMtrace_U7_NA_II,Mixed_info_U7_NA_II]   = GenerateVAMs(U7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);
        [VAMtrace_KU7_NA_II,Mixed_info_KU7_NA_II] = GenerateVAMs(KU7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);

        thresholds.heading = H_threshold(3);
        NewAlgorithm = false;
        [VAMtrace_U7_III,Mixed_info_U7_III]   = GenerateVAMs(U7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);
        [VAMtrace_KU7_III,Mixed_info_KU7_III] = GenerateVAMs(KU7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);
        NewAlgorithm = true;
        [VAMtrace_U7_NA_III,Mixed_info_U7_NA_III]   = GenerateVAMs(U7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);
        [VAMtrace_KU7_NA_III,Mixed_info_KU7_NA_III] = GenerateVAMs(KU7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);

        VAMcoordinates_H_thresh_U7 = struct;
        VAMcoordinates_H_thresh_KU7 = struct;
        VAMcoordinates_H_thresh_U7_NA = struct;
        VAMcoordinates_H_thresh_KU7_NA = struct;

        VAMcoordinates_H_thresh_U7.I   = VAMTraceProcessor(VAMtrace_U7_I,Mixed_info_U7_I,"ORIGINAL");
        VAMcoordinates_H_thresh_U7.II  = VAMTraceProcessor(VAMtrace_U7_II,Mixed_info_U7_II,"ORIGINAL");
        VAMcoordinates_H_thresh_U7.III = VAMTraceProcessor(VAMtrace_U7_III,Mixed_info_U7_III,"ORIGINAL");

        VAMcoordinates_H_thresh_KU7.I   = VAMTraceProcessor(VAMtrace_KU7_I,Mixed_info_KU7_I,"KF");
        VAMcoordinates_H_thresh_KU7.II  = VAMTraceProcessor(VAMtrace_KU7_II,Mixed_info_KU7_II,"KF");
        VAMcoordinates_H_thresh_KU7.III = VAMTraceProcessor(VAMtrace_KU7_III,Mixed_info_KU7_III,"KF");

        VAMcoordinates_H_thresh_U7_NA.I   = VAMTraceProcessor(VAMtrace_U7_NA_I,Mixed_info_U7_NA_I,"ERR\_EST");
        VAMcoordinates_H_thresh_U7_NA.II  = VAMTraceProcessor(VAMtrace_U7_NA_II,Mixed_info_U7_NA_II,"ERR\_EST");
        VAMcoordinates_H_thresh_U7_NA.III = VAMTraceProcessor(VAMtrace_U7_NA_III,Mixed_info_U7_NA_III,"ERR\_EST");

        VAMcoordinates_H_thresh_KU7_NA.I   = VAMTraceProcessor(VAMtrace_KU7_NA_I,Mixed_info_KU7_NA_I,"KF+ERR\_EST");
        VAMcoordinates_H_thresh_KU7_NA.II  = VAMTraceProcessor(VAMtrace_KU7_NA_II,Mixed_info_KU7_NA_II,"KF+ERR\_EST");
        VAMcoordinates_H_thresh_KU7_NA.III = VAMTraceProcessor(VAMtrace_KU7_NA_III,Mixed_info_KU7_NA_III,"KF+ERR\_EST");
    end
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%


    % VAM generation multi thresholds
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%
    if VAM_gen_multi_thresh
        thresholds = struct;
        thresholds.distance = 4;
        H_multi_thresh = [10 20 30];
        thresholds.speed = 0.5;

        thresholds.heading = H_multi_thresh(1);
        NewAlgorithm = false;
        [VAMtrace_U7_I,Mixed_info_U7_I]   = GenerateVAMs(U7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);
        [VAMtrace_KU7_I,Mixed_info_KU7_I] = GenerateVAMs(KU7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);
        NewAlgorithm = true;
        [VAMtrace_U7_NA_I,Mixed_info_U7_NA_I]   = GenerateVAMs(U7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);
        [VAMtrace_KU7_NA_I,Mixed_info_KU7_NA_I] = GenerateVAMs(KU7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);

        thresholds.heading = H_multi_thresh(2);
        NewAlgorithm = false;
        [VAMtrace_U7_II,Mixed_info_U7_II]   = GenerateVAMs(U7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);
        [VAMtrace_KU7_II,Mixed_info_KU7_II] = GenerateVAMs(KU7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);
        NewAlgorithm = true;
        [VAMtrace_U7_NA_II,Mixed_info_U7_NA_II]   = GenerateVAMs(U7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);
        [VAMtrace_KU7_NA_II,Mixed_info_KU7_NA_II] = GenerateVAMs(KU7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);

        thresholds.heading = H_multi_thresh(3);
        NewAlgorithm = false;
        [VAMtrace_U7_III,Mixed_info_U7_III]   = GenerateVAMs(U7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);
        [VAMtrace_KU7_III,Mixed_info_KU7_III] = GenerateVAMs(KU7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);
        NewAlgorithm = true;
        [VAMtrace_U7_NA_III,Mixed_info_U7_NA_III]   = GenerateVAMs(U7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);
        [VAMtrace_KU7_NA_III,Mixed_info_KU7_NA_III] = GenerateVAMs(KU7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);

        VAMcoordinates_multi_thresh_U7 = struct;
        VAMcoordinates_multi_thresh_KU7 = struct;
        VAMcoordinates_multi_thresh_U7_NA = struct;
        VAMcoordinates_multi_thresh_KU7_NA = struct;

        VAMcoordinates_multi_thresh_U7.I   = VAMTraceProcessor(VAMtrace_U7_I,Mixed_info_U7_I,"ORIGINAL");
        VAMcoordinates_multi_thresh_U7.II  = VAMTraceProcessor(VAMtrace_U7_II,Mixed_info_U7_II,"ORIGINAL");
        VAMcoordinates_multi_thresh_U7.III = VAMTraceProcessor(VAMtrace_U7_III,Mixed_info_U7_III,"ORIGINAL");

        VAMcoordinates_multi_thresh_KU7.I   = VAMTraceProcessor(VAMtrace_KU7_I,Mixed_info_KU7_I,"KF");
        VAMcoordinates_multi_thresh_KU7.II  = VAMTraceProcessor(VAMtrace_KU7_II,Mixed_info_KU7_II,"KF");
        VAMcoordinates_multi_thresh_KU7.III = VAMTraceProcessor(VAMtrace_KU7_III,Mixed_info_KU7_III,"KF");

        VAMcoordinates_multi_thresh_U7_NA.I   = VAMTraceProcessor(VAMtrace_U7_NA_I,Mixed_info_U7_NA_I,"ERR\_EST");
        VAMcoordinates_multi_thresh_U7_NA.II  = VAMTraceProcessor(VAMtrace_U7_NA_II,Mixed_info_U7_NA_II,"ERR\_EST");
        VAMcoordinates_multi_thresh_U7_NA.III = VAMTraceProcessor(VAMtrace_U7_NA_III,Mixed_info_U7_NA_III,"ERR\_EST");

        VAMcoordinates_multi_thresh_KU7_NA.I   = VAMTraceProcessor(VAMtrace_KU7_NA_I,Mixed_info_KU7_NA_I,"KF+ERR\_EST");
        VAMcoordinates_multi_thresh_KU7_NA.II  = VAMTraceProcessor(VAMtrace_KU7_NA_II,Mixed_info_KU7_NA_II,"KF+ERR\_EST");
        VAMcoordinates_multi_thresh_KU7_NA.III = VAMTraceProcessor(VAMtrace_KU7_NA_III,Mixed_info_KU7_NA_III,"KF+ERR\_EST");
    end
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%


    % VAM generation multi sampling interval
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%
    if VAM_gen_multi_si
        si_vector = [200 500 1000];

        U7_RMC_data_I   = change_sampling_interval(U7_RMC_data,si_vector(1));
        U7_RMC_data_II  = change_sampling_interval(U7_RMC_data,si_vector(2));
        U7_RMC_data_III = change_sampling_interval(U7_RMC_data,si_vector(3));

        KU7_RMC_data_I   = change_sampling_interval(KU7_RMC_data,si_vector(1));
        KU7_RMC_data_II  = change_sampling_interval(KU7_RMC_data,si_vector(2));
        KU7_RMC_data_III = change_sampling_interval(KU7_RMC_data,si_vector(3));
        
        thresholds = struct;
        thresholds.distance = 4;
        thresholds.heading = 10;
        thresholds.speed = 0.5;

        NewAlgorithm = false;
        [VAMtrace_U7_I,Mixed_info_U7_I]   = GenerateVAMs(U7_RMC_data_I,U7_GST_data,thresholds,NewAlgorithm);
        [VAMtrace_KU7_I,Mixed_info_KU7_I] = GenerateVAMs(KU7_RMC_data_I,U7_GST_data,thresholds,NewAlgorithm);
        NewAlgorithm = true;
        [VAMtrace_U7_NA_I,Mixed_info_U7_NA_I]   = GenerateVAMs(U7_RMC_data_I,U7_GST_data,thresholds,NewAlgorithm);
        [VAMtrace_KU7_NA_I,Mixed_info_KU7_NA_I] = GenerateVAMs(KU7_RMC_data_I,U7_GST_data,thresholds,NewAlgorithm);

        NewAlgorithm = false;
        [VAMtrace_U7_II,Mixed_info_U7_II]   = GenerateVAMs(U7_RMC_data_II,U7_GST_data,thresholds,NewAlgorithm);
        [VAMtrace_KU7_II,Mixed_info_KU7_II] = GenerateVAMs(KU7_RMC_data_II,U7_GST_data,thresholds,NewAlgorithm);
        NewAlgorithm = true;
        [VAMtrace_U7_NA_II,Mixed_info_U7_NA_II]   = GenerateVAMs(U7_RMC_data_II,U7_GST_data,thresholds,NewAlgorithm);
        [VAMtrace_KU7_NA_II,Mixed_info_KU7_NA_II] = GenerateVAMs(KU7_RMC_data_II,U7_GST_data,thresholds,NewAlgorithm);

        NewAlgorithm = false;
        [VAMtrace_U7_III,Mixed_info_U7_III]   = GenerateVAMs(U7_RMC_data_III,U7_GST_data,thresholds,NewAlgorithm);
        [VAMtrace_KU7_III,Mixed_info_KU7_III] = GenerateVAMs(KU7_RMC_data_III,U7_GST_data,thresholds,NewAlgorithm);
        NewAlgorithm = true;
        [VAMtrace_U7_NA_III,Mixed_info_U7_NA_III]   = GenerateVAMs(U7_RMC_data_III,U7_GST_data,thresholds,NewAlgorithm);
        [VAMtrace_KU7_NA_III,Mixed_info_KU7_NA_III] = GenerateVAMs(KU7_RMC_data_III,U7_GST_data,thresholds,NewAlgorithm);


        VAMcoordinates_multi_si_U7 = struct;
        VAMcoordinates_multi_si_KU7 = struct;
        VAMcoordinates_multi_si_U7_NA = struct;
        VAMcoordinates_multi_si_KU7_NA = struct;

        VAMcoordinates_multi_si_U7.I   = VAMTraceProcessor(VAMtrace_U7_I,Mixed_info_U7_I,"ORIGINAL");
        VAMcoordinates_multi_si_U7.II  = VAMTraceProcessor(VAMtrace_U7_II,Mixed_info_U7_II,"ORIGINAL");
        VAMcoordinates_multi_si_U7.III = VAMTraceProcessor(VAMtrace_U7_III,Mixed_info_U7_III,"ORIGINAL");

        VAMcoordinates_multi_si_KU7.I   = VAMTraceProcessor(VAMtrace_KU7_I,Mixed_info_KU7_I,"KF");
        VAMcoordinates_multi_si_KU7.II  = VAMTraceProcessor(VAMtrace_KU7_II,Mixed_info_KU7_II,"KF");
        VAMcoordinates_multi_si_KU7.III = VAMTraceProcessor(VAMtrace_KU7_III,Mixed_info_KU7_III,"KF");

        VAMcoordinates_multi_si_U7_NA.I   = VAMTraceProcessor(VAMtrace_U7_NA_I,Mixed_info_U7_NA_I,"ERR\_EST");
        VAMcoordinates_multi_si_U7_NA.II  = VAMTraceProcessor(VAMtrace_U7_NA_II,Mixed_info_U7_NA_II,"ERR\_EST");
        VAMcoordinates_multi_si_U7_NA.III = VAMTraceProcessor(VAMtrace_U7_NA_III,Mixed_info_U7_NA_III,"ERR\_EST");

        VAMcoordinates_multi_si_KU7_NA.I   = VAMTraceProcessor(VAMtrace_KU7_NA_I,Mixed_info_KU7_NA_I,"KF+ERR\_EST");
        VAMcoordinates_multi_si_KU7_NA.II  = VAMTraceProcessor(VAMtrace_KU7_NA_II,Mixed_info_KU7_NA_II,"KF+ERR\_EST");
        VAMcoordinates_multi_si_KU7_NA.III = VAMTraceProcessor(VAMtrace_KU7_NA_III,Mixed_info_KU7_NA_III,"KF+ERR\_EST");

        VAMcell = struct2cell(VAMcoordinates_multi_si_U7);

        fprintf(strcat("\n<strong>Delta_heading = 10°, TcheckVAM = ", num2str(si_vector(3))," ms</strong>\n"));
        fprintf("  --> # Total number of VAMs = %d\n",length(VAMtrace_U7_III.timestamp));
        fprintf("  --> # VAM of distance = %d\n",length(VAMcell{3}.distance_timestamp));
        fprintf("  --> # VAM of heading = %d\n",length(VAMcell{3}.heading_timestamp));
        fprintf("  --> # VAM of speed = %d\n",length(VAMcell{3}.speed_timestamp));

    end
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%

    
    %+-+-+-+-+-+-+-+-+-+-+-+%
    %+                     +%
    %+    PLOTS SECTION    +%
    %+                     +%
    %+-+-+-+-+-+-+-+-+-+-+-+%

    Size = struct;
    Size.title = 16;
    Size.label = 16;
    Size.labelGeo = 18;
    Size.legend = 18;
    Size.marker = 5;

    add_basemap_OpenStreetMap();

    Color = ["#0072BD" "#D95319" "#EDB120" "#7E2F8E" "#77AC30" "#4DBEEE" "#A2142F"];


    %--- Trajectories Plot ---%
    Trajectory_data_U7  = select_round(U7_RMC_data,Round_start(VectorIndex),Round_end(VectorIndex),true,false);
    avg_speed = mean(Trajectory_data_U7.speed,'omitnan')*3.6;
    fprintf("--> Average speed for the selected path = %.2f km/h\n",avg_speed);
    FigH = figure;
    s = geoplot(Trajectory_data_U7.latitude,Trajectory_data_U7.longitude,'-g','LineWidth',2);
    dtRows = [dataTipTextRow("Timestamp",Trajectory_data_U7.timestamp)];
    s.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
    geobasemap 'satellite'
    title(sprintf('Trajectories, $source=GNSS$, $T_{samp}=%d$ $ms$, $speed_{avg}=%.2f$ $m/s$',sampling_interval,avg_speed),'fontweight','bold','FontSize',Size.title,'Interpreter','latex');
    set(legend,'FontSize',Size.legend,'Interpreter','latex');
    legend('GNSS');
    gx = gca;
    [lat_lim,lon_lim] = geolimits;
    geolimits(lat_lim,lon_lim);
    set(gx, 'FontSize', Size.label);
    set(gcf,'position',[1,1,1250,650]);
    set(FigH,'Units','Inches');
    pos = get(FigH,'Position');
    set(FigH,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
    set(FigH,'visible','off');
    if Trajectories_plot
        set(FigH,'visible','on');
        if SaveEN
            saveas(FigH,strcat(PlotFolder,"/",'Trajectories'),'pdf');
        end
    end

    
    %--- HeadingVariations plot ---%
    if HeadingVariations_plot
        vector = 0.1:0.1:length(KU7_RMC_data.timestamp)*0.1; 
        FigH = figure;
        hold on
        plot(vector,U7_RMC_data.heading,strcat('-s','g'),'MarkerFaceColor','g','MarkerSize',4);
        plot(vector,KU7_RMC_data.heading,strcat('-o','b'),'MarkerFaceColor','b','MarkerSize',4);
        title(sprintf('Heading Plot, $source=GNSS$, $T_{samp}=%d$ $ms$',sampling_interval),'fontweight','bold','FontSize',Size.title,'Interpreter','latex');
        xaxisproperties = get(gca, 'XAxis');
        xaxisproperties.TickLabelInterpreter = 'latex';
        xlabel('time [s]','FontSize',Size.label,'Interpreter','latex');
        yaxisproperties = get(gca, 'YAxis');
        yaxisproperties.TickLabelInterpreter = 'latex';
        ylabel('Heading','FontSize',Size.label,'Interpreter','latex');
        ylim([-5,365]);
        set(legend,'FontSize',Size.legend,'Interpreter','latex');
        legend('SPAN');
        set(gca, 'FontSize',Size.label);
        grid on;
        box on;
        set(gcf,'position',[1,1,1250,650]);
        set(FigH,'Units','Inches');
        pos = get(FigH,'Position');
        set(FigH,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
        if SaveEN
            saveas(FigH,strcat(PlotFolder,"/",'Heading_vs_time'),'pdf');
        end
    end



    if HeadingVariations_plot
        FigH = figure;
        plot(SPAN_RMC_data.heading,'-','Color','r','LineWidth',2);
        title(sprintf('Heading Plot, $source=GNSS$, $T_{samp}=%d$ $ms$',sampling_interval),'fontweight','bold','FontSize',Size.title,'Interpreter','latex');
        xaxisproperties = get(gca, 'XAxis');
        xaxisproperties.TickLabelInterpreter = 'latex';
        xlabel('time [s]','FontSize',Size.label,'Interpreter','latex');
        yaxisproperties = get(gca, 'YAxis');
        yaxisproperties.TickLabelInterpreter = 'latex';
        ylabel('Heading','FontSize',Size.label,'Interpreter','latex');
        ylim([-5,365]);
        set(legend,'FontSize',Size.legend,'Interpreter','latex');
        legend('SPAN');
        set(gca, 'FontSize',Size.label);
        grid on;
        box on;
        set(gcf,'position',[1,1,1250,650]);
        set(FigH,'Units','Inches');
        pos = get(FigH,'Position');
        set(FigH,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
        if SaveEN
            saveas(FigH,strcat(PlotFolder,"/",'Heading_vs_time'),'pdf');
        end
    end


    %--- Speed plot ---%
    if Speed_plot
        FigH = figure;
        vector = 0.1:0.1:length(U7_RMC_data.timestamp)*0.1;
        plot(vector,U7_RMC_data.speed*3.6,strcat('o','g'),'MarkerFaceColor','g','MarkerSize',4);
        hold on
        plot(vector,KU7_speed_comp*3.6,strcat('o','b'),'MarkerFaceColor','b','MarkerSize',4);
        title(sprintf('Speed Plot, $source=GNSS$, $T_{samp}=%d$ $ms$',sampling_interval),'fontweight','bold','FontSize',Size.title,'Interpreter','latex');
        xaxisproperties = get(gca, 'XAxis');
        xaxisproperties.TickLabelInterpreter = 'latex';
        xlabel('time [s]','FontSize',Size.label,'Interpreter','latex');
        yaxisproperties = get(gca, 'YAxis');
        yaxisproperties.TickLabelInterpreter = 'latex';
        ylabel('Heading','FontSize',Size.label,'Interpreter','latex');
        ylim([-5,365]);
        set(legend,'FontSize',Size.legend,'Interpreter','latex');
        legend('U7\_GPS','KU7\_comp');
        set(gca, 'FontSize',Size.label);
        grid on;
        box on;
        set(gcf,'position',[1,1,1250,650]);
        set(FigH,'Units','Inches');
        pos = get(FigH,'Position');
        set(FigH,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
        if SaveEN
            saveas(FigH,strcat(PlotFolder,"/",'Speed_vs_time'),'pdf');
        end
    end


    %--- Probability Mass Function (PMF) plots ---%
    if PMF_plot
        VAM_PMF(VAMtrace_U7,"U7",PlotFolder,Size,SaveEN);
        VAM_PMF(VAMtrace_KU7,"KU7",PlotFolder,Size,SaveEN);
        VAM_PMF(VAMtrace_U7_NA,"U7_NA",PlotFolder,Size,SaveEN);
        VAM_PMF(VAMtrace_KU7_NA,"KU7_NA",PlotFolder,Size,SaveEN);
    end


    %--- VAM Traces PLOT ---%
    if Geo_plot
        VAM_GeoPlot_2(VAMcoordinates_U7, VAMcoordinates_KU7_NA, "Distance", PlotFolder,Size,SaveEN);
        VAM_GeoPlot_2(VAMcoordinates_U7, VAMcoordinates_KU7_NA, "Heading", PlotFolder,Size,SaveEN);
        VAM_GeoPlot_2(VAMcoordinates_U7, VAMcoordinates_KU7_NA, "Speed", PlotFolder,Size,SaveEN);
    end


    %--- VAM Traces H thresholds ---%
    if Geo_plot_H_thresh
        VAM_GeoPlot_H_thresh(VAMcoordinates_H_thresh_U7,H_threshold,sampling_interval,Round_start,Round_end,VectorIndex,Color,Size,lat_lim,lon_lim,PlotFolder,SaveEN);
        VAM_GeoPlot_H_thresh(VAMcoordinates_H_thresh_KU7,H_threshold,sampling_interval,Round_start,Round_end,VectorIndex,Color,Size,lat_lim,lon_lim,PlotFolder,SaveEN);
        VAM_GeoPlot_H_thresh(VAMcoordinates_H_thresh_U7_NA,H_threshold,sampling_interval,Round_start,Round_end,VectorIndex,Color,Size,lat_lim,lon_lim,PlotFolder,SaveEN);
        VAM_GeoPlot_H_thresh(VAMcoordinates_H_thresh_KU7_NA,H_threshold,sampling_interval,Round_start,Round_end,VectorIndex,Color,Size,lat_lim,lon_lim,PlotFolder,SaveEN);
    end


    %--- VAM Traces multi thresholds ---%
    if Geo_plot_multi_thresh
        VAM_GeoPlot_multi_thresh(VAMcoordinates_multi_thresh_U7,H_multi_thresh,sampling_interval,Round_start,Round_end,VectorIndex,Color,Size,lat_lim,lon_lim,PlotFolder,SaveEN);
        VAM_GeoPlot_multi_thresh(VAMcoordinates_multi_thresh_KU7,H_multi_thresh,sampling_interval,Round_start,Round_end,VectorIndex,Color,Size,lat_lim,lon_lim,PlotFolder,SaveEN);
        VAM_GeoPlot_multi_thresh(VAMcoordinates_multi_thresh_U7_NA,H_multi_thresh,sampling_interval,Round_start,Round_end,VectorIndex,Color,Size,lat_lim,lon_lim,PlotFolder,SaveEN);
        VAM_GeoPlot_multi_thresh(VAMcoordinates_multi_thresh_KU7_NA,H_multi_thresh,sampling_interval,Round_start,Round_end,VectorIndex,Color,Size,lat_lim,lon_lim,PlotFolder,SaveEN);
    end


    %--- VAM Traces multi si ---%
    if Geo_plot_multi_si
        VAM_GeoPlot_multi_si(VAMcoordinates_multi_si_U7,si_vector,thresholds,Round_start,Round_end,VectorIndex,Color,Size,lat_lim,lon_lim,PlotFolder,SaveEN);
        VAM_GeoPlot_multi_si(VAMcoordinates_multi_si_KU7,si_vector,thresholds,Round_start,Round_end,VectorIndex,Color,Size,lat_lim,lon_lim,PlotFolder,SaveEN);
        VAM_GeoPlot_multi_si(VAMcoordinates_multi_si_U7_NA,si_vector,thresholds,Round_start,Round_end,VectorIndex,Color,Size,lat_lim,lon_lim,PlotFolder,SaveEN);
        VAM_GeoPlot_multi_si(VAMcoordinates_multi_si_KU7_NA,si_vector,thresholds,Round_start,Round_end,VectorIndex,Color,Size,lat_lim,lon_lim,PlotFolder,SaveEN);
    end

end