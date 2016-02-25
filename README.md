### CHANGE HOSTS for OSX ###

Piccolo e pratico software per gestire il file host in modo semplice ma soprattutto modulare.  
Sviluppato pensando a situazioni con vari domini locali con proxy e virtualhost con nome di dominio.

## Utilizzo ##

Eseguire il programma con il parametro necessario:  
* '_-a_' o '_add_' seguito da: '_dns_', il nome dell'organizzazione e il nome del record DNS per aggiungerlo; '_hosts_', il nome dell'organizzazione, il nome del record host e dall'indirizzo per aggiungere un record host temporaneo; '_org_' e il nome dell'organizzazione per aggiungerne una;
* '_-d_' o '_default_' per decidere l'host di default per l'organizzazione;
* '_-g_' o '_generate_' per generare il file host in base alle impostazioni selezionate. ATTENZIONE. Sovrascrive il file host esistente senza possibilità di recupero;
* '_-h_' o '_help_' o '_man_' per visualizzare questa guida;
* '_-l_' o '_list_' seguito da '_dns_', '_hosts_' o '_org_' per ottenere l'elenco dei record dns, degli host o delle organizzazioni presenti. Per i DNS e gli Host è possibile specificare immediatamente l'organizzazione voluta postponendone il nome esatto;
* '_-m_' o '_modify_' seguito da '_dns_', '_hosts_' o '_org_' per modificare un record presente;
* '_-r_' o '_remove_' seguito da: '_dns_', il nome dell'organizzazione e il nome per rimuovere un record dns; '_hosts_', il nome dell'organizzazione e il nome per rimuovere un record host temporaneo; '_org_' e il nome dell'organizzazione per rimuoverne una;
* '_-s_' o '_select_' eventualmente seguito dal nome dell'organizzazione per aggiungerla all'elenco delle organizzazioni selezionate;
* '_-u_' o '_unselect_' eventualmente seguito dal nome dell'organizzazione per rimuoverla dall'elenco delle organizzazioni selezionate;
