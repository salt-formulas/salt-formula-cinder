# -*- coding: utf-8 -*-
"""
Management of Cinder resources
===============================
:depends:   - cinderclient Python module
"""

import ast
import logging

LOG = logging.getLogger(__name__)


def __virtual__():
    """
    Only load if python-cinderclient is present in __salt__
    """
    return 'cinderng'


def volume_type_present(name=None, profile=None):
    """
    Ensures that the specified volume type is present.
    """
    ret = {
        'name': name,
        'changes': {},
        'result': True,
        'comment': 'Volume type "{0}" already exists'.format(name)
    }
    signal = __salt__['cinderng.create_volume_type'](name, profile)
    if 'exists' in signal:
        pass
    elif 'created' in signal:
        ret['comment'] = 'Volume type {0} has been created'.format(name)
        ret['changes']['Volume type'] = 'Created'
    elif 'failed' in signal:
        ret = {
            'name': name,
            'changes': {},
            'result': False,
            'comment': 'Volume type "{0}" failed to create'.format(name)
        }
    return ret


def volume_type_key_present(name=None, key=None, value=None, profile=None):
    """
    Ensures that the extra specs are present on a volume type.
    """
    keys = "{u'" + key + "': u'" + value + "'}"
    keys = ast.literal_eval(keys)
    ret = {
        'name': name,
        'changes': {},
        'result': True,
        'comment': 'Volume type keys "{0}" '
                   'in volume type "{1}" already exist'.format(keys, name)
    }
    signal = __salt__['cinderng.set_keys_volume_type'](name, keys, profile)
    if 'exist' in signal:
        pass
    elif 'updated' in signal:
        ret['comment'] = 'Volume type keys "{0}" in volume type "{1}" ' \
                         'have been updated'.format(keys, name)
        ret['changes']['Volume type keys'] = 'Updated'
    elif 'failed' in signal:
        ret = {
            'name': name,
            'changes': {},
            'result': False,
            'comment': 'Volume type keys "{0}" in volume type "{1}" '
                       'failed to update'.format(keys, name)
        }
    elif 'not found' in signal:
        ret = {
            'name': name,
            'changes': {},
            'result': False,
            'comment': 'Volume type "{0}" was not found'.format(name)
        }
    return ret


def _already_exists(name, resource):
    changes_dict = {
        'name': name,
        'changes': {},
        'result': True,
        'comment': '{0} {1} already exists'.format(resource, name)
    }
    return changes_dict


def _created(name, resource, resource_definition):
    changes_dict = {
        'name': name,
        'changes': resource_definition,
        'result': True,
        'comment': '{0} {1} created'.format(resource, name)
    }
    return changes_dict


def _updated(name, resource, resource_definition):
    changes_dict = {
        'name': name,
        'changes': resource_definition,
        'result': True,
        'comment': '{0} {1} tenant was updated'.format(resource, name)
    }
    return changes_dict


def _update_failed(name, resource):
    changes_dict = {
        'name': name,
        'changes': {},
        'comment': '{0} {1} failed to update'.format(resource, name),
        'result': False
    }
    return changes_dict


def _no_change(name, resource, test=False):
    changes_dict = {'name': name,
                    'changes': {},
                    'result': True}
    if test:
        changes_dict['comment'] = \
            '{0} {1} will be {2}'.format(resource, name, test)
    else:
        changes_dict['comment'] = \
            '{0} {1} is in correct state'.format(resource, name)
    return changes_dict
