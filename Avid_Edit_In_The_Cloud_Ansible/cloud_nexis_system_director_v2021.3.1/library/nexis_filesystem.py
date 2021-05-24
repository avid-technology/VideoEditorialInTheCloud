#!/usr/bin/python

import urllib
import urllib2
import ssl
import json
from ansible.module_utils.basic import AnsibleModule

def get_admin_token_body(host, username, password): 
    url = "http://" + host + "/api/login"
    form_values = {'user': username, 
                    'pass': password } 
    form_data = urllib.urlencode(form_values) 
    request = urllib2.Request(url, form_data)
    response = urllib2.urlopen(request)
    response_data = response.read() 
    return response_data 

def create_file_system(host, token): 
    url = "http://" + host + "/api/fs/new"
    form_values = {'token': token } 
    form_data = json.dumps(form_values) 
    opener = urllib2.build_opener(urllib2.HTTPHandler) 
    request = urllib2.Request(url, data=form_data)
    request.add_header('Content-Type', 'application/json')
    request.add_header('Connection', 'keep-alive')
    request.get_method = lambda: 'PUT'     
    response = opener.open(request, timeout=3000)
    response_data = response.read()
    response_json = json.loads(response_data)
    if not response_json['result'] or response_json['result'] != 'Success':
        raise Exception(response_data)

def run_module():
    module_args = dict(
        host=dict(type='str', required=True),        
        username=dict(type='str', required=True),
        password=dict(type='str', required=True) 
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
        token = ""
        # get token and check if file system exists
        get_token_data = get_admin_token_body(module.params['host'], module.params['username'],module.params['password'])
        get_token_json = json.loads(get_token_data)

        if not get_token_json['token'] or not get_token_json['token']['value'] : 
            result['error'] = "unable to get token. Nexis response: " + get_token_data
            result['failed'] = True
            module.exit_json(**result)
        else:
            token = get_token_json['token']['value']

        if not get_token_json['fsStateFileReason']: 
            result['error'] = "unable to get file system status. Nexis response: " + get_token_data
            result['failed'] = True
            module.exit_json(**result)
        if get_token_json['fsStateFileReason'] == "File system is found.": 
            module.exit_json(**result) 
        
        # create a new filesystem
        result['changed'] = True
        create_file_system(module.params['host'], token)
    except Exception as e: 
        result['failed'] = True
        result['error'] = e
        module.exit_json(**result)

    module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()