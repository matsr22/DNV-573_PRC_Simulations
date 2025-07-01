function Adjust_All_Colour_Bars(folder_save_location)
% Get all figure handles (including hidden ones)
figHandles = findall(0, 'Type', 'figure');

max_vals_incident = [];
min_vals_incident = [];
max_vals_damage = [];
for k = 1:length(figHandles)
    fig = figHandles(k);
    
    % Find all imagesc objects in the figure
    imageObjs = findall(fig, 'Type', 'image');
    
    axesList = findall(fig, 'Type', 'axes');
    
    
    ax = axesList(1);
    titleText = get(get(ax, 'Title'), 'String');
    
    if isempty(imageObjs)
        fprintf('  No imagesc plots found.\n');
    elseif contains(titleText, 'log', 'IgnoreCase', true)
        for i = 1:length(imageObjs)
            img = imageObjs(i);
            cdata = img.CData; % Extract the matrix from imagesc
            
            % Get the maximum value of the matrix
            max_vals_incident(end+1) = max(cdata(:));
            min_vals_incident(end+1) = min(cdata(:));
            
        end
    else
        for i = 1:length(imageObjs)
        img = imageObjs(i);
        cdata = img.CData; % Extract the matrix from imagesc
        
        % Get the maximum value of the matrix
        max_vals_damage(end+1) = max(cdata(:));
        end
    end
end

newCLim_incident = [-5 Colour_Lim_Ceil_Adjust(max(max_vals_incident))];
newClim_damage = [0 Colour_Lim_Ceil_Adjust(max(max_vals_damage))];

for k = 1:length(figHandles)
    fig = figHandles(k);
    
    % Find all axes in the figure
    axHandles = findall(fig, 'Type', 'axes');

    
    
    for j = 1:length(axHandles)
        ax = axHandles(j);

        titleText = get(get(ax, 'Title'), 'String');
        
        % Check if this axes has an image (imagesc)
        img = findall(ax, 'Type', 'image');
        
        if ~isempty(img)
            % Set new color limits

            if contains(titleText, 'log', 'IgnoreCase', true)
                 ax.CLim = newCLim_incident;
            else
                ax.CLim = newClim_damage;
            end
        end
    end

    savedName = fig.UserData;
    Save_Fig_Validated(fig, folder_save_location+savedName);
end
end