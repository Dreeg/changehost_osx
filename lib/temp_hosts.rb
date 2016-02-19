require "#{ChangeHosts::LibDir}/data_writer.rb"

class TempHosts
    def initialize(org=nil)
        @org = ChangeHosts::Config['organizations']
        @hosts = get_temp(org)
    end

    def list(org=nil) 
        puts ""
        puts "n   |   Org - Name - Ip"
        count = 1
        @hosts.each do |org, hosts|
            first = true
            lo = org.length
            lm = 0
            hosts.keys.each do |n|
                lm = n.length if (n.length > lm)
            end
            puts "-   |   ---------------"
            hosts.each do |n,i|
                if first
                    puts "#{count}   |   #{org} - #{n}#{' '*(lm-n.length)} - #{i}"
                    first = false
                else
                    puts "#{count}  |   #{' '*(lo/2-1)}''#{' '*(lo/2-1)} - #{n}#{' '*(lm-n.length)} - #{i}"
                end
                count += 1
            end
        end
        puts ""
    end

    def add(org=nil, name=nil, addr=nil)
        json = DataWriter.new
        if org.nil?
            org = select_org
        end
        if name.nil?
            print "Inserisci il nome da assegnare al record hosts da inserire in #{org}: "
            name = STDIN.gets.chomp
        end
        if addr.nil?
            print "Inserisci l'indirizzo IP del record hosts #{name} da inserire in #{org}: "
            addr = STDIN.gets.chomp
        end

        if @hosts[org].include? name
            puts "Il record #{name} è già presente nel file"
        elsif !check_ip(addr)
            puts "L'indirizzo IP non è valido. Riprova."
            add(org, name)
        else
            $data['organizations'][org]['hosts'][name] = addr
            json.update_json($data)
            puts "Il record #{name} - #{addr} è stato aggiunto con successo"
        end
    end

    def modify(org=nil)
        json = DataWriter.new
        if org.nil?
            org = select_org
        end

        old = select
        print "Inserisci il nuovo nome (o lascia vuoto per non modificare): "
        name = STDIN.gets.chomp.downcase
        puts
        print "Inserisci il nuovo IP (o lascia vuoto per non modificare): "
        addr = STDIN.gets.chomp

        if addr.empty?
            addr = old[1]
        else
            unless check_ip(addr)
                puts "L'indirizzo IP non è valido. Riprova."
                modify(org)
            end
        end
        if name.empty?
            name = old[0]
        else
            remove(org, old[0])
        end

        $data['organizations'][org]['hosts'][name] = addr
        json.update_json($data)
        puts "Il record #{name} - #{addr} è stato aggiornato con successo"
    end

    def remove(org=nil, name=nil)
        json = DataWriter.new
        if org.nil?
            org = select_org
        end
        if name.nil?
            name = select[0]
        end

        if @hosts[org].include? name
            $data['organizations'][org]['hosts'].delete name
            json.update_json($data)
            puts "Il record #{name} è stato rimosso con successo da #{org}"
        else
            puts "Il record #{name} non è presente in #{org}"
        end
    end

    def select_default(org=nil)
        json = DataWriter.new
        if org.nil?
            org = select_org
        end

        name = select(org)[0]

        $data['organizations'][org]['hosts']['selected'] = name
        json.update_json($data)
        puts "Il record #{name} è stato selezionato come host di default con successo per #{org}"

        check = Array.new
        $data['organizations'].each do |org, data|
            unless data['hosts'].include? 'selected'
                check.push("#{org}")
            end
        end
        unless check.empty?
            puts "!! -- ATTENZIONE -- !!"
            puts "Le seguenti organizzazioni NON hanno alcun host di default:"
            check.each do |o|
                puts o
            end
            print "Vuoi selezionarne uno per le organizzazioni orfane? (y|n)"
            choose = STDIN.gets.chomp
            if choose == 'y'
                select_default(check[0])
            end
        end
    end

    def select(org=nil)
        list(org)
        print "Inserisci il numero corrispondente: "
        choose = STDIN.gets.chomp.to_i

        actual = 0
        if org == nil
            @hosts.values.each do |hosts|
                hosts.each do |name, addr|
                    actual += 1
                    if actual == choose
                        host = [name,addr]
                        return host
                    end
                end
            end
        else    
            @hosts[org].each do |name, addr|
                actual += 1
                if actual == choose
                    host = [name,addr]
                    return host
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

    def check_ip(addr)
        addr = addr.split(".")
        if addr.length == 4
            addr.each do |ip|
                unless ip.to_i.between?(0,255)
                    return false
                end
            end
            return true
        else
            return false
        end
    end

    def get_temp(org=nil)
        if org == nil
            hosts = Hash.new
            @org.each do |o|
                hosts[o] = $data['organizations']["#{o}"]['hosts']
            end
        else
            hosts = Hash.new
            hosts[org] = $data['organizations']["#{org}"]['hosts']
        end

        return hosts
    end
end