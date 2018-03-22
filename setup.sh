#!/bin/bash

salt-call --config-dir install --file-root install/salt --pillar-root install/pillar --local state.apply

salt-call  --config-dir install --file-root install/salt --pillar-root install/pillar --local pillar.get role
