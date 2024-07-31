require 'db/migrations/utils'


# NOTE: This is an alternative version of the migration script, creating a dynamic value list for all 
#       unique (literal) values in "qualifier". Not sure how wise it is for real use, unless you know 
#       your data. But it works, and pretty fast! In order to use it: 
#        - rename 001_convert_qualifier_to_known_keys.rb to _001_convert_qualifier_to_known_keys.rb
#        - rename this file _001_convert_qualifier_values_to_enum.rb to 001_convert_qualifier_values_to_enum.rb

  Sequel.migration do
  
  # the tables containing a "qualifier" column
  tables = [:name_person, :parallel_name_person, :name_corporate_entity, :parallel_name_corporate_entity, :name_family, :parallel_name_family, :name_software, :parallel_name_software]

  up do
  
    # create an array of unique values for all "qualifier" fields in the selected tables
    qualifier_values = []
  
    tables.each do |table|
      qualifier_values += from(table).exclude(qualifier: nil).map(:qualifier).uniq
    end
  
    qualifier_values = qualifier_values.uniq
  
      
    # create a dynamic editable enum, based on the values in the qualifier_values arrary
    create_editable_enum("qualifier_type", qualifier_values)
     
    # get the id code for the qualifier enum
    qualifier_enum_id = from(:enumeration).filter(:name => 'qualifier_type').get(:id)
    
    # report which values have been created and should be included in the translation file
    $stderr.puts("An editable enumeration list 'qualifier_type' has been created in the database. Make sure you have following section in your enumeration translation file (with translated values):")
    $stderr.puts("--------------")
    $stderr.puts("    qualifier_type:")
    from(:enumeration_value).where(enumeration_id: qualifier_enum_id).map(:value).each do |value|
      $stderr.puts("      " + value + ': "' + value + '"')
    end
    $stderr.puts("--------------")

    # loop over the tables, add a qualifier_id column, and populate it with the corresponding enumeration value id
    tables.each do |table|   
      add_column table, :qualifier_id, Integer
      from(table).update(qualifier_id: from(:enumeration_value).
        select{id}.
        where(enumeration_id: qualifier_enum_id, value: Sequel[table][:qualifier])
      )
    end

  end

  down do
    tables.each do |table|
      alter_table(table) do
        drop_column(:qualifier_id)
      end
    end
  end

end