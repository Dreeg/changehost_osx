def main
	if $*.length == 0 || $*.length > 5
		puts
		puts "Si prega di passare il numero corretto di argomenti in base alla necessità. Potete consultare la guida di seguito, invocabile con 'changehosts help'"
		puts
		help
		puts
		return
	end

	action = ARGV[0].downcase unless ARGV[0].nil?
	field = ARGV[1].downcase unless ARGV[1].nil?
	arg1 = ARGV[2].downcase unless ARGV[2].nil?
	arg2 = ARGV[3].downcase unless ARGV[3].nil?
	arg3 = ARGV[4].downcase unless ARGV[4].nil?

	action(action, field, arg1, arg2, arg3)
end

def action(action=nil, field=nil, arg1=nil, arg2=nil, arg3=nil)
	case action
	when 'list', '-l'
		case field
		when 'hosts'
			temp = TempHosts.new(arg1)
			temp.list(arg1)
		when 'dns'
			dns = Dns.new(arg1)
			dns.list(arg1)
		when 'org'
			org = Org.new
			org.list
		else
			choose_act(action)
		end
	when 'add', '-a'
		case field
		when 'hosts'
			temp = TempHosts.new(arg1)
			temp.add(arg1,arg2,arg3)
		when 'dns'
			dns = Dns.new(arg1)
			dns.add(arg1,arg2)
		when 'org'
			org = Org.new
			org.add(arg1)
		else
			choose_act(action)
		end
	when 'modify', '-m'
		case field
		when 'hosts'
			temp = TempHosts.new(arg1)
			temp.modify(arg1)
		when 'dns'
			dns = Dns.new(arg1)
			dns.modify(arg1)
		when 'org'
			org = Org.new
			org.modify
		else
			choose_act(action)
		end
	when 'remove', '-r'
		case field
		when 'hosts'
			temp = TempHosts.new(arg1)
			temp.remove(arg1,arg2)
		when 'dns'
			dns = Dns.new(arg1)
			dns.remove(arg1,arg2)
		when 'org'
			org = Org.new
			org.remove(arg1)
		else
			choose_act(action)
		end
	when 'generate', '-g'
		gen = Generator.new
	when 'man', 'help', '-h'
		help
	else
		raise 'I parametri non corrispondono ad alcuna opzione valida: generate, list, modify, add, remove o man'
	end
end

def choose_act(action)
	puts "I parametri che hai inserito per #{action} sono sbagliati o assenti, scegline uno dall'elenco qui sotto:"
	puts '1 | hosts'
	puts '2 | DNS'
	puts '3 | Organizzazioni'
	puts
	print 'Scelta: '
	choose = STDIN.gets.chomp.to_s.downcase

	case action
	when 'list', '-l'
		case choose
		when 'hosts', '1'
			action('list', 'hosts')
		when 'dns', '2'
			action('list', 'dns')
		when 'org', 'organizzazioni', '3'
			action('list', 'org')
		else
			puts 'Il parametro inserito risulta errato, riprovare.'
			choose_act(action)
		end
	when 'add', '-a'
		case choose
		when 'hosts', '1'
			action('add', 'hosts')
		when 'dns', '2'
			action('add', 'dns')
		when 'org', 'organizzazioni', '3'
			action('add', 'org')
		else
			puts 'Il parametro inserito risulta errato, riprovare.'
			choose_act(action)
		end
	when 'modify', '-m'
		case choose
		when 'hosts', '1'
			action('modify', 'hosts')
		when 'dns', '2'
			action('modify', 'dns')
		when 'org', 'organizzazioni', '3'
			action('modify', 'org')
		else
			puts 'Il parametro inserito risulta errato, riprovare.'
			choose_act(action)
		end
	when 'remove', '-r'
		case choose
		when 'hosts', '1'
			action('remove', 'hosts')
		when 'dns', '2'
			action('remove', 'dns')
		when 'org', 'organizzazioni', '3'
			action('remove', 'org')
		else
			puts 'Il parametro inserito risulta errato, riprovare.'
			choose_act(action)
		end
	else
		puts "Questo caso non è ancora gestito, chiedo venia per l'inconveniente."
	end
end

def help
	puts "Eseguire il programma con il parametro necessario:"
	puts "'-l' o 'list' seguito da 'dns', 'hosts' o 'org' per ottenere l'elenco dei record dns, degli host o delle organizzazioni presenti in maniera temporanea"
	puts "'-g' o 'generate' seguito da un nome host esistente, per generare un nuovo set di records"
	puts "'-a' o 'add' seguito da: 'dns' e il nome per aggiungere un record dns; 'hosts' dal nome e dall'indirizzo per aggiungere un record host temporaneo; 'org' e il nome dell'organizzazione per aggiungerne una;"
	puts "'-m' o 'modify' seguito da 'dns', 'hosts' o 'org' per modificare un record presente"
	puts "'-r' o 'remove' seguito da: 'dns' e il nome per rimuovere un record dns; 'hosts' dal nome e dall'indirizzo per rimuovere un record host temporaneo; 'org' e il nome dell'organizzazione per rimuoverne una;"
	puts "'-h' o 'help' o 'man' per visualizzare questa guida"
end

def check_files
	hash = {"config"=>{"organizations"=>["no_org"], "def_org"=>["no_org"]}, "organizations"=>{"no_org"=>{"hosts"=>{"localhost"=>"127.0.0.1"}, "dns"=>["localhost"]}}, "static"=>{"local"=>{"127.0.0.1"=>["localhost"], "255.255.255.255"=>["broadcasthost"], "::1"=>["localhost"]}}, "extra"=>{"header"=>["#", "# Host Database", "#", "# localhost is used to configure the loopback interface", "# when the system is booting.  Do not delete this entry.", "##"]}}
	json = JSON.pretty_generate(hash)

	unless Dir.exist?("../data/")
		Dir.mkdir("#ChangeHosts::DataDir")
	end

	if File.exist?("../data/data.json")
		begin
			JSON.parse(File.read("../data/data.json"))
		rescue
			puts
			puts "!!  --  A T T E N Z I O N E  --  !!"
			puts
			puts " - Il file data/data.json risulta CORROTTO. Ripristino dati di default. -"
			puts
			puts " - Una copia del vecchio file è reperibile in data/data_corrupted_backup.json - "
			puts
			File.rename("../data/data.json", "../data/data_corrupted_backup.json")
			File.write("../data/data.json", json)
		end
	else
		File.write("../data/data.json", json)
	end
end

require 'json'
check_files
require './config.rb'
require "#{ChangeHosts::LibDir}/generator.rb"
require "#{ChangeHosts::LibDir}/org.rb"
require "#{ChangeHosts::LibDir}/dns.rb"
require "#{ChangeHosts::LibDir}/temp_hosts.rb"

$data = JSON.parse(File.read("#{ChangeHosts::DataDir}/data.json"))
main