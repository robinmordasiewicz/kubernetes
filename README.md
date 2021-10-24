# kubernetes using kubespray

1. Initialize a repo

   ```ShellSession
      mkdir $HOME/kubernetes
      cd $HOME/kubernetes
      git init
   ```

2. [Integrate kubespray as a submodule to this repo](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/integration.md).

  - Add kubespray forked repo as submodule

   ```ShellSession
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
      git checkout -b work
      git pull https://github.com/robinmordasiewicz/kubespray.git work
      git push --set-upstream origin work
   ```

3. Copy the kubespray sample folder to your project and build your local inventory 

   ```ShellSession
      cd $HOME/kubernetes
      mkdir $HOME/kubernetes/inventory
      cp -a $HOME/kubernetes/kubespray/inventory/sample $HOME/kubernetes/inventory/cluster1
   ```

  - Create your local inventory

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
