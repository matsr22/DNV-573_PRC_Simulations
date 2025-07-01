% This code is used to plot any grid like results 
function SpeedDropletPlot(y_bins,matrix,myTitle,file_save_name,x_bins,y_label,x_label)
    
    if nargin < 5
        x_bins = 0:30;
    end
    if nargin<6
        y_label = "D [mm]";
    end
    if nargin<7
        x_label = "V [m/s]";
    end
    fig = figure;
    fig.UserData = file_save_name;
    hold on;
% Use "imagesc" to plot the matrix, this will create a "grid" view
    matrix = flip(matrix,2);
    y_bins = flip(y_bins);
    matrix(isinf(matrix)) = 0;
    matrix = matrix';

    imagesc(matrix);


    % Use "jet" colormap
    colormap('jet');

    % Include a colorbar
    cb = colorbar;

    % Set the grid on and make lines black - doesn't work at the moment
    grid on;
    set(gca, 'GridColor', 'w','GridLineStyle',':','GridLineWidth',1,'GridAlpha',0.8);

    % Label the axes and give a title to the plot
    xlabel(x_label)
    ylabel(y_label)
    title(myTitle, 'interpreter', 'latex');
    ticksX{1}=x_bins(1);
    tickyDef = 1:length(y_bins);
    tickxDef = 1:length(x_bins);
    for i =tickyDef
        ticksY{i} =num2str(y_bins(i),4); 
    end
    for i=1:(length(x_bins)-1)/5
        ticksX{i+1} =num2str(i*5);
    end
    xticks(0.5:5:length(x_bins)-0.5)
    xticklabels(ticksX)
    yticks(0.5:length(y_bins)-0.5)
    yticklabels(ticksY)



    pbaspect([1 1 1])
    axis([0.5 length(x_bins)-0.5 0.5 length(y_bins)-0.5])



    x0=0;
    y0=0;
    width=600;
    height=400;
    set(gcf,'position',[x0,y0,width,height])

    set(gca, 'Layer', 'top');

    set(gca,'LineWidth',2);
    cb.LineWidth = 2;

    current_axis = gca;
    current_axis.LabelFontSizeMultiplier = 0.8;

    box on;
    hold off;

end
