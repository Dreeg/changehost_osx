require "#{ChangeHosts::LibDir}/data_writer.rb"

class Org
    def initialize
        @org = get_org
    end

    def list
        count = 1
        puts 
        puts 'n   |   Org'
        puts '-   |   ---'
        @org.each do |o|
            stringCount = "#{count}".ljust(4,' ')
            puts "#{stringCount}|   #{o}"
            count += 1
        end
        puts ""
    end

    def add(name=nil)
        json = DataWriter.new
        if !name.nil?
            if @org.include? name
                puts "Il record #{name} è già presente nell'elenco delle organizzazioni"
            else
                $data['organizations'][name] = {'hosts' => {}, 'dns' => []}
                json.update_json($data)
                puts "Il record #{name} è stato aggiunto con successo"
            end
        else
            print 'Inserisci il nome: '
            name = STDIN.gets.chomp.downcase
            add(name)
        end
    end

    def modify
        list
        print "Inserisci il numero corrispondente all'opzione: "
        num = STDIN.gets.chomp.to_i
        if num.between?(1,@org.length)
            print 'Inserisci il nuovo nome (o lascia vuoto per non modificare): '
            name = STDIN.gets.chomp
            old_name = @org[num-1]
            if (name.empty? || name == old_name)
                puts 'Il record non è stato cambiato'
            else
                add(name)
                transfer(name,old_name)
                remove(old_name)
            end
        else
            puts "Hai scelto un'opzione non valida. Riprova."
            modify
        end
    end

    def remove(name=nil)
        json = DataWriter.new
        if name.nil?
            name = select
        end
        if @org.include? name
            $data['organizations'].delete(name)
            json.update_json($data)
            puts "Il record #{name} è stato rimosso con successo"
        else
            puts "Il record #{name} non è presente nell'elenco delle organizzazioni"
        end
    end

    def transfer(org1,org2)
        $data['organizations']["#{org2}"] = $data['organizations']["#{org1}"]
    end

    def add_selected(org=nil)
        json = DataWriter.new
        if org == nil
            puts 'Le organizzazioni attualmente selezionate sono:'
            $data['config']['organizations'].each do |o|
                puts o
            end
            puts
            puts ' --- '
            org = select
        end

        if $data['config']['organizations'].include? org
            puts "L'elenco delle organizzazioni selezionate include già #{org}"
        elsif !@org.include? org
            puts "#{org} non fa parte della lista di organizzazioni. Riprovare."
            add_selected
        else
            $data['config']['organizations'].push(org)
            json.update_json($data)
            puts "#{org} aggiunta con successo all'elenco delle organizzazioni selezionate"
        end
    end

    def remove_selected(org=nil)
        json = DataWriter.new
        if org == nil
            puts 'Le organizzazioni attualmente selezionate sono:'
            $data['config']['organizations'].each do |o|
                puts o
            end
            puts
            puts ' --- '
            org = select
        end

        if $data['config']['organizations'].include? org
            $data['config']['organizations'].delete(org)
            json.update_json($data)
            puts "#{org} rimossa con successo dall'elenco delle organizzazioni selezionate"
        else
            puts "L'elenco delle organizzazioni selezionate non include #{org}"
        end
    end

    def select
        list
        print 'Inserisci il nome o il numero corrispondente: '
        choose = STDIN.gets.chomp.downcase
        if choose.to_i == 0
            org = choose
        else
            if ((choose.to_i) <= @org.length) && ((choose.to_i) > 0)
                org = @org[choose.to_i-1]
            else
                puts 'Hai inserito un valore non valido, riprova:'
                select
            end
        end
        return org
    end

    def get_org
        return $data['organizations'].keys
    end
end