function plot_falses(false_U7,false_KU7,false_U7_NA,false_KU7_NA,FalseType,PlotFolder,Size,SaveEN)

    Color = ["#0072BD" "#D95319" "#EDB120" "#7E2F8E" "#77AC30" "#4DBEEE" "#A2142F"];

    Size.title = 16;
    Size.label = 16;
    Size.legend = 16;

    if FalseType == "neg"
        Name = "False_Negatives";
    end
    if FalseType == "pos"
        Name = "False_Positives";
    end

    data = [false_U7.distance, false_U7.heading, false_U7.speed;
        false_KU7.distance, false_KU7.heading, false_KU7.speed;
        false_U7_NA.distance, false_U7_NA.heading, false_U7_NA.speed;
        false_KU7_NA.distance, false_KU7_NA.heading, false_KU7_NA.speed];
    
    FigH = figure;
    b = bar(data);
    b(1).FaceColor = Color(1);
    b(2).FaceColor = Color(2);
    b(3).FaceColor = Color(3);

    grid on
    box on

    set(legend,'FontSize',Size.legend,'Interpreter','latex');
    legend('Distance', 'Heading', 'Speed');

    title(strrep(Name,'_',' '),'fontweight','bold','FontSize',Size.title,'Interpreter','latex');
    set(gca,'FontSize',Size.label);

    xticks(1:1:4);
    xticklabels({'ORIGINAL', 'KF', 'ERR\_EST', 'KF+ERR\_EST'});
    xaxisproperties = get(gca, 'XAxis');
    xaxisproperties.TickLabelInterpreter = 'latex';
    xlabel("Type of solution employed",'FontSize',Size.label,'Interpreter','latex');

    yticks(0:250:2500);
    ylim([0,2501]);
    yaxisproperties = get(gca, 'YAxis');
    yaxisproperties.TickLabelInterpreter = 'latex';
    ylabel("Number of falses",'FontSize',Size.label,'Interpreter','latex');

    set(gcf,'position',[1,1,1250,650]);
    set(FigH,'Units','Inches');
    pos = get(FigH,'Position');
    set(FigH,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    
    if SaveEN
        saveas(FigH,strcat(PlotFolder,Name),'pdf');
    end
end