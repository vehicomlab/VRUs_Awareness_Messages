function [Phone_RMC_data,Phone_GST_data] = data_analyzer_PHONE(varargin)

    if nargin == 0
        close all
        clear all
        clc
        Phone_file = "Phone_11_03_2024_bike.txt";   % Phone_11_03_2024_bike.txt, Phone_12_03_2024_foot.txt, Phone_12_03_2024_bike.txt

    elseif nargin == 1

        Phone_file = varargin{1};

    else

        error("Invalid number of input arguments in JRC_data_analyzer function");
        
    end

    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+%
    %             SETTING PANEL START             %
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+%
    folderPath = "Field_Tests/";
    PlotFolder = "PLOT/Phone/";

    VAM_gen                  =   false;
    Trajectories_plot        =   false;
    HeadingVariations_plot   =   false;
    Speed_plot               =   false;
    PMF_plot                 =   false;
    Geo_plot                 =   true;
    
    SaveEN = false;

    format long;
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+%
    %              SETTING PANEL END              %
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+%

    fid = fopen(strcat(folderPath,Phone_file), 'r');
    [Phone_RMC_data,Phone_GST_data] = read_Phone_file(fid);
    fclose(fid);


    % VAM generation
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%
    if VAM_gen
        thresholds = struct;
        thresholds.distance = 4;
        thresholds.heading = 4;
        thresholds.speed = 0.5;
    
        NewAlgorithm = false;
        [VAMtrace_Phone,Mixed_info_Phone] = GenerateVAMs(Phone_RMC_data,Phone_GST_data,thresholds,NewAlgorithm);
        VAMcoordinates_Phone = VAMTraceProcessor(VAMtrace_Phone,Mixed_info_Phone,"PHONE");
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

    add_basemap_OpenStreetMap()
    
    Color = ['b' 'r' 'g'];
 
    %--- Trajectories Plot ---%
    if Trajectories_plot
        FigH = figure;
        s = geoplot(Phone_RMC_data.latitude,Phone_RMC_data.longitude,strcat('-o','g'),'MarkerFaceColor','g','MarkerSize',4);
        dtRows = [dataTipTextRow("Timestamp",str2double(Phone_RMC_data.timestamp))];
        s.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
        geobasemap 'satellite';
        title('VRU Trajectories','fontweight','bold','FontSize',Size.title,'Interpreter','latex');
        set(legend,'FontSize',Size.legend,'Interpreter','latex');
        legend('PHONE');
        gx = gca;
        set(gx, 'FontSize', Size.label);
        gx.LatitudeAxis.TickLabelInterpreter = 'latex';
        gx.LatitudeAxis.Label.Interpreter = 'latex';
        gx.LatitudeAxis.Label.FontSize = Size.labelGeo;
        gx.LatitudeAxis.TickLabels = strrep(gx.LatitudeAxis.TickLabels, '°', '$^{\circ}$');
        gx.LongitudeAxis.TickLabelInterpreter = 'latex';
        gx.LongitudeAxis.Label.Interpreter = 'latex';
        gx.LongitudeAxis.Label.FontSize = Size.labelGeo;
        gx.LongitudeAxis.TickLabels = strrep(gx.LongitudeAxis.TickLabels, '°', '$^{\circ}$');
        set(gcf,'position',[1,1,1250,650]);
        set(FigH,'Units','Inches');
        pos = get(FigH,'Position');
        set(FigH,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
        if SaveEN
            saveas(FigH,strcat(PlotFolder,"/",'Trajectories'),'pdf');
        end
    end

    %--- HeadingVariations plot ---%
    if HeadingVariations_plot
        vector = 0.1:0.1:length(Phone_RMC_data.timestamp)*0.1; 
        FigH = figure;
        plot(vector,Phone_RMC_data.heading,strcat('-s','b'),'MarkerFaceColor','b','MarkerSize',4);
        title('Heading Plot','fontweight','bold','FontSize',Size.title,'Interpreter','latex');
        xaxisproperties = get(gca, 'XAxis');
        xaxisproperties.TickLabelInterpreter = 'latex';
        xlabel('time [s]','FontSize',LabelSize,'Interpreter','latex');
        yaxisproperties = get(gca, 'YAxis');
        yaxisproperties.TickLabelInterpreter = 'latex';
        ylabel('Heading','FontSize',LabelSize,'Interpreter','latex');
        ylim([-5,365]);
        set(legend,'FontSize',Size.legend,'Interpreter','latex');
        legend('PHONE');
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
        vector = 0.1:0.1:length(Phone_RMC_data.timestamp)*0.1;
        plot(vector,Phone_RMC_data.speed*3.6,strcat('o','b'),'MarkerFaceColor','b','MarkerSize',4);
        title('Speed Plot','fontweight','bold','FontSize',Size.title,'Interpreter','latex');
        xaxisproperties = get(gca, 'XAxis');
        xaxisproperties.TickLabelInterpreter = 'latex';
        xlabel('time [s]','FontSize',LabelSize,'Interpreter','latex');
        yaxisproperties = get(gca, 'YAxis');
        yaxisproperties.TickLabelInterpreter = 'latex';
        ylabel('Speed','FontSize',LabelSize,'Interpreter','latex');
        set(legend,'FontSize',Size.legend,'Interpreter','latex');
        legend('PHONE');
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
        VAM_PMF(VAMtrace_Phone,"PHONE",PlotFolder,Size,SaveEN);
        ylim([0,1]);
    end

    %--- VAM Traces PLOT ---%
    if Geo_plot
        FigH = figure;
        TypeVector = ["Distance" "Heading" "Speed"];
        s = geoplot(VAMcoordinates_Phone.distance_lat,VAMcoordinates_Phone.distance_lon,strcat('o','b'),'MarkerFaceColor','b','MarkerSize',4);
        dtRows = [dataTipTextRow("Timestamp",VAMcoordinates_Phone.distance_timestamp)];
        s.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
        hold on
        g = geoplot(VAMcoordinates_Phone.heading_lat,VAMcoordinates_Phone.heading_lon,strcat('o','r'),'MarkerFaceColor','r','MarkerSize',4);
        dtRows = [dataTipTextRow("Timestamp",VAMcoordinates_Phone.heading_timestamp)];
        g.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
        h = geoplot(VAMcoordinates_Phone.speed_lat,VAMcoordinates_Phone.speed_lon,strcat('o','g'),'MarkerFaceColor','g','MarkerSize',4);
        dtRows = [dataTipTextRow("Timestamp",VAMcoordinates_Phone.speed_timestamp)];
        h.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
        geobasemap 'satellite';
        title('Triggered VAM','fontweight','bold','FontSize',Size.title,'Interpreter','latex');
        set(legend,'FontSize',Size.legend,'Interpreter','latex');
        legend('Distance','Heading','Speed');
        gx = gca;
        set(gx, 'FontSize', Size.label);
        gx.LatitudeAxis.TickLabelInterpreter = 'latex';
        gx.LatitudeAxis.Label.Interpreter = 'latex';
        gx.LatitudeAxis.Label.FontSize = Size.labelGeo;
        gx.LatitudeAxis.TickLabels = strrep(gx.LatitudeAxis.TickLabels, '°', '$^{\circ}$');
        gx.LongitudeAxis.TickLabelInterpreter = 'latex';
        gx.LongitudeAxis.Label.Interpreter = 'latex';
        gx.LongitudeAxis.Label.FontSize = Size.labelGeo;
        gx.LongitudeAxis.TickLabels = strrep(gx.LongitudeAxis.TickLabels, '°', '$^{\circ}$');
        set(gcf,'position',[1,1,1250,650]);
        set(FigH,'Units','Inches');
        pos = get(FigH,'Position');
        set(FigH,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
        if SaveEN
            saveas(FigH,strcat(PlotFolder,"/",'VAM_Traces'),'pdf');
        end
    end

end