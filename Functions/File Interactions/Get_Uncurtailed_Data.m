function [uncurt_damage,damage_criteria,time_series_damage_uncurt,AEP] =  Get_Uncurtailed_Data(location_considered,use_best_distribution,lifetime_extention_multiplier)
    
    % Gets the uncurtailed data for comparison to the curtailed data -
    % should be improved due to curtailed data depending on settings and
    % not currently being dynamically updated with the exact settings used
    % for the curtailed settings

    uncurtailed_data = load("Simulation_Data\Uncurtailed_Data.mat");
    
    if location_considered == "Lampedusa" && use_best_distribution
        damage = uncurtailed_data.lampedusa_best_damage;
        AEP = uncurtailed_data.lampedusa_AEP;
    elseif location_considered == "Lampedusa" && ~use_best_distribution
        damage = uncurtailed_data.lampedusa_measured_damage;
        AEP = uncurtailed_data.lampedusa_AEP;
    elseif location_considered == "Lancaster" && use_best_distribution
        damage = uncurtailed_data.lancaster_best_damage;
        AEP = uncurtailed_data.lancaster_AEP;
    elseif location_considered == "Lancaster" && ~use_best_distribution
        damage = uncurtailed_data.lancaster_measured_damage;
        AEP = uncurtailed_data.lancaster_AEP;
    elseif location_considered == "North_Sea"
        damage = uncurtailed_data.north_sea_best_damage;
        AEP = uncurtailed_data.north_sea_AEP;
    else
        error("Location not valid for PRC")
    end

    time_series_damage_uncurt = damage;
    damage = sort(damage);
    total_damage_allowable = sum(damage)./lifetime_extention_multiplier;

    cumsum_damages = cumsum(damage);

    damage_criteria_index = find(cumsum_damages>=total_damage_allowable,1,"first");

    damage_criteria = damage(damage_criteria_index);
    uncurt_damage = sum(damage,"all");
    
end