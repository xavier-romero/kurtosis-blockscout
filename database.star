INIT_SQL_NAME = "init.sql"
INIT_ENTRYPOINT = "/docker-entrypoint-initdb.d/"


def run(plan, cfg, db_configs, init_sql):
    init_script_tpl = read_file(src=init_sql)
    init_script = plan.render_templates(
        name=INIT_SQL_NAME,
        config={INIT_SQL_NAME: struct(template=init_script_tpl, data=db_configs)},
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
        files={INIT_ENTRYPOINT: init_script},
        cmd=["-N 500"],
    )

    postgres_service = plan.add_service(
        name=cfg.get("SERVICE_NAME"),
        config=postgres_service_cfg,
        description="Starting Postgres Service",
    )

    return postgres_service.ip_address
