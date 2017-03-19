property :version, String, name_property: true
property :build, String, default: '1'
property :enterprise_key, String, required: true
property :url, String
property :checksum, String

action_class do
  def validate_version
    unless new_resource.version =~ /\d+.\d+.\d+/
      Chef::Log.fatal("The version must be in X.Y.Z format. Passed value: #{new_resource.version}")
      raise
    end
  end

  def major_minor
    split_version = new_resource.version.split('.')
    [split_version[0], split_version[1]].join('.')
  end
end

action :install do
  validate_version
  package_version = "#{new_resource.version}-#{new_resource.build}"
  plat_ver_int = node['platform_version'].to_i
  ee_url_prefix = Gem::Version.new(version_str) >= Gem::Version.new('2.0.8') ?
    "http://private.downloads.basho.com/riak_ee/#{new_resource.enterprise_key}/#{new_resource.version}" :
    "http://private.downloads.basho.com/riak_ee/#{new_resource.enterprise_key}/#{major_minor}/#{new_resource.version}"

  case node['platform']
  when 'debian'
    package_file = "riak-ee_#{package_version}_amd64.deb"
    ee_url_suffix = "/debian/#{plat_ver_int}/#{package_file}"
    if Gem::Version.new(version_str) >= Gem::Version.new('2.2.0')
      ee_url_suffix = "/debian/#{node['lsb']['codename']}/#{package_file}"
    end
    if Gem::Version.new(version_str) >= Gem::Version.new('2.0.8') &&
       Gem::Version.new(version_str) < Gem::Version.new('2.1.0')
      ee_url_suffix = "/debian/#{node['lsb']['codename']}/#{package_file}"
    end
  when 'ubuntu'
    package_file = "riak-ee_#{package_version}_amd64.deb"
    ee_url_suffix = "/ubuntu/#{node['lsb']['codename']}/#{package_file}"
  when 'centos', 'redhat'
    case plat_ver_int
    when 7
      package_file = "riak-ee-#{package_version}.el7.centos.x86_64.rpm"
    when 6
      package_file = "riak-ee-#{package_version}.el#{plat_ver_int}.x86_64.rpm"
    end
    ee_url_suffix = "/rhel/#{plat_ver_int}/#{package_file}"
  when 'amazon'
    package_file = "riak-ee-#{package_version}.el6.x86_64.rpm"
    ee_url_suffix = "/rhel/6/#{package_file}"
  when 'freebsd'
    case plat_ver_int
    when 10
      package_file = "riak-ee-#{version_str}.txz"
      ee_url_suffix = "/freebsd/10/#{package_file}"
    end
  end

  pkg_url = new_resource.url && new_resource.url.length > 0 ?
            "#{new_resource.url}/#{package_file}" :
            ee_url_prefix + ee_url_suffix

  remote_file "#{Chef::Config[:file_cache_path]}/#{package_file}" do
    source pkg_url
    checksum new_resource.checksum
    owner 'root'
    mode 0644
  end

  package 'riak-ee' do
    source "#{Chef::Config[:file_cache_path]}/#{package_file}"
    action :install
    provider value_for_platform_family(
       %w(debian) => Chef::Provider::Package::Dpkg,
       %w(rhel fedora) => Chef::Provider::Package::Rpm)
    only_if do
      ::File.exist?("#{Chef::Config[:file_cache_path]}/#{package_file}") &&
        new_resource.checksum &&
        Digest::SHA256.file("#{Chef::Config[:file_cache_path]}/#{package_file}").hexdigest ==
          new_resource.checksum
    end
  end
end
