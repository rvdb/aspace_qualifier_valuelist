def create_editable_enum(name, values, default = nil, opts = {})
  create_enum(name, values, default, true, opts)
end

def create_enum(name, values, default = nil, editable = false, opts = {})
  id = self[:enumeration].insert(:name => name,
                                 :json_schema_version => 1,
                                 :editable => editable ? 1 : 0,
                                 :create_time => Time.now,
                                 :system_mtime => Time.now,
                                 :user_mtime => Time.now)

  id_of_default = nil

  readonly_values = Array(opts[:readonly_values])
  # we updated the schema to include ordering for enum values. so, we will need
  # those for future adding enums
  include_position = self.schema(:enumeration_value).flatten.include?(:position)

  values.each_with_index do |value, i|
    props = { :enumeration_id => id, :value => value, :readonly => readonly_values.include?(value) ? 1 : 0 }
    props[:position] = i if include_position

    id_of_value = self[:enumeration_value].insert(props)

    id_of_default = id_of_value if value === default
  end

  if !id_of_default.nil?
    self[:enumeration].where(:id => id).update(:default_value => id_of_default)
  end
end

Sequel.migration do
  tables = [:name_person, :parallel_name_person, :name_corporate_entity, :parallel_name_corporate_entity, :name_family, :parallel_name_family, :name_software, :parallel_name_software]

  up do

    tables.each do |table|
      alter_table(table) do
        add_column(:qualifier_id, :integer, :null => true)
      end
    end 
  
    create_editable_enum("qualifier", ["acronym", "married_wife", "official","pseudonym","religious","signature","full"])

  end

  down do
    tables.each do |table|
      alter_table(table) do
        drop_column(:qualifier_id)
      end
    end
  end

end