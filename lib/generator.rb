class Generator
    def initialize
        puts
        puts ' ####################################'
        puts ' ## --- GENERAZIONE FILE HOSTS --- ##'
        puts ' ####################################'
        puts
        puts ' -- Elenco Organizzazioni Selezionate --'
        ChangeHosts::Config['organizations'].each do |o|
            puts "    - #{o}"
        end
        puts

        generate
    end

    def generate
        fh = File.new("#{ChangeHosts::DataDir}/hosts", "w")

        #header
        $data['extra']['header'].each do |l|
            fh.puts(l)
        end
        fh.puts

        #static
        fh.puts("## STATIC HOSTS ##")
        $data['static'].each do |title,static|
            fh.puts("  # #{title} #")
            static.each do |ip, name|
                fh.puts("    #{ip} #{name.join(' ')}")
            end
        end
        fh.puts
        
        #temp 
        $data['organizations'].each do |org,data|
            if ChangeHosts::Config['organizations'].include? org
                fh.puts("### #{org.upcase}-HOSTS START ###")
                fh.puts("  # #{data['hosts']['selected']} #")
                ip = data['hosts']["#{data['hosts']['selected']}"]
                data['dns'].each do |d|
                    fh.puts("  #{ip} #{d}")
                end
                fh.puts("### #{org.upcase}-HOSTS END ###")
                fh.puts
            end
        end

        fh.close

        puts " !! -- ATTENZIONE -- !!"
        puts "Il file host in /private/etc/hosts e di conseguenza il file in /etc/hosts verrà SOVRASCRITTO senza possibilità di recupero"
        puts
        puts "Se il file è stato modificato manualmente, TALI MODIFICHE ANDRANNO IRRIMEDIABILMENTE PERSE"
        puts
        print 'Continuare? (y|n): '
        choose = STDIN.gets.chomp
        if choose == 'y'
            write_file
        end
    end

    def write_file
        #Sostituisce e mostra il file hosts nel sistema
        %x`cp #{ChangeHosts::DataDir}/hosts /private/etc/`

        File.open("/private/etc/hosts", "r") do |fh|
            while (line = fh.gets)
                puts line
            end
        end
    end
end
