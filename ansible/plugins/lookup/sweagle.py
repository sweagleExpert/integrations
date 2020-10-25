# python 3 headers, required if submitting to Ansible
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = """
        lookup: sweagle
        author: Dimitris Finas <dimitris.finas@servicenow.com>
        version_added: "1.0"
        short_description: read content from SWEAGLE
        description:
            - This lookup returns specified configurations variables & values from a SWEAGLE platform.
        options:
          _terms:
            description: CDS = Configuration Data Set to export or search for key/value
            required: true
          sweagle_args:
            description: optional, args to use for exporter selected
            type: string
          sweagle_format:
            description: optional, export format of the configuration
            type: string
            default: "json"
          sweagle_parser:
            description: Exporter used
            type: string
            default: "all"
          sweagle_tag:
            description: Tag of the configuration to retrieve, default is empty meaning latest release
            type: string
            default: ""
          sweagle_tenant:
            description: Tenant to connect to
            type: string
            default: "https://testing.sweagle.com"
          sweagle_token:
            description: API Token used to authenticate
            type: string
          use_proxy:
            description: Flag to control if the lookup will observe HTTP proxy environment variables when present.
            type: boolean
            default: False
        notes:
          - all parameters are optional, they will be replaced by default values in code if not provided.
"""

EXAMPLES = """
- name: return a specific node in a configuration and assign it to a var
- hosts: all
  vars:
     contents: "{{ lookup('sweagle', 'samples-test-dev', sweagle_args='dev', sweagle_parser='returnDataForNode') }}"
  tasks:
     - debug:
         msg: the value of SWEAGLE configuration is {{ contents }}

- name: return a full ConfigDataSet (CDS)
  debug: msg="{{ lookup('sweagle', 'samples-test-dev') }}"

- name: search value of specific key
  debug: msg="{{ lookup('sweagle', 'samples-test-dev', sweagle_args='resource.dev_stack.maxPoolSize', sweagle_parser='returnValueforKey', sweagle_format='raw') }}"
"""

RETURN = """
  _list:
    description: list of configurations calculated by SWEAGLE in json format
"""

from ansible.errors import AnsibleError
#from ansible.module_utils.six.moves.urllib.error import HTTPError, URLError
from ansible.module_utils._text import to_text, to_native
#from ansible.module_utils.urls import open_url, ConnectionError, SSLValidationError
from ansible.plugins.lookup import LookupBase
from ansible.utils.display import Display
import os
import requests

display = Display()


class LookupModule(LookupBase):

    def run(self, terms, variables=None, **kwargs):

        self.set_options(direct=kwargs)

        # Manage input options with default values
        if self.get_option('sweagle_args'):
            sweagle_args = self.get_option('sweagle_args')
        else:
            sweagle_args = ""
        if self.get_option('sweagle_parser'):
            sweagle_parser = self.get_option('sweagle_parser')
        else:
            sweagle_parser = "all"
        if self.get_option('sweagle_format'):
            sweagle_format = self.get_option('sweagle_format')
        else:
            sweagle_format = "json"
        if self.get_option('sweagle_tag'):
            sweagle_tag = self.get_option('sweagle_tag')
        else:
            sweagle_tag = ""
        if self.get_option('sweagle_tenant'):
            sweagle_tenant = self.get_option('sweagle_tenant')
        else:
            sweagle_tenant = "https://testing.sweagle.com"
        if self.get_option('sweagle_token'):
            sweagle_token = self.get_option('sweagle_token')
        else:
            sweagle_token = "ecd7384a-XXXX-XXXX-XXXX-XXXX"

        display.vvvv("[sweagle_lookup]: Lookup with exporter ("+sweagle_parser+") and args ("+sweagle_args+") from SWEAGLE tenant "+sweagle_tenant)

        headers = { 'Authorization': 'Bearer ' + sweagle_token, 'Accept': 'application/json', 'Content-Type': 'application/json' }

        # For future use, add here code to add proxies if required
        if not self.get_option('use_proxy'):
            proxies = { "http": None, "https": None }
            # This is to disable proxy for all hosts as it generates errors on local MacOS at least
            os.environ['no_proxy'] = '*'

        ret = []
        for term in terms:
            display.vvvv("[sweagle_lookup]: Will export Sweagle data from CDS=%s" % term)
            try:
                url = sweagle_tenant+'/api/v1/tenant/metadata-parser/parse?mds=' + term + \
                    '&parser=' + sweagle_parser + \
                    '&format=' + sweagle_format + \
                    '&args=' + sweagle_args + \
                    '&tag=' + sweagle_tag
                display.vvvv("[sweagle_lookup]: url= %s" % url)

                response = requests.post(url, headers=headers, proxies=proxies)
                display.vvvv("[sweagle_lookup]: response code="+ str(response.status_code))
                display.vvvv("[sweagle_lookup]: response headers="+ str(response.headers))
                display.vvvv("[sweagle_lookup]: response content="+ str(response.text))
                display.vvvv("[sweagle_lookup]: proxy= %s" % self.get_option('use_proxy'))

            except HTTPError as e:
                raise AnsibleError("Received HTTP error for %s : %s" % (term, to_native(e)))
            except URLError as e:
                raise AnsibleError("Failed lookup url for %s : %s" % (term, to_native(e)))
            except SSLValidationError as e:
                raise AnsibleError("Error validating the server's certificate for %s: %s" % (term, to_native(e)))
            except ConnectionError as e:
                raise AnsibleError("Error connecting to %s: %s" % (term, to_native(e)))

            ret.append(response.text)
        return ret
