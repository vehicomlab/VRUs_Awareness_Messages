close all
clear all
clc

%+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+%
%             SETTING PANEL START             %
%+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+%
PlotFolder = "PLOT/Final/";

RMC_file   = ["U7_RMC_11_03_2024_bike.txt" "U7_RMC_12_03_2024_foot.txt" "U7_RMC_12_03_2024_bike.txt"];
GST_file   = ["U7_GST_11_03_2024_bike.txt" "U7_GST_12_03_2024_foot.txt" "U7_GST_12_03_2024_bike.txt"];
SPAN_file  = ["GT_11_03_2024_bike.txt" "GT_12_03_2024_foot.txt" "GT_12_03_2024_bike.txt"];

Round_start = ["150959.10" "94013.40" "101011.00"];
Round_end   = ["151555.50" "95949.80" "104811.90"];

FileIndex   = 1;
RoundIndex  = 1;
sampling_interval = 100;

Trajectories_plot    =   true;
Speed_plot           =   false;
PMF_plot             =   false;
Geo_plot             =   false;
False_plot           =   false;

false_identification =   false;
SaveEN               =   false;

format long;
%+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+%
%              SETTING PANEL END              %
%+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+%


[SPAN_RMC_data,SPAN_GST_data] = data_analyzer_SPAN(SPAN_file(FileIndex),sampling_interval);
[U7_RMC_data,KU7_RMC_data,U7_GST_data,missing_indices] = data_analyzer_GNSS(RMC_file(FileIndex),GST_file(FileIndex),sampling_interval);


% remove missing timestamp
%+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%
if ~isempty(missing_indices)
    SPAN_RMC_data = remove_tiemstamp(SPAN_RMC_data,missing_indices);
end
%+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%


% remove extra heading values from KU7_RMC_data
%+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%
for i=1:1:length(U7_RMC_data.timestamp)
    if isnan(U7_RMC_data.heading(i))
        KU7_RMC_data.heading(i) = NaN;
    end
end
%+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%


KU7_RMC_data.speed = KalmanFilter_1D(KU7_RMC_data.speed,1,20);

fprintf("\n--> File name SPAN test: %s",SPAN_file(FileIndex));
fprintf("\n--> File name U7_data test: %s and %s",RMC_file(FileIndex),GST_file(FileIndex));


% VAM generation
%+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%

% SPAN
% ------------------------------
thresholds = struct;
thresholds.distance = 4;
thresholds.heading = 10;
thresholds.speed = 0.5;

fprintf("\n\n\n<strong>SPAN</strong>\n");
fprintf("----------------------------------------\n");
fprintf("|  Simulation Time SPAN = %.2f s\n",length(SPAN_RMC_data.timestamp)/10);
fprintf("|  Average speed SPAN = %.2f km/h\n",mean(SPAN_RMC_data.speed)*3.6);
fprintf("\n|  <strong>thresholds</strong>\n");
fprintf("|    distance = %.1f m\n",thresholds.distance);
fprintf("|    heading = %.1f°\n",thresholds.heading);
fprintf("|    speed = %.1f m/s\n",thresholds.speed);

NewAlgorithm = true;   % in the SPAN system always set NewAlgorithm = false
[VAMtrace_SPAN,Mixed_info_SPAN] = GenerateVAMs(SPAN_RMC_data,SPAN_GST_data,thresholds,NewAlgorithm);
VAMcoordinates_ref = VAMTraceProcessor(VAMtrace_SPAN,Mixed_info_SPAN,"SPAN");

fprintf("\n|  <strong>VAM triggered by</strong>\n");
fprintf("|    distance variation = %d\n",length(VAMcoordinates_ref.distance_timestamp));
fprintf("|    heading variation = %d\n",length(VAMcoordinates_ref.heading_timestamp));
fprintf("|    speed variation = %d\n",length(VAMcoordinates_ref.speed_timestamp));
fprintf("----------------------------------------");

% U7
% ------------------------------
thresholds = struct;
thresholds.distance = 4;
thresholds.heading = 10;
thresholds.speed = 0.5;

fprintf('\n\n\n<strong>U7</strong>\n');
fprintf("----------------------------------------\n");
fprintf("|  Simulation Time U7 = %.2f s\n",length(U7_RMC_data.timestamp)/10);
fprintf("|  Average speed U7 = %.2f km/h\n",mean(U7_RMC_data.speed)*3.6);
fprintf("\n|  <strong>thresholds</strong>\n");
fprintf("|    distance = %.1f m\n",thresholds.distance);
fprintf("|    heading = %.1f°\n",thresholds.heading);
fprintf("|    speed = %.1f m/s\n",thresholds.speed);

fprintf("\n|  ORIGINAL");
fprintf("\n|  <strong>VAM triggered by</strong>\n");
NewAlgorithm = false;
[VAMtrace_U7,Mixed_info_U7] = GenerateVAMs(U7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);
VAMcoordinates_U7 = VAMTraceProcessor(VAMtrace_U7,Mixed_info_U7,"U7");
fprintf("|    distance variation = %d\n",length(VAMcoordinates_U7.distance_timestamp));
fprintf("|    heading variation = %d\n",length(VAMcoordinates_U7.heading_timestamp));
fprintf("|    speed variation = %d\n",length(VAMcoordinates_U7.speed_timestamp));

fprintf("\n|  KF");
fprintf("\n|  <strong>VAM triggered by</strong>\n");
NewAlgorithm = false;
[VAMtrace_KU7,Mixed_info_KU7] = GenerateVAMs(KU7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);
VAMcoordinates_KU7 = VAMTraceProcessor(VAMtrace_KU7,Mixed_info_KU7,"KU7");
fprintf("|    distance variation = %d\n",length(VAMcoordinates_KU7.distance_timestamp));
fprintf("|    heading variation = %d\n",length(VAMcoordinates_KU7.heading_timestamp));
fprintf("|    speed variation = %d\n",length(VAMcoordinates_KU7.speed_timestamp));

fprintf("\n|  ERR_EST");
fprintf("\n|  <strong>VAM triggered by</strong>\n");
NewAlgorithm = true;
[VAMtrace_U7_NA,Mixed_info_U7_NA] = GenerateVAMs(U7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);
VAMcoordinates_U7_NA = VAMTraceProcessor(VAMtrace_U7_NA,Mixed_info_U7_NA,"U7\_NA");
fprintf("|    distance variation = %d\n",length(VAMcoordinates_U7_NA.distance_timestamp));
fprintf("|    heading variation = %d\n",length(VAMcoordinates_U7_NA.heading_timestamp));
fprintf("|    speed variation = %d\n",length(VAMcoordinates_U7_NA.speed_timestamp));

fprintf("\n|  KF+ERR_EST");
fprintf("\n|  <strong>VAM triggered by</strong>\n");
NewAlgorithm = true;
[VAMtrace_KU7_NA,Mixed_info_KU7_NA] = GenerateVAMs(KU7_RMC_data,U7_GST_data,thresholds,NewAlgorithm);
VAMcoordinates_KU7_NA = VAMTraceProcessor(VAMtrace_KU7_NA,Mixed_info_KU7_NA,"KU7\_NA");
fprintf("|    distance variation = %d\n",length(VAMcoordinates_KU7_NA.distance_timestamp));
fprintf("|    heading variation = %d\n",length(VAMcoordinates_KU7_NA.heading_timestamp));
fprintf("|    speed variation = %d\n",length(VAMcoordinates_KU7_NA.speed_timestamp));
fprintf("----------------------------------------");
%+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%


% false identification
%+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-%
if false_identification
    max_delta = 1;      % neighborhood of 1 second
    
    [false_pos_U7,false_neg_U7] = false_identifier(VAMcoordinates_ref,VAMcoordinates_U7,max_delta);
    [false_pos_KU7,false_neg_KU7] = false_identifier(VAMcoordinates_ref,VAMcoordinates_KU7,max_delta);
    [false_pos_U7_NA,false_neg_U7_NA] = false_identifier(VAMcoordinates_ref,VAMcoordinates_U7_NA,max_delta);
    [false_pos_KU7_NA,false_neg_KU7_NA] = false_identifier(VAMcoordinates_ref,VAMcoordinates_KU7_NA,max_delta);
    
    fprintf('\n\n\n<strong>FALSES</strong>\n');
    fprintf("----------------------------------------\n");
    fprintf("|  ORIGINAL\n");
    fprintf("|  <strong>false negatives</strong>\n");
    fprintf("|   distance = %d\n",false_neg_U7.distance);
    fprintf("|    heading = %d\n",false_neg_U7.heading);
    fprintf("|    speed = %d\n",false_neg_U7.speed);
    fprintf("|  <strong>false positives</strong>\n");
    fprintf("|    distance = %d\n",false_pos_U7.distance);
    fprintf("|    heading = %d\n",false_pos_U7.heading);
    fprintf("|    speed = %d\n\n",false_pos_U7.speed);

    fprintf("|  KF\n");
    fprintf("|  <strong>false negatives</strong>\n");
    fprintf("|    distance = %d\n",false_neg_KU7.distance);
    fprintf("|    heading = %d\n",false_neg_KU7.heading);
    fprintf("|    speed = %d\n",false_neg_KU7.speed);
    fprintf("|  <strong>false positives</strong>\n");
    fprintf("|    distance = %d\n",false_pos_KU7.distance);
    fprintf("|    heading = %d\n",false_pos_KU7.heading);
    fprintf("|    speed = %d\n\n",false_pos_KU7.speed);

    fprintf("|  ERR_EST\n");
    fprintf("|  <strong>false negatives</strong>\n");
    fprintf("|    distance = %d\n",false_neg_U7_NA.distance);
    fprintf("|    heading = %d\n",false_neg_U7_NA.heading);
    fprintf("|    speed = %d\n",false_neg_U7_NA.speed);
    fprintf("|  <strong>false positives</strong>\n");
    fprintf("|    distance = %d\n",false_pos_U7_NA.distance);
    fprintf("|    heading = %d\n",false_pos_U7_NA.heading);
    fprintf("|    speed = %d\n\n",false_pos_U7_NA.speed);

    fprintf("|  KF+ERR_EST\n");
    fprintf("|  <strong>false negatives</strong>\n");
    fprintf("|    distance = %d\n",false_neg_KU7_NA.distance);
    fprintf("|    heading = %d\n",false_neg_KU7_NA.heading);
    fprintf("|    speed = %d\n",false_neg_KU7_NA.speed);
    fprintf("|  <strong>false positives</strong>\n");
    fprintf("|    distance = %d\n",false_pos_KU7_NA.distance);
    fprintf("|    heading = %d\n",false_pos_KU7_NA.heading);
    fprintf("|    speed = %d\n",false_pos_KU7_NA.speed);
    fprintf("----------------------------------------\n");
else
    fprintf("\n\n");
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
Size.legend = 16;


%--- Trajectories PLOT ---%
if Trajectories_plot
    Trajectory_data = select_round(SPAN_RMC_data,Round_start(RoundIndex),Round_end(RoundIndex),true,false);
    FigH = figure;
    s = geoplot(Trajectory_data.latitude,Trajectory_data.longitude,strcat('-o','y'),'MarkerFaceColor','y','MarkerSize',4);
    dtRows = [dataTipTextRow("Timestamp",SPAN_RMC_data.timestamp)];
    s.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
    geobasemap 'satellite'
    title('VRU Trajectories','fontweight','bold','FontSize',Size.title,'Interpreter','latex');
    set(legend,'FontSize',Size.legend,'Interpreter','latex');
    % set(gca,'FontSize',Size.label);
    gx = geoaxes;
    % geolimits([yy,yy],[xx,xx]);
    gx.LatitudeAxis.TickLabelInterpreter  = 'latex';
    gx.LongitudeAxis.TickLabelInterpreter = 'latex';
    legend('SPAN');
    set(gcf,'position',[1,1,1250,650]);
    set(FigH,'Units','Inches');
    pos = get(FigH,'Position');
    set(FigH,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
    if SaveEN
        saveas(FigH,strcat(PlotFolder,"/",'Trajectory'),'pdf');
    end
end


%--- Speed PLOT ---%
if Speed_plot
    FigH = figure;
    for i=1:length(U7_RMC_data.speed)
        vector(i)=0.1*i;
    end
    plot(vector,U7_RMC_data.speed*3.6,strcat('o','b'),'MarkerFaceColor','b','MarkerSize',4);
    hold on
    plot(vector,SPAN_RMC_data.speed*3.6,strcat('o','y'),'MarkerFaceColor','y','MarkerSize',4);
    title('Speed Plot','fontweight','bold','FontSize',Size.title,'Interpreter','latex');
    set(gca,'FontSize',Size.label);
    xaxisproperties = get(gca,'XAxis');
    xaxisproperties.TickLabelInterpreter = 'latex';
    xlabel('time [s]','FontSize',Size.label,'Interpreter','latex');
    yaxisproperties = get(gca, 'YAxis');
    yaxisproperties.TickLabelInterpreter = 'latex';
    ylabel('Speed','FontSize',Size.label,'Interpreter','latex');
    set(legend,'FontSize',Size.legend,'Interpreter','latex');
    legend('U7','SPAN');
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


%--- PMF Plot ---%
if PMF_plot
    VAM_PMF(VAMtrace_SPAN,"SPAN",PlotFolder,Size,SaveEN);
    VAM_PMF(VAMtrace_U7,"U7",PlotFolder,Size,SaveEN);
    VAM_PMF(VAMtrace_KU7,"KU7",PlotFolder,Size,SaveEN);
    VAM_PMF(VAMtrace_U7_NA,"U7_NA",PlotFolder,Size,SaveEN);
    VAM_PMF(VAMtrace_KU7_NA,"KU7_NA",PlotFolder,Size,SaveEN);
end


%--- VAM Traces PLOT ---%
if Geo_plot
    VAMcoordinates_ref = select_round(VAMcoordinates_ref,Round_start(RoundIndex),Round_end(RoundIndex),false,true);
    VAMcoordinates_U7 = select_round(VAMcoordinates_U7,Round_start(RoundIndex),Round_end(RoundIndex),false,true);
    VAMcoordinates_KU7 = select_round(VAMcoordinates_KU7,Round_start(RoundIndex),Round_end(RoundIndex),false,true);
    VAMcoordinates_U7_NA = select_round(VAMcoordinates_U7_NA,Round_start(RoundIndex),Round_end(RoundIndex),false,true);
    VAMcoordinates_KU7_NA = select_round(VAMcoordinates_KU7_NA,Round_start(RoundIndex),Round_end(RoundIndex),false,true);

    VAM_GeoPlot_3(VAMcoordinates_ref,VAMcoordinates_U7,VAMcoordinates_KU7,"Distance",PlotFolder,Size,SaveEN)
    VAM_GeoPlot_3(VAMcoordinates_ref,VAMcoordinates_U7,VAMcoordinates_KU7,"Heading",PlotFolder,Size,SaveEN)
    VAM_GeoPlot_3(VAMcoordinates_ref,VAMcoordinates_U7,VAMcoordinates_KU7,"Speed",PlotFolder,Size,SaveEN)
end


%--- False plot ---%
if False_plot
    plot_falses(false_neg_U7,false_neg_KU7,false_neg_U7_NA,false_neg_KU7_NA,"neg",PlotFolder,Size,SaveEN);
    plot_falses(false_pos_U7,false_pos_KU7,false_pos_U7_NA,false_pos_KU7_NA,"pos",PlotFolder,Size,SaveEN);
end
