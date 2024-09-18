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

    % Convert to a column vector for full output 
    %fields = fieldnames(flt);
    fields = {'SDN','CRUISE','STATION','LON','LAT','PRES','TEMP',...
        'PSAL','DOXY','NITRATE','CHLA','BBP','PH_IN','CHL435','CHLA_ADJ'};
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

% Loop through floats to save mean surface data
for i = 1:length(fn)

    % Load float data
    load([fpath char(fn(i))])
    [l,w] = size(flt.PRES);

    %fields = fieldnames(flt);
    fields = {'SDN','CRUISE','STATION','LON','LAT','PRES','TEMP',...
        'PSAL','DOXY','NITRATE','CHLA','BBP','PH_IN','CHL435','CHLA_ADJ'};
    for j = 1:length(fields)
        cvar = char(fields(j));
        if i == 1
            fs.(cvar) = [];
        else
        end
        if ~isfield(flt,cvar)
            fs.(cvar) = [fs.(cvar);NaN(w,1)];
        else
            if size(flt.(cvar),2) == 1
                % Then just save as is (e.g., sdn, lat, lon)
                fs.(cvar) = [fs.(cvar);flt.(cvar)];
            else
                % Then take mean in upper 7 m data
                pidx = (flt.PRES <= 7);
                for k = 1:w
                    fs.(cvar) = [fs.(cvar); mean(flt.(cvar)(pidx(:,k),k),'omitnan')];
                end

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
writetable(F, strcat(fpath, "/bbfl2_float_data.csv"));
save([fpath, '/bbfl2_float_data.mat'],'f')
save([fpath, '/bbfl2_surface_float_data.mat'],'fs')


%% plot data
ufl = unique(f.CRUISE);
figure(1)
for k = 1:length(ufl)
    idx = find(f.PRES < 5 & f.CRUISE == ufl(k));
    subplot(3,5,k)
    scatter(f.CHL435(idx),f.CHLA(idx),10,f.PRES(idx),'filled')
    colorbar
end
title('x = 435, y = 470, color = latitude')


% plot data
ufl = unique(f.CRUISE);
figure(1)
for k = 1:length(ufl)
    idx = find(f.PRES < 5 & f.CRUISE == ufl(k));
    subplot(3,5,k)
    scatter(f.CHL435(idx),f.CHLA(idx),10,f.STATION(idx),'filled')
    colorbar
    title(str2num(f.CRUISE(idx(1))))
end
title({((f.CRUISE(idx(1))));['x = 435, y = 470, color = profile']})

%% Loop through the unique floats and just save the profile info
cd(fpath)
fn = dir('*.mat');
fn = {fn.name};
fields = {'SDN','CRUISE','STATION','LON','LAT'};

clear fp
% Loop through floats
for i = 1:length(fn)

    % Load float data
    load([fpath char(fn(i))])
    [l,w] = size(flt.SDN);
    % Convert to a column vector
    for j = 1:length(fields)
        cvar = char(fields(j));
        if i == 1
            fp.(cvar) = [];
        else
        end
        %if ~isfield(flt,cvar)
            %fp.(cvar) = [f.(cvar);NaN(l,1)];
        %else
            % Then repmat the field
         fp.(cvar) = [fp.(cvar);flt.(cvar)];
        %end
    end
end

%% Fix up the float data
% date
fp.date = string(datestr(fp.SDN,'YYYY-MM-DD'));
% longitude
fp.lon_W  = fp.LON;
% convert to lon west
idx = find(fp.lon_W > 180);
fp.lon_W(idx) = fp.lon_W(idx) - 360;


%% Save the data
FP = struct2table(fp);
writetable(FP, strcat(fpath, "/float_profile_info.csv"));
save([fpath, '/float_profile_info.mat'],'FP')
%% Map the data
FP = readtable([fpath, '/float_profile_info.csv']);

ufl = unique(FP.CRUISE);
figure(1)
for k = 1:length(ufl)
    idx = find(FP.CRUISE == ufl(k));
    subplot(3,5,k)
    m_proj('Robinson','long',[-180 180],'lat',[-90 90]);hold on
    h=m_scatter(FP.LON(idx),FP.LAT(idx),'r');
    m_gshhs_l('patch',rgb('gray'),'edgecolor','k');hold on % getting
%     error trying to use this function now, switching to m_coast
    m_coast('patch',rgb('gray'),'edgecolor','k')
    title(num2str(FP.CRUISE(idx(1))))

end

