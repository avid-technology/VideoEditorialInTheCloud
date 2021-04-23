#!/usr/bin/python

import urllib
import urllib2
import ssl
import json
import copy
from ansible.module_utils.basic import AnsibleModule

def get_workspace(host, token, name): 
    url = "http://" + host + "/api/workspaces"
    form_values = {'token': token } 
    form_data = urllib.urlencode(form_values) 
    request = urllib2.Request(url, form_data)
    response = urllib2.urlopen(request)
    response_data = response.read() 
    response_json = json.loads(response_data)
    workspace = next((x for x in response_json['workspace'] if x['ioName'] == name), None) 
    return workspace 

def get_workspace_id(outId): 
    # no explanations from my side can be added here, just this is how it works.
    # nore datails can be found in this story: 
    # https://avid-ondemand.atlassian.net/browse/ECD-617
    # (note: 4294967295 is a hex representation of FFFFFFFF)
    return int(outId) & 4294967295

def get_default_workpace(host, token): 
    url = "http://" + host + "/api/workspace/Create"
    form_values = {'token': token } 
    form_data = urllib.urlencode(form_values) 
    request = urllib2.Request(url, form_data)
    response = urllib2.urlopen(request)
    response_data = response.read() 
    response_json = json.loads(response_data) 
    return response_json

def create_workspace(host, token, original, modified):
    url = "http://" + host + "/api/workspace/Create"
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
        size=dict(type='str', required=True)
    )
  
    result = dict(
        changed=False
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=False
    )

    try:
        # check if workspace exists 
        workspace = get_workspace(module.params['host'], module.params['token'], module.params['name']) 
        if workspace:
            result['id'] = get_workspace_id(workspace['outID']) 
            module.exit_json(**result)

        # create workspace 
        workspace_original = get_default_workpace(module.params['host'], module.params['token'])
        workspace_modified = copy.deepcopy(workspace_original) 
        workspace_modified['ioName'] = module.params['name'] 
        workspace_modified['ioByteCount'] = module.params['size'] 
        result['changed'] = True 
        create_workspace(module.params['host'], module.params['token'], workspace_original, workspace_modified)

        # get workspace details
        workspace = get_workspace(module.params['host'], module.params['token'], module.params['name']) 
        if not workspace: 
            raise Exception("unable to get workspace details after creation") 
        result['id'] = get_workspace_id(workspace['outID']) 

    except Exception as e: 
        result['failed'] = True
        result['error'] = e
        module.exit_json(**result)

    module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()