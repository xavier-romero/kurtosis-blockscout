def run(plan, cfg, stack_info):
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
                    service_port, application_protocol="http", wait="30s"
                ),
            },
            public_ports={
                service_name: PortSpec(
                    service_port, application_protocol="http", wait="30s"
                ),
            },
            env_vars={
                "PORT": str(service_port),
                "NEXT_PUBLIC_NETWORK_NAME": title,
                "NEXT_PUBLIC_NETWORK_ID": str(chain_id),
                "NEXT_PUBLIC_API_HOST": stack_info["api_host"],
                "NEXT_PUBLIC_API_PORT": str(stack_info["api_port"]),
                "NEXT_PUBLIC_API_PROTOCOL": "http",
                "NEXT_PUBLIC_API_WEBSOCKET_PROTOCOL": "ws",
                "NEXT_PUBLIC_STATS_API_HOST": "http://{}:{}".format(
                    stack_info["stats_host"], stack_info["stats_port"]
                ),
                "NEXT_PUBLIC_VISUALIZE_API_HOST": "http://{}:{}".format(
                    stack_info["visualize_host"], stack_info["visualize_port"]
                ),
                "NEXT_PUBLIC_APP_PROTOCOL": "http",
                "NEXT_PUBLIC_APP_HOST": "127.0.0.1",
                "NEXT_PUBLIC_APP_PORT": str(service_port),
                "NEXT_PUBLIC_USE_NEXT_JS_PROXY": "true",
                "NEXT_PUBLIC_AD_BANNER_PROVIDER": "none",
                "NEXT_PUBLIC_AD_TEXT_PROVIDER": "none",
            },
        ),
    )
