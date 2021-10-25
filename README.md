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

  - Docker container runtime has been depracated so modify line 202 of $HOME/foo/inventory/cluster1/group_vars/k8s_cluster/k8s-cluster.yml to enable containerd

  ```ShellSession
     ## Container runtime
     ## docker for docker, crio for cri-o and containerd for containerd.
     container_manager: containerd
  ```

* Or run the following sed command.

  ```ShellSession
     sed -i 's/^container_manager: docker$/container_manager: containerd/g' $HOME/foo/inventory/cluster1/group_vars/k8s_cluster/k8s-cluster.yml
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
