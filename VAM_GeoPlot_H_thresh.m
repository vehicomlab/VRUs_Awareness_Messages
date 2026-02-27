function VAM_GeoPlot_H_thresh(VAMcoordinates,H_threshold,sampling_interval,Round_start,Round_end,VectorIndex,Color,Size,lat_lim,lon_lim,PlotFolder,SaveEN)

    VAMcoordinates.I   = select_round(VAMcoordinates.I,Round_start(VectorIndex),Round_end(VectorIndex),false,true);
    VAMcoordinates.II  = select_round(VAMcoordinates.II,Round_start(VectorIndex),Round_end(VectorIndex),false,true);
    VAMcoordinates.III = select_round(VAMcoordinates.III,Round_start(VectorIndex),Round_end(VectorIndex),false,true);

    VAMcell = struct2cell(VAMcoordinates);
    for i=1:1:length(H_threshold)
        FigH = figure;
        s = geoplot(VAMcell{i}.heading_lat,VAMcell{i}.heading_lon,"o","MarkerEdgeColor",Color(2),'MarkerFaceColor',Color(2),'MarkerSize',Size.marker);
        dtRows = [dataTipTextRow("Timestamp",VAMcell{i}.heading_timestamp)];
        s.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
        geobasemap 'openstreetmap';
        title(sprintf('Triggered VAMs (heading), $data=%s$, $T_{samp}=%d$ $ms$',VAMcell{i}.label,sampling_interval),'fontweight','bold','FontSize',Size.title,'Interpreter','latex');
        set(legend,'Location','northwest','FontSize',Size.legend,'Interpreter','latex');
        legend(sprintf('$\\Delta H \\ge %.1f$ $^{\\circ}$',H_threshold(i)));
        gx = gca;
        geolimits(lat_lim,lon_lim);
        set(gx, 'FontSize', Size.label);
        set(gcf,'position',[1,1,1250,650]);
        set(FigH,'Units','Inches');
        pos = get(FigH,'Position');
        set(FigH,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
        if SaveEN
            saveas(FigH,strcat(PlotFolder,"/",'VAM_Traces_',erase(VAMcell{i}.label,'\'),'_H_thresh_',num2str(H_threshold(i))),'pdf');
        end
    end

end