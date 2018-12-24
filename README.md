# Pihole HA (Highly Available)
Containerized Pihole on Kubernetes to provide highly available DNS and DNS-based ad blocking.

### Overview
This project aims to provide fast configuration and deployment of the Pihole service.  It includes:

- Default adlist and whitelist configurations.
- Ability to apply custom DNS entries (see: `data/dnsmasq.d/custom-dns.conf`)
- Docker deployment
- Spec for a Pihole deployment to a Kubernetes cluster.  

### Docker Deployment
Export the password you wish to use to access the web admin interface to the `$PIHOLE_PASS` environment variable.  Then execute the `run.sh` script.

### Kubernetes Requirements
If the cluster is run on bare metal, [Metal LB](https://metallb.universe.tf/) will be neceesary for the service's specific IP address assignment.  The IP address must be chosen and specified in the appropriate locations in both `pihole-ha-deployment.yaml` and `pihole-ha-service.yaml` sepcs.

The kubernetes Deployment will require a `pihole-ui-secret` secret to exist with a key `password` whose value is the base 64 encoding of the password that will gain access to the web admin interface.

#### Upcoming Changes
Currently the deployment uses the [emptyDir](https://kubernetes.io/docs/concepts/storage/volumes/#emptydir) volume type, so configuration changes and statistics are not persisted.  This will be updated to use a Persistant Volume shortly, specifically the fstab/cifs flexVolume.

Custom DNS entries will reside in a kubernetes [ConfigMap](https://github.com/MoJo2600/pihole-kubernetes/blob/master/configmap-pihole-custom-dnsmasq.yml) and automatically mapped to the pihole, removing a crucial bit of state out of the container.

### Kubernetes Deployment
- First determine desired IP address of Pihole and update `pihole-ha-deployment` and `pihole-ha-service` specs.
- Apply the `pihole-ha-deployment` spec.  This will bring up one pihole instance.  In the event of a failure of the node the instance is running on, Kubernetes will automatically start a new instance on a healthy node.
- Appy the `pihole-ha-service` spec.  This will allow ingress to the pihole container, providing access to DNS querying and the web admin interface.  The service has been configured to provide both UDP and TCP access for DNS.
- Finally, update router and/or clients to point to the chosen IP address as its upstream DNS server.