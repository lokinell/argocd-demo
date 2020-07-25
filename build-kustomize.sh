#!/bin/bash

if [ -z "$GOROOT" ]; then 
    echo "Please set your go env.. (GOROOT is missing)"
    exit 0
fi
if [ -z "$GOPATH" ]; then
    echo "Please set your go env.. (GOPATH is missing)"
    exit 0
fi
GO111MODULE=on

# Kustomize
echo "Installing kustomize api"
go get sigs.k8s.io/kustomize/api@v0.4.1
echo "Installing kustomize cli"
go get sigs.k8s.io/kustomize/kustomize/v3@v3.6.1

# Checksumer
echo "Installing kustomize checksumer plugin"
cd /tmp/
GIT_CHECKSUMER_REFSPEC=v0.0.4
mkdir -p $HOME/.config/kustomize/plugin/gitlab.com/maltcommunity/checksumer
git clone https://gitlab.com/maltcommunity/public/checksumer.git
cd checksumer
git checkout ${GIT_CHECKSUMER_REFSPEC}
go build -buildmode plugin -o $HOME/.config/kustomize/plugin/gitlab.com/maltcommunity/checksumer/Checksumer.so Checksumer.go
rm -rf /tmp/checksumer

# SopsDecoder
echo "Installing kustomize sopsdecoder plugin"
cd /tmp
GIT_SOPSDECODER_REFSPEC=v0.0.3
mkdir -p $HOME/.config/kustomize/plugin/gitlab.com/maltcommunity/sopsdecoder
git clone https://gitlab.com/maltcommunity/public/sopsdecoder.git
cd sopsdecoder
git checkout ${GIT_SOPSDECODER_REFSPEC}
go build -buildmode plugin -o $HOME/.config/kustomize/plugin/gitlab.com/maltcommunity/sopsdecoder/SopsDecoder.so SopsDecoder.go
rm -rf /tmp/sopsdecoder
