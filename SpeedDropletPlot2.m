% % This code is used to plot any grid like results 
% function SpeedDropletPlot2(xBins, yBins, matrix, myTitle)
%     figure;
%     hold on;
% % Use "imagesc" to plot the matrix, this will create a "grid" view
%     matrix = flip(matrix,2);
%     matrix(isinf(matrix)) = 0;
%     matrix = matrix';
% 
%     x_ticks = xBins(1:end-1);
%     y_ticks = yBins(1:end-1);
% 
%     imagesc(matrix);
% 
% 
%     % Use "jet" colormap
%     colormap('jet');
% 
%     % Include a colorbar
%     colorbar;
% 
%     % Set the grid on and make lines black - doesn't work at the moment
%     grid on;
%     set(gca, 'GridColor', 'k');
% 
%     % Label the axes and give a title to the plot
%     xlabel("V_w [m/s]")
%     ylabel("d [mm]")
%     title(myTitle);
% 
%     xticks(x_ticks)
% 
%     yticks(y_ticks)
% 
%     pbaspect([1 1 1])
%     axis([0.5 30.5 0.5 22.5])
% 
%     x0=0;
%     y0=0;
%     width=600;
%     height=400;
%     set(gcf,'position',[x0,y0,width,height])
%     set(findall(gcf,'-property','FontSize'),'FontSize',15)
%     set(findall(gcf,'-property','LineWidth'),'LineWidth',1.5)
%     hold off;
% 
% end

function SpeedDropletPlot2(x_bins, y_bins, data_matrix, my_title)
    % Ensure input matrix dimensions match the bin sizes
    data_matrix = data_matrix';


    if size(data_matrix, 1) ~= length(y_bins)-1 || size(data_matrix, 2) ~= length(x_bins)-1
        error('data_matrix dimensions must match (length(y_bins)-1, length(x_bins)-1)');
    end

    % Create figure
    figure;
    hold on;
    colormap(jet); % Choose a colormap
    clim([min(data_matrix(:)), max(data_matrix(:))]); % Scale color mapping
    colorbar; % Show color scale

    % Loop to draw rectangles (each using bin-to-bin width/height)
    for i = 1:length(x_bins)-1
        for j = 1:length(y_bins)-1
            x = x_bins(i);
            y = y_bins(j);
            width = x_bins(i+1) - x_bins(i);   % Individual pixel width
            height = y_bins(j+1) - y_bins(j); % Individual pixel height
            color_value = data_matrix(j, i); % Get data value for color
            
            % Convert value to colormap color
            cmap = colormap; % Get current colormap
            norm_value = (color_value - min(data_matrix(:))) / (max(data_matrix(:)) - min(data_matrix(:)));
            color_index = max(1, min(size(cmap,1), round(norm_value * (size(cmap,1)-1) + 1)));
            rect_color = cmap(color_index, :);
            
            % Draw rectangle
            rectangle('Position', [x, y, width, height], 'FaceColor', rect_color, 'EdgeColor', 'none');
        end
    end

    % Add dashed gridlines
    for i = 1:5:length(x_bins)
        plot([x_bins(i), x_bins(i)], [y_bins(1), y_bins(end)], 'w:', 'LineWidth', 0.2); % Vertical lines
    end
    for j = 1:5:length(y_bins)
        plot([x_bins(1), x_bins(end)], [y_bins(j), y_bins(j)], 'w:', 'LineWidth', 0.2); % Horizontal lines
    end

    % Adjust x and y ticks to match bin edges
    xticks(x_bins);
    yticks(y_bins);

    % Set tick color to black
    set(gca, 'XColor', 'k', 'YColor', 'k'); 

    set(gca, 'YDir', 'reverse');  % This flips the Y-axis

    % Adjust axis limits to preserve equal scaling
    x_range = max(x_bins) - min(x_bins); % x-axis range
    y_range = max(y_bins) - min(y_bins); % y-axis range

    % Ensure the plot is square while preserving aspect ratio
    if x_range > y_range
        set(gca, 'Position', [0.1, 0.1, 0.8, 0.8 * (y_range / x_range)]); % Adjust figure size for square plot
    elseif y_range > x_range
        set(gca, 'Position', [0.1, 0.1, 0.8 * (x_range / y_range), 0.8]); % Adjust figure size for square plot
    end
    
    % Set the aspect ratio of the plot to be square-like
    pbaspect([1, 1, 1]); % Enforces a square aspect ratio for the plot area

    % Set the layer order so that ticks are on top of the plot
    set(gca, 'Layer', 'top');
    current_axis = gca;
    current_axis.LabelFontSizeMultiplier = 1;
    % Set axis labels
    xlabel('X Axis');
    ylabel('Y Axis');
    title(my_title);
    current_axis.Position = [0.1 0.1 0.8 0.8];  % Modify the position (left, bottom, width, height)
    
    % Adjust figure size
    %set(gcf, 'Position', [100, 100, 600, 600]); % Make figure square
    % set(findall(gcf, '-property', 'FontSize'), 'FontSize', 15);
    % set(findall(gcf, '-property', 'LineWidth'), 'LineWidth', 1.5);
        % Adjust figure size (keep the figure square)

    hold off;
end
