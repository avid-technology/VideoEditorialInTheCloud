#!/usr/bin/python

import urllib
import urllib2
import ssl
import json
import copy
from ansible.module_utils.basic import AnsibleModule

def get_default_mediapack(host, token): 
    url = "http://" + host + "/api/mediapacks"
    form_values = {'token': token } 
    form_data = urllib.urlencode(form_values) 
    request = urllib2.Request(url, form_data)
    response = urllib2.urlopen(request)
    response_data = response.read() 
    response_json = json.loads(response_data) 
    if not response_json['storageElementManager'] or len(response_json['storageElementManager']) < 1: 
        error_message = "unable to list mediapacks. Nexis response: " + response_data
        raise Exception(error_message)     
    return response_json['storageElementManager'][0]['outID']

def get_media_pack(host, token, mediapack_id): 
    url = "http://" + host + "/api/mediapack/" + mediapack_id
    form_values = {'token': token } 
    form_data = urllib.urlencode(form_values) 
    request = urllib2.Request(url, form_data)
    response = urllib2.urlopen(request)
    response_data = response.read() 
    response_json = json.loads(response_data) 
    if not response_json['type'] or response_json['type'] != "StorageElementManagerDetails": 
        error_message = "unable to get mediapack. Nexis response: " + response_data
        raise Exception(error_message)     
    return response_json

def update_media_pack(host, token, mediapack_id, original, modified):
    url = "http://" + host + "/api/mediapack/bind/" + mediapack_id
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
        mediapack_id=dict(type='str', required=False)
    )
  
    result = dict(
        changed=False
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=False
    )

    try: 
    # if True: 
        # get default mediapack id if was not passed
        mediapack_id = module.params['mediapack_id']
        if not mediapack_id: 
            mediapack_id = get_default_mediapack(module.params['host'], module.params['token']) 

        # add mediapack id to module output
        result['mediapack_id'] = mediapack_id 

        # get mediapack details     
        media_pack_original = get_media_pack(module.params['host'], module.params['token'], mediapack_id) 
        
        # check if mediapack properties: check if mediapack is already bound 
        if media_pack_original['ioType'] == "2": 
            module.exit_json(**result)
        
        result['changed'] = True
        # check if mediapack properties: check if mediapack is orphaned
        if media_pack_original['ioType'] == "2": 
            # reset orphaned media pack = set ioType to 3
            media_pack_modified = copy.deepcopy(media_pack_original) 
            media_pack_modified['ioType'] = 3 
            update_media_pack(module.params['host'], module.params['token'], mediapack_id, media_pack_original, media_pack_modified)
            media_pack_original = get_media_pack(module.params['host'], module.params['token'], mediapack_id)

        # bound mediapack    
        media_pack_modified = copy.deepcopy(media_pack_original) 
        media_pack_modified['inProtectScheme'] = media_pack_original['outSupportedProtectScheme']
        media_pack_modified['ioCnfgStripSize'] = "19" 
        media_pack_modified['ioType'] = "2"
        update_media_pack(module.params['host'], module.params['token'], mediapack_id, media_pack_original, media_pack_modified)

    except Exception as e: 
        result['failed'] = True
        result['error'] = e
        module.exit_json(**result)

    module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()