# kubernetes using kubespray

1. Initialize a repo

  ```mkdir $HOME/kubernetes```

  ```cd $HOME/kubernetes```

  ```git init```

1. [Integrate kubespray as a submodule to this repo](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/integration.md).

  - Add kubespray forked repo as submodule

   ```git submodule add https://github.com/robinmordasiewicz/kubespray.git kubespray```

  - Configure git to show submodule status
  
  ```git config --global status.submoduleSummary true```

  - Add original kubespray repo as upstream

  ```cd $HOME/kubernetes/kubespray && git remote add upstream https://github.com/kubernetes-sigs/kubespray.git```

  - Sync your master branch with upstream:

   ```git checkout master```

   ```git fetch upstream```

   ```git merge upstream/master```

   ```git push origin master```

   ```git checkout -b work```

   ```git push --set-upstream origin work```

2. Copy kubespray/inventory/sample to cluster1

  ```cd $HOME/kubernetes```

  ```cp -a $HOME/kubernetes/kubestray/inventory/sample $HOME/kubernetes/inventory/cluster1```

> docker run --rm -it --mount type=bind,source="$(pwd)"/cluster1,dst=/inventory --mount type=bind,source="${HOME}"/.ssh/id_rsa,dst=/root/.ssh/id_rsa robinhoodis/kubespray-ansible:arm64 bash
