def run(plan, cfg, bs_connection_string):
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

    service_port = cfg["PORT"]
    service_port_name = cfg["PORT_NAME"]
    service_name = cfg["NAME"]
    service_image = cfg["IMAGE"]

    service = plan.add_service(
        name=service_name,
        config=ServiceConfig(
            image=service_image,
            ports={
                service_port_name: PortSpec(
                    service_port, application_protocol="http", wait="30s"
                ),
            },
            env_vars={
                "STATS__DB_URL": connection_string,
                "STATS__BLOCKSCOUT_DB_URL": bs_connection_string,
                "STATS__CREATE_DATABASE": "false",
                "STATS__RUN_MIGRATIONS": "true",
                "STATS__SERVER__HTTP__CORS__ENABLED": "false",
            },
        ),
    )

    return service
