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
    chain_id = cfg["COMMON"].get("chain_id", None)
    l1_rpc_url = cfg["COMMON"].get("l1_rpc_url", None)
    bridge_info = cfg["COMMON"].get("bridge_info", None)
    backend_exposed = cfg["COMMON"].get("backend_exposed", False)
    title = cfg["TITLE"]
    service_port = cfg["PORT"]
    service_name = cfg["NAME"]
    service_image = cfg["IMAGE"]

    env_vars = {
        "PORT": str(service_port),
        "NETWORK": "POE",
        "SUBNETWORK": title,
        "CHAIN_ID": str(chain_id),
        "CHAIN_TYPE": "polygon_zkevm",
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
        "INDEXER_POLYGON_ZKEVM_BATCHES_ENABLED": "true",
        "BRIDGED_TOKENS_ENABLED": "true",
        "MICROSERVICE_SC_VERIFIER_ENABLED": "true",
        "MICROSERVICE_SC_VERIFIER_URL": "http://verifier.google.com",
        "MICROSERVICE_SC_VERIFIER_TYPE": "sc_verifier"
    }
    if l1_rpc_url:
        env_vars["INDEXER_POLYGON_ZKEVM_L1_RPC"] = l1_rpc_url

    if bridge_info:
        env_vars["INDEXER_POLYGON_ZKEVM_L1_BRIDGE_START_BLOCK"] = str(
            bridge_info["l1_start_block"]
        )
        env_vars["INDEXER_POLYGON_ZKEVM_L1_BRIDGE_CONTRACT"] = bridge_info[
            "l1_contract"
        ]
        env_vars["INDEXER_POLYGON_ZKEVM_L1_BRIDGE_NETWORK_ID"] = str(
            bridge_info["l1_network_id"]
        )
        env_vars["INDEXER_POLYGON_ZKEVM_L1_BRIDGE_ROLLUP_INDEX"] = str(
            bridge_info["l1_rollup_index"]
        )
        env_vars["INDEXER_POLYGON_ZKEVM_L2_BRIDGE_START_BLOCK"] = str(
            bridge_info["l2_start_block"]
        )
        env_vars["INDEXER_POLYGON_ZKEVM_L2_BRIDGE_CONTRACT"] = bridge_info[
            "l2_contract"
        ]
        env_vars["INDEXER_POLYGON_ZKEVM_L2_BRIDGE_NETWORK_ID"] = str(
            bridge_info["l2_network_id"]
        )
        env_vars["INDEXER_POLYGON_ZKEVM_L2_BRIDGE_ROLLUP_INDEX"] = str(
            bridge_info["l2_rollup_index"]
        )

    public_ports = {}
    if backend_exposed:
        public_ports = {
            service_name: PortSpec(
                service_port, application_protocol="http", wait="1m"
            ),
        }

    service = plan.add_service(
        name=service_name,
        config=ServiceConfig(
            image=service_image,
            ports={
                service_name: PortSpec(
                    service_port, application_protocol="http", wait="1m"
                ),
            },
            public_ports=public_ports,
            env_vars=env_vars,
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
