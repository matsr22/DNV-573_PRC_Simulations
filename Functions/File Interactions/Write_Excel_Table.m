function Write_Excel_Table(variable_data,column_data,path,global_run_number)
    
    % Writes data to an excel table
    % Creates the 

    sheet_number = 1; % Allways write to the first sheet
    new_column_name = char("Run Number "+ string(global_run_number)); % Unique title 
    if isfile(path) % If spreadsheet allready created
        % Read the spreadsheet
        table_data = readtable(path, 'Sheet', sheet_number);
    
        % Check if data allready exists so not writing identical column 
        column_exists = false;
        for i = 1:width(table_data)
            if isequal(table_data{:, i}, column_data)
                column_exists = true;
                break;
            end
        end
    
    % Appends new collumn and overwrites table
    if ~column_exists
        table_data.(new_column_name) = column_data;
        writetable(table_data, path, 'Sheet', sheet_number);
    else
        disp('Identical data already exists. No column added to table.');
    end
    else
    
    % Create new table, with variable as first column 
    table_data = table(variable_data,column_data, 'VariableNames', {'Data_Field',new_column_name});
    writetable(table_data, path, 'Sheet', sheet_number);
    end
end