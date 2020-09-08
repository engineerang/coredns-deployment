# Deploy the kubeconfig, generate systemd service files, enable the service, run it
all: check deploy generate_config enable
        @echo "You can now use make [start|stop|restart]"

# Check prereqs
check:

# Check podman installed
ifeq (, $(shell which podman))
        $(error "No podman in $(PATH), Check docs to install https://podman.io/getting-started/installation.html")
endif

# Check user not root
ifeq (${USER}, root)
        $(error "root user detected, please run as an unprivileged user")
endif

# Check unprivileged ports allowed for user
ifeq ($(shell sysctl --value net.ipv4.ip_unprivileged_port_start), 1)
        sudo sysctl net.ipv4.ip_unprivileged_port_start=0
        @echo "\033[0;31mUnprivileged users cannot bind ports below 1024, temporarily adding. To make persistent add net.ipv4.ip_unprivileged_port_start=0 to /etc/sysctl.conf"
endif

# Deploy and run the coredns pod
deploy:
        podman play kube core-dns-deployment.yaml
        # To enable using makefile commands
        podman pod stop coredns-deployment

undeploy: clean
        systemctl --user stop pod-coredns-deployment
        podman pod rm coredns-deployment
        rm -rf ~/.config/systemd/user/pod-coredns-deployment.service
        rm -rf ~/.config/systemd/user/container-coredns-deployment-*.service
        systemctl --user daemon-reload

# Generate and install the coredns systemd service
generate_config:
        podman generate systemd --files --name coredns-deployment
        mkdir -p ~/.config/systemd/user
        cp container-coredns-deployment-*.service ~/.config/systemd/user
        cp pod-coredns-deployment.service ~/.config/systemd/user

# Enable the service to start at boot
enable:
        systemctl --user enable pod-coredns-deployment.service
        loginctl enable-linger ${USER}

# Start the service
start:
        systemctl --user start pod-coredns-deployment

# Stop the service
stop:
        systemctl --user stop pod-coredns-deployment

# Restart the service
restart:
        systemctl --user restart pod-coredns-deployment

# Check the service status
status:
        systemctl --user status pod-coredns-deployment

logs:
        podman logs --follow coredns-deployment-coredns

clean:
        rm -rf pod-coredns-deployment.service container-coredns-deployment-*.service