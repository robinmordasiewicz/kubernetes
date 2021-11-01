# kubernetes using kubespray

1. Initialize a repo

   ```ShellSession
      mkdir $HOME/kubernetes
      cd $HOME/kubernetes
      git init
   ```

2. [Integrate kubespray as a submodule to your repo](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/integration.md).

  - Using your browser, visit the [kubespray repo](https://github.com/kubernetes-sigs/kubespray) and click "fork".

  - Add kubespray forked repo as submodule

  ```ShellSession
     cd $HOME/kubernetes
     git submodule add https://github.com/robinmordasiewicz/kubespray.git kubespray
  ```

  - Configure git to show submodule status
 
  ```ShellSession
     git config --global status.submoduleSummary true
  ```

  - Add original kubespray repo as upstream

  ```ShellSession
     cd $HOME/kubernetes/kubespray
     git remote add upstream https://github.com/kubernetes-sigs/kubespray.git
  ```

  - Sync your master branch with upstream:

  ```ShellSession
     git checkout master
     git fetch upstream
     git merge upstream/master
     git push origin master
  ```

  - Create a new branch which you will use in your working environment:

  ```ShellSession
     cd $HOME/kubernetes/kubespray
     git checkout -b work
     git pull https://github.com/robinmordasiewicz/kubespray.git work
     git push --set-upstream origin work
  ```

3. Modify kubespray to work on Ubuntu nodes

  - Ubuntu has grouped nf_conntrack_ipv4 and nf_conntrack_ipv6 modules together into a single module name called nf_conntrack. Update the kubespray repo to probe module name nf_conntrack 
  - Edit the file $HOME/kubernetes/kubespray/roles/kubernetes/node/tasks/main.yml
  - Change all instances of the string "nf_conntrack_ipv4" to "nf_conntrack"
  - If you use vi enter this search and replace command ":%s/nf_conntrack_ipv4/nf_conntrack/g" or run the following sed command.

  ```ShellSession
     sed -i 's/nf_conntrack_ipv4/nf_conntrack/g' $HOME/kubernetes/kubespray/roles/kubernetes/node/tasks/main.yml
  ```

4. Copy kubespray sample inventory to your repo inventory

  ```ShellSession
     cd $HOME/kubernetes
     mkdir $HOME/kubernetes/inventory
     cp -a $HOME/kubernetes/kubespray/inventory/sample $HOME/kubernetes/inventory/cluster1
  ```

5. Modify kubespray config files before cluster deployment.

  - Name the cluster. Modify line 160 of $HOME/foo/inventory/cluster1/group_vars/k8s_cluster/k8s-cluster.yml

  ```ini
     # Kubernetes cluster name, also will be used as DNS domain
     cluster_name: cluster1.example.com
  ```
     - Or run the following sed command.

  ```ShellSession
     sed -i 's/^cluster_name: cluster.local$/cluster_name: cluster1.example.com/g' $HOME/foo/inventory/cluster1/group_vars/k8s_cluster/k8s-cluster.yml
  ```

  - Docker container runtime has been depracated so modify line 202 of $HOME/foo/inventory/cluster1/group_vars/k8s_cluster/k8s-cluster.yml to enable containerd

  ```ini
     ## Container runtime
     ## docker for docker, crio for cri-o and containerd for containerd.
     container_manager: containerd
  ```
     - Or run the following sed command.

  ```ShellSession
     sed -i 's/^container_manager: docker$/container_manager: containerd/g' $HOME/foo/inventory/cluster1/group_vars/k8s_cluster/k8s-cluster.yml
  ```

  - ETCD deploys with docker by default. Modify ETCD so that it runs under the host OS rather than docker runtime. Modify line 22 of $HOME/foo/inventory/cluster1/group_vars/etcd.yml

  ```ini
     ## Settings for etcd deployment type
     etcd_deployment_type: host
  ```
     - Or run the following sed command.

  ```ShellSession
     sed -i 's/^etcd_deployment_type: docker$/etcd_deployment_type: host/g' $HOME/foo/inventory/cluster1/group_vars/etcd.yml
  ```

  - Enable the "HELM" package manager for Kubernetes. Modify line 7 of $HOME/foo/inventory/cluster1/group_vars/k8s_cluster/addons.yml

  ```ini
     # Helm deployment
     helm_enabled: true
  ```
     - Or run the following sed command.

  ```ShellSession
     sed -i 's/^helm_enabled: false$/helm_enabled: true/g' $HOME/foo/inventory/cluster1/group_vars/k8s_cluster/addons.yml
  ```

  - Enable the metrics collection. Modify line 16 of $HOME/foo/inventory/cluster1/group_vars/k8s_cluster/addons.yml

  ```ini
     # Metrics Server deployment
     metrics_server_enabled: true
  ```
     - Or run the following sed command.

  ```ShellSession
     sed -i 's/^metrics_server_enabled: false$/metrics_server_enabled: true/g' $HOME/foo/inventory/cluster1/group_vars/k8s_cluster/addons.yml
  ```

  - Enable the NGINX ingress controller, and set host network to false since we will also enable MetalLB. Modify line 93, and 94 of $HOME/foo/inventory/cluster1/group_vars/k8s_cluster/addons.yml

  ```ini
     # Nginx ingress controller deployment
     ingress_nginx_enabled: true
     ingress_nginx_host_network: false
  ```
     - Or run the following sed commands.

  ```ShellSession
     sed -i 's/^ingress_nginx_enabled: false$/ingress_nginx_enabled: true/g' $HOME/foo/inventory/cluster1/group_vars/k8s_cluster/addons.yml
     sed -i 's/^# ingress_nginx_host_network: false$/ingress_nginx_host_network: false/g' $HOME/foo/inventory/cluster1/group_vars/k8s_cluster/addons.yml
  ```

  - Enable MetalLB LoadBalancer, and define a network range to assign to NGINX ingress Modify line 140, and 142 of $HOME/foo/inventory/cluster1/group_vars/k8s_cluster/addons.yml

  ```ini
     # MetalLB deployment 
     metallb_enabled: true
     metallb_ip_range:
          - "192.168.1.193-192.168.1.200"
  ```
     - Or run the following sed commands.

  ```ShellSession
     sed -i 's/^metallb_enabled: false$/metallb_enabled: true/g' $HOME/foo/inventory/cluster1/group_vars/k8s_cluster/addons.yml
     sed -i 's/^# metallb_ip_range:/metallb_ip_range:/g' $HOME/foo/inventory/cluster1/group_vars/k8s_cluster/addons.yml
     sed -i 's/^#   - "10.5.0.50-10.5.0.99"$/  - "192.168.1.193-192.168.1.200"/g' $HOME/foo/inventory/cluster1/group_vars/k8s_cluster/addons.yml
  ```

  - Enable L2 connectivity between pods. Modify line 173 of $HOME/foo/inventory/cluster1/group_vars/k8s_cluster/addons.yml

  ```ini
     metallb_protocol: "layer2"
  ```
     - Or run the following sed commands.

  ```ShellSession
     sed -i 's/^# metallb_protocol: "bgp"$/metallb_protocol: "layer2"/g' $HOME/foo/inventory/cluster1/group_vars/k8s_cluster/addons.yml
  ```

  - Enable "strict arp" for MetalLB. Modify line 129 of $HOME/foo/inventory/cluster1/group_vars/k8s_cluster/k8s-cluster.yml

  ```ini
     # must be set to true for MetalLB to work
     kube_proxy_strict_arp: true
  ```
     - Or run the following sed commands.

  ```ShellSession
     sed -i 's/^kube_proxy_strict_arp: false$/kube_proxy_strict_arp: true/g' $HOME/foo/inventory/cluster1/group_vars/k8s_cluster/k8s-cluster.yml
  ```

  - Download the admin.conf file. Modify line 236 of $HOME/foo/inventory/cluster1/group_vars/k8s_cluster/k8s-cluster.yml

  ```ini
     # Make a copy of kubeconfig on the host that runs Ansible in {{ inventory_dir  }}/artifacts
     kubeconfig_localhost: true
  ```
     - Or run the following sed commands.

  ```ShellSession
     sed -i 's/^# kubeconfig_localhost: false$/kubeconfig_localhost: true/g' $HOME/foo/inventory/cluster1/group_vars/k8s_cluster/k8s-cluster.yml
  ```


5. Enter your ubuntu node IP addresses and create your local inventory

  ```ShellSession
     cd $HOME/kubernetes
     declare -a IPS=(192.168.1.10 192.168.1.11 192.168.1.12 192.168.1.13 192.168.1.14 192.168.1.20 192.168.1.21)
     CONFIG_FILE=inventory/cluster1/hosts.yaml python3 kubespray/contrib/inventory_builder/inventory.py ${IPS[@]}
  ```

4. Deploy the cluster

  ```ShellSession
     docker run --rm -it --mount type=bind,source=$HOME/kubernetes/inventory/cluster1,dst=/inventory \
       --mount type=bind,source="${HOME}"/.ssh/id_rsa,dst=/root/.ssh/id_rsa \
       robinhoodis/kubespray-ansible:arm64 /bin/bash
  ```
