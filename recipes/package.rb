#
# Author:: Benjamin Black (<b@b3k.us>), Sean Cribbs (<sean@basho.com>),
# Seth Thomas (<sthomas@basho.com>), and Hector Castro (<hector@basho.com>)
# Cookbook Name:: riak
# Recipe:: package
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

is_enterprise = !node['riak']['package']['enterprise_key'].empty?
version_str = %w(major minor incremental).map { |ver| node['riak']['package']['version'][ver] }.join('.')
plat_ver_int = node['platform_version'].to_i
build = node['riak']['package']['version']['build']
package_url = node['riak']['package']['local']['url']
package_checksum = node['riak']['package']['local']['checksum'][node['platform']][plat_ver_int.to_s]

# Enterprise download URL changed with release of 2.0.8 and greater
if Gem::Version.new(version_str) >= Gem::Version.new('2.0.8')
  ee_url_prefix = "http://private.downloads.basho.com/riak_ee/#{node['riak']['package']['enterprise_key']}/#{version_str}"
else
  ee_url_prefix = "http://private.downloads.basho.com/riak_ee/#{node['riak']['package']['enterprise_key']}/#{major_minor}/#{version_str}"
end

if node['platform'] == 'freebsd'
  install_method = 'custom_package'
elsif is_enterprise
  install_method = 'enterprise_package'
else
  install_method node['riak']['install_method']
end

case  install_method
when 'package', 'custom_repository'
  riak_package version_str do
    version version_str
    build build
    custom_repository install_method == 'custom_repository'
  end
when 'custom_package'
  riak_custom_package version_str do
    build build
    url package_url
    checksum package_checksum
  end
when'enterprise_package'
  riak_enterprise_package version_str do
    build build
    enterprise_key node['riak']['package']['enterprise_key']
    url package_url
    checksum package_checksum
  end
end
