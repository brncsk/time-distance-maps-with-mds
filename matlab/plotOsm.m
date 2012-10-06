function plotOsm(parsed_osm)
    fig = figure;
    ax = axes('Parent', fig);
    hold(ax, 'on')
    plot_way(ax, parsed_osm)
