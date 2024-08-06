%
% Process the BB2FL2 float data to use for the PACE satellite matchups
%
% These float files were processed by Yui Takeshita by collecting the float
% data normally, and also the aux files. The aux files which contained the
% CHL435 data were interpolated to the rest of the data for each float
% using pressure
%
%
%

close all; clear all
fpath = ('/Users/jlong/Documents/Data/PACE Hackweek/BBFL2_floats/');

cd(fpath)
fn = dir('*.mat');
fn = {fn.name};

% Loop through floats
for i = 1:length(fn)

    % Load float data
    load([fpath char(fn(i))])
    [l,w] = size(flt.PRES);

    % Convert to a column vector
    %fields = fieldnames(flt);
    fields = {'SDN','CRUISE','STATION','LON','LAT','PRES','TEMP',...
        'PSAL','DOXY','NITRATE','CHLA','BBP','PH_IN','CHL435'};
    for j = 1:length(fields)
        cvar = char(fields(j));
        if i == 1
            f.(cvar) = [];
        else
        end
        if ~isfield(flt,cvar)
            f.(cvar) = [f.(cvar);NaN(l*w,1)];
        else
            if size(flt.(cvar),2) == 1
                % Then repmat the field
                f.(cvar) = [f.(cvar);repmat(flt.(cvar),l,1)];
            else
                % Then concatenate
                f.(cvar) = [f.(cvar);reshape(flt.(cvar),l*w,1)];
            end
        end

    end


end

%% Fix up the float data
% date
f.date = string(datestr(f.SDN,'YYYY-MM-DD'));
% longitude
f.lon_W  = f.LON;
% convert to lon west
idx = find(f.lon_W > 180);
f.lon_W(idx) = f.lon_W(idx) - 360;

%% Save the data

F = struct2table(f);

writematrix([fpath '/bbfl2_float_data.csv'],'F')


% plot data
ufl = unique(f.CRUISE);