function varargout = ui(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @ui_OpeningFcn, ...
                       'gui_OutputFcn',  @ui_OutputFcn, ...
                       'gui_LayoutFcn',  [], ...
                       'gui_Callback',   []                ...
                       );
    if nargin && ischar(varargin{1})
       gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
end

function ui_OpeningFcn(hObject, ~, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    set(handles.popCPVar, 'String', evalin('base', 'who()'));
    set(handles.popDissimilarityVar, 'String', evalin('base', 'who()'));
    set(handles.popFeatureVar, 'String', evalin('base', 'who()'));
end

function varargout = ui_OutputFcn(~, ~, handles)
    varargout{1} = handles.output;
end

function pushbutton1_Callback(~, ~, handles)
    global conn;
    
    weightingAlgo = get(handles.popWeightingAlgo, {'String', 'Value'});
    
    if (get(handles.radCPFromVar, 'Value'))
        cpv = get(handles.popCPVar, {'String', 'Value'});
        cps = evalin('base', cpv{1}{cpv{2}});
        cpd = cpv{1}{cpv{2}};
    else
        cpv = get(handles.txtCPTags, 'String');
        cps = postgis_fetch_nodes_by_tag(conn, get(handles.txtCPTags, 'String'));
        cpd = cpv;
    end    
    
    if (get(handles.radFeaturesFromVar, 'Value'))
        fv = get(handles.popFeatureVar, {'String', 'Value'});
        fs = evalin('base', fv{1}{fv{2}});
        fd = fv{1}{fv{2}};
    else
        fv = get(handles.txtFeatureTags, 'String');
        fs = postgis_fetch_ways_by_tag(conn, get(handles.txtFeatureTags, 'String'));
        fd = fv;
    end
    
    dmv = get(handles.popDissimilarityVar, {'String', 'Value'});
    dm = evalin('base', dmv{1}{dmv{2}});
    dd = dmv{1}{dmv{2}};

    optimStruct = struct(                                                                        ...
       'Features',                  fs,                                                          ...
       'FeaturesDescription',       fd,                                                          ...
       'ControlPoints',             cps,                                                         ...
       'ControlPointDescription',   cpd,                                                         ...
       'DissimilarityMatrix',       dm,                                                          ...
       'DissimilarityDescription',  dd,                                                          ...
       'MaxIter',                   str2double(get(handles.txtMaxIter, 'String')),               ...
       'DecTol',                    str2double(get(handles.txtDecTol, 'String')),                ...
       'IDWPower',                  str2double(get(handles.txtIDWPower, 'String')),              ...
       'AngleStress',               get(handles.chkAngleStress, 'Value'),                        ...
       'AngleWeight',               str2double(get(handles.txtAngleWeight, 'String')),           ...
       'WeightingAlgo',             weightingAlgo{1}{weightingAlgo{2}},                          ...
       'WeightPower',               str2double(get(handles.txtWeightPower, 'String')),           ...
       'TransformedWCoeff',         str2double(get(handles.txtTransformedWeightCoeff, 'String')),...
       'WeightByTopN',              str2double(get(handles.txtWeightByTopN, 'String')),          ...
       'WeightScaleByDistance',     get(handles.chkScaleByDistance, 'Value'),                    ...
       'PlotOrigCPs',               get(handles.chkPlotOrigCPs, 'Value'),                        ...
       'PlotTransformedCPs',        get(handles.chkPlotTransformedCPs, 'Value'),                 ...
       'PlotCPLabels',              get(handles.chkPlotCPLabels, 'Value'),                       ...
       'PlotCPTraces',              get(handles.chkPlotCPTraces, 'Value'),                       ...
       'PlotTransformationVectors', get(handles.chkPlotTransformationVectors, 'Value'),          ...
       'PlotWeightingEdges',        get(handles.chkPlotWeightingEdges, 'Value'),                 ...
       'PlotOrigFeatures',          get(handles.chkPlotOrigFeatures, 'Value'),                   ...
       'PlotTransformedFeatures',   get(handles.chkPlotTransformedFeatures, 'Value'),            ...
       'MapCaption',                {get(handles.txtMapCaption, 'String')},                      ...
       'ExportMap',                 get(handles.chkExportMap,  'Value'),                         ...
       'FilePrefix',                get(handles.txtFilePrefix,  'String'),                       ...
       'FileTimestamp',             get(handles.chkFileTimestamp,  'Value'),                     ...
       'ExportShapefiles',          get(handles.chkExportShapefiles, 'Value'),                   ...
       'ShpOrigCPs',                get(handles.chkShpOrigCPs, 'Value'),                         ...
       'ShpTransformedCPs',         get(handles.chkShpTransformedCPs, 'Value'),                  ...
       'ShpOrigFeatures',           get(handles.chkShpOrigFeatures, 'Value'),                    ...
       'ShpTransformedFeatures',    get(handles.chkShpTransformedFeatures, 'Value'),             ...
       'ShpTransformationVectors',  get(handles.chkShpTransformationVectors, 'Value')            ...
    );

    mds_wrapper(optimStruct);
end

function popWeightingAlgo_Callback(~, ~, handles)
    wa = get(handles.popWeightingAlgo,{'String','Value'});
    if (strcmp(wa{1}{wa{2}}, 'Delaunay triangulation'))
        set(handles.text4, 'Enable', 'off');
        set(handles.text5, 'Enable', 'off');
        set(handles.txtWeightByTopN, 'Enable', 'off');
        set(handles.chkScaleByDistance, 'Enable', 'off');    
    else
        set(handles.text4, 'Enable', 'on');
        set(handles.text5, 'Enable', 'on');
        set(handles.txtWeightByTopN, 'Enable', 'on');
        set(handles.chkScaleByDistance, 'Enable', 'on');    
    end
end

function radFeaturesFromVar_Callback(hObject, eventdata, handles)
    set(handles.popFeatureVar, 'Enable', 'on');
    set(handles.txtFeatureTags, 'Enable', 'off');
    set(handles.radFeaturesFromVar, 'Value', 1);
    set(handles.radFeaturesFromTags, 'Value', 0);
end

function radFeaturesFromTags_Callback(hObject, eventdata, handles)
    set(handles.popFeatureVar, 'Enable', 'off');
    set(handles.txtFeatureTags, 'Enable', 'on');
    set(handles.radFeaturesFromVar, 'Value', 0);
    set(handles.radFeaturesFromTags, 'Value', 1);
end


function radCPFromVar_Callback(hObject, eventdata, handles)
    set(handles.popCPVar, 'Enable', 'on');
    set(handles.txtCPTags, 'Enable', 'off');
    set(handles.radCPFromVar, 'Value', 1);
    set(handles.radCPFromTags, 'Value', 0);
end

function radCPFromTags_Callback(hObject, eventdata, handles)
    set(handles.popCPVar, 'Enable', 'off');
    set(handles.txtCPTags, 'Enable', 'on');
    set(handles.radCPFromVar, 'Value', 0);
    set(handles.radCPFromTags, 'Value', 1);
end


function chkAngleStress_Callback(hObject, eventdata, handles)
    if get(hObject, 'Value')
        set(handles.text13, 'Enable', 'on');
        set(handles.txtAngleWeight, 'Enable', 'on');        
    else
        set(handles.text13, 'Enable', 'off');
        set(handles.txtAngleWeight, 'Enable', 'off');
    end
end

function chkExportShapefiles_Callback(hObject, eventdata, handles)
    if get(hObject, 'Value')
        set(handles.chkShpOrigCPs, 'Enable', 'on');
        set(handles.chkShpTransformedCPs, 'Enable', 'on');        
        set(handles.chkShpTransformationVectors, 'Enable', 'on');
        set(handles.chkShpOrigFeatures, 'Enable', 'on');        
        set(handles.chkShpTransformedFeatures, 'Enable', 'on');
        set(handles.chkFileTimestamp, 'Enable', 'on');        
        set(handles.txtFilePrefix, 'Enable', 'on');
        set(handles.text24, 'Enable', 'on');        
        set(handles.text25, 'Enable', 'on');        
    else
        set(handles.chkShpOrigCPs, 'Enable', 'off');
        set(handles.chkShpTransformedCPs, 'Enable', 'off');        
        set(handles.chkShpTransformationVectors, 'Enable', 'off');
        set(handles.chkShpOrigFeatures, 'Enable', 'off');        
        set(handles.chkShpTransformedFeatures, 'Enable', 'off');
        if ~get(handles.chkExportMap, 'Value')
            set(handles.chkFileTimestamp, 'Enable', 'off');        
            set(handles.txtFilePrefix, 'Enable', 'off');
            set(handles.text24, 'Enable', 'off');        
            set(handles.text25, 'Enable', 'off');        
        end
    end
end


function chkExportMap_Callback(hObject, eventdata, handles)
    if get(hObject, 'Value')
        if ~get(handles.chkExportShapefiles, 'Value')
            set(handles.chkFileTimestamp, 'Enable', 'on');        
            set(handles.txtFilePrefix, 'Enable', 'on');
            set(handles.text24, 'Enable', 'on');        
            set(handles.text25, 'Enable', 'on');        
        end
    else
        if ~get(handles.chkExportShapefiles, 'Value')
            set(handles.chkFileTimestamp, 'Enable', 'off');        
            set(handles.txtFilePrefix, 'Enable', 'off');
            set(handles.text24, 'Enable', 'off');        
            set(handles.text25, 'Enable', 'off');        
        end
    end
end
