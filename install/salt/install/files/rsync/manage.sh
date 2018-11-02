#!/bin/bash

salt -E "manage" cmd.run 'systemctl restart node'
salt -E "manage" cmd.run 'systemctl daemon-reload'
salt -E "manage" cmd.run 'grclis reload'