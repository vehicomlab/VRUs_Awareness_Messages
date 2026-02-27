function VAM_GeoPlot_2(trace1,trace2,TriggerType,PlotFolder,Size,SaveEN)

    if TriggerType == "Distance"

        FigH = figure;
        s = geoplot(trace1.distance_lat,trace1.distance_lon,strcat('o','y'),'MarkerFaceColor','y','MarkerSize',4);
        if ischar(trace1.distance_timestamp)
            dtRows = [dataTipTextRow("Timestamp",str2double(trace1.distance_timestamp))];
        else
            dtRows = [dataTipTextRow("Timestamp",trace1.distance_timestamp)];
        end
        s.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
        hold on;
        g = geoplot(trace2.distance_lat,trace2.distance_lon,strcat('o','b'),'MarkerFaceColor','b','MarkerSize',4);
        if ischar(trace2.distance_timestamp)
            dtRows = [dataTipTextRow("Timestamp",str2double(trace2.distance_timestamp))];
        else
            dtRows = [dataTipTextRow("Timestamp",trace2.distance_timestamp)];
        end
        g.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
        geobasemap 'satellite';
        title(sprintf('Triggered VAM by Distance, $source=GNSS$, $T_{samp}=%d$ $ms$',sampling_interval),'fontweight','bold','FontSize',Size.title,'Interpreter','latex');
        set(legend,'FontSize',Size.legend,'Interpreter','latex');
        legend(trace1.label,trace2.label);
        gx = gca;
        set(gx, 'FontSize', Size.label);
        set(gcf,'position',[1,1,1250,650]);
        set(FigH,'Units','Inches');
        pos = get(FigH,'Position');
        set(FigH,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
        if SaveEN
            saveas(FigH,strcat(PlotFolder,"/Trig_VAM_Distance (",erase(trace1.label,"\")," and ",erase(trace2.label,"\"),")"),'pdf');
        end

    elseif TriggerType == "Heading"

        FigH = figure;
        s = geoplot(trace1.heading_lat,trace1.heading_lon,strcat('o','y'),'MarkerFaceColor','y','MarkerSize',4);
        if ischar(trace1.heading_timestamp)
            dtRows = [dataTipTextRow("Timestamp",str2double(trace1.heading_timestamp))];
        else
            dtRows = [dataTipTextRow("Timestamp",trace1.heading_timestamp)];
        end        
        s.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
        hold on;
        g = geoplot(trace2.heading_lat,trace2.heading_lon,strcat('o','b'),'MarkerFaceColor','b','MarkerSize',4);
        if ischar(trace2.heading_timestamp)
            dtRows = [dataTipTextRow("Timestamp",str2double(trace2.heading_timestamp))];
        else
            dtRows = [dataTipTextRow("Timestamp",trace2.heading_timestamp)];
        end       
        g.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
        title(sprintf('Triggered VAM by Heading, $source=GNSS$, $T_{samp}=%d$ $ms$',sampling_interval),'fontweight','bold','FontSize',Size.title,'Interpreter','latex');
        set(legend,'FontSize',Size.legend,'Interpreter','latex');
        legend(trace1.label,trace2.label);
        gx = gca;
        set(gx, 'FontSize', Size.label);
        set(gcf,'position',[1,1,1250,650]);
        set(FigH,'Units','Inches');
        pos = get(FigH,'Position');
        set(FigH,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
        if SaveEN
            saveas(FigH,strcat(PlotFolder,"/Trig_VAM_Heading (",erase(trace1.label,"\")," and ",erase(trace2.label,"\"),")"),'pdf');
        end

    elseif TriggerType == "Speed"

        FigH = figure;
        s = geoplot(trace1.speed_lat,trace1.speed_lon,strcat('o','y'),'MarkerFaceColor','y','MarkerSize',4);
        if ischar(trace1.speed_timestamp)
            dtRows = [dataTipTextRow("Timestamp",str2double(trace1.speed_timestamp))];
        else
            dtRows = [dataTipTextRow("Timestamp",trace1.speed_timestamp)];
        end
        s.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
        hold on;
        g = geoplot(trace2.speed_lat,trace2.speed_lon,strcat('o','b'),'MarkerFaceColor','b','MarkerSize',4);
        if ischar(trace2.speed_timestamp)
            dtRows = [dataTipTextRow("Timestamp",str2double(trace2.speed_timestamp))];
        else
            dtRows = [dataTipTextRow("Timestamp",trace2.speed_timestamp)];
        end
        g.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
        title(sprintf('Triggered VAM by Speed, $source=GNSS$, $T_{samp}=%d$ $ms$',sampling_interval),'fontweight','bold','FontSize',Size.title,'Interpreter','latex');
        set(legend,'FontSize',Size.legend,'Interpreter','latex');
        legend(trace1.label,trace2.label);
        gx = gca;
        set(gx, 'FontSize', Size.label);
        set(gcf,'position',[1,1,1250,650]);
        set(FigH,'Units','Inches');
        pos = get(FigH,'Position');
        set(FigH,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
        if SaveEN
            saveas(FigH,strcat(PlotFolder,"/Trig_VAM_Speed (",erase(trace1.label,"\")," and ",erase(trace2.label,"\"),")"),'pdf');
        end

    end
end