#/bin/bash
#
function global_conf(){
    for index in 0 1; do
        ip=${DR_IPS[${index}]}
        echo """
global_defs {
    notification_email {
       nm@tf.tjiptv.net
    }
    notification_email_from dr-1@tf.tjiptv.net
    smtp_server smtp.tjiptv.net
    smtp_connect_timeout 15
    router_id dr-1.tf.tjiptv.net
}

vrrp_sync_group ${V_NAME2} {
    group {
        ${V_NAME2}
    }
    smtp_alert
    notify_master "/etc/keepalived/master.sh ${VIP2}"
    notify_backup "/etc/keepalived/backup.sh ${VIP2}"
    notify_fault "/etc/keepalived/fault.sh ${VIP2}"
}

vrrp_sync_group ${V_NAME1} {
    group {
        ${V_NAME1}
    }
    smtp_alert
    notify_master "/etc/keepalived/master.sh ${VIP1}"
    notify_backup "/etc/keepalived/backup.sh ${VIP1}"
    notify_fault "/etc/keepalived/fault.sh   ${VIP1}"
}

vrrp_instance ${V_NAME2} {
    state ${STATE[${index}]}
    interface ${NET_IF}
    lvs_sync_daemon_interface ${NET_IF}
    virtual_router_id 140
    priority ${PRIORITY[${index}]}
    preempt_delay 180
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 9999
    }
    virtual_ipaddress {
        ${VIP1}
    }

    smtp_alert
    notify_stop "/etc/keepalived/stop.sh ${VIP2}"
}

vrrp_instance ${V_NAME1} {
    state ${STATE[${index}]}
    interface ${NET_IF}
    lvs_sync_daemon_interface ${NET_IF}
    virtual_router_id 8
    priority ${PRIORITY[${index}]}
    preempt_delay 180
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 2222
    }
    virtual_ipaddress {
        ${VIP2}
    }
    smtp_alert
    notify_stop "/etc/keepalived/stop.sh ${VIP1}"
}

${VIRTUAL_SERVER}

""" > /root/keepalived/keepalived-${index}.conf
        scp /root/keepalived/keepalived-${index}.conf ${ip}:/etc/keepalived/keepalived.conf
    done
}




function virtual_server(){
    VIRTUAL_SERVER=""
    for index in 0 1 2 3; do
        PORT=${PORTS[${index}]}
        RS_IPS=(${RS_IP1} ${RS_IP2})
        HEALTH_CHECK=""
        for index in 0 1; do
            HEALTH_CHECK=${HEALTH_CHECK}"""
    real_server ${RS_IPS[$index]} ${PORT} {
        weight 1
        HTTP_GET {
            url {
              path /
              status_code 200
            }
            connect_timeout 3
            nb_get_retry 2
            delay_before_retry 2
        }
    }
"""
        done

        VIRTUAL_SERVER=${VIRTUAL_SERVER}"""
virtual_server ${VIPS[${index}]} ${PORT} {
    delay_loop 5
    lb_algo sh
    lb_kind DR
    persistence_timeout 30
    protocol TCP

${HEALTH_CHECK}
}
"""
    done
}




source ./keepalived-info
echo """
keepalived-info:
    MASTER_IP:      ${MASTER_IP}
    BACKUP_IP:      ${BACKUP_IP}
    VIP1:           ${VIP1}
    V_NAME1         ${V_NAME1}      
    VIP2:           ${VIP2}
    V_NAME2         ${V_NAME2}
    PORT1           ${PORT1}
    PORT2           ${PORT2}
    PORT3           ${PORT3}
    PORT4           ${PORT4}
    RS_IP1          ${RS_IP1}
    RS_IP1          ${RS_IP1}
    NET_IF:         ${NET_IF}
"""
echo -n 'Please print "yes" to continue or "no" to cancel: '
read AGREE
while [ "${AGREE}" != "yes" ]; do
    if [ "${AGREE}" == "no" ]; then
        exit 0;
    else
        echo -n 'Please print "yes" to continue or "no" to cancel: '
        read AGREE
    fi
done

VIPS=(${VIP1} ${VIP1} ${VIP1} ${VIP2} )
PORTS=(${PORT1} ${PORT2} ${PORT3} ${PORT4})
virtual_server

DR_IPS=(${MASTER_IP} ${BACKUP_IP})
PRIOITY=(100 90)
STATE=("MASTER" "BACKUP")
global_conf
