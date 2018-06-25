import os
import salt.utils

def showip():
    cmd = 'bash /opt/rainbond/envs/.myip'
    output = __salt__['cmd.run_stdout'](cmd)
    return output
