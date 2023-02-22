from pyzabbix import ZabbixAPI, ZabbixAPIException

import time
from datetime import datetime

def zabbix_interfaces(zabbix, db, name, network_prefix="0.0.0.0/0"):
    """
    Get the list of all zabbix interface belonging to the network to associate
    to the device

    :arg pyzabbix.api.ZabbixAPI zabbix: Zabbix API instance
    :arg dict db: netbox database
    :arg str name: device name
    :arg str network_prefix: IP address of the network (e.g., `192.0.2.0/24`).
                             Default is `0.0.0.0/0`

    :returns: list.
    """
    device = db['devices'][name]

    ifaces = []
    # Create as many interface as there are interfaces and IP addresses
    # .. loop over the physical interfaces
    for interface in device['interfaces']:
        # .... loop over their IPs
        for address in interface['ip_addresses']:
            # Extract IP from address
            ip = re.sub('\/\d+', '', address)

            if ip_address(ip) in ip_network(network_prefix):
                # Create an interface
                # TODO add a function to create interfaces of different types
                ifaces.append({"main": "1",
                                "useip": "1",
                                "dns": "",
                                "ip": ip,
                                "type": "1",
                                "port": "10050"
                                })
    return ifaces


def zabbix_groups(zabbix, db, name, create_group=False):
    """
    Get the list of all zabbix groups to associate to the device and optionally
    create it it doesn't exist.

    :arg pyzabbix.api.ZabbixAPI zabbix: Zabbix API instance
    :arg dict db: netbox database
    :arg str name: group name
    :arg bool create_group: wether to create the group if it does not exist.
                            Default is `False`
    
    :returns: list.
    """
    groups = zabbix.hostgroup.get(output=['groupid', 'name'], filter={ 'name': [name] } )

    if create_group and len(groups) == 0:
        res = zabbix.hostgroup.create({'name': name})
        for id in res['groupids']:
            groups.append({'groupid': id, 'name': name})

    return groups

def zabbix_templates(zabbix, db, name):
    """
    Get the list of all zabbix templates to associate to the device

    :arg pyzabbix.api.ZabbixAPI zabbix: Zabbix API instance
    :arg dict db: netbox database
    :arg str name: template name
    
    :returns: list.
    """
    return zabbix.template.get(output=['templateid', 'name'], filter={ 'name': [name] } )

def create_hosts(zabbix, db, network_prefix, host_group_name, template_name):
    """
    Create hosts in Zabbix using the template and added to the host group. If
    the host group doesn't exist, it is created. The interface associated to the
    host is one that has an IP address covered by the prefix. The new host is
    named `device_name`.`host_group`.

    The id of the created hosts is returned.

    :arg pyzabbix.api.ZabbixAPI zabbix: Zabbix API instance
    :arg dict db: netbox database
    :arg str network_prefix: IP address of the network (e.g., `192.0.2.0/24`).
    :arg str host_group_name: group name
    :arg str template_name: template name

    :returns: list.
    """
    # Get the host group (create if not exist)
    groups = zabbix_groups(zabbix=zabbix, db=db, name=host_group_name, create_group=True)

    # Get the template for the host
    templates = zabbix_templates(zabbix=zabbix, db=db, name=template_name)

    # Add every device as host
    hostids = []
    for device_name in db['devices'].keys():
        # Pick one interface of the device
        ifaces = zabbix_interfaces(zabbix=zabbix, db=db, name=device_name, network_prefix=network_prefix)
        if len(ifaces) == 0:
            continue
        iface = [ifaces[0]]


        # Create the host
        host = '{name}.{host_group}'.format(name=device_name, host_group=host_group_name)
        res = zabbix.host.create( host=host,
                            templates=templates,
                            groups=groups,
                            interfaces=iface,
                            description=db['devices'][device_name].get('description', device_name)
                        )
        hostids = hostids + res['hostids']
    return hostids

def getHostIds(zabbix, hosts=None):
    """
    Obtain the zabbix id for hosts. 

    :arg pyzabbix.api.ZabbixAPI zabbix: Zabbix API instance
    :arg list hosts: The list of hostname to get ids for. Default to None.
    :returns dict: key=hostname, value=hostid
    """
    filter = {'host': hosts} if hosts is not None else {}
    res = zabbix.host.get(monitored_hosts=1, output='extend', filter=filter)
    hosts_id = {}
    for host in res:
        hosts_id[host['host']] = host['hostid']
    return hosts_id

def getPowerHistory(zabbix, hosts_id, pdu, outlet, duration=12):
    """
    Get the history of power consumption for the host. Each entry of the result
    is the timestamp of the measurement and the value of the measurement.

    :arg pyzabbix.api.ZabbixAPI zabbix: Zabbix API instance
    :arg dict hosts_id: the netbox hostname => zabbix host_id mapping
    :arg str pdu: the hostname of the pdu
    :arg str outlet: the outlet name on the pdu
    :arg int duration: the duration in hours of the period of measurements
                       (since current time, i.e., now - duration). Default to 12
    :returns: list.
    """
    # now 
    time_till = int(time.mktime(datetime.now().timetuple()))
    # now - duration hours
    time_from = int(time_till - (60 * 60 * duration))

    host_id = hosts_id['{}.inria-net'.format(pdu)]
    metric = 'power[{}]'.format(outlet)
    items = zabbix.item.get(monitored=True,output=['itemid'],filter={'key_': metric, 'hostid': host_id})

    history = []

    if len(items) > 0:
        item_id = items[0]['itemid']
        history = zabbix.history.get(
            itemids=[item_id],
            time_from=time_from,
            time_till=time_till,
            output=['value', 'clock']
        )
    return history