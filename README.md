# Pihole HA (Highly Available)
Containerized Pihole on Kubernetes to provide highly available DNS and DNS-based ad blocking.

### Overview
This project aims to provide fast configuration and deployment of the Pihole service.  It includes:

- Default adlist and whitelist configurations.
- Ability to apply custom DNS entries (see: `data/dnsmasq.d/custom-dns.conf`)
- Docker deployment
- Helm chart for a Pihole deployment to a Kubernetes cluster.  

### Docker Deployment
Export the password you wish to use to access the web admin interface to the `$PIHOLE_PASS` environment variable.  Then execute the `run.sh` script.

### Kubernetes Requirements
If the cluster is run on bare metal, [Metal LB](https://metallb.universe.tf/) will be neceesary for the service's specific IP address assignment.  

The Deployment utilizes a Persistent Volume Claim to persist Pihole configuration and data.

### Kubernetes Deployment
Install the Helm chart.  The IP address, network storage path/credentials and the UI password must be passed to the helm chart installation.  Example:
```
helm install pihole \
	--set service.ip=192.168.2.123 \
	--set secrets.storage.networkPath=//network/storage/path \
	--set secrets.storage.user=network_storage_user \
	--set secrets.storage.password=network_storage_password \
	--set secrets.ui.password=ui-password!123 \
	.
```

Finally, update router and/or clients to point to the chosen IP address as its upstream DNS server.

#### Custom DNS entries
Custom DNS entries can be made by overriding the `dns.custom` value in the helm chart installation.  The format of the override is:

```--set dns.custom.<DNS name>=<IP Address>```

Also be sure to declare the domain the name resides in by using the `dns.domain` value.

**Example:**

To declare the `test-test` domain with the IP address `192.168.0.123` and the `cool-app` domain with the IP address `192.168.2.10`, both under the `k8s` domain, consider the following helm command:
```
helm install pihole \
  --set dns.custom.test-test=192.168.0.123 \
  --set dns.custom.cool-app=192.168.2.10 \ 
  --set dns.domain=k8s \
  .
```

### Caveats

If the pihole is not being used as the DHCP server for the network, but rather another device such as a router, hostnames will not resolve unless the DHCP server is configured as the first upstream resolver for the pihole container, in addition to any nameservers that are already specified.  This can be configured using the helm value override:
``` --set dhcp.server=192.168.0.1 ```

##### Deployment Updates
There is an issue in the current version of Metal LB [v0.7.3](https://github.com/google/metallb/issues/317) that prevents the assignment of an IP address to the load balancer when the Deployment is deleted or modified.  To resolve this, delete the Metal LB speaker Pods so that it is recreated using the new state.
