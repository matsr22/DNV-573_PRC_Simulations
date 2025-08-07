function [damages_fdf,frequency_fdf] = Create_Binned_FDFs(w_calc,parameter_mid,damages,wind_velocities,parameter_binned)
        damages_fdf = zeros(length(w_calc), length(parameter_mid));
        frequency_fdf = zeros(length(w_calc), length(parameter_mid));

        for w=1:length(w_calc)
            for d=1:length(parameter_mid)
                wind = w_calc(w);
                parameter = parameter_mid(d);
                damages_fdf(w,d) = sum(damages(wind == wind_velocities & parameter == parameter_binned, :), "all");
         
                frequency_fdf(w,d) = size(damages(wind == wind_velocities & parameter == parameter_binned, :), 1);
                
            end
        end
end