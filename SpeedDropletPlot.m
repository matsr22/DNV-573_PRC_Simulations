% 
% 
% function SpeedDropletPlot(x_bins,y_bins,data,graph_title)
% % Validate inputs
% 
% if size(data, 2) ~= length(y_bins) - 1 || size(data, 1) ~= length(x_bins) - 1
%     error('Size of data matrix must match the number of bins defined by x_bins and y_bins');
% end
% 
% % Create figure
% figure;
% hold on;
% 
% % Generate patches for each bin
% colormap('turbo'); 
% caxis([min(data(:)), max(data(:))]); % Set color scaling
% set(gca, 'YDir', 'reverse');
% 
% for i = 1:length(x_bins)-1
%     for j = 1:length(y_bins)-1
%         % Define the corners of the current bin
%         x_corners = [x_bins(i), x_bins(i+1), x_bins(i+1), x_bins(i)];
%         y_corners = [y_bins(j), y_bins(j), y_bins(j+1), y_bins(j+1)];
% 
%         % Fill the bin with the corresponding color based on the data value
%         patch('XData', x_corners, 'YData', y_corners, ...
%               'FaceColor', 'flat', 'EdgeColor', 'none', ...
%               'FaceVertexCData', data(i, j));
%     end
% end
% 
% % Add colorbar
% colorbar;
% ylabel('d[mm]');
% xlabel('V_m [m/s]');
% title(graph_title);
% 
% hold off;
% 
% end

function SpeedDropletPlot(dropSizes,matrix,myTitle)
    figure;
    hold on;
% Use "imagesc" to plot the matrix, this will create a "grid" view
    matrix = flip(matrix,2);
    dropSizes = flip(dropSizes)
    dropSizes = dropSizes(1:length(dropSizes));
    matrix(isinf(matrix)) = 0;
    matrix = matrix';
    imagesc(matrix);


    % Use "jet" colormap
    colormap('jet');

    % Include a colorbar
    colorbar;

    % Set the grid on and make lines black
    grid on;
    set(gca, 'GridColor', 'k');

    % Label the axes and give a title to the plot
    xlabel("V_w [m/s]")
    ylabel("d [mm]")
    title(myTitle);
    ticks{1}="0";
    ticksW{1}="0";
    tickDef = 1:length(dropSizes);
    for i =tickDef
        ticks{i} =num2str(dropSizes(i)); 
    end
    for i=1:30/5
        ticksW{i+1} =num2str(i*5);
    end
    xticks(0.5:5:30.5)
    xticklabels(ticksW)
    yticks(0.5:22.5)
    yticklabels(ticks)
    pbaspect([1 1 1])
    axis([0.5 30.5 0.5 22.5])

    x0=0;
    y0=0;
    width=600;
    height=400;
    set(gcf,'position',[x0,y0,width,height])
    set(findall(gcf,'-property','FontSize'),'FontSize',15)
    set(findall(gcf,'-property','LineWidth'),'LineWidth',1.5)
    hold off;

end
