Puppet::Type.newtype(:yaml_setting) do
  @doc = "Manage settings in yaml configuration files"

  ensurable

  newproperty(:target) do
    desc "The configuration file in which to place settings"
    isrequired
    isnamevar
  end

  newproperty(:key) do
    desc "The yaml key"
    isrequired
    isnamevar
  end

  newparam(:name) do
    desc "The name"
    munge do |discard|
      target = @resource.original_parameters[:target]
      key    = @resource.original_parameters[:key]
      "#{target.to_s}:#{key.to_s}"
    end
  end

  newproperty(:value) do
    desc "The value to give the configuration key"
  end

  # Our title_patterns method for mapping titles to namevars for supporting
  # composite namevars.
  def self.title_patterns
    identity = lambda {|x| x}
    [
      [
        /^([^:]+)$/,
        [
          [ :name, identity ]
        ]
      ],
      [
        /^((.*):(.*))$/,
        [
          [ :name, identity ],
          [ :key, identity ],
          [ :value, identity ]
        ]
      ]
    ]
  end
end
