

function SpeedDropletPlot(x_bins,y_bins,data,title)
% Validate inputs
if size(data, 1) ~= length(y_bins) - 1 || size(data, 2) ~= length(x_bins) - 1
    error('Size of data matrix must match the number of bins defined by x_bins and y_bins');
end

% Create figure
figure;
hold on;

% Generate patches for each bin
colormap('turbo'); 
clim([min(data(:)), max(data(:))]); % Set color scaling

for i = 1:length(x_bins)-1
    for j = 1:length(y_bins)-1
        % Define the corners of the current bin
        x_corners = [x_bins(i), x_bins(i+1), x_bins(i+1), x_bins(i)];
        y_corners = [y_bins(j), y_bins(j), y_bins(j+1), y_bins(j+1)];
        
        % Fill the bin with the corresponding color based on the data value
        patch('XData', x_corners, 'YData', y_corners, ...
              'FaceColor', 'flat', 'EdgeColor', 'none', ...
              'FaceVertexCData', data(j, i));
    end
end

% Add colorbar
colorbar;
ylabel('d[mm]');
xlabel('V_m [m/s]');
title(title);

hold off;

end