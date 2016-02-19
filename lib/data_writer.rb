require 'json'
require '../bin/config.rb'

class DataWriter

    def update_json(json)
        jfile = JSON.pretty_generate($data.merge!(json))
        File.write("#{ChangeHosts::DataDir}/data.json", jfile)
    end
end