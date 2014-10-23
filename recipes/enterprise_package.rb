#
# Author:: Benjamin Black (<b@b3k.us>), Sean Cribbs (<sean@basho.com>),
# and Seth Thomas (<sthomas@basho.com>), Hector Castro (<hector@basho.com>)
# Cookbook Name:: riak
# Recipe:: enterprise_package
#
# Copyright (c) 2014 Basho Technologies, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
version_str = %w(major minor incremental).map { |ver| node['riak']['package']['version'][ver] }.join('.')
major_minor = %w(major minor).map { |ver| node['riak']['package']['version'][ver] }.join('.')
base_uri = "#{node['riak']['package']['url']}/#{node['riak']['package']['enterprise_key']}/#{major_minor}/#{version_str}/"
base_filename = "riak-ee-#{version_str}"
platform_version = node['platform_version'].to_i
checksum_val = node['riak']['package']['enterprise']['checksum']

case node['platform_family']
when 'debian'
  machines = { 'x86_64' => 'amd64', 'i386' => 'i386', 'i686' => 'i386' }
  package_file = "#{base_filename.gsub(/\-/, '_').sub(/_/, '-')}-#{node['riak']['package']['version']['build']}_#{machines[node['kernel']['machine']]}.deb"

  if node['platform'] == 'ubuntu'
    base_uri = "#{base_uri}#{node['platform']}/#{node['lsb']['codename']}/"

    package 'libssl0.9.8' do
      action :install
    end
  elsif node['platform'] == 'debian'
    base_uri = "#{base_uri}#{node['platform']}/#{platform_version}/"
  end
when 'rhel'
  if node['platform'] == 'amazon' && platform_version >= 2013
    platform_version = 6
  elsif node['platform'] == 'amazon'
    platform_version = 5
  end

  machines = { 'x86_64' => 'x86_64', 'i386' => 'i386', 'i686' => 'i686' }

  if platform_version == 7
    package_file = "#{base_filename}-#{node['riak']['package']['version']['build']}.el#{platform_version}.centos.#{machines[node['kernel']['machine']]}.rpm"
  else
    package_file = "#{base_filename}-#{node['riak']['package']['version']['build']}.el#{platform_version}.#{machines[node['kernel']['machine']]}.rpm"
  end

  base_uri = "#{base_uri}rhel/#{platform_version}/"
when 'fedora'
  base_uri = "#{base_uri}#{node['platform']}/#{platform_version}/"
  package_file = "#{base_filename}-#{node['riak']['package']['version']['build']}.fc#{platform_version}.#{node['kernel']['machine']}.rpm"
end

package_uri = "#{base_uri}#{package_file}"

remote_file "#{Chef::Config[:file_cache_path]}/#{package_file}" do
  source package_uri
  checksum checksum_val
  owner 'root'
  mode 0644
end

package 'riak-ee' do
  source "#{Chef::Config[:file_cache_path]}/#{package_file}"
  action :install
  options '--force-confdef --force-confold' if node['platform_family'] == 'debian'
  provider value_for_platform_family(
    ['debian'] => Chef::Provider::Package::Dpkg,
    %w(rhel fedora) => Chef::Provider::Package::Rpm
  )
end
