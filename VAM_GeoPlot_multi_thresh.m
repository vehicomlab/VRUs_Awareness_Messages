function VAM_GeoPlot_multi_thresh(VAMcoordinates,H_multi_thresh,sampling_interval,Round_start,Round_end,VectorIndex,Color,Size,lat_lim,lon_lim,PlotFolder,SaveEN)

    fix_shift = 0.00001;

    VAMcoordinates.I   = select_round(VAMcoordinates.I,Round_start(VectorIndex),Round_end(VectorIndex),false,true);
    VAMcoordinates.II  = select_round(VAMcoordinates.II,Round_start(VectorIndex),Round_end(VectorIndex),false,true);
    VAMcoordinates.III = select_round(VAMcoordinates.III,Round_start(VectorIndex),Round_end(VectorIndex),false,true);

    VAMcell = struct2cell(VAMcoordinates);
    FigH = figure;
    s = geoplot(VAMcell{1}.heading_lat-fix_shift,VAMcell{1}.heading_lon-fix_shift,"o","MarkerEdgeColor",Color(1),'MarkerFaceColor',Color(1),'MarkerSize',Size.marker);
    dtRows = [dataTipTextRow("Timestamp",VAMcell{1}.heading_timestamp)];
    s.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
    hold on
    g = geoplot(VAMcell{2}.heading_lat-fix_shift,VAMcell{2}.heading_lon-fix_shift,"square","MarkerEdgeColor",Color(4),'MarkerFaceColor',Color(4),'MarkerSize',Size.marker);
    dtRows = [dataTipTextRow("Timestamp",VAMcell{2}.heading_timestamp)];
    g.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
    h = geoplot(VAMcell{3}.heading_lat-fix_shift,VAMcell{3}.heading_lon-fix_shift,"^","MarkerEdgeColor",Color(2),'MarkerFaceColor',Color(2),'MarkerSize',Size.marker);
    dtRows = [dataTipTextRow("Timestamp",VAMcell{3}.heading_timestamp)];
    h.DataTipTemplate.DataTipRows(end+1:end+1) = dtRows;
    geobasemap 'openstreetmap';
    title(sprintf('Triggered VAMs (heading), $data=%s$, $T_{samp}=%d$ $ms$',VAMcell{1}.label,sampling_interval),'fontweight','bold','FontSize',Size.title,'Interpreter','latex');
    set(legend,'Location','northwest','FontSize',Size.legend,'Interpreter','latex');
    legend(sprintf('$\\Delta H \\ge %.1f$ $^{\\circ}$',H_multi_thresh(1)),sprintf('$\\Delta H \\ge %.1f$ $^{\\circ}$',H_multi_thresh(2)),sprintf('$\\Delta H \\ge %.1f$ $^{\\circ}$',H_multi_thresh(3)));
    gx = gca;
    geolimits([lat_lim(1)+0.0025,lat_lim(2)-0.00011],[lon_lim(1)+0.0017,lon_lim(2)-0.0004]);
    set(gx, 'FontSize', Size.label);
    set(gcf,'position',[1,1,1250,650]);
    set(FigH,'Units','Inches');
    pos = get(FigH,'Position');
    set(FigH,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
    if SaveEN
        saveas(FigH,strcat(PlotFolder,"/",'VAM_Traces_',erase(VAMcell{1}.label,'\'),'_multi_thresh_',num2str(H_multi_thresh(1)),'_',num2str(H_multi_thresh(2)),'_',num2str(H_multi_thresh(3))),'pdf');
    end

end