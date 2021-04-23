#!/usr/bin/python

import urllib
import urllib2
import ssl
import json
import copy
from ansible.module_utils.basic import AnsibleModule

def get_user(host, token, name): 
    url = "http://" + host + "/api/users"
    form_values = {'token': token } 
    form_data = urllib.urlencode(form_values) 
    request = urllib2.Request(url, form_data)
    response = urllib2.urlopen(request)
    response_data = response.read() 
    response_json = json.loads(response_data)
    user = next((x for x in response_json['user'] if x['ioName'] == name), None)
    return user

def get_default_user(host, token): 
    url = "http://" + host + "/api/user/Create"
    form_values = {'token': token } 
    form_data = urllib.urlencode(form_values) 
    request = urllib2.Request(url, form_data)
    response = urllib2.urlopen(request)
    response_data = response.read() 
    response_json = json.loads(response_data) 
    return response_json

def create_user(host, token, original, modified): 
    url = "http://" + host + "/api/user/Create"
    form_values = { 'token': token, 
                    'original': original, 
                    'modified': modified } 
    form_data = json.dumps(form_values) 
    opener = urllib2.build_opener(urllib2.HTTPHandler) 
    request = urllib2.Request(url, data=form_data)
    request.add_header('Content-Type', 'application/json')
    request.add_header('Connection', 'keep-alive')
    request.get_method = lambda: 'PUT'     
    response = opener.open(request, timeout=3000)   

def run_module():
    module_args = dict(
        host=dict(type='str', required=True),
        token=dict(type='str', required=True), 
        name=dict(type='str', required=True), 
        password=dict(type='str', required=False),  
        remote=dict(type='bool', required=False), 
    )
  
    result = dict(
        changed=False
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=False
    )
    
    # validate parameters 
    if not module.params['remote'] and not module.params['password']: 
        result['error'] = "user should be set to remote or have a password" 
        result['failed'] = True
        module.exit_json(**result) 

    try: 
        # check if user exists 
        user = get_user(module.params['host'], module.params['token'], module.params['name']) 
        if user: 
            module.exit_json(**result)

        # create user if does not exist 
        user_original = get_default_user(module.params['host'], module.params['token']) 
        user_modified = copy.deepcopy(user_original) 
        user_modified['ioName'] = module.params['name'] 
        if module.params['remote']: 
            user_modified['ioRemoteUser'] = "1" 
        else: 
            user_modified['inPassword'] = module.params['password'] 
            user_modified['inVerifyPassword'] = module.params['password']
        result['changed'] = True
        create_user(module.params['host'], module.params['token'], user_original, user_modified)

    except Exception as e: 
        result['failed'] = True
        result['error'] = e
        module.exit_json(**result)
    
    module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()