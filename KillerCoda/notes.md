## Vim Setup
vim ~/.vimrc

set expandtab
set tabstop=2
set shiftwidth=2

## Kubectl contexts
k config use-context yellow
k config set-context yellow
kubectl config get-contexts -o name