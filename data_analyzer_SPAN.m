function [SPAN_RMC_data,SPAN_GST_data] = data_analyzer_SPAN(varargin)

    if nargin == 0          % Handle case when no inputs are provided

        close all
        clear all
        clc

        sampling_interval = 100;                % [100,1000] ms, multiple 100 ms
        SPAN_file = "GT_11_03_2024_bike.txt";   % GT_11_03_2024_bike.txt, GT_12_03_2024_foot.txt, GT_12_03_2024_bike.txt

    elseif nargin == 1

        close all
        clear all
        clc
        sampling_interval = 100;                 % [100,1000] ms, multiple 100 ms
        SPAN_file = varargin{1};

    elseif nargin == 2

        close all
        clear all
        clc
        SPAN_file = varargin{1};
        sampling_interval = varargin{2};

    else

        error("Invalid number of input arguments in data_analyzer_SPAN function");
        
    end
        
    if SPAN_file == "GT_11_03_2024_bike.txt"
        Round_start = ["154604.90" "154623.30" "151828.80" "155158.10" "155900.00" "152159.10"];    % to parse whole file use "150735.00"
        Round_end   = ["155316.10" "154738.40" "152031.60" "155316.90" "160526.60" "152313.10"];    % to parse whole file use "161330.90"
    end

    if SPAN_file == "GT_12_03_2024_foot.txt"
        Round_start = ["92013.20" "92100.30" "90816.30"];   % to parse whole file use "85646.00"
        Round_end   = ["94015.50" "92516.30" "91519.10"];   % to parse whole file use "100129.90"
    end

    if SPAN_file == "GT_12_03_2024_bike.txt"
        Round_start = ["102807.30" "102808.30" "103200.90" "103645.20" "102508.40"];    % to parse whole file use "101011.00"
        Round_end   = ["104258.00" "102939.40" "103438.90" "103756.60" "102645.40"];    % to parse whole file use "104811.90"
    end
    
    VectorIndex = 1;


    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+%
    %             SETTING PANEL START             %
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+%
    folderPath = "Field_Tests/";
    PlotFolder = "PLOT/SPAN/21_05_2024/Bike_11_03_2024/";
    % PlotFolder = "PLOT/SPAN/PMF/";

    VAM_gen                  =   false;
    VAM_gen_H_thresh         =   false;
    VAM_gen_multi_thresh     =   false;
    VAM_gen_multi_si         =   false;

    Trajectories_plot        =   false;
    HeadingVariations_plot   =   false;
    StandardDeviation_plot   =   false;
    PMF_plot                 =   false;
    Geo_plot                 =   false;
    Geo_plot_H_thresh        =   false;
    Geo_plot_multi_thresh    =   false;
    Geo_plot_multi_si        =   false;
    
    SaveEN = false;

    format long;
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+%
    %              SETTING PANEL END              %
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+%

    
    fid = fopen(strcat(folderPath,SPAN_file), 'r');
    [SPAN_RMC_data,SPAN_GST_data] = read_SPAN_file(fid);
    fclose(fid);
    
    SPAN_RMC_data = change_sampling_interval(SPAN_RMC_data,sampling_interval);


    % VAM generation
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%
    if VAM_gen
        thresholds = struct;
        thresholds.distance = 4;
        thresholds.heading = 4;
        thresholds.speed = 0.5;
    
        NewAlgorithm = false;
        [VAMtrace_SPAN,Mixed_info_SPAN] = GenerateVAMs(SPAN_RMC_data,SPAN_GST_data,thresholds,NewAlgorithm);
        VAMcoordinates_ref = VAMTraceProcessor(VAMtrace_SPAN,Mixed_info_SPAN,"SPAN");
    end
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%


    % VAM generation multi H thresholds
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%
    if VAM_gen_H_thresh
        thresholds = struct;
        thresholds.distance = 4;
        H_threshold = [4 7 10];
        thresholds.speed = 0.5;

        NewAlgorithm = false;
        thresholds.heading = H_threshold(1);
        [VAMtrace_SPAN_I,Mixed_info_SPAN_I] = GenerateVAMs(SPAN_RMC_data,SPAN_GST_data,thresholds,NewAlgorithm);
        thresholds.heading = H_threshold(2);
        [VAMtrace_SPAN_II,Mixed_info_SPAN_II] = GenerateVAMs(SPAN_RMC_data,SPAN_GST_data,thresholds,NewAlgorithm);
        thresholds.heading = H_threshold(3);
        [VAMtrace_SPAN_III,Mixed_info_SPAN_III] = GenerateVAMs(SPAN_RMC_data,SPAN_GST_data,thresholds,NewAlgorithm);

        VAMcoordinates_H_thresh = struct;
        VAMcoordinates_H_thresh.I   = VAMTraceProcessor(VAMtrace_SPAN_I,Mixed_info_SPAN_I,"SPAN");
        VAMcoordinates_H_thresh.II  = VAMTraceProcessor(VAMtrace_SPAN_II,Mixed_info_SPAN_II,"SPAN");
        VAMcoordinates_H_thresh.III = VAMTraceProcessor(VAMtrace_SPAN_III,Mixed_info_SPAN_III,"SPAN");

        VAMcell = struct2cell(VAMcoordinates_H_thresh);

        fprintf(strcat("\n<strong>Delta_heading = ", num2str(H_threshold(1)) ,"°, TcheckVAM = 100 ms</strong>\n"));
        fprintf("  --> # Total number of VAMs = %d\n",length(VAMtrace_SPAN_I.timestamp));
        fprintf("  --> # VAM of distance = %d\n",length(VAMcell{1}.distance_timestamp));
        fprintf("  --> # VAM of heading = %d\n",length(VAMcell{1}.heading_timestamp));
        fprintf("  --> # VAM of speed = %d\n",length(VAMcell{1}.speed_timestamp));

        fprintf(strcat("\n<strong>Delta_heading = ", num2str(H_threshold(3)) ,"°, TcheckVAM = 100 ms</strong>\n"));
        fprintf("  --> # Total number of VAMs = %d\n",length(VAMtrace_SPAN_III.timestamp));
        fprintf("  --> # VAM of distance = %d\n",length(VAMcell{3}.distance_timestamp));
        fprintf("  --> # VAM of heading = %d\n",length(VAMcell{3}.heading_timestamp));
        fprintf("  --> # VAM of speed = %d\n",length(VAMcell{3}.speed_timestamp));
    end
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%


    % VAM generation multi thresholds 
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%
    if VAM_gen_multi_thresh
        thresholds = struct;
        thresholds.distance = 4;
        H_multi_thresh = [10 15 20];
        thresholds.speed = 0.5;

        NewAlgorithm = false;
        thresholds.heading = H_multi_thresh(1);
        [VAMtrace_SPAN_I,Mixed_info_SPAN_I] = GenerateVAMs(SPAN_RMC_data,SPAN_GST_data,thresholds,NewAlgorithm);
        thresholds.heading = H_multi_thresh(2);
        [VAMtrace_SPAN_II,Mixed_info_SPAN_II] = GenerateVAMs(SPAN_RMC_data,SPAN_GST_data,thresholds,NewAlgorithm);
        thresholds.heading = H_multi_thresh(3);
        [VAMtrace_SPAN_III,Mixed_info_SPAN_III] = GenerateVAMs(SPAN_RMC_data,SPAN_GST_data,thresholds,NewAlgorithm);

        VAMcoordinates_multi_thresh = struct;
        VAMcoordinates_multi_thresh.I = VAMTraceProcessor(VAMtrace_SPAN_I,Mixed_info_SPAN_I,"SPAN");
        VAMcoordinates_multi_thresh.II = VAMTraceProcessor(VAMtrace_SPAN_II,Mixed_info_SPAN_II,"SPAN");
        VAMcoordinates_multi_thresh.III = VAMTraceProcessor(VAMtrace_SPAN_III,Mixed_info_SPAN_III,"SPAN");
    end
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%


    % VAM generation multi sampling interval
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%
    if VAM_gen_multi_si
        si_vector = [200 500 1000];
        SPAN_RMC_data_I   = change_sampling_interval(SPAN_RMC_data,si_vector(1));
        SPAN_RMC_data_II  = change_sampling_interval(SPAN_RMC_data,si_vector(2));
        SPAN_RMC_data_III = change_sampling_interval(SPAN_RMC_data,si_vector(3));
        
        thresholds = struct;
        thresholds.distance = 4;
        thresholds.heading = 10;
        thresholds.speed = 0.5;

        NewAlgorithm = false;
        [VAMtrace_SPAN_I,Mixed_info_SPAN_I] = GenerateVAMs(SPAN_RMC_data_I,SPAN_GST_data,thresholds,NewAlgorithm);        
        [VAMtrace_SPAN_II,Mixed_info_SPAN_II] = GenerateVAMs(SPAN_RMC_data_II,SPAN_GST_data,thresholds,NewAlgorithm);
        [VAMtrace_SPAN_III,Mixed_info_SPAN_III] = GenerateVAMs(SPAN_RMC_data_III,SPAN_GST_data,thresholds,NewAlgorithm);

        VAMcoordinates_multi_si = struct;
        VAMcoordinates_multi_si.I = VAMTraceProcessor(VAMtrace_SPAN_I,Mixed_info_SPAN_I,"SPAN");
        VAMcoordinates_multi_si.II = VAMTraceProcessor(VAMtrace_SPAN_II,Mixed_info_SPAN_II,"SPAN");
        VAMcoordinates_multi_si.III = VAMTraceProcessor(VAMtrace_SPAN_III,Mixed_info_SPAN_III,"SPAN");

        VAMcell = struct2cell(VAMcoordinates_multi_si);

        fprintf(strcat("\n<strong>Delta_heading = 10°, TcheckVAM = ", num2str(si_vector(3))," ms</strong>\n"));
        fprintf("  --> # Total number of VAMs = %d\n",length(VAMtrace_SPAN_III.timestamp));
        fprintf("  --> # VAM of distance = %d\n",length(VAMcell{3}.distance_timestamp));
        fprintf("  --> # VAM of heading = %d\n",length(VAMcell{3}.heading_timestamp));
        fprintf("  --> # VAM of speed = %d\n",length(VAMcell{3}.speed_timestamp));
    end
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%

    
    fprintf("--> Average standard deviation latitude = %.2f m \r\n",mean(SPAN_GST_data.latitude_SD));
    fprintf("--> Average standard deviation longitude = %.2f m \r\n",mean(SPAN_GST_data.longitude_SD));
    fprintf("--> Average standard deviation heading = %.2f ° \r\n",mean(SPAN_GST_data.heading_SD));
    fprintf("--> Average standard deviation speed_x = %.2f ° \r\n",mean(SPAN_GST_data.speed_x_SD));
    fprintf("--> Average standard deviation speed_y = %.2f ° \r\n",mean(SPAN_GST_data.speed_y_SD));

    
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
    Size.marker = 10;

    add_basemap_OpenStreetMap();
    Color = ["#0072BD" "#D95319" "#2F4F4F" "#00FF00" "#77AC30" "#4DBEEE" "#A2142F"];

    %--- Trajectories Plot ---%
    lat_arrow_left  = [45.8118472024,45.8117771872,45.8107008585,45.810001708,45.8099685294];
    lat_arrow_right = [45.8093629491,45.8098849517,45.8097074484,45.8094463634];
    lat_arrow_up    = [45.8111567657];
    lat_arrow_down  = [45.8103616066];

    lon_arrow_left  = [8.6267164987,8.624999118,8.62754868,8.6272383619,8.6262383004];
    lon_arrow_right = [8.6250462608,8.6266608613,8.6257999787,8.6273383898];
    lon_arrow_up    = [8.6282040241];
    lon_arrow_down  = [8.6244280842];

    Trajectory_data = select_round(SPAN_RMC_data,Round_start(VectorIndex),Round_end(VectorIndex),true,false);
    avg_speed = mean(Trajectory_data.speed,'omitnan')*3.6;
    fprintf("\n\nAverage speed for the selected path = %.2f km/h\n",avg_speed);
    FigH = figure;
    s = geoplot(Trajectory_data.latitude,Trajectory_data.longitude,'-k','LineWidth',2);
    dtRows = [dataTipTextRow("Timestamp",Trajectory_data.timestamp)];
    s.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
    hold on
    geoplot(lat_arrow_left,lon_arrow_left,"<","MarkerEdgeColor",'k','MarkerFaceColor','k','MarkerSize',Size.marker);
    geoplot(lat_arrow_right,lon_arrow_right,">","MarkerEdgeColor",'k','MarkerFaceColor','k','MarkerSize',Size.marker);
    geoplot(lat_arrow_up,lon_arrow_up,"^","MarkerEdgeColor",'k','MarkerFaceColor','k','MarkerSize',Size.marker);
    geoplot(lat_arrow_down,lon_arrow_down,"v","MarkerEdgeColor",'k','MarkerFaceColor','k','MarkerSize',Size.marker);
    geobasemap 'openstreetmap'
    title(sprintf('Reference Trajectories, $source=SPAN$, $T_{samp}=%d$ $ms$, $speed_{avg}=%.2f$ $m/s$',sampling_interval,avg_speed),'fontweight','bold','FontSize',Size.title,'Interpreter','latex');
    set(legend,'Location','northwest','FontSize',Size.legend,'Interpreter','latex');
    legend('VRU Trajectory')
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


    %--- Heading Plot ---%
    if HeadingVariations_plot
        FigH = figure;
        plot(SPAN_RMC_data.heading,'-','Color','r','LineWidth',2);
        title(sprintf('Heading Plot, $source=SPAN$, $T_{samp}=%d$ $ms$',sampling_interval),'fontweight','bold','FontSize',Size.title,'Interpreter','latex');
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


    %--- Latitude and Longitude Standard Deviation Plot ---%
    if StandardDeviation_plot
        FigH = figure;
        plot(SPAN_GST_data.latitude_error ,'-','Color','r','LineWidth',2);
        hold on;
        plot(SPAN_GST_data.longitude_error ,'-','Color','b','LineWidth',2);
        title(sprintf('Latitude and Longitude Standard Deviation, $source=SPAN$, $T_{samp}=%d$ $ms$',sampling_interval),'fontweight','bold','FontSize',Size.title,'Interpreter','latex');
        xaxisproperties = get(gca, 'XAxis');
        xaxisproperties.TickLabelInterpreter = 'latex';
        xlabel('time [s]','FontSize',Size.label,'Interpreter','latex');
        yaxisproperties = get(gca, 'YAxis');
        yaxisproperties.TickLabelInterpreter = 'latex';
        ylabel('Standard Deviation [m]','FontSize',Size.label,'Interpreter','latex');
        yticks(0:0.01:0.25)
        ylim([0,0.25]);
        set(gca, 'FontSize',Size.label);
        set(legend,'FontSize',Size.legend,'Interpreter','latex');
        legend('latitude','longitude');
        grid on;
        box on;
        set(gcf,'position',[1,1,1250,650]);
        set(FigH,'Units','Inches');
        pos = get(FigH,'Position');
        set(FigH,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
        if SaveEN
            saveas(FigH,strcat(PlotFolder,"/",'Standard_Deviation'),'pdf');
        end
    end


    %--- Probability Mass Function (PMF) plots ---%
    if PMF_plot
        % VAM_PMF(VAMtrace_SPAN,"SPAN",PlotFolder,Size,SaveEN,sampling_interval);
        VAM_PMF(VAMtrace_SPAN_III,sprintf('$\\Delta H \\ge 10$ $^{\\circ}$'),PlotFolder,Size,SaveEN); 
    end


    %--- VAM Traces PLOT ---%
    if Geo_plot
        FigH = figure;
        VAMcoordinates_ref_Geo_plot = select_round(VAMcoordinates_ref,Round_start(VectorIndex),Round_end(VectorIndex),false,true);
        s = geoplot(VAMcoordinates_ref_Geo_plot.distance_lat,VAMcoordinates_ref_Geo_plot.distance_lon,strcat('o','b'),'MarkerFaceColor','b','MarkerSize',Size.marker);
        dtRows = [dataTipTextRow("Timestamp",VAMcoordinates_ref_Geo_plot.distance_timestamp)];
        s.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
        hold on
        g = geoplot(VAMcoordinates_ref_Geo_plot.heading_lat,VAMcoordinates_ref_Geo_plot.heading_lon,strcat('o','r'),'MarkerFaceColor','r','MarkerSize',Size.marker);
        dtRows = [dataTipTextRow("Timestamp",VAMcoordinates_ref_Geo_plot.heading_timestamp)];
        g.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
        h = geoplot(VAMcoordinates_ref_Geo_plot.speed_lat,VAMcoordinates_ref_Geo_plot.speed_lon,strcat('o','g'),'MarkerFaceColor','g','MarkerSize',Size.marker);
        dtRows = [dataTipTextRow("Timestamp",VAMcoordinates_ref_Geo_plot.speed_timestamp)];
        h.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
        geobasemap 'satellite';
        title(sprintf('Triggered VAMs, $source=SPAN$, $T_{samp}=%d$ $ms$',sampling_interval),'fontweight','bold','FontSize',Size.title,'Interpreter','latex');
        set(legend,'FontSize',Size.legend,'Interpreter','latex');
        legend('Distance','Heading','Speed');
        gx = gca;
        set(gx, 'FontSize', Size.label);
        set(gcf,'position',[1,1,1250,650]);
        set(FigH,'Units','Inches');
        pos = get(FigH,'Position');
        set(FigH,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
        if SaveEN
            saveas(FigH,strcat(PlotFolder,"/",'VAM_Traces'),'pdf');
        end
    end


    %--- VAM Traces H thresholds ---%
    if Geo_plot_H_thresh
        VAM_GeoPlot_H_thresh(VAMcoordinates_H_thresh,H_threshold,sampling_interval,Round_start,Round_end,VectorIndex,Color,Size,lat_lim,lon_lim,PlotFolder,SaveEN);
    end


    %--- VAM Traces multi thresholds ---%
     if Geo_plot_multi_thresh
        VAM_GeoPlot_multi_thresh(VAMcoordinates_multi_thresh,H_multi_thresh,sampling_interval,Round_start,Round_end,VectorIndex,Color,Size,lat_lim,lon_lim,PlotFolder,SaveEN);
     end


    %--- VAM Traces multi si ---%
    if Geo_plot_multi_si
        VAM_GeoPlot_multi_si(VAMcoordinates_multi_si,si_vector,thresholds,Round_start,Round_end,VectorIndex,Color,Size,lat_lim,lon_lim,PlotFolder,SaveEN);
    end

end
