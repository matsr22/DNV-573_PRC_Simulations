function Save_Fig_Validated(fig,path)

% savefig but creates the directory if it doesn't exist
if nargin >1


    if ~exist(fileparts(path), 'dir')
    mkdir(fileparts(path));
    end
    
    savefig(fig,path);
else
    savefig(fig)
end

end