property :version, String, name_property: true
property :build, String, default: '1'
property :custom_repository, [true, false], default: false

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

  case node['platform']
  when 'ubuntu', 'debian'
    packagecloud_repo 'basho/riak' do
      type 'deb'
      not_if { new_resource.custom_repository }
    end

  when 'centos', 'redhat', 'amazon', 'fedora'
    packagecloud_repo 'basho/riak' do
      type 'rpm'
      not_if { new_resource.custom_repository }
    end

    case node['platform_version'].to_i
    when 6, 2013, 2014
      package_version = "#{package_version}.el6"
    when 7
      package_version = "#{package_version}.el7.centos"
    when 19
      package_version = "#{package_version}.fc#{plat_ver_int}"
    end
  end

  package 'riak' do
    action :install
    version package_version
    options '-o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"' \
            if node['platform_family'] == 'debian'
  end
end
