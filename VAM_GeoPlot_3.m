function VAM_GeoPlot_3(trace1,trace2,trace3,TriggerType,PlotFolder,Size,SaveEN)

    if TriggerType == "Distance"

        FigH = figure;
        s = geoplot(trace1.distance_lat,trace1.distance_lon,strcat('o','y'),'MarkerFaceColor','y','MarkerSize',4);
        dtRows = [dataTipTextRow("Timestamp",trace1.distance_timestamp)];
        s.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
        hold on;
        g = geoplot(trace2.distance_lat,trace2.distance_lon,strcat('o','b'),'MarkerFaceColor','b','MarkerSize',4);
        dtRows = [dataTipTextRow("Timestamp",trace2.distance_timestamp)];
        g.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
        h = geoplot(trace3.distance_lat,trace3.distance_lon,strcat('o','r'),'MarkerFaceColor','r','MarkerSize',4);
        dtRows = [dataTipTextRow("Timestamp",trace3.distance_timestamp)];
        h.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
        geobasemap 'satellite';
        title('Triggered VAM by Distance','fontweight','bold','FontSize',Size.title,'Interpreter','latex');
        set(legend,'FontSize',Size.legend,'Interpreter','latex');
        legend(trace1.label,trace2.label,trace3.label);
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
            saveas(FigH,strcat(PlotFolder,"/Trig_VAM_Distance"),'pdf');
        end

    elseif TriggerType == "Heading"

        FigH = figure;
        s = geoplot(trace1.heading_lat,trace1.heading_lon,strcat('o','y'),'MarkerFaceColor','y','MarkerSize',4);
        dtRows = [dataTipTextRow("Timestamp",trace1.heading_timestamp)];
        s.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
        hold on;
        g = geoplot(trace2.heading_lat,trace2.heading_lon,strcat('o','b'),'MarkerFaceColor','b','MarkerSize',4);
        dtRows = [dataTipTextRow("Timestamp",trace2.heading_timestamp)];
        g.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
        h = geoplot(trace3.heading_lat,trace3.heading_lon,strcat('o','r'),'MarkerFaceColor','r','MarkerSize',4);
        dtRows = [dataTipTextRow("Timestamp",trace3.heading_timestamp)];
        h.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
        geobasemap 'satellite';
        title('Triggered VAM by Heading','fontweight','bold','FontSize',Size.title,'Interpreter','latex');
        set(legend,'FontSize',Size.legend,'Interpreter','latex');
        legend(trace1.label,trace2.label,trace3.label);
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
            saveas(FigH,strcat(PlotFolder,"/Trig_VAM_Heading"),'pdf');
        end

    elseif TriggerType == "Speed"

        FigH = figure;
        s = geoplot(trace1.speed_lat,trace1.speed_lon,strcat('o','y'),'MarkerFaceColor','y','MarkerSize',4);
        dtRows = [dataTipTextRow("Timestamp",trace1.speed_timestamp)];
        s.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
        hold on;
        g = geoplot(trace2.speed_lat,trace2.speed_lon,strcat('o','b'),'MarkerFaceColor','b','MarkerSize',4);
        dtRows = [dataTipTextRow("Timestamp",trace2.speed_timestamp)];
        g.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
        h = geoplot(trace3.speed_lat,trace3.speed_lon,strcat('o','r'),'MarkerFaceColor','r','MarkerSize',4);
        dtRows = [dataTipTextRow("Timestamp",trace3.speed_timestamp)];
        h.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
        geobasemap 'satellite';
        title('Triggered VAM by Speed','fontweight','bold','FontSize',Size.title,'Interpreter','latex');
        set(legend,'FontSize',Size.legend,'Interpreter','latex');
        legend(trace1.label,trace2.label,trace3.label);
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
            saveas(FigH,strcat(PlotFolder,"/Trig_VAM_Speed"),'pdf');
        end

    end
end