% directory = uigetdir("\\skat\Research Team\DUrban\MatLab\Process B-Scans\");
% 
% addpath(genpath("C:\Users\durban\OneDrive - Optos Inc\Documents\MATLAB\MatLab\DEFR"))
% addpath(genpath("C:\Users\durban\OneDrive - Optos Inc\Documents\MATLAB\MatLab\Process B-scans"))
% 
% %%

directories = ["\\skat\Research Team\DUrban\MatLab\Process B-Scans\SilverstoneFlattening\20240201-153117-00",
    "\\skat\Research Team\DUrban\MatLab\Process B-Scans\SilverstoneFlattening\20240201-155859-00"];

clear results

for jj = 1:length(directories)

    directory = directories(jj);

    f = Frame(directory, 3);
    f_phs = f.disp_comp(10);
    
    N = 1;
    M = 10;
    
    snrs = zeros(1, N);
    
    for i = 1:N+1
        f_n = Frame(directory, i);
        f_n = f_n.apply_phase((f_phs.phase));
    
        f_d = f_n.incoherent_average_laterally(M);
    
        if i == 1
            f_mean = f_d;
        else
            f_mean = f_mean.incoh_plus(f_d);
        end
    end

    results(jj) = f_mean;

end
%

figure
imshow(logScaling(f_mean.bscan_real), Colormap=turbo);
title(sprintf("Incoherent Average N = %i", N*M))
daspect([1, f_mean.siz(1)/f_mean.siz(2), 1])

%%

curved = circshift((results(1).bscan_real), -1500, 2);
flat = circshift(flipud(results(2).bscan_real), 150, 2);

px_per_mm_x = 4000/(140/360*25*pi*2) * 1.1667/1e3; % BscanLen / 70deg Section * OSTestRatio / mm
px_per_mm_y = 640/4/1e3; % AscanLen / AscanRange / mm
aspect_ratio = px_per_mm_x / px_per_mm_y * 2;

figure
tiledlayout("vertical", "TileSpacing", "None", "Padding", "tight")
ax = nexttile;
scaled = logScaling(curved(:, 1:end/2));
imshow(scaled, DisplayRange=[])
colormap turbo
daspect([1, 1/aspect_ratio 1])
text(ax, 10, 60, "a", "FontSize", 18, "Color", [0.99 0.99 0.99])

ax = nexttile;
imshow(logScaling(flat(:, 1:end/2), curved(:, 1:end/2)), DisplayRange=[min(scaled(:)), max(scaled(:))]);
colormap turbo
daspect([1, 1/aspect_ratio 1])
text(ax, 10, 60, "b", "FontSize", 18, "Color", [0.99 0.99 0.99])

c = colorbar;
c.Label.String = "";
c.Limits = [0, 1];
c.Layout.Tile = "east";
c.Ticks = [0 1];


bar_length = 1000;

hbar = scalebar(ax, "y");
hbar.Visible = "off";
hbar.Axis = "y";
hbar.Color = [0.99 1 1];
hbar.ScalebarLength = bar_length;
hbar.ConversionFactor = 640/4/1e3; % AscanLen / AscanRange / mm
hbar.UnitLabel = char("");

hbar2 = scalebar(ax, "x");
hbar2.Visible = "off";
hbar2.Axis = "x";
hbar2.Color = [0.99 1 1];
hbar2.ScalebarLength = bar_length;
hbar2.ConversionFactor = 4000/(140/360*25*pi*2)/1e3; % BscanLen / 70deg Sector
hbar2.UnitLabel = char("");