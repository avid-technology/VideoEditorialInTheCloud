#!/usr/bin/python

import urllib
import urllib2
import ssl
import json
import copy
from ansible.module_utils.basic import AnsibleModule

def get_admin_token(host, username, password): 
    url = "http://" + host + "/api/login"
    form_values = {'user': username, 
                    'pass': password } 
    form_data = urllib.urlencode(form_values) 
    request = urllib2.Request(url, form_data)
    try: 
        response = urllib2.urlopen(request, timeout=3000)
        response_data = response.read() 
        response_json = json.loads(response_data)
        return response_json['token']
    except urllib2.HTTPError as e: 
        ""

def set_admin_password(host, token, password): 
    url = "http://" + host + "/api/adminpw"
    form_values = { 'token': token,
                    'params': {
                        'old': "", 
                        'new': password, 
                        'verify': password
                    } } 
    form_data = json.dumps(form_values) 
    opener = urllib2.build_opener(urllib2.HTTPHandler) 
    request = urllib2.Request(url, data=form_data)
    request.add_header('Content-Type', 'application/json')
    request.add_header('Connection', 'keep-alive')
    request.get_method = lambda: 'PUT'     
    response = opener.open(request, timeout=3000)
    response_data = response.read()
    response_json = json.loads(response_data)
    # if not response_json['changePassword_result'] or response_json['changePassword_result']['result'] != "Success": 
    #     error_message = "Unable to change admin password. Got response from nexis: " + response_data
    #     raise Exception(error_message)

def run_module():
    module_args = dict(
        host=dict(type='str', required=True),        
        token=dict(type='str', required=True),
        password=dict(type='str', required=True)
    )
  
    result = dict(
        changed=False
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=False
    )

    try:
        # by default, nexis allows administrator to login with empty password
        # check if password is not set by logging in with empty password

        empty_password_login_token = get_admin_token(module.params['host'], "administrator", "") 
        if empty_password_login_token:
            set_admin_password(module.params['host'], module.params['token'], module.params['password'])
            result['changed'] = True
        else:
            admin_token = get_admin_token(module.params['host'], "administrator", module.params['password'])
            if not admin_token:
                result['failed'] = True
                result['error'] = "Administrator password set to something other than password provided"

    except Exception as e: 
        result['failed'] = True
        result['error'] = e

    module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()