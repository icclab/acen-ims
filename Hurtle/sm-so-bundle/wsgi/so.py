"""
IMSaaS SO.

This Service Orchestrator (SO) deploys and provisions Project
Clearwater's components and delivers IMS as-a-service.

Currently, the components can be orchestrated upon
OpenStack and CloudStack platforms (os<->cs, cs<->cs, cs<->os)

Therefore platform types must be one of the following options:
cs - CloudStack platform
os - OpenStack platform
"""

import os
import Crypto.PublicKey
import uuid


from sdk.mcn import util
from sm.so import service_orchestrator
from sm.so.service_orchestrator import LOG

from fabric.api import settings
from fabric.api import sudo


class SOE(service_orchestrator.Execution):

    def __init__(self, token, tenant, attributes):
        super(SOE, self).__init__(token, tenant)
        self.uuid = uuid.uuid4()
        self.stack_id = None

        # TODO parse input params here
        self.platform = 'cs'
        self.region = 'CloudStack'

        self.deployer = util.get_deployer(
            token, url_type='public', tenant_name=tenant,
            region=self.region)

        # Generate management SSH key pair
        self.keypair = Crypto.PublicKey.RSA.generate(2048, os.urandom)
        self.pem_path = '/tmp/%s.PEM' % str(self.uuid)

    def _save_file(self, filepath, data):
        with open(filepath, 'w') as f:
            f.write(data)
        return filepath

    def _delete_file(self, filepath):
        os.remove(filepath)

    def _get_public_key(self):
        return self.keypair.exportKey('OpenSSH')

    def _get_private_key(self):
        return self.keypair.exportKey('PEM')

    def design(self):
        LOG.info('Entered design() - nothing to do here')
        pass

    def deploy(self):
        """Deploy Project Clearwater infrastructure

        Note that the HOT requires providing your environment
        specific details such as VM flavours, available network
        offerings, management ssh & CloudStack APIs keys, etc.
        """
        LOG.info('Deploying...')
        cp = os.path.dirname(os.path.abspath(__file__))
        HOT_dir = os.path.abspath(os.path.join(cp, '../data/'))
        HOT_path = os.path.join(
            HOT_dir, str(self.platform) + '-clearwater-keys.yaml')

        LOG.info('HOT path: %s' % HOT_path)

        params = {}
        LOG.info('Params: %s' % params)

        if self.stack_id is None:
            with open(HOT_path, 'r') as f:
                template = f.read()
            script_path = os.path.join(HOT_dir, 'scripts/inject-key.sh')
            with open(script_path, 'r') as f:
                script = f.read()
            params['script'] = script
            self.stack_id = self.deployer.deploy(
                template, self.token, parameters=params)
            LOG.info('Stack ID: ' + self.stack_id.__repr__())

    def provision(self):
        """ Provision SICs
        Run scripts.
        """
        LOG.info('Calling provision...')

        # TODO get components IPs here
        # self.deployer.details(self.stack_id, self.token)
        # LOG.info('Server IP address: %s' % vpn_server_external_ip)

        # Use fabric to configure endpoints
        # Create temporary PEM file
        self._save_file(self.pem_path, self._get_private_key())
        # TODO run scripts here
        # TODO provision ClearWater components
        # self._run_script()
        self._delete_file(self.pem_path)

    def _run_script(self, script_path, host):
        with settings(host_string=host,
                      user='ubuntu',
                      key_filename=self.pem_path):
            with open(script_path, 'r') as f:
                sudo(f.read())

    def dispose(self):
        """
        Dispose SICs
        """
        LOG.info('Calling dispose...')
        if self.stack_id is not None:
            LOG.debug('Deleting stack: %s' % self.stack_id)
            self.deployer.dispose(self.stack_id, self.token)
            self.stack_id = None

    def state(self):
        """
        Report on state of the stack
        """
        if self.stack_id is not None:
            tmp = self.deployer.details(
                self.stack_id, self.token)
            stack_state = tmp['state']
            LOG.info('Returning stack output')
            # XXX type should be consistent
            output = ''
            try:
                output = tmp['output']
            except KeyError:
                pass

            return stack_state, self.stack_id, output
        else:
            LOG.info('Stack output: none - Unknown, N/A')
            return 'Unknown', 'N/A', None

    def update(self, old, new, extras):
        # TODO implement your own update logic - this could be a heat template
        # update call
        LOG.info('Calling update - nothing to do!')


class SOD(service_orchestrator.Decision):
    """
    Sample Decision part of SO.
    """

    def stop(self):
        pass

    def __init__(self, so_e, token, tenant):
        super(SOD, self).__init__(so_e, token, tenant)

    def run(self):
        """
        Decision part implementation goes here.
        """
        pass


class ServiceOrchestrator(object):
    """
    Sample SO.
    """

    def __init__(self, token, tenant, attributes):
        self.so_e = SOE(token, tenant, attributes)
        self.so_d = SOD(self.so_e, token, tenant)
        # so_d.start()
