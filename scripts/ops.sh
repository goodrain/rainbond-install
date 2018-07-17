[ -f "/etc/docker/daemon.json" ] && rm -rf /etc/docker/daemon.json
systemctl restart docker

MANAGE_MODULES="misc \
grbase \
etcd \
network \
kubernetes.server \
node \
db \
plugins \
proxy \
kubernetes.node"

install_func(){
    fail_num=0
    step_num=1
    all_steps=$(echo ${MANAGE_MODULES} | tr ' ' '\n' | wc -l)
    echo "will install manage node.It will take 15-30 minutes to install"
  
    for module in ${MANAGE_MODULES}
    do
        if [ "$module" = "plugins" -o "$module" = "proxy" ];then
            echo "Start install $module(step: $step_num/$all_steps), it will take 3-8 minutes "
        else
            echo "Start install $module(step: $step_num/$all_steps) ..."
        fi
        if ! (salt "*" state.sls $module);then
            ((fail_num+=1))
            break
        fi
        ((step_num++))
        sleep 1
    done

    if [ "$fail_num" -eq 0 ];then
        uuid=$(salt '*' grains.get uuid | grep "-" | awk '{print $1}')
        notready=$(grctl  node list | grep $uuid | grep false)
        if [ "$notready" != "" ];then
            grctl node up $uuid
        fi
        echo "install successfully"
    fi
}