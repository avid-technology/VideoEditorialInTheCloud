#!/usr/bin/python

import urllib
import urllib2
import ssl
import json
import copy
from ansible.module_utils.basic import AnsibleModule

def get_default_user_group(host, token):
    """Get nexis user group default data.

    Args:
        token (str): nexis session token
        host (str): nexis server host

    Returns: 
        default_user_group (dict): default user group data
    """
    url = "http://" + host + "/api/usergroup/Create"
    form_values = {'token': token } 
    form_data = urllib.urlencode(form_values) 
    request = urllib2.Request(url, form_data)
    response = urllib2.urlopen(request)
    response_data = response.read() 
    return json.loads(response_data)

def create_user_group(host, token, original, modified):
    """Creates a user group in nexis.

    Args:
        token (str): nexis session token
        host (str): nexis server host
        original (dict): nexis user group default data
        modified (dict): nexis user group data used for user group creation
    """
    url = "http://" + host + "/api/usergroup/Create"
    form_values = {'token': token, 'original': original, 'modified': modified } 
    form_data = json.dumps(form_values) 
    opener = urllib2.build_opener(urllib2.HTTPHandler) 
    request = urllib2.Request(url, data=form_data)
    request.add_header('Content-Type', 'application/json')
    request.add_header('Connection', 'keep-alive')
    request.get_method = lambda: 'PUT'     
    response = opener.open(request, timeout=3000)

def get_user_groups(host, token):
    """Get list of nexis users groups.

    Args:
        token (str): nexis session token
        host (str): nexis server host

    Returns: 
        user_list (list): list of nexis users groups
    """
    url = "http://" + host + "/api/usergroups"
    form_values = {'token': token } 
    form_data = urllib.urlencode(form_values) 
    request = urllib2.Request(url, form_data)
    response = urllib2.urlopen(request)
    response_data = response.read() 
    return json.loads(response_data)

def run_module():
    module_args = dict(
        host=dict(type='str', required=True),
        token=dict(type='str', required=True),
        group_name=dict(type='str', required=True), 
        wsadmin=dict(type='bool', required=False)
    )

    result = dict(
        changed=False
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=False
    )

    ssl._create_default_https_context = ssl._create_unverified_context

    try:
        # get default user group atributes
        default_user_group = get_default_user_group(module.params["host"], module.params["token"])

        original_user_group = copy.deepcopy(default_user_group)
        modified_user_group = copy.deepcopy(default_user_group)

        modified_user_group["ioName"] = module.params["group_name"]
        if module.params.get("wsadmin"):
            modified_user_group["ioRoleFlags"] = "wsadmin"

        create_user_group(module.params["host"], module.params["token"], original_user_group, modified_user_group)
        user_groups = get_user_groups(module.params["host"], module.params["token"])

        created_user_group_id = next((group["outID"] for group in user_groups['user'] if group['ioName'] == module.params['group_name']), None)
        if created_user_group_id == None:
            raise Exception("created user group id not found")

        result['changed'] = True
        result['user_group_id'] = created_user_group_id

        module.exit_json(**result)


    except urllib2.HTTPError as e:
        result['failed'] = True
        result['error'] = e.read()
        module.exit_json(**result)
    except Exception as e:
        result['failed'] = True
        result['error'] = str(e)
        module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()
