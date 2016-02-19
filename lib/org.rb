require "#{ChangeHosts::LibDir}/data_writer.rb"

class Org
    def initialize
        @org = get_org
    end

    def list
        count = 1
        puts ""
        puts "n   |   Org"
        puts "-   |   ---"
        @org.each do |o|
            if count < 10
                puts "#{count}   |   #{o}"
            else
                puts "#{count}  |   #{o}"
            end
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
            print "Inserisci il nome: "
            name = STDIN.gets.chomp.downcase
            add(name)
        end
    end

    def modify
        list
        print "Inserisci il numero corrispondente all'opzione: "
        num = STDIN.gets.chomp.to_i
        if num.between?(1,@org.length)
            print "Inserisci il nuovo nome (o lascia vuoto per non modificare): "
            name = STDIN.gets.chomp
            old_name = @org[num-1]
            if (name.empty? || name == old_name)
                puts "Il record non è stato cambiato" 
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

    def select
        list
        print "Inserisci il nome o il numero corrispondente: "
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