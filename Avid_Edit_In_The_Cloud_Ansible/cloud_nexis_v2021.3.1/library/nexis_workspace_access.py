#!/usr/bin/python

import urllib
import urllib2
import ssl
import json
from ansible.module_utils.basic import AnsibleModule

def run_module():
    module_args = dict(
        host=dict(type='str', required=True),
        token=dict(type='str', required=True), 
        user=dict(type='str', required=True), 
        workspace=dict(type='str', required=True), 
        access=dict(type='str', required=True)
    )
  
    result = dict(
        changed=False
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=False
    )
    
    # list users 
    response_json = ""
    
    url = "http://" + module.params['host'] + "/api/users"
    form_values = {'token': module.params['token'] } 
    form_data = urllib.urlencode(form_values)    
    request = urllib2.Request(url, form_data)
    try: 
        response = urllib2.urlopen(request)
        response_data = response.read()
        response_json = json.loads(response_data)

    except urllib2.HTTPError as e: 
        result['failed'] = True
        result['error'] = e.read()    

    # find user from a list 
    user = next((x for x in response_json['user'] if x['ioName'] == module.params['user']), None)
    if user == None or not user['outID'] :
        result['failed'] = True
        result['error'] = "user was not found" 

    # get user details 
    updated_user = ""
    url = "http://" + module.params['host'] + "/api/user/" + user['outID']
    form_values = {'token': module.params['token'] } 
    form_data = urllib.urlencode(form_values)    
    request = urllib2.Request(url, form_data)
    try: 
        response = urllib2.urlopen(request)
        response_data = response.read()
        response_json = json.loads(response_data) 
        updated_user = json.loads(response_data)

    except urllib2.HTTPError as e: 
        result['failed'] = True
        result['error'] = e.read()    

    # update user
    workspace = next((x for x in updated_user['workspaceAccesses']['access'] if x['outName'] == module.params['workspace']), None)
    if workspace == None or not workspace['outID'] :
        result['failed'] = True
        result['error'] = "workspace was not found" 
    
    if workspace['ioAccess'] == module.params['access']: 
        module.exit_json(**result)
  
    workspace['ioAccess'] = module.params['access']      
    updated_user['workspaceAccesses']['access'] = [workspace]    

    create_user_form_values = {
        'token': module.params['token'], 
        'original': response_json ,
        'modified': updated_user
    }
    result['val'] = create_user_form_values

    url = "http://" + module.params['host'] + "/api/user/" + user['outID']

    form_data = json.dumps(create_user_form_values)  
    opener = urllib2.build_opener(urllib2.HTTPHandler) 
    
    request = urllib2.Request(url, data=form_data)
    request.add_header('Content-Type', 'application/json')
    request.get_method = lambda: 'PUT'
   
    try:         
        response = opener.open(request)
        response_data = response.read()
        result['changed'] = True
        result['response'] = response_data
    except urllib2.HTTPError as e: 
        result['failed'] = True
        result['error'] = e.read()    

    module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()