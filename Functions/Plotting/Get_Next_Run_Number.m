function run_number = Get_Next_Run_Number(path,query_iterate)
    % Iterates and grabs the next run number
    if ~isfile(path)
        run_number = 1;
    else
        fid = fopen(path, 'r');
        run_number = fscanf(fid, '%d');
        fclose(fid);
        
        if query_iterate
        run_number = run_number + 1;
        end
    end

    fid = fopen(path, 'w');
    fprintf(fid, '%d', run_number);
    fclose(fid);
end