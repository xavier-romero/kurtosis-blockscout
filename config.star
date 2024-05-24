# https://github.com/blockscout/frontend/blob/main/docs/ENVS.md#transaction-interpretation
# https://docs.blockscout.com/for-developers/information-and-settings/env-variables
DB_PORT = 5432
TITLE = "Polygon CDK"
IMAGE_POSTGRES = "postgres:16.2"
IMAGE_BACKEND = "blockscout/blockscout-zkevm:6.5.0"
IMAGE_STATS = "ghcr.io/blockscout/stats:main"
IMAGE_VISUALIZE = "ghcr.io/blockscout/visualizer:main"
IMAGE_FRONTEND = "ghcr.io/blockscout/frontend:v1.30.0"


def get_config(args, db_host=None, get_db_configs=False):
    deployment_suffix = args.get("deployment_suffix", "")
    swap_url = args.get("swap_url", "https://app.uniswap.org/#/swap")
    l1_explorer = args.get("l1_explorer", "https://etherscan.io/")
    l1_rpc_url = args.get("l1_rpc_url")

    CONFIG = {
        "POSTGRES": {
            "IMAGE": IMAGE_POSTGRES,
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
            "IMAGE": IMAGE_BACKEND,
            "NAME": "bs-backend" + deployment_suffix,
            "PORT": 4004,
            "TITLE": TITLE,
        },
        "STATS": {
            "DB": {
                "NAME": "stats",
                "USER": "stats",
                "PASSWORD": "stats",
                "PORT": DB_PORT,
            },
            "IMAGE": IMAGE_STATS,
            "NAME": "bs-stats" + deployment_suffix,
            "PORT": 8050,
        },
        "VISUALIZE": {
            "IMAGE": IMAGE_VISUALIZE,
            "NAME": "bs-visualize" + deployment_suffix,
            "PORT": 8050,
        },
        "FRONTEND": {
            "IMAGE": IMAGE_FRONTEND,
            "NAME": "bs-frontend" + deployment_suffix,
            "PORT": args.get("blockscout_public_port", 8000),
            "TITLE": TITLE,
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
