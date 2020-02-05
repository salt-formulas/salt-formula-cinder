from __future__ import absolute_import

import common

try:
    from urllib.parse import urlencode
except ImportError:
    from urllib import urlencode


@common.send("get")
def volume_list(**kwargs):
    """
    Return list of cinder volumes.
    """
    url = '/volumes?{}'.format(urlencode(kwargs))
    return url, {}


@common.send("get")
def volume_type_list(**kwargs):
    """
    Return list of volume types
    """
    url = '/types?{}'.format(urlencode(kwargs))
    return url, {}


@common.get_by_name_or_uuid(volume_type_list, 'volume_types')
@common.send("get")
def volume_type_get(volume_type_id, **kwargs):
    """
    Returns id of the specified volume type name
    """
    url = "/types/{volume_type_id}".format(volume_type_id=volume_type_id)
    return url, {}


@common.get_by_name_or_uuid(volume_type_list, 'volume_types')
@common.send("delete")
def volume_type_delete(volume_type_id, **kwargs):
    """
    delete the specified volume type
    """
    url = "/types/{volume_type_id}".format(volume_type_id=volume_type_id)
    return url, {}


@common.send("post")
def volume_type_create(name, **kwargs):
    """
    Create cinder volume type
    """
    url = "/types"
    req = {"volume_type": {"name": name}}
    return url, {'json': req}


@common.get_by_name_or_uuid(volume_type_list, 'volume_types')
@common.send("get")
def keys_volume_type_get(volume_type_id, **kwargs):
    """
    Return extra specs of the specified volume type.
    """
    url = "/types/{volume_type_id}/extra_specs".format(
        volume_type_id=volume_type_id)
    return url, {}


@common.send("put")
def _key_volume_type_set(type_id, key, value, **kwargs):
    url = "/types/{volume_type_id}/extra_specs/{key}".format(
        volume_type_id=type_id, key=key)
    return url, {'json': {str(key): str(value)}}


@common.get_by_name_or_uuid(volume_type_list, 'volume_types')
def keys_volume_type_set(volume_type_id, keys=None, **kwargs):
    """
    Set extra specs of the specified volume type.
    """
    if keys is None:
        keys = {}
    cloud_name = kwargs["cloud_name"]
    cur_keys = keys_volume_type_get(
        volume_type_id, cloud_name=cloud_name)["extra_specs"]

    for k, v in keys.items():
        if (k, v) in cur_keys.items():
            continue
        resp = _key_volume_type_set(volume_type_id, k, v, cloud_name=cloud_name)
        if resp.get("result") is False:
            return resp

    return {"result": True}
