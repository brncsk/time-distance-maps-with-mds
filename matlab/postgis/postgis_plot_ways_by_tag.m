function postgis_plot_ways_by_tag(conn, tags, varargin)
    query = ['SELECT * FROM mt_ways_by_tag(''' tags ''')'];
    
    if (~isempty(varargin))
        postgis_plot_query(conn, query, 'Line', varargin{1});
    else
        postgis_plot_query(conn, query);
    end
end