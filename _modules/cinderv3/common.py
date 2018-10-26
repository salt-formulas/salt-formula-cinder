import six
import logging
import uuid
import time

import os_client_config
from salt import exceptions


log = logging.getLogger(__name__)

SERVICE_KEY = 'volumev3'


def get_raw_client(cloud_name):
    config = os_client_config.OpenStackConfig()
    cloud = config.get_one_cloud(cloud_name)
    adapter = cloud.get_session_client(SERVICE_KEY)
    try:
        access_info = adapter.session.auth.get_access(adapter.session)
        endpoints = access_info.service_catalog.get_endpoints()
    except (AttributeError, ValueError) as exc:
        six.raise_from(exc, exceptions.SaltInvocationError(
            "Cannot load keystoneauth plugin. Please check your environment "
            "configuration."))
    if SERVICE_KEY not in endpoints:
        raise exceptions.SaltInvocationError("Cannot find cinder endpoint in "
                                             "environment endpoint list.")
    return adapter


def send(method):
    def wrap(func):
        @six.wraps(func)
        def wrapped_f(*args, **kwargs):
            cloud_name = kwargs.pop('cloud_name', None)
            connect_retries = 30
            connect_retry_delay = 1
            if not cloud_name:
                raise exceptions.SaltInvocationError(
                    "No cloud_name specified. Please provide cloud_name "
                    "parameter")
            adapter = get_raw_client(cloud_name)
            kwarg_keys = list(kwargs.keys())
            for k in kwarg_keys:
                if k.startswith('__'):
                    kwargs.pop(k)
            url, request_kwargs = func(*args, **kwargs)
            response = None
            for i in range(connect_retries):
                try:
                  response = getattr(adapter, method.lower())(
                      url, connect_retries=connect_retries,
                      **request_kwargs)
                except Exception as e:
                    if hasattr(e, 'http_status') and (e.http_status >= 500
                        or e.http_status == 0):
                        msg = ("Got retriable exception when contacting "
                               "Cinder API. Sleeping for %ss. Attepmpts "
                               "%s of %s")
                        log.error(msg % (connect_retry_delay, i, connect_retries))
                        time.sleep(connect_retry_delay)
                        continue
                break
            if not response or not response.content:
                return {}
            try:
                resp = response.json()
            except ValueError:
                resp = response.content
            return resp
        return wrapped_f
    return wrap


def _check_uuid(val):
    try:
        return str(uuid.UUID(val)) == val
    except (TypeError, ValueError, AttributeError):
        return False


def get_by_name_or_uuid(resource_list, resp_key):
    def wrap(func):
        @six.wraps(func)
        def wrapped_f(*args, **kwargs):
            if 'name' in kwargs:
                ref = kwargs.pop('name', None)
                start_arg = 0
            else:
                start_arg = 1
                ref = args[0]
            item_id = None
            if _check_uuid(ref):
                item_id = ref
            else:
                cloud_name = kwargs['cloud_name']
                # seems no filtering on volume type name in cinder
                resp = resource_list(cloud_name=cloud_name)[resp_key]
                # so need to search in list directly
                for item in resp:
                    if item["name"] == ref:
                        if item_id is not None:
                            msg = ("Multiple resource: {resource} "
                                   "with name: {name} found ").format(
                                    resource=resp_key, name=ref)
                            return {"result": False,
                                    "body": msg,
                                    "status_code": 400}
                        item_id = item["id"]
                if not item_id:
                    msg = ("Uniq {resource} resource "
                           "with name={name} not found.").format(
                            resource=resp_key, name=ref)
                    return {"result": False,
                            "body": msg,
                            "status_code": 404}
            return func(item_id, *args[start_arg:], **kwargs)
        return wrapped_f
    return wrap
