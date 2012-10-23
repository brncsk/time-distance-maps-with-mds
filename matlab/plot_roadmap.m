function plot_roadmap
    global conn;

    axesm('mercator');
    symbolspec;
    
    postgis_plot_ways_by_tag(conn, 'boundary=administrative admin_level=2,3,4,5,6', symspec.border);
    postgis_plot_ways_by_tag(conn, 'highway=primary,primary_link,motorway,motorway_link', symspec.roads);
    postgis_plot_nodes_by_tag(conn, 'place=city', symspec.cities);
    postgis_plot_nodes_by_tag(conn, 'place=town', symspec.towns);
end