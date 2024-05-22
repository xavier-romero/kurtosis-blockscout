def run(plan, cfg, db_configs):
    init_script_tpl = read_file(src="./init.sql")
    init_script = plan.render_templates(
        name="init.sql",
        config={"init.sql": struct(template=init_script_tpl, data=db_configs)},
    )

    postgres_service_cfg = ServiceConfig(
        image=cfg.get("IMAGE"),
        ports={
            "postgres": PortSpec(cfg.get("PORT"), application_protocol="postgresql"),
        },
        env_vars={
            "POSTGRES_DB": cfg.get("NAME"),
            "POSTGRES_USER": cfg.get("USER"),
            "POSTGRES_PASSWORD": cfg.get("PASSWORD"),
        },
        files={"/docker-entrypoint-initdb.d/": init_script},
        cmd=["-N 500"],
    )

    postgres_service = plan.add_service(
        name="postgres",
        config=postgres_service_cfg,
        description="Starting Postgres Service",
    )

    return postgres_service.ip_address
