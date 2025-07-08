function config = Set_North_Sea(config)


    config.use_best_distribution_simulation = true;
    config.ommit_first_droplet_class = true;
    config.ommit_lowest_rainfall_rates = true;

    config.location_considered = "North_Sea"; % Determines which location is being analysed, options: [Lancaster], [Lecce], [Lampedusa], [North_Sea]

end