require 'db/migrations/utils'

Sequel.migration do
    
  # the tables containing a "qualifier" column
  tables = [:name_person, :parallel_name_person, :name_corporate_entity, :parallel_name_corporate_entity, :name_family, :parallel_name_family, :name_software, :parallel_name_software]
  
  # a map of expected values in the qualifier fields (key) and their values in the dynamic enumeration (value)
  # this should be tailored to the actual input data 
  qualifier_types = {
    "Acroniem" => "acronym",
    "Naam getrouwde vrouw" => "married",
    "Officiële naam" => "official",
    "Pseudoniem" => "pseudonym",
    "Religieuze naam" => "religious",
    "Signatuur" => "signature",
    "Volledige naam" => "full"
  }
  
  up do

    # create a dynamic editable enum, based on the values in the qualifier_types map
    create_editable_enum("qualifier", qualifier_types.map { |k,v| v })
    #create_editable_enum("qualifier", qualifier_types.map { |k,v| k })
    
    # get the id code for the qualifier enum
    qualifier_enum_id= self[:enumeration].filter(:name => 'qualifier').get(:id)
    
    # loop over the tables, add a qualifier_id column, and populate it with the corresponding enumeration value id
    tables.each do |table|
      alter_table(table) do
        add_column(:qualifier_id, :integer, :null => true)
      end
      
      self[table].exclude(:qualifier => nil).each do |row|
        qualifier_type = qualifier_types[row[:qualifier].strip]
        qualifier_id = self[:enumeration_value].filter(:enumeration_id => qualifier_enum_id, :value => qualifier_type).get(:id)

        # qualifier_type = row[:qualifier].strip
        # qualifier_id = qualifier_type_ids[qualifier_type][:id]
          
        unless qualifier_id.nil? || qualifier_id == ""
          self[table].filter(:id => row[:id]).update(:qualifier_id => qualifier_id)
        end
    
      end
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