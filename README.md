# coredns-deployment
A podman deployment of CoreDNS, Prometheus, &amp; Grafana using kubeconfig

# Getting Started

## Installation
You will need podman, so head over to [Podman.io](https://podman.io/getting-started/installation.html) and install for your distro.

## Quickstart
````bash
git clone https://github.com/engineerang/coredns-deployment.git
cd coredns-deployment
podman kube play core-dns-deployment.yaml
````

# Using make targets
If you're using RHEL or DEB you can run the Makefile.

## Useful targets
````bash 
make # Deploy the pod and systemd service files
make stop # Use the systemd service file to stop the pod
make start # Use the systemd service file to start the pod
make status # Use the systemd service file to get the status of the pod
make clean # Remove the systemd service files
make undeploy # Remove the pod and systemd service files
````
# Services
## Grafana & Prometheus
This deployment make use of CoreDNS's prometheus metric endpoint browse to URL ```<ip_address>:3000``` and use admin:admin to login

> **NOTE** If you find you cannot hit the URL you may run the following:
```
sudo sysctl net.ipv4.ip_unprivileged_port_start=0
systemctl --user restart pod-coredns-deployment
```

