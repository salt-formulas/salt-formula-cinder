# -*- coding: utf-8 -*-
import logging
import time
import functools

LOG = logging.getLogger(__name__)

# Import third party libs
HAS_CINDER = False
try:
    from cinderclient.client import Client
    HAS_CINDER = True
except ImportError:
    pass

__opts__ = {}


def __virtual__():
    """
    Only load this module if cinder
    is installed on this minion.
    """
    if HAS_CINDER:
        return 'cinderng'
    return False


def _authng(profile=None):
    """
    Set up cinder credentials
    """
    credentials = {
        'username': profile['user'],
        'password': profile['password'],
        'project_id': profile['project_id'],
        'auth_url': "{}://{}:{}/{}".format(
            profile['protocol'],
            profile['host'],
            profile['port'],
            profile.get('api_version', 'v3')
        ),
        'endpoint_type': profile['endpoint_type'],
        'certificate': profile['certificate'],
        'region_name': profile['region_name'],
        'retries': profile.get('retries', 5)
    }
    return credentials

def retries(func):
    @functools.wraps(func)
    def func_wrapper(*args, **kwargs):
        retries = kwargs.get('retries', 5)
        timeout = kwargs.get('timeout', 5)
        res = None
        for i in range(retries):
            try:
                return func(*args, **kwargs)
            except Exception as e:
                if i == retries - 1:
                    raise e
                else:
                    time.sleep(timeout)
    return func_wrapper

def create_conn(cred=None):
    """
    create connection
    """
    nt = Client(
        '2',
        username=cred['username'],
        api_key=cred['password'],
        project_id=cred['project_id'],
        auth_url=cred['auth_url'],
        endpoint_type=cred['endpoint_type'],
        cacert=cred['certificate'],
        region_name=cred['region_name'],
        retries=cred['retries']
    )
    return nt

@retries
def list_volumes(profile=None, **kwargs):
    """
    Return list of cinder volumes.
    """
    cred = _authng(profile)
    nt = create_conn(cred)
    return nt.volumes.list()

@retries
def list_volume_type(profile=None, **kwargs):
    """
    Return list of volume types
    """
    cred = _authng(profile)
    nt = create_conn(cred)
    return nt.volume_types.list()

@retries
def get_volume_type(type_name, profile=None, **kwargs):
    """
    Returns id of the specified volume type name
    """
    vt_id = None
    vt_list = list_volume_type(profile)
    for vt in vt_list:
        if vt.name == type_name:
            vt_id = vt.id

    if vt_id:
        cred = _authng(profile)
        nt = create_conn(cred)
        try:
            vt = nt.volume_types.get(vt_id)
            return vt
        except:
            return
    else:
        return

@retries
def create_volume_type(type_name, profile=None, **kwargs):
    """
    Create cinder volume type
    """
    vt = get_volume_type(type_name, profile)
    if not vt:
        cred = _authng(profile)
        nt = create_conn(cred)
        try:
            nt.volume_types.create(type_name)
            return 'created'
        except:
            return 'failed'
    else:
        return 'exists'

@retries
def get_keys_volume_type(type_name, profile=None, **kwargs):
    """
    Return extra specs of the specified volume type.
    """

    vt = get_volume_type(type_name, profile)
    if vt:
        try:
            return vt.get_keys()
        except:
            return 'failed'
    else:
        return

@retries
def set_keys_volume_type(type_name, keys={}, profile=None, **kwargs):
    """
    Set extra specs of the specified volume type.
    """
    set_keys = False
    vt = get_volume_type(type_name, profile)
    if vt:
        k = get_keys_volume_type(type_name, profile)
        if not k:
            set_keys = True
        elif k:
            for key in keys:
                if k.get(key) != keys[key]:
                    set_keys = True
        elif len(k) != len(keys):
            set_keys = True
        else:
            return

        if set_keys:
            try:
                vt.set_keys(keys)
                return 'updated'
            except:
                return 'failed'
        else:
            return 'exist'
    else:
        return 'not found'
