def run(plan, cfg):
    service_name = cfg["NAME"]
    service_image = cfg["IMAGE"]
    service_port = cfg["PORT"]
    service_port_name = cfg["PORT_NAME"]

    service = plan.add_service(
        name=service_name,
        config=ServiceConfig(
            image=service_image,
            ports={
                service_port_name: PortSpec(service_port, application_protocol="http"),
            },
        ),
    )

    return service
