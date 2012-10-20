function plot_roadmap
    global conn;

    h = figure;
    axesm('mercator');
    symbolspec;
    postgis_plot_ways_by_tag(conn, 'admin_level=2', symspec.border);
    postgis_plot_ways_by_tag(conn, 'highway=primary,primary_link,motorway,motorway_link', symspec.roads);
    postgis_plot_nodes_by_tag(conn, 'place=city', symspec.cities);

    set(h, 'WindowButtonDownFcn', @button_down_callback);
end

function button_down_callback
    '!!!'
end