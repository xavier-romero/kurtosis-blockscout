def run(plan, cfg):
    service_name = cfg["NAME"]
    service_image = cfg["IMAGE"]
    service_port = cfg["PORT"]

    service = plan.add_service(
        name=service_name,
        config=ServiceConfig(
            image=service_image,
            ports={
                service_name: PortSpec(service_port, application_protocol="http"),
            },
        ),
    )

    return service
