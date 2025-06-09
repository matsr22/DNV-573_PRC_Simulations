%png script
figFolder = 'C:\Users\matth\Documents\MATLAB\DNV matlab code\Plots\NMB'; 
figFiles = dir(fullfile(figFolder, '*.fig'));

for k = 1:length(figFiles)
    figPath = fullfile(figFolder, figFiles(k).name);
    fig = openfig(figPath, 'invisible');  % Open without displaying
    [~, name, ~] = fileparts(figFiles(k).name);
    saveas(fig, fullfile(figFolder, [name '.png']));
    close(fig);  
end