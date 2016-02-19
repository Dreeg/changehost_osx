require "#{ChangeHosts::LibDir}/data_writer.rb"

class Dns
    def initialize(org=nil)
        @org = ChangeHosts::Config['organizations']
        @dns = get_dns(org)
    end

    def list(org=nil) 
        puts ""
        puts "n   |   Org - DNS"
        count = 1
        @dns.each do |org, dns|
            first = true
            l=org.length
            puts "-   |   ---------"
            dns.each do |d|
                if count < 10
                    if first
                        puts "#{count}   |   #{org} - #{d}"
                        first = false
                    else
                        puts "#{count}   |   #{' '*(l/2-1)}''#{' '*(l/2-1)} - #{d}"
                    end
                else
                    if first
                        puts "#{count}  |   #{org} - #{d}"
                        first = false
                    else
                        puts "#{count}  |   #{' '*(l/2-1)}''#{' '*(l/2-1)} - #{d}"                        
                    end
                end
                count += 1
            end
        end
        puts ""
    end

    def add(org=nil, name=nil)
        json = DataWriter.new
        if org.nil?
            org = select_org
        end
        if name.nil?
            print "Inserisci il valore del record DNS da inserire in #{org}: "
            name = STDIN.gets.chomp
        end

        if @dns[org].include? name
            puts "Il record #{name} è già presente nell'organizzazione #{org}"
        else
            $data['organizations'][org]['dns'].push(name)
            json.update_json($data)
            puts "Il record #{name} è stato aggiunto con successo all'organizzazione #{org}"
        end
    end

    def modify(org=nil)
        if org.nil?
            org = select_org
        end

        oldname = select
        print "Inserisci il nuovo nome (o lascia vuoto per non modificare): "
        name = STDIN.gets.chomp.downcase
        if (name.empty? || name == oldname)
            puts "Il record non è stato cambiato"
        else
            remove(org,oldname)
            add(org,name)
        end
    end

    def remove(org=nil, name=nil)
        json = DataWriter.new
        if org.nil?
            org = select_org
        end
        if name.nil?
            name = select(org)
        end

        if @dns[org].include? name
            $data['organizations'][org]['dns'].delete(name)
            json.update_json($data)
            puts "Il record #{name} è stato rimosso con successo dall'organizzazione #{org}"
        else
            puts "Il record #{name} non è presente nell'organizzazione #{org}"
        end
    end

    def select(org=nil)
        list(org)
        print "Inserisci il numero corrispondente: "
        choose = STDIN.gets.chomp.to_i

        actual = 0
        if org == nil
            @dns.values.each do |dns|
                dns.each do |n|
                    actual += 1
                    if actual == choose
                        return n
                    end
                end
            end
        else
            @dns[org].each do |dns|
                actual += 1
                if actual == choose
                    return dns
                end
            end
        end

        puts 'Hai inserito un valore non valido, riprova.'
        select(org)
    end

    def select_org
        @o = Org.new unless @o
        return @o.select
    end

    def get_dns(org=nil)
        if org == nil
            dns = Hash.new
            @org.each do |o|
                dns[o] = $data['organizations']["#{o}"]['dns']
            end
        else
            dns = Hash.new
            dns[org] = $data['organizations']["#{org}"]['dns']
        end
        return dns
    end
end