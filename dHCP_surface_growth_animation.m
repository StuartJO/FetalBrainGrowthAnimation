%% dHCP Surface Morphing Animation
% This script animates morphing between cortical surfaces across
% gestational ages (GA), and optionally saves frame-by-frame images.

clear; clf

%% Load data
load('dHCP_edited_surf_data.mat')  % Contains faces, vertices_GA, GA, etc.

%% Parameters
printout = 0; % Set to 1 to save frames as images
Niterp = 30;                       % Number of interpolation steps between surfaces
SmallFont = 8;                     % Font size for side annotations
LargeFont = 72;                    % Font size for center annotation

StartGA = 21;                      % The GA to start from
EndGA = 40;                        % The GA to end at

%%

if printout
    mkdir ./Imgs
end

r = linspace(0, 1, Niterp);             % Interpolation ratio (0=start, 1=end)
r2use = r(2:end);                  % Skip the starting point (redundant with previous frame)
StartGAind = find(GA==StartGA);
EndGAind = find(GA==EndGA);

% Smoothly scale font sizes and positions across interpolation frames
fontsizing = linspace(SmallFont, LargeFont, Niterp);
fontsizing = fontsizing(2:end-1);         % Exclude first and last (redundant)
fontsizing_ = fliplr(fontsizing);         % Mirror font sizes for symmetry

Pos1 = linspace(0.5, 0.25, Niterp);            % Left label position across frames
Pos2 = linspace(0.75, 0.5, Niterp);            % Right label position across frames
Pos1 = Pos1(2:end-1);
Pos2 = Pos2(2:end-1);

F = length(r2use);                        % Number of frames per GA pair

%% Initialize 3D brain surface

% The final brain is plotted, which is used to get the axis limits
p = patch('Faces', faces, 'Vertices', vertices_GA{EndGAind});
set(p, 'FaceColor', [0.5 0.5 0.5], ...
       'EdgeColor', 'none', ...
       'FaceLighting', 'gouraud', ...
       'Clipping', 'off');
axis off equal tight
material dull
view([-90 0])
camlight('headlight');  % Add light source

%% Store axis limits for consistency across frames
xlimits = xlim;
ylimits = ylim;
zlimits = zlim;
xlim(xlimits); ylim(ylimits); zlim(zlimits);

%% Initialize annotations
GAweek_naming = GA;
annotsize = 0.35;
Iter = 1;

% --- Display the first frame (baseline) ---
i = StartGAind;
p.Vertices = vertices_GA{i};

A = annotation('textbox', [0.25 - annotsize/2, 0.935, annotsize, 0.05], ...
    'String', sprintf('%d weeks', GAweek_naming(i) - 1), ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle', ...
    'FontSize', SmallFont, ...
    'FitBoxToText', 'off', ...
    'EdgeColor', 'none');

B = annotation('textbox', [0.5 - annotsize/2, 0.935, annotsize, 0.05], ...
    'String', sprintf('%d weeks', GAweek_naming(i)), ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle', ...
    'FontSize', LargeFont, ...
    'FitBoxToText', 'off', ...
    'EdgeColor', 'none');

C = annotation('textbox', [0.75 - annotsize/2, 0.935, annotsize, 0.05], ...
    'String', sprintf('%d weeks', GAweek_naming(i) + 1), ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle', ...
    'FontSize', SmallFont, ...
    'FitBoxToText', 'off', ...
    'EdgeColor', 'none');

if printout
    print(sprintf('./Imgs/Img%d.png', Iter), '-dpng')
end
Iter = Iter + 1;

%% Main loop — Morph between consecutive gestational ages
for i = StartGAind:EndGAind-1
    for j = 1:F
        % Interpolate vertex positions between consecutive surfaces
        newVerts = find_point_on_line(vertices_GA{i}, vertices_GA{i+1}, r2use(j));
        p.Vertices = newVerts;

        % Delete old annotations
        if exist('A', 'var'), delete(A); end
        if exist('B', 'var'), delete(B); end
        if exist('C', 'var'), delete(C); end

        % Update annotations for current frame
        if j == F
            % At the end of interpolation: shift labels forward
            A = annotation('textbox', [0.25 - annotsize/2, 0.935, annotsize, 0.05], ...
                'String', sprintf('%d weeks', GAweek_naming(i)), ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
                'FontSize', SmallFont, 'FitBoxToText', 'off', 'EdgeColor', 'none');

            B = annotation('textbox', [0.5 - annotsize/2, 0.935, annotsize, 0.05], ...
                'String', sprintf('%d weeks', GAweek_naming(i) + 1), ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
                'FontSize', LargeFont, 'FitBoxToText', 'off', 'EdgeColor', 'none');

            C = annotation('textbox', [0.75 - annotsize/2, 0.935, annotsize, 0.05], ...
                'String', sprintf('%d weeks', GAweek_naming(i) + 2), ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
                'FontSize', SmallFont, 'FitBoxToText', 'off', 'EdgeColor', 'none');
        else
            % Intermediate frame: smoothly adjust label size and position
            B = annotation('textbox', [Pos1(j) - annotsize/2, 0.935, annotsize, 0.05], ...
                'String', sprintf('%d weeks', GAweek_naming(i)), ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
                'FontSize', fontsizing_(j), 'FitBoxToText', 'off', 'EdgeColor', 'none');

            C = annotation('textbox', [Pos2(j) - annotsize/2, 0.935, annotsize, 0.05], ...
                'String', sprintf('%d weeks', GAweek_naming(i) + 1), ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
                'FontSize', fontsizing(j), 'FitBoxToText', 'off', 'EdgeColor', 'none');
        end

        % Short pause for smooth animation
        pause(0.1);

        % Optionally save the frame
        if printout
            print(sprintf('./Imgs/Img%d.png', Iter), '-dpng')
        end
        Iter = Iter + 1;
    end
end