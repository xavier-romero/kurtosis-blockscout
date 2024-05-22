config = "./config.star"
database = "./database.star"
backend = "./backend.star"
stats = "./stats.star"
visualize = "./visualize.star"
frontend = "./frontend.star"


def run(plan, args):
    if not args.get("chain_id"):
        chain_id_run = plan.run_sh(
            description="Determining CPU system architecture",
            run="chainid=$(curl -s " + args["rpc_url"] +
            """ -X POST -H "Content-Type: application/json" --data '{"method":"eth_chainId","params":[],"id":1,"jsonrpc":"2.0"}' | jq .result -r)
            printf "%d" $chainid
            """
        )
        args["chain_id"] = chain_id_run.output
        plan.print("Detected chain_id: " + args["chain_id"])

    # Get the configuration
    cfg, db_configs = import_module(config).get_config(args, get_db_configs=True)
    # Deploy database
    db_host = import_module(database).run(plan, cfg.get("POSTGRES"), db_configs)
    # Rebuild the config with the database host
    cfg = import_module(config).get_config(args, db_host)

    bs_service, bs_connection_string = import_module(backend).run(
        plan, cfg.get("BACKEND")
    )

    stats_service = import_module(stats).run(
        plan, cfg.get("STATS"), bs_connection_string
    )

    visualize_service = import_module(visualize).run(plan, cfg.get("VISUALIZE"))

    plan.print(bs_service.ports.values())

    stack_info = {
        "api_host": bs_service.ip_address,
        "api_port": bs_service.ports.values()[0].number,
        "stats_host": stats_service.ip_address,
        "stats_port": stats_service.ports.values()[0].number,
        "visualize_host": visualize_service.ip_address,
        "visualize_port": visualize_service.ports.values()[0].number,
    }
    import_module(frontend).run(plan, cfg.get("FRONTEND"), stack_info)
