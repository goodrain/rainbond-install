#!/bin/bash


salt-ssh -i "*" state.sls minions.install

salt -E "compute" state.sls init

salt -E "compute" state.sls storage

salt -E "compute" state.sls grbase.dns

salt -E "compute" state.sls docker

salt -E "compute" state.sls network

salt -E "compute" state.sls node

salt -E "compute" state.sls kubernetes.node



