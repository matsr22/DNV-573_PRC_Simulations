% This code is used to plot any grid like results 
function SpeedDropletPlot(dropSizes,matrix,myTitle)
    figure;
    hold on;
% Use "imagesc" to plot the matrix, this will create a "grid" view
    matrix = flip(matrix,2);
    dropSizes = flip(dropSizes);
    dropSizes = dropSizes(1:length(dropSizes));
    matrix(isinf(matrix)) = 0;
    matrix = matrix';

    imagesc(matrix);


    % Use "jet" colormap
    colormap('jet');

    % Include a colorbar
    colorbar;

    % Set the grid on and make lines black - doesn't work at the moment
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
