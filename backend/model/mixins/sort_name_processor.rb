module SortNameProcessor

  module CorporateEntity
    def self.process(json, extras = {})
      result = ""

      result << "#{json["primary_name"]}" if json["primary_name"]
      result << ". #{json["subordinate_name_1"]}" if json["subordinate_name_1"]
      result << ". #{json["subordinate_name_2"]}" if json["subordinate_name_2"]

      grouped = [json["number"]].reject {|v| v.nil?}
      result << ", #{grouped.join(" : ")}" if not grouped.empty?
      result << " (#{I18n.t('enumerations.qualifier.'+json['qualifier'], :default => json['qualifier'])})" if json["qualifier"]

      result << " (#{json["dates"]})" if json["dates"]
      result << " (#{json["location"]})" if json["location"]

      result.length > 255 ? result[0..254] : result
    end
  end

  module Family
    def self.process(json, extras = {})
      result = ""

      result << json["family_name"] if json["family_name"]
      result << ", #{json["prefix"]}" if json["prefix"]
      result << " (#{I18n.t('enumerations.qualifier.'+json['qualifier'], :default => json['qualifier'])})" if json["qualifier"]

      result << " (#{json["dates"]})" if json["dates"]
      result << " (#{json["location"]})" if json["location"]

      result.length > 255 ? result[0..254] : result
    end
  end

  module Person
    def self.process(json, extras = {})
      result = ""

      if json["name_order"] === "inverted"
        result << json["primary_name"] if json["primary_name"]
        result << ", #{json["rest_of_name"]}" if json["rest_of_name"]
      elsif json["name_order"] === "direct"
        result << json["rest_of_name"] if json["rest_of_name"]
        result << " #{json["primary_name"]}" if json["primary_name"]
      else
        result << json["primary_name"]
      end

      result << ", #{json["prefix"]}" if json["prefix"]
      result << ", #{json["suffix"]}" if json["suffix"]
      result << ", #{json["title"]}" if json["title"]
      result << ", #{json["number"]}" if json["number"]
      result << " (#{json["fuller_form"]})" if json["fuller_form"]
      result << ", #{json["dates"]}" if json["dates"]
      result << " (#{I18n.t('enumerations.qualifier.'+json['qualifier'], :default => json['qualifier'])})" if json["qualifier"]

      dates = json['dates'].nil? ? SortNameProcessor::Utils.first_date(extras, 'dates_of_existence') : nil
      result << " (#{dates})" if dates

      result.lstrip!
      result.length > 255 ? result[0..254] : result
    end
  end

  module Software
    def self.process(json, extras = {})
      result = ""

      result << "#{json["manufacturer"]} " if json["manufacturer"]
      result << "#{json["software_name"]}" if json["software_name"]
      result << " #{json["version"]}" if json["version"]
      result << " (#{I18n.t('enumerations.qualifier.'+json['qualifier'], :default => json['qualifier'])})" if json["qualifier"]
      result << ", #{json["dates"]}" if json["dates"]

      dates = json['dates'].nil? ? SortNameProcessor::Utils.first_date(extras, 'dates_of_existence') : nil
      result << " (#{dates})" if dates

      result.length > 255 ? result[0..254] : result
    end
  end
end
