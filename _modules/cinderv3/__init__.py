try:
    import os_client_config
    REQUIREMENTS_MET = True
except ImportError:
    REQUIREMENTS_MET = False
import os
import sys

# i failed to load module witjout this
# seems bugs in salt or it is only me
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

import volume

volume_list = volume.volume_list
volume_type_list = volume.volume_type_list
volume_type_get = volume.volume_type_get
volume_type_create = volume.volume_type_create
volume_type_delete = volume.volume_type_delete
keys_volume_type_get = volume.keys_volume_type_get
keys_volume_type_set = volume.keys_volume_type_set

__all__ = ('volume_list', 'volume_type_list', 'volume_type_get',
           'volume_type_create', 'keys_volume_type_get',
           'keys_volume_type_set', 'volume_type_delete')


def __virtual__():
    if REQUIREMENTS_MET:
        return 'cinderv3'
    else:
        return False, ("The cinderv3 execution module cannot be loaded: "
                       "os_client_config are unavailable.")
