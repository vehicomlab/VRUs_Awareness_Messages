function VAM_GeoPlot_multi_si(VAMcoordinates,si_vector,thresholds,Round_start,Round_end,VectorIndex,Color,Size,lat_lim,lon_lim,PlotFolder,SaveEN)

    VAMcoordinates.I   = select_round(VAMcoordinates.I,Round_start(VectorIndex),Round_end(VectorIndex),false,true);
    VAMcoordinates.II  = select_round(VAMcoordinates.II,Round_start(VectorIndex),Round_end(VectorIndex),false,true);
    VAMcoordinates.III = select_round(VAMcoordinates.III,Round_start(VectorIndex),Round_end(VectorIndex),false,true);

    VAMcell = struct2cell(VAMcoordinates);

    for i=1:1:length(si_vector)
        FigH = figure;
        s = geoplot(VAMcell{i}.distance_lat,VAMcell{i}.distance_lon,"o","MarkerEdgeColor",Color(1),'MarkerFaceColor',Color(1),'MarkerSize',Size.marker);
        dtRows = [dataTipTextRow("Timestamp",VAMcell{i}.distance_timestamp)];
        s.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
        geobasemap 'openstreetmap';
        title(sprintf('Triggered VAMs (distance), $data=%s$, $T_{samp}=%d$ $ms$, $\\Delta D_{sh} = %.1f$ $m$, $\\Delta H_{sh} = %.1f$ $^{\\circ}$, $\\Delta S_{sh} = %.1f$ $m/s$',VAMcell{i}.label,si_vector(i),thresholds.distance,thresholds.heading,thresholds.speed),'fontweight','bold','FontSize',Size.title,'Interpreter','latex');
        set(legend,'Location','northwest','FontSize',Size.legend,'Interpreter','latex');
        legend(sprintf('$\\Delta D \\ge %.1f$ $m$',thresholds.distance));
        gx = gca;
        geolimits(lat_lim,lon_lim);
        set(gx, 'FontSize', Size.label);
        set(gcf,'position',[1,1,1250,650]);
        set(FigH,'Units','Inches');
        pos = get(FigH,'Position');
        set(FigH,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
        if SaveEN
            saveas(FigH,strcat(PlotFolder,"/",'VAM_Traces_',erase(VAMcell{i}.label,'\'),'_multi_si_distance_',num2str(si_vector(i)),'_ms'),'pdf');
        end
    end

    for i=1:1:length(si_vector)
        FigH = figure;
        s = geoplot(VAMcell{i}.heading_lat,VAMcell{i}.heading_lon,"o","MarkerEdgeColor",Color(2),'MarkerFaceColor',Color(2),'MarkerSize',Size.marker);
        dtRows = [dataTipTextRow("Timestamp",VAMcell{i}.heading_timestamp)];
        s.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
        geobasemap 'openstreetmap';
        title(sprintf('Triggered VAMs (heading), $data=%s$, $T_{samp}=%d$ $ms$, $\\Delta D_{sh} = %.1f$ $m$, $\\Delta H_{sh} = %.1f$ $^{\\circ}$, $\\Delta S_{sh} = %.1f$ $m/s$',VAMcell{i}.label,si_vector(i),thresholds.distance,thresholds.heading,thresholds.speed),'fontweight','bold','FontSize',Size.title,'Interpreter','latex');
        set(legend,'Location','northwest','FontSize',Size.legend,'Interpreter','latex');
        legend(sprintf('$\\Delta H \\ge %.1f$ $^{\\circ}$',thresholds.heading));
        gx = gca;
        geolimits(lat_lim,lon_lim);
        set(gx, 'FontSize', Size.label);
        set(gcf,'position',[1,1,1250,650]);
        set(FigH,'Units','Inches');
        pos = get(FigH,'Position');
        set(FigH,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
        if SaveEN
            saveas(FigH,strcat(PlotFolder,"/",'VAM_Traces_',erase(VAMcell{i}.label,'\'),'_multi_si_heading_',num2str(si_vector(i)),'_ms'),'pdf');
        end
    end

    for i=1:1:length(si_vector)
        FigH = figure;
        s = geoplot(VAMcell{i}.speed_lat,VAMcell{i}.speed_lon,"o","MarkerEdgeColor",Color(3),'MarkerFaceColor',Color(3),'MarkerSize',Size.marker);
        dtRows = [dataTipTextRow("Timestamp",VAMcell{i}.speed_timestamp)];
        s.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
        geobasemap 'openstreetmap';
        title(sprintf('Triggered VAMs (speed), $data=%s$, $T_{samp}=%d$ $ms$, $\\Delta D_{sh} = %.1f$ $m$, $\\Delta H_{sh} = %.1f$ $^{\\circ}$, $\\Delta S_{sh} = %.1f$ $m/s$',VAMcell{i}.label,si_vector(i),thresholds.distance,thresholds.heading,thresholds.speed),'fontweight','bold','FontSize',Size.title,'Interpreter','latex');
        set(legend,'Location','northwest','FontSize',Size.legend,'Interpreter','latex');
        legend(sprintf('$\\Delta S \\ge %.1f$ $m/s$',thresholds.speed));
        gx = gca;
        geolimits(lat_lim,lon_lim);
        set(gx, 'FontSize', Size.label);
        set(gcf,'position',[1,1,1250,650]);
        set(FigH,'Units','Inches');
        pos = get(FigH,'Position');
        set(FigH,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
        if SaveEN
            saveas(FigH,strcat(PlotFolder,"/",'VAM_Traces_',erase(VAMcell{i}.label,'\'),'_multi_si_speed_',num2str(si_vector(i)),'_ms'),'pdf');
        end
    end

end