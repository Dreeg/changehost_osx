dir = Dir.pwd.split("/")
dir.delete("")
dir.delete_at(-1)
DIR = "/"+dir.join("/")

module ChangeHosts
    DataDir = "#{DIR}/data"
    BinDir = "#{DIR}/bin"
    LibDir = "#{DIR}/lib"
    Config = JSON.parse(File.read("#{DataDir}/data.json"))['config']
end