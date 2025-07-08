function config = Set_Lancaster(config)


    config.use_best_distribution_simulation = false;
    config.ommit_first_droplet_class = true;
    config.ommit_lowest_rainfall_rates = true;

    config.location_considered = "Lancaster"; % Determines which location is being analysed, options: [Lancaster], [Lecce], [Lampedusa], [North_Sea]

end