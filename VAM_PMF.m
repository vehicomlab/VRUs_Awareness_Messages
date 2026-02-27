function VAM_PMF(varargin)

    if nargin == 5

        VAMtrace = varargin{1};
        TraceName = varargin{2};
        PlotFolder = varargin{3};
        Size = varargin{4};
        SaveEN = varargin{5};
        sampling_interval = 100;

    elseif nargin == 6

        VAMtrace = varargin{1};
        TraceName = varargin{2};
        PlotFolder = varargin{3};
        Size = varargin{4};
        SaveEN = varargin{5};
        sampling_interval = varargin{6};

    else

        error("Invalid number of input arguments in VAM_PMF function");
        
    end

    TriggerTypes = {'Distance', 'Heading', 'Speed', 'Timeout', 'Mixed'};
    Color = ["#0072BD" "#D95319" "#EDB120" "#7E2F8E" "#77AC30" "#4DBEEE" "#A2142F"];

    if TraceName == "U7"
        TraceTitle = "ORIGINAL";
        PDF_Name = erase(TraceTitle,'\');
    elseif TraceName == "KU7"
        TraceTitle = "KF";
        PDF_Name = erase(TraceTitle,'\');
    elseif TraceName == "U7_NA"
        TraceTitle = "ERR\_EST";
        PDF_Name = erase(TraceTitle,'\');
    elseif TraceName == "KU7_NA"
        TraceTitle = "KF+ERR\_EST";
        PDF_Name = erase(TraceTitle,'\');
    else
        TraceTitle = TraceName;
        PDF_Name = TraceName;
    end

    pdf_title = strcat('PMF',' (',PDF_Name,')');

    T_VAM_ms = 100:100:5000;
    T_VAM = zeros(size(T_VAM_ms));
    T_VAM_distance = zeros(size(T_VAM_ms));
    T_VAM_heading = zeros(size(T_VAM_ms));
    T_VAM_speed = zeros(size(T_VAM_ms));
    T_VAM_timeout = zeros(size(T_VAM_ms));
    T_VAM_mixed = zeros(size(T_VAM_ms));

    for i = 1:length(T_VAM_ms)
        idx = (T_VAM_ms(i) == VAMtrace.T_VAM);
        T_VAM_distance(i) = sum(idx & (VAMtrace.TriggerType == 'Distance'));
        T_VAM_heading(i) = sum(idx & (VAMtrace.TriggerType == 'Heading'));
        T_VAM_speed(i) = sum(idx & (VAMtrace.TriggerType == 'Speed'));
        T_VAM_timeout(i) = sum(idx & (VAMtrace.TriggerType == 'Timeout'));
        T_VAM_mixed(i) = sum(idx & (VAMtrace.TriggerType == 'Mixed'));
    end

    num_T_VAM = length(VAMtrace.T_VAM);     % overall number of VAMs
    sum_T_VAM = sum(VAMtrace.T_VAM);        % sum of all the VAMs element
    average_T_VAM = sum_T_VAM/num_T_VAM;    % average value computation

    threshold_plot = 10;
    T_VAM_distance(T_VAM_distance < threshold_plot) = 0;
    T_VAM_heading(T_VAM_heading < threshold_plot) = 0;
    T_VAM_speed(T_VAM_speed < threshold_plot) = 0;
    T_VAM_timeout(T_VAM_timeout < threshold_plot) = 0;
    T_VAM_mixed(T_VAM_mixed < threshold_plot) = 0;

    PMF_values = [T_VAM_distance; T_VAM_heading; T_VAM_speed; T_VAM_timeout; T_VAM_mixed] / num_T_VAM;

    FigH = figure;
    h = bar(PMF_values', 'stacked');
    h(1).FaceColor = Color(1);
    h(2).FaceColor = Color(2);
    h(3).FaceColor = Color(3);
    h(4).FaceColor = Color(4);
    h(5).FaceColor = Color(5);

    set(gca, 'FontSize', Size.label);

    xticks(1:length(T_VAM_ms));
    xticklabels(string(T_VAM_ms));
    xtickangle(90);
    xlabel("$\mathrm{x [ms]}$", 'FontSize', Size.label, 'Interpreter', 'latex');
    % xlim([0,20]);

    yaxisproperties = get(gca, 'YAxis');
    yaxisproperties.TickLabelInterpreter = 'latex';  % latex for y-axis
    ylabel("$\mathrm{P\left(T_{VAM} = x\right)}$", 'FontSize', Size.label, 'Interpreter', 'latex');
    % ylim([0,0.3]);

    grid on
    box on
    if nargin == 4
        title(sprintf('PMF ($%s$), average $T_{VAM} = %.2f$ ms', TraceTitle, average_T_VAM),'fontweight','bold','FontSize',Size.title,'Interpreter','latex');
    else
        title(sprintf('PMF ($%s$), $T_{samp}=%d$ $ms$, average $T_{VAM} = %.2f$ ms',TraceTitle,sampling_interval,average_T_VAM),'fontweight','bold','FontSize',Size.title,'Interpreter','latex');
    end
    set(legend,'FontSize',Size.legend,'Interpreter','latex');
    legend(h, TriggerTypes);

    set(gcf,'position',[1,1,1250,650]);
    set(FigH,'Units','Inches');
    pos = get(FigH,'Position');
    set(FigH,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    if SaveEN
        pdf_title = strcat("PMF_H_thres_10_si_",num2str(sampling_interval),"_foot");
        saveas(FigH,strcat(PlotFolder,"/",pdf_title),'pdf')
    end
end