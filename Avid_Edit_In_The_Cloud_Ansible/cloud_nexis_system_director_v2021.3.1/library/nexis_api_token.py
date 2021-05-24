#!/usr/bin/python

import urllib
import urllib2
import ssl
import json
from ansible.module_utils.basic import AnsibleModule

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
    
    auth_url = "http://" + module.params['host'] + "/api/login"

    ssl._create_default_https_context = ssl._create_unverified_context

    form_values = {'user': module.params['username'], 
                    'pass': module.params['password'] } 
    form_data = urllib.urlencode(form_values)
    
    request = urllib2.Request(auth_url, form_data)

    try: 
        response = urllib2.urlopen(request)
        response_data = response.read()
        response_json = json.loads(response_data)
        if not response_json['token'] or not response_json['token']['value'] : 
            result['failed'] = True
            result['error'] = response_data 
        else:
            result['token'] = response_json['token']['value']
    except urllib2.HTTPError as e: 
        result['failed'] = True
        result['error'] = e.read()    

    module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()