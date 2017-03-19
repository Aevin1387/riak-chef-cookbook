property :version, String, name_property: true
property :build, String, default: '1'
property :url, String, required: true
property :checksum, String

action_class do
  def validate_version
    unless new_resource.version =~ /\d+.\d+.\d+/
      Chef::Log.fatal("The version must be in X.Y.Z format. Passed value: #{new_resource.version}")
      raise
    end
  end
end

action :install do
  validate_version
  package_version = "#{new_resource.version}-#{new_resource.build}"
  plat_ver_int = node['platform_version'].to_i

  case node['platform']
  when 'debian'
    package_file = "riak_#{package_version}_amd64.deb"
  when 'ubuntu'
    package_file = "riak_#{package_version}_amd64.deb"
  when 'centos', 'redhat'
    case plat_ver_int
    when 7
      package_file = "riak-#{package_version}.el7.centos.x86_64.rpm"
    when 6
      package_file = "riak-#{package_version}.el#{plat_ver_int}.x86_64.rpm"
    end
  when 'amazon'
    package_file = "riak-#{package_version}.el6.x86_64.rpm"
  when 'freebsd'
    case plat_ver_int
    when 10
      package_file = "riak-#{new_resource.version}.txz"
    end
  end

  pkg_url = "#{new_resource.url}/#{package_file}"

  remote_file "#{Chef::Config[:file_cache_path]}/#{package_file}" do
    source pkg_url
    checksum new_resource.checksum if new_resource.checksum
    owner 'root'
    mode 0644
  end

  package 'riak' do
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
