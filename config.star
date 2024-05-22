DB_PORT = 5432


def get_config(args, db_host=None, get_db_configs=False):
    deployment_suffix = args.get("deployment_suffix", "")
    CONFIG = {
        "POSTGRES": {
            "IMAGE": "postgres:16.2",
            "PORT": DB_PORT,
            "NAME": "master",
            "USER": "master",
            "PASSWORD": "master",
            "SERVICE_NAME": "bs-postgres" + deployment_suffix,
        },
        "BACKEND": {
            "DB": {
                "NAME": "blockscout",
                "USER": "blockscout",
                "PASSWORD": "blockscout",
                "PORT": DB_PORT,
            },
            "IMAGE": "blockscout/blockscout-zkevm:6.5.0",
            "NAME": "bs-backend" + deployment_suffix,
            "PORT": 4004,
            "TITLE": "Polygon CDK",
        },
        "STATS": {
            "DB": {
                "NAME": "stats",
                "USER": "stats",
                "PASSWORD": "stats",
                "PORT": DB_PORT,
            },
            "IMAGE": "ghcr.io/blockscout/stats:main",
            "NAME": "bs-stats" + deployment_suffix,
            "PORT": 8050,
        },
        "VISUALIZE": {
            "IMAGE": "ghcr.io/blockscout/visualizer:main",
            "NAME": "bs-visualize" + deployment_suffix,
            "PORT": 8050,
        },
        "FRONTEND": {
            "IMAGE": "ghcr.io/blockscout/frontend:v1.29.2",
            "NAME": "bs-frontend" + deployment_suffix,
            "PORT": args.get("blockscout_public_port", 8000),
            "TITLE": "Polygon CDK",
        },
    }

    for k in CONFIG.keys():
        CONFIG[k]["COMMON"] = args

    if db_host:
        for k in CONFIG.keys():
            if CONFIG[k].get("DB"):
                CONFIG[k]["DB"]["HOST"] = db_host

    if get_db_configs:
        db_configs = []
        for k in CONFIG.keys():
            if CONFIG[k].get("DB"):
                db_configs.append(
                    {
                        "db": CONFIG[k]["DB"]["NAME"],
                        "user": CONFIG[k]["DB"]["USER"],
                        "password": CONFIG[k]["DB"]["PASSWORD"],
                    }
                )
        return CONFIG, db_configs

    return CONFIG
