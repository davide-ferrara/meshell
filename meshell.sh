#!/bin/bash

help="Usage: $0 [start <vm_name>|start all|stop <vm_name>|status|ls|ssh <vm_name>|--h]"
lab_machines=("lab1" "lab2" "lab3" "lab4")

if [[ $# -lt 1 ]]; then
  echo "$help"
  exit 1
fi

case "$1" in

  "start")
    if [[ -z "$2" ]]; then
      echo "Usage: $0 start <vm_name>|all"
      exit 1
    fi

    if [[ "$2" == "all" ]]; then
      echo "Starting all VMs..."
      for vm in "${lab_machines[@]}"; do
        echo "Starting $vm..."
        VBoxManage startvm "$vm" --type headless
      done
    else
      echo "Starting VM: $2"
      VBoxManage startvm "$2" --type headless
    fi
    ;;

  "stop")
    if [[ -z "$2" ]]; then
      echo "Usage: $0 stop <vm_name>|all"
      exit 1
    fi

    if [[ "$2" == "all" ]]; then
      echo "Stopping all VMs..."
      for vm in "${lab_machines[@]}"; do
        echo "Stopping $vm..."
        VBoxManage controlvm "$vm" acpipowerbutton
      done
    else
      echo "Stopping VM: $2"
      VBoxManage controlvm "$2" acpipowerbutton
    fi
    ;;

  "status")
    echo "Currently running VMs:"
    VBoxManage list runningvms
    ;;

  "ls")
    echo "Available VMs:"
    VBoxManage list vms
    ;;

  "rm")
    echo "INOP"
    ;;


  "--cmd")
    case $2 in
      "meshell-update")
        echo "Aggiornado Meshell"
        cd /usr/share/meshell/
        git pull
        cd
        ;; 
      "cd")
        echo "Eseguendo 'cd': Permette di cambiare directory"
        cd $(meshell_list_dirs) >> /dev/null
        ;; 
      "cdback")
        cd .. >> /dev/null
        ;; 
      "cdhome")
        cd ~ >/dev/null
        ;;
      "cdroot")
        cd / >/dev/null
        ;;
      "ls")
        echo "Eseguendo 'ls -la': Elenca i file e le directory con i dettagli."
        ls -la
        ;; 
      "inode")
        echo "Eseguendo 'ls -li': Elenca i file e le directory con i dettagli e gli inode."
        ls -li
        ;; 
      "pwd")
        echo "Eseguendo 'pwd': Mostra la working directory."
        pwd
        ;; 
      "uptime")
        echo "Eseguendo 'uptime -p': Mostra da quanto tempo il sistema è attivo."
        uptime -p
        ;; 
      "free")
        echo "Eseguendo 'free -h': Mostra l'utilizzo della memoria in formato leggibile."
        free -h
        ;; 
      "ps")
        echo "Eseguendo 'ps aux --forest': Mostra i processi in esecuzione in una struttura ad albero."
        ps aux --forest
        ;; 
      "searchps")
        echo "Eseguendo 'ps aux | grep \$name': Mostra i processi con quel nome."
        read -p "Nome del processo da cercare: " psname
        ps aux | grep $psname
        ;; 
      "w")
        echo "Eseguendo 'w': Mostra chi è loggato."
        w
        ;; 
      "last")
        echo "Eseguendo 'last -n 10': Mostra gli ultimi 10 login."
        last -n 10
        ;; 
      "df")
        echo "Eseguendo 'df -hT': Mostra l'utilizzo dello spazio su disco in formato leggibile."
        df -hT
        ;; 
      "id")
        echo "Eseguendo 'id': Mostra l'ID dell'utente e del gruppo."
        id
        ;; 
      "whoami")
        echo "Eseguendo 'whoami': Mostra l'utente corrente."
        whoami
        ;; 
      "shutdown")
        echo "Eseguendo 'shutdown': Arresta il sistema."
        shutdown
        ;; 
      "reboot")
        echo "Eseguendo 'reboot': Riavvia il sistema."
        reboot
        ;; 
      "top")
        echo "Eseguendo 'top': Mostra i processi in esecuzione e l'utilizzo delle risorse."
        top
        ;; 
      "kill")
        echo -n "Inserisci l'ID del processo da terminare: "
        read pid
        echo "Eseguendo 'kill $pid': Termina il processo con l'ID specificato."
        kill $pid
        ;; 
      "update")
        echo "Eseguendo 'sudo apt update && sudo apt upgrade': Aggiorna l'elenco dei pacchetti e aggiorna i pacchetti installati."
        sudo apt update && sudo apt -y upgrade
        ;; 
      "install")
        echo -n "Inserisci il nome del pacchetto da installare: "
        read package
        echo "Eseguendo 'sudo apt install $package': Installa il pacchetto specificato."
        sudo apt install -y $package
        ;; 
      "search")
        echo -n "Inserisci il nome del pacchetto da cercare: "
        read package
        echo "Eseguendo 'apt search $package': Cerca il pacchetto specificato."
        apt search $package
        ;; 
      "remove")
        echo -n "Inserisci il nome del pacchetto da rimuovere: "
        read package
        echo "Eseguendo 'sudo apt remove $package': Rimuove il pacchetto specificato."
        sudo apt remove -y $package
        ;; 
      "touch")
        echo -n "Inserisci il nome del file da creare: "
        read filename
        echo "Eseguendo 'touch $filename': Crea un file vuoto con il nome specificato."
        touch $filename
        ;; 
      "tree")
        echo "Eseguendo 'tree -L $n': Mostra la struttura delle directory ad albero."
        read -p "Fino a che livello vuoi scendere? " n
        echo $n
        if [[ -z "$n" ]]; then
          tree -L 1
        fi
        tree -L $n
        ;; 
      "ln")
        echo -n "Inserisci il file da linkare simbolicamente: "
        read source
        echo -n "Inserisci il percoorso di destinazione: "
        read dest
        echo "Eseguendo 'ln -s $source $dest': Crea un collegamento simbolico."
        ln -s $source $dest
        ;; 
      "umask")
        UMASK_ATTUALE=$(umask)
        echo "umask (User Mask) DEFINISCE i permessi di default per i nuovi file/directory."
        echo "--------------------------------------------------------"
        echo "UMASK SOTTRAE i permessi che NON vuoi che vengano assegnati, dai massimi permessi possibili."
        echo ""
        echo "   - Massimi per i FILE:      666 (rw-rw-rw-)"
        echo "   - Massimi per DIRECTORY:   777 (rwxrwxrwx)"
        echo ""
        echo "Umask impostata a 022. Significa: togli il permesso di scrittura (2) al Gruppo e agli Altri."
        echo ""
        echo "   - Calcolo per DIRECTORY: 777 - 022 = 755 (rwxr-xr-x)"
        echo "   - Calcolo per FILE:      666 - 022 = 644 (rw-r--r--)"
        echo "--------------------------------------------------------"
        echo "1) Umask Attuale"
        echo "L'umask corrente è: $UMASK_ATTUALE"

        echo -n "Inserisci il valore della maschera (es. 022): "
        read mask

        if [ -z "$mask" ]; then
            echo "Errore: Nessun valore inserito. Umask non modificata."
            echo "Umask attuale rimane: $(umask)"
            exit 1
        fi
            umask "$mask"
            echo "Umask impostato su: $(umask)"
        ;; 
      "chmod")
        echo "Guida rapida ai Permessi (Formato Ottale UGO):"
        echo "Ogni cifra (Utente/Gruppo/Altri) è la somma di (4=Lettura, 2=Scrittura, 1=Esecuzione)"
        echo ""

        echo "--------------------------------------------------------"
        echo "  Permesso | Significato UGO (rwx) | Uso Comune"
        echo "--------------------------------------------------------"
        echo "  777      | rwxrwxrwx             | Tutti i permessi (ATTENZIONE!)"
        echo "  755      | rwxr-xr-x             | Script Eseguibili e Directory Standard"
        echo "  700      | rwx------             | Accesso Completo Solo Utente (Massima Privacy)"
        echo "  644      | rw-r--r--             | File di Testo/Documenti Standard"
        echo "  600      | rw-------             | File Configurazione Privati"
        echo "--------------------------------------------------------"
        echo ""

        echo -n "Inserisci i permessi (es. 755): "
        read permissions

        if [ -z "$permissions" ]; then
          echo "Errore: Permessi non inseriti. Operazione annullata."
          exit 1
        fi

        echo -n "Inserisci il nome del file: "
        read filename

        if [ -z "$filename" ]; then
          echo "Errore: Nome file non inserito. Operazione annullata."
          exit 1
        fi

        if [ ! -e "$filename" ]; then
          echo "Attenzione: Il file '$filename' non esiste. Lo creo per l'esempio."
          touch "$filename"
        fi

        echo "Eseguendo 'chmod $permissions $filename': Cambia i permessi del file."
        chmod $permissions "$filename"

        echo "Permessi aggiornati:"
        ls -l "$filename" | awk '{print $1, $NF}'
        ;; 
      "chown")
        echo -n "Inserisci il nuovo proprietario: "
        read owner
        echo -n "Inserisci il nome del file: "
        read filename
        echo "Eseguendo 'chown $owner $filename': Cambia il proprietario del file."
        sudo chown $owner $filename
        ;; 
      "ping")
        echo -n "Inserisci l'host da pingare: "
        read host
        echo "Eseguendo 'ping $host': Invia pacchetti ICMP all'host specificato."
        ping $host
        ;; 
      "wget")
        echo -n "Inserisci l'URL da scaricare: "
        read url
        echo "Eseguendo 'wget $url': Scarica un file dall'URL specificato."
        wget $url
        ;; 
      "curl")
        echo -n "Inserisci l'URL da scaricare: "
        read url
        echo "Eseguendo 'curl $url': Scarica il contenuto di un URL."
        curl $url
        ;; 
      "ip")
        echo "Eseguendo 'ip a': Mostra le informazioni sull'interfaccia di rete."
        ip a
        ;; 
      "netcat")
        echo -n "Inserisci l'host a cui connettersi: "
        read host
        echo -n "Inserisci la porta: "
        read port
        echo "Eseguendo 'netcat $host $port': Stabilisce una connessione TCP con l'host e la porta specificati."
        netcat $host $port
        ;; 
      "portmap")
        echo "Eseguendo 'portmap': Mostra le informazioni sulla mappatura delle porte RPC."
        portmap
        ;; 
      "dig")
        echo -n "Inserisci il dominio da interrogare: "
        read domain
        echo "Eseguendo 'dig $domain': Interroga i server DNS per informazioni sul dominio."
        dig $domain
        ;; 
      "host")
        echo -n "Inserisci il dominio o l'indirizzo IP da interrogare: "
        read host
        echo "Eseguendo 'host $host': Esegue una ricerca DNS per l'host specificato."
        host $host
        ;; 
      "nslookup")
        echo -n "Inserisci il dominio da interrogare: "
        read domain
        echo "Eseguendo 'nslookup $domain': Interroga i server dei nomi per informazioni sul dominio."
        nslookup $domain
        ;; 
      "which")
        echo -n "Inserisci il nome del comando: "
        read command
        echo "Eseguendo 'which $command': Mostra il percorso completo del comando."
        which $command
        ;; 
      "find")
        echo -n "Inserisci il percorso in cui cercare: "
        read path
        echo -n "Inserisci il nome del file da cercare: "
        read filename
        echo "Eseguendo 'find $path -name $filename': Cerca i file con il nome specificato."
        find $path -name $filename
        ;; 
      "type")
        echo -n "Inserisci il nome del comando: "
        read command
        echo "Eseguendo 'type $command': Mostra il tipo di comando."
        type $command
        ;; 
      "file")
        echo -n "Inserisci il nome del file: "
        read filename
        echo "Eseguendo 'file $filename': Determina il tipo di file."
        file $filename
        ;; 
      "alias")
        echo -n "Inserisci il nome dell'alias: "
        read alias_name
        echo -n "Inserisci il comando per l'alias: "
        read command
        echo "Eseguendo 'alias $alias_name=\"$command\"': Crea un alias per un comando."
        echo "alias $alias_name='$command'" >> ~/.bash_aliases
        source ~/.bash_aliases
        ;; 
      "alias-remove")
        vi ~/.bash_aliases
        ;; 
      "mkdir")
        echo -n "Inserisci il nome della cartella da creare: "
        read folder_name
        echo "Eseguendo 'mkdir $folder_name': Crea una nuova directory."
        mkdir $folder_name
        ;; 
      "passwd")
        echo -n "Passwd permette di cambiare la password dell'utente corrente."
        echo ""
        passwd
        ;;
      "sudash")
        echo -n "Eseguendo: su -utente. Permette di cambiare utente."
        echo ""
        echo "Inserisci il nome dell'utente: "
        read user
        su - $user
        ;;
      "useradd")
        echo -n "Inserisci il nome utente da creare: "
        read username
        # -m -> Crea la directory Home
        # -s /bin/bash -> Imposta la shell
        echo "Eseguendo 'sudo useradd -m -s /bin/bash $username'..."
        sudo useradd -m -s /bin/bash $username

        echo "--------------------------------------------------------"
        echo "Ora imposta la password per $username:"
        sudo passwd $username
        echo "--------------------------------------------------------"
        echo "Utente $username creato con successo."
        ;;
      "userlock")
        echo -n "Inserisci il nome utente da bloccare: "
        read user
        echo "Eseguendo 'sudo usermod -L $user': Blocca l'utente $user."
        echo ""
        sudo usermod -L $user
        echo "Utente $user bloccato con successoo."
        ;; 
      "userdel")
        echo -n "Inserisci il nome utente da eliminare: "
        read username
        echo "Eseguendo 'sudo userdel $username': Elimina un utente."
        # -f -> forced,-r rimuove la home directory
        sudo userdel -fr $username
        ;; 
      "groups")
        echo "Eseguendo il comando: groups\n"
        echo -n "Gruppi a cui appartiene $(whoami): \n"
        groups
        ;; 
      "groupadd")
        echo -n "Inserisci il nome del gruppo da creare: "
        read group_name
        echo "Eseguendo 'sudo groupadd $group_name': Crea un nuovo gruppo."
        sudo groupadd $group_name
        ;; 
      "groupdel")
        echo -n "Inserisci il nome del gruppo da eliminare: "
        read group_name
        echo "Eseguendo 'sudo groupdel $group_name': Elimina un gruppo."
        sudo groupdel $group_name
        ;; 
      "showusers")
        echo -n "Utenti del sistema con UID >= 1000 contenuto in /etc/passwd: "
        echo ""
        awk -F: '($3 >= 1000) {print $1}' /etc/passwd
        ;;
      "showgroups")
        echo -n "Gruppi del sistema con UID >= 1000 contenuto in /etc/group: "
        echo ""
        awk -F: '($3 >= 1000) {print $1}' /etc/group
        ;;
      "useraddtogroup")
        echo "Aggiungi un utente ad un gruppo \n"
        echo -n "Inserisci il nome dell'utente da aggiungere al gruppo"
        echo ""
        read user
        echo -n "Inserisci il nome del gruppo a cui aggiungere l'utente"
        echo ""
        read gruop_name
        echo "Eseguendo 'sudo usermod -aG $group_name $user'"
        sudo usermod -aG $gruop_name $user
        ;;
      "history")
        echo "Eseguendo 'history': Mostra la cronologia dei comandi."
        history
        ;; 
      "date")
        echo "Eseguendo 'date': Mostra la data e l'ora correnti."
        date
        ;; 
      "cal")
        echo "Eseguendo 'cal': Mostra il calendario."
        cal
        ;; 
      "uname")
        echo "Eseguendo 'uname -a': Mostra le informazioni di sistema."
        uname -a
        ;; 
      "du")
        echo "Eseguendo 'du -h': Mostra l'utilizzo dello spazio su disco in formato leggibile."
        du -h
        ;; 
      "vm_stat")
        echo "Eseguendo 'vm_stat': Mostra le statistiche sulla memoria virtuale."
        vm_stat
        ;; 
      "ifconfig")
        echo "Eseguendo 'ifconfig': Mostra le informazioni sull'interfaccia di rete."
        ifconfig
        ;; 
      "netstat")
        echo "Eseguendo 'netstat -an': Mostra le connessioni di rete, le tabelle di routing, le statistiche dell'interfaccia, le connessioni mascherate e le appartenenze multicast."
        netstat -an
        ;; 
      "route")
        echo "Eseguendo 'netstat -r': Mostra la tabella di routing IP."
        netstat -r
        ;; 
      "arp")
        echo "Eseguendo 'arp -a': Mostra la tabella ARP."
        arp -a
        ;;
      "lshw")
        if ! command -v lshw &> /dev/null
        then
          echo "lshw could not be found"
          echo "Please install it using: sudo apt install lshw"
          exit
        fi
        echo "Eseguendo 'sudo lshw': Mostra le informazioni sull'hardware del sistema."
        sudo lshw
        ;;
      "lsblk")
        if ! command -v lsblk &> /dev/null
        then
          echo "lsblk could not be found"
          echo "Please install it using: sudo apt install util-linux"
          exit
        fi
        echo "Eseguendo 'lsblk': Mostra i dispositivi a blocchi."
        lsblk
        ;;
      "lspci")
        if ! command -v lspci &> /dev/null
        then
          echo "lspci non é stato trovato"
          echo "Installalo usando: sudo apt install pciutils"
          exit
        fi
        echo "Eseguendo 'lspci': Mostra i dispositivi PCI."
        lspci
        ;;
      "lsusb")
        if ! command -v lsusb &> /dev/null
        then
          echo "lsusb non é stato trovato."
          echo "Installalo usando: sudo apt install usbutils"
          exit
        fi
        echo "Eseguendo 'lsusb': Mostra i dispositivi USB."
        lsusb
        ;;
      "lsmod")
        echo "Eseguendo 'lsmod': Mostra i moduli del kernel."
        lsmod
        ;;
      "dmesg")
        echo "Eseguendo 'dmesg': Mostra i messaggi del kernel."
        dmesg
        ;;
      "journalctl")
        echo "Eseguendo 'journalctl': Mostra il journal di sistema."
        journalctl
        ;;
      "prompt")
        echo -n "Prompt della shell corrente: "
        echo $PS1
        ;;
      "path")
        echo -n "Percorso dal quale la shell cerca gli esecuibili: "
        echo $PATH
        ;;
      "bashrc")
        vi ~/.bashrc
        ;;
      esac
      ;;

    "--h" | "--help" | "help")

      echo "$help"
      ;; 

    *)
      echo "$help"
      ;; 
  esac
