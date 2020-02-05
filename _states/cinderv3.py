"""
Management of Cinder resources
"""

import ast
import logging

LOG = logging.getLogger(__name__)


def __virtual__():
    return 'cinderv3'


def _cinder_call(fname, *args, **kwargs):
    return __salt__['cinderv3.{}'.format(fname)](*args, **kwargs)


def volume_type_present(name=None, cloud_name=None):
    """
    Ensures that the specified volume type is present.
    """
    ret = {
        'name': name,
        'changes': {},
        'result': True,
        'comment': 'Volume type "{0}" already exists'.format(name)
    }
    type_req = _cinder_call('volume_type_get', name=name, cloud_name=cloud_name)
    if type_req.get("result"):
        return ret
    else:
        create_req = _cinder_call('volume_type_create', name=name,
                                  cloud_name=cloud_name)
        if create_req.get("result") is False:
            ret = {
                'name': name,
                'changes': {},
                'result': False,
                'comment': 'Volume type "{0}" failed to create'.format(name)
            }
        else:
            ret['comment'] = 'Volume type {0} has been created'.format(name)
            ret['changes']['Volume type'] = 'Created'
        return ret


def volume_type_absent(name=None, cloud_name=None):
    """
    Ensures that the specified volume type is absent.
    """
    ret = {
        'name': name,
        'changes': {},
        'result': True,
        'comment': 'Volume type "{0}" not found'.format(name)
    }
    type_req = _cinder_call('volume_type_get', name=name, cloud_name=cloud_name)
    if not type_req.get("result"):
        return ret
    else:
        delete_req = _cinder_call('volume_type_delete', name=name,
                                  cloud_name=cloud_name)
        if delete_req.get("result") is False:
            ret = {
                'name': name,
                'changes': {},
                'result': False,
                'comment': 'Volume type "{0}" failed to delete'.format(name)
            }
        else:
            ret['comment'] = 'Volume type {0} has been deleted'.format(name)
            ret['changes']['Volume type'] = 'Deleted'
        return ret


def volume_type_key_present(name=None, key=None, value=None, cloud_name=None):
    """
    Ensures that the extra specs are present on a volume type.
    """
    keys = "{u'" + key + "': u'" + value + "'}"
    keys = ast.literal_eval(keys)
    signal_create = _cinder_call('keys_volume_type_set',
                                 name=name, keys=keys, cloud_name=cloud_name)
    if signal_create["result"] is True:
        ret = {
            'name': name,
            'changes': keys,
            'result': True,
            'comment': 'Volume type "{0}" was updated'.format(name)
        }
    else:
        ret = {
            'name': name,
            'changes': {},
            'result': False,
            'comment': signal_create.get("comment")
        }
    return ret
