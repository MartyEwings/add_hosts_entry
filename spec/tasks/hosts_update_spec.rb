# frozen_string_literal: true

require 'spec_helper'
require 'json'
require 'open3'
require 'tempfile'

# Unit tests for the add_hosts_entry::hosts_update task.
#
# These cover two things:
#   1. The task / module metadata is well-formed and points at real files.
#   2. The POSIX shell implementation behaves correctly (adds an entry,
#      is idempotent, and fails cleanly on bad input).
describe 'add_hosts_entry::hosts_update' do
  module_root = File.expand_path('../..', __dir__)

  describe 'task metadata' do
    let(:task) { JSON.parse(File.read(File.join(module_root, 'tasks', 'hosts_update.json'))) }

    it 'is valid JSON with a description' do
      expect(task['description']).to be_a(String)
      expect(task['description']).not_to be_empty
    end

    it 'declares the required m_ip and m_host parameters' do
      expect(task['parameters']).to include('m_ip', 'm_host')
    end

    it 'references implementation files that exist on disk' do
      task['implementations'].each do |impl|
        path = File.join(module_root, 'tasks', impl['name'])
        expect(File).to exist(path), "expected implementation #{impl['name']} to exist"
      end
    end
  end

  describe 'module metadata' do
    let(:metadata) { JSON.parse(File.read(File.join(module_root, 'metadata.json'))) }

    it 'requires a Puppet version compatible with current PE and Puppet core (7.x / 8.x)' do
      puppet_req = metadata['requirements'].find { |r| r['name'] == 'puppet' }
      expect(puppet_req['version_requirement']).to eq('>= 7.0.0 < 9.0.0')
    end

    it 'supports modern Linux and Windows operating systems' do
      supported = metadata['operatingsystem_support'].map { |os| os['operatingsystem'] }
      expect(supported).to include('RedHat', 'Ubuntu', 'Debian', 'windows')
    end
  end

  describe 'POSIX shell implementation' do
    let(:script) { File.join(module_root, 'tasks', 'hosts_update_linux.sh') }
    let(:hosts) { Tempfile.new('hosts') }

    after(:each) { hosts.close! }

    # Run the task script the way Bolt does: parameters via PT_ env vars.
    def run_task(env)
      Open3.capture2e(env, 'sh', script)
    end

    it 'has a POSIX /bin/sh shebang and no bashisms' do
      contents = File.read(script)
      expect(contents.lines.first).to eq("#!/bin/sh\n")
      expect(contents).not_to match(%r{^\s*declare\s})
    end

    it 'appends the entry to the hosts file' do
      output, status = run_task('PT_m_ip' => '10.10.10.1', 'PT_m_host' => 'master.puppet.com', 'PT_hosts_file' => hosts.path)
      expect(status).to be_success
      expect(output).to match(%r{Added})
      expect(File.read(hosts.path)).to include('10.10.10.1 master.puppet.com')
    end

    it 'is idempotent and does not add duplicate entries' do
      env = { 'PT_m_ip' => '10.10.10.1', 'PT_m_host' => 'master.puppet.com', 'PT_hosts_file' => hosts.path }
      run_task(env)
      output, status = run_task(env)
      expect(status).to be_success
      expect(output).to match(%r{already present})
      expect(File.read(hosts.path).scan('10.10.10.1 master.puppet.com').length).to eq(1)
    end

    it 'fails with a structured error when m_ip is missing' do
      output, status = run_task('PT_m_host' => 'master.puppet.com', 'PT_hosts_file' => hosts.path)
      expect(status).not_to be_success
      expect(output).to include('_error')
      expect(output).to include('m_ip')
    end

    it 'fails with a structured error when m_host is missing' do
      output, status = run_task('PT_m_ip' => '10.10.10.1', 'PT_hosts_file' => hosts.path)
      expect(status).not_to be_success
      expect(output).to include('_error')
      expect(output).to include('m_host')
    end
  end
end
