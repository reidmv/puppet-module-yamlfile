Puppet::Type.newtype(:yaml_setting) do
  @doc = "Manage settings in yaml configuration files"

  ensurable

  newparam(:name) do
    desc "The name"
    isnamevar
  end

  newproperty(:target) do
    desc "The configuration file in which to place settings"
    isrequired
    #defaultto do
    #  File.join(Facter.value('mcollective_confdir'), 'server.cfg')
    #end
  end

  newproperty(:value) do
    desc "The value to give the configuration key"
  end

end
