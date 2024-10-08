def run(plan, cfg, stack_info):
    title = cfg["TITLE"]
    chain_id = cfg["COMMON"]["chain_id"]
    l1_explorer = cfg["COMMON"]["l1_explorer"]
    swap_url = cfg["COMMON"].get("swap_url")
    backend_exposed = cfg["COMMON"].get("backend_exposed", False)

    service_port = cfg["PORT"]
    service_port_name = cfg["PORT_NAME"]
    service_ip = cfg["IP"]
    service_name = cfg["NAME"]
    service_image = cfg["IMAGE"]

    api_host = stack_info["api_host"]
    api_port = str(stack_info["api_port"])
    if backend_exposed:
        api_host = service_ip
        api_port = str(backend_exposed)

    env_vars = {
        "PORT": str(service_port),
        ## Blockchain configuration.
        # https://github.com/blockscout/frontend/blob/main/docs/ENVS.md#blockchain-parameters
        "NEXT_PUBLIC_NETWORK_NAME": title,
        "NEXT_PUBLIC_NETWORK_ID": str(chain_id),
        # https://github.com/blockscout/frontend/blob/main/docs/ENVS.md#rollup-chain
        "NEXT_PUBLIC_ROLLUP_TYPE": "zkEvm",
        "NEXT_PUBLIC_ROLLUP_L1_BASE_URL": l1_explorer,
        # https://github.com/blockscout/frontend/blob/main/docs/ENVS.md#transaction-interpretation
        "NEXT_PUBLIC_TRANSACTION_INTERPRETATION_PROVIDER": "blockscout",
        ## API configuration.
        # https://github.com/blockscout/frontend/blob/main/docs/ENVS.md#api-configuration
        "NEXT_PUBLIC_API_PROTOCOL": "http",
        "NEXT_PUBLIC_API_HOST": api_host,
        "NEXT_PUBLIC_API_PORT": api_port,
        "NEXT_PUBLIC_API_WEBSOCKET_PROTOCOL": "ws",
        # https://github.com/blockscout/frontend/blob/main/docs/ENVS.md#blockchain-statistics
        "NEXT_PUBLIC_STATS_API_HOST": "http://{}:{}".format(
            stack_info["stats_host"], stack_info["stats_port"]
        ),
        # https://github.com/blockscout/frontend/blob/main/docs/ENVS.md#solidity-to-uml-diagrams
        "NEXT_PUBLIC_VISUALIZE_API_HOST": "http://{}:{}".format(
            stack_info["visualize_host"], stack_info["visualize_port"]
        ),
        # https://github.com/blockscout/frontend/blob/main/docs/ENVS.md#app-configuration
        "NEXT_PUBLIC_APP_PROTOCOL": "http",
        "NEXT_PUBLIC_APP_HOST": service_ip or "127.0.0.1",
        "NEXT_PUBLIC_APP_PORT": str(service_port),
        "NEXT_PUBLIC_USE_NEXT_JS_PROXY": "true",
        ## Remove ads.
        # https://github.com/blockscout/frontend/blob/main/docs/ENVS.md#banner-ads
        "NEXT_PUBLIC_AD_BANNER_PROVIDER": "none",
        # https://github.com/blockscout/frontend/blob/main/docs/ENVS.md#text-ads
        "NEXT_PUBLIC_AD_TEXT_PROVIDER": "none",
    }
    if swap_url:
        swap_item = {"text": "Polygon zkEVM Bridge", "icon": "swap", "url": swap_url}
        env_vars["NEXT_PUBLIC_DEFI_DROPDOWN_ITEMS"] = json.encode([swap_item])

    service = plan.add_service(
        name=service_name,
        config=ServiceConfig(
            image=service_image,
            ports={
                service_port_name: PortSpec(
                    service_port, application_protocol="http", wait="30s"
                ),
            },
            public_ports={
                service_port_name: PortSpec(
                    service_port, application_protocol="http", wait="30s"
                ),
            },
            env_vars=env_vars,
        ),
    )
