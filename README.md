# kubernetes

Reference: https://github.com/kubernetes-sigs/kubespray/blob/master/docs/integration.md
Fork the kubesperay repo
  - https://github.com/robinmordasiewicz/kubespray
  - git submodule add https://github.com/robinmordasiewicz/kubespray.git kubespray
  - Configure git to show submodule status: git config --global status.submoduleSummary true
  - Add original kubespray repo as upstream: cd kubespray && git remote add upstream https://github.com/kubernetes-sigs/kubespray.git
  - Sync your master branch with upstream:
  -
  -    git checkout master
  -    git fetch upstream
  -    git merge upstream/master
  -    git push origin master
