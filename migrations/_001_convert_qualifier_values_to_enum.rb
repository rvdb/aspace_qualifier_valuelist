require 'db/migrations/utils'


# NOTE: This is an alternative version of the migration script, creating a dynamic value list for all 
#       unique (literal) values in "qualifier". Not sure how wise it is for real use, unless you know 
#       your data. But it works, and pretty fast! In order to use it: 
#        - rename 001_convert_qualifier_to_known_keys.rb to _001_convert_qualifier_to_known_keys.rb
#        - rename this file _001_convert_qualifier_values_to_enum.rb to 001_convert_qualifier_values_to_enum.rb

  Sequel.migration do
  
  # the tables containing a "qualifier" column
  tables = [:name_person, :parallel_name_person, :name_corporate_entity, :parallel_name_corporate_entity, :name_family, :parallel_name_family, :name_software, :parallel_name_software]
  
  # the name of the enum
  enum_name = "qualifier_type"

  enum_source_field = :qualifier
  enum_target_field = :qualifier_id

  up do
  
    # create an array of unique values for all "qualifier" fields in the selected tables
    enum_values = []
  
    tables.each do |table|
      enum_values += from(table).exclude(qualifier: nil).map(:qualifier).uniq
    end
  
    enum_values = enum_values.uniq

    enum_id= from(:enumeration).filter(:name => enum_name).get(:id)
      
    # create a dynamic editable enum, based on the values in the enum_values arrary
    unless enum_id
      create_editable_enum(enum_name, enum_values)
    end
    
    # get the id code for the enum
    enum_id= from(:enumeration).filter(:name => enum_name).get(:id)
    
    # report which values have been created and should be included in the translation file
    $stderr.puts("An editable enumeration list '#{enum_name}' has been created in the database. Make sure you have following section in your enumeration translation file (with translated values):")
    $stderr.puts("--------------")
    $stderr.puts("    #{enum_name}:")
    from(:enumeration_value).where(enumeration_id: enum_id).map(:value).each do |value|
      $stderr.puts("      " + value + ': "' + value + '"')
    end
    $stderr.puts("--------------")

    # loop over the tables, add an enum_target_field column, and populate it with the corresponding enumeration value id
    tables.each do |table|
      unless self.schema(table).map(&:first).include?(enum_target_field)
        alter_table(table) do
          add_column(enum_target_field, :integer, :null => true)
        end
      end
      from(table).update(enum_target_field => from(:enumeration_value).
        select{id}.
        where(enumeration_id: enum_id, value: Sequel[table][:qualifier])
      )
      #alter_table(table) do
      #  enum_source_field_orig =(enum_source_field.to_s + '_orig').to_sym
      #  rename_column(enum_source_field, enum_source_field_orig)
      #end

    end

  end

  down do
    tables.each do |table|
      alter_table(table) do
        drop_column(enum_target_field)
      end
    end
  end

end