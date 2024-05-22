def run(plan, cfg):
    host = cfg["DB"]["HOST"]
    port = cfg["DB"]["PORT"]
    db = cfg["DB"]["NAME"]
    user = cfg["DB"]["USER"]
    password = cfg["DB"]["PASSWORD"]

    connection_string = (
        "postgresql://"
        + user
        + ":"
        + password
        + "@"
        + host
        + ":"
        + str(port)
        + "/"
        + db
    )

    rpc_url = cfg["COMMON"]["rpc_url"]
    trace_url = cfg["COMMON"].get("trace_url", rpc_url)
    ws_url = cfg["COMMON"]["ws_url"]
    chain_id = cfg["COMMON"]["chain_id"]
    title = cfg["TITLE"]
    service_port = cfg["PORT"]
    service_name = cfg["NAME"]
    service_image = cfg["IMAGE"]

    service = plan.add_service(
        name=service_name,
        config=ServiceConfig(
            image=service_image,
            ports={
                service_name: PortSpec(
                    service_port, application_protocol="http", wait="1m"
                ),
            },
            env_vars={
                "PORT": str(service_port),
                "NETWORK": "POE",
                "SUBNETWORK": title,
                "CHAIN_ID": str(chain_id),
                "COIN": "ETH",
                "ETHEREUM_JSONRPC_VARIANT": "geth",
                "ETHEREUM_JSONRPC_HTTP_URL": rpc_url,
                "ETHEREUM_JSONRPC_TRACE_URL": trace_url,
                "ETHEREUM_JSONRPC_WS_URL": ws_url,
                "ETHEREUM_JSONRPC_HTTP_INSECURE": "true",
                "DATABASE_URL": connection_string,
                "ECTO_USE_SSL": "false",
                "MIX_ENV": "prod",
                "LOGO": "/images/blockscout_logo.svg",
                "LOGO_FOOTER": "/images/blockscout_logo.svg",
                "SUPPORTED_CHAINS": "[]",
                "SHOW_OUTDATED_NETWORK_MODAL": "false",
                "DISABLE_INDEXER": "false",
                "INDEXER_ZKEVM_BATCHES_ENABLED": "true",
                "API_V2_ENABLED": "true",
                "BLOCKSCOUT_PROTOCOL": "http",
            },
            cmd=[
                "/bin/sh",
                "-c",
                'bin/blockscout eval "Elixir.Explorer.ReleaseTasks.create_and_migrate()" && bin/blockscout start',
            ],
        ),
    )
    plan.exec(
        description="""
        Allow 30s for blockscout to start indexing,
        otherwise bs/Stats crashes because it expects to find content on DB
        """,
        service_name=service_name,
        recipe=ExecRecipe(
            command=["/bin/sh", "-c", "sleep 30"],
        ),
    )

    return service, connection_string
