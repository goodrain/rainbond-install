[ -f "/etc/docker/daemon.json" ] && rm -rf /etc/docker/daemon.json
systemctl restart docker
systemctl restart salt-master
systemctl restart salt-minion

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
    echo "will install manage node.It will take 15-30 minutes to install"
    for module in ${MANAGE_MODULES}
    do
        if [ "$module" = "plugins" -o "$module" = "proxy" ];then
            echo "Start install $module, it will take 3-8 minutes "
        else
            echo "Start install $module ..."
        fi
        if ! (salt "*" state.sls $module);then
            break
        fi
        sleep 1
    done

    
}

install_func

if [ "$?" -eq 0 ];then
        uuid=$(salt '*' grains.get uuid | grep "-" | awk '{print $1}')
        notready=$(grctl  node list | grep $uuid | grep false)
        if [ "$notready" != "" ];then
            grctl node up $uuid
        fi
    echo "install successfully"
fi