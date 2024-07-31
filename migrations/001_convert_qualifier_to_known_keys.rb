require 'db/migrations/utils'

Sequel.migration do
  # the tables containing a "qualifier" column
  tables = [:name_person, :parallel_name_person, :name_corporate_entity, :parallel_name_corporate_entity, :name_family, :parallel_name_family, :name_software, :parallel_name_software]
  
  # the name of the enum
  enum_name = "qualifier_type"

  enum_source_field = :qualifier
  enum_target_field = :qualifier_id

  # a map of expected values in the enum_source_field fields (key) and their values in the dynamic enumeration (value)
  # this should be tailored to the actual input data
  enum_value_lookup = {
    "Acroniem" => "acronym",
    "Naam getrouwde vrouw" => "married",
    "Officiële naam" => "official",
    "Pseudoniem" => "pseudonym",
    "Religieuze naam" => "religious",
    "Signatuur" => "signature",
    "Volledige naam" => "full"
  }
  
  up do

    enum_id= self[:enumeration].filter(:name => enum_name).get(:id)

    # create a dynamic editable enum, based on the values in the enum_value_lookup hash
    unless enum_id
      create_editable_enum(enum_name, enum_value_lookup.map { |k,v| v })
      # create_editable_enum(enum_name, enum_value_lookup.map { |k,v| k })
    end
    
    # get the id code for the enum
    enum_id= self[:enumeration].filter(:name => enum_name).get(:id)

    $stderr.puts("data migration of column #{enum_source_field.to_s} may take some time")
    
    # loop over the tables, add an enum_target_field column, and populate it with the corresponding enumeration value id
    tables.each do |table|
      unless self.schema(table).map(&:first).include?(enum_target_field)
        alter_table(table) do
          add_column(enum_target_field, :integer, :null => true)
        end
      end

      $stderr.puts("- table #{table}: processing " + self[table].exclude(enum_source_field => nil).count(enum_source_field).to_s + " rows with values");

      self[table].exclude(enum_source_field => nil).each_by_page do |row|
        enum_value = enum_value_lookup[row[enum_source_field].strip]
        # enum_value = row[enum_source_field].strip
        enum_value_id = self[:enumeration_value].filter(:enumeration_id => enum_id, :value => enum_value).get(:id)

        # $stderr.puts("enum_id: " + enum_id.to_s)
        # $stderr.puts("enum_source_field value: " + row[enum_source_field].strip)
        # $stderr.puts("enum_value: " + enum_value.to_s)
        # $stderr.puts("enum_value_id: " + enum_value_id.to_s)
      
        unless enum_value_id.nil? || enum_value_id == ""
          self[table].where(:id => row[:id]).update(enum_target_field => enum_value_id)
        end

        #alter_table(table) do
        #  enum_source_field_orig =(enum_source_field.to_s + '_orig').to_sym
        #  rename_column(enum_source_field, enum_source_field_orig)
        #end

      end
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