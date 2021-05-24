#!/usr/bin/python

import urllib
import urllib2
import ssl
import json
import copy
from ansible.module_utils.basic import AnsibleModule

def get_storage_group(host, token, name): 
    url = "http://" + host + "/api/storagegroups"
    form_values = {'token': token } 
    form_data = urllib.urlencode(form_values) 
    request = urllib2.Request(url, form_data)
    response = urllib2.urlopen(request)
    response_data = response.read() 
    response_json = json.loads(response_data) 
    storage_group = next((x for x in response_json['storageGroup'] if x['ioName'] == name), None)   
    return storage_group

def get_default_storage(host, token): 
    url = "http://" + host + "/api/storagegroup/Create"
    form_values = {'token': token } 
    form_data = urllib.urlencode(form_values) 
    request = urllib2.Request(url, form_data)
    response = urllib2.urlopen(request)
    response_data = response.read() 
    response_json = json.loads(response_data) 
    return response_json

def create_storage_group(host, token, original, modified):
    url = "http://" + host + "/api/storagegroup/Create"
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
        ioAccountName=dict(type='str', required=True), 
        ioAccountKey=dict(type='str', required=True), 
        ioSetType=dict(type='str', required=True),
        ioAccountType=dict(type='str', required=True),
        outPerformance=dict(type='str', required=True)
    )
  
    result = dict(
        changed=False
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=False
    )

    try: 
        # check if storage group exists 
        storage_group = get_storage_group(module.params['host'], module.params['token'], module.params['name'])
        if storage_group and storage_group['outID']:
            result['storage_group_id'] = storage_group['outID']
            module.exit_json(**result)

        # create new storage group if not exist 
        original_storage_group = get_default_storage(module.params['host'],module.params['token']) 
        modified_storage_group = copy.deepcopy(original_storage_group)
        modified_storage_group['ioName'] = module.params['name'] 
        modified_storage_group['ioAccountName'] = module.params['ioAccountName']
        modified_storage_group['ioAccountKey'] = module.params['ioAccountKey']
        modified_storage_group['storageElementManagers']['storageElementManager'][0]['ioTypeSe'] = "3" 
        modified_storage_group['ioSetType'] = module.params['ioSetType']
        modified_storage_group['ioAccountType'] = module.params['ioAccountType']
        modified_storage_group['outPerformance'] = module.params['outPerformance']
        result['changed'] = True 
        create_storage_group(module.params['host'],module.params['token'], original_storage_group, modified_storage_group)

        # get storage group id after creation 
        storage_group = get_storage_group(module.params['host'], module.params['token'], module.params['name'])
        if storage_group and storage_group['outID']:
            result['storage_group_id'] = storage_group['outID']
        else: 
            raise Exception("unable to get storage group details after creation")    
    except Exception as e: 
        result['failed'] = True
        result['error'] = e
        module.exit_json(**result)

    module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()