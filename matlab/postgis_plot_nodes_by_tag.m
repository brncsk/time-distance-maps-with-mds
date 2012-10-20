function postgis_plot_nodes_by_tag(conn, tags, varargin)
    query = ['SELECT * FROM mt_nodes_by_tag(''' tags ''')'];
    
    if (~isempty(varargin))
        postgis_plot_query(conn, query, 'MultiPoint', varargin{1});
    else
        postgis_plot_query(conn, query, 'MultiPoint');
    end
end