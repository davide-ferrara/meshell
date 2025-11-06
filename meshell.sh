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
        ;; 
      "cd")
        echo "Eseguendo 'cd': Permette di cambiare directory"
        cd $(meshell_list_dirs) >> /dev/null
        ;; 
      "cdback")
        cd ..
        ;; 
      "cdhome")
        cd ~
        ;;
      "cdroot")
        cd /
        ;;
      "ls")
        echo "Eseguendo 'ls -la': Elenca i file e le directory con i dettagli."
        ls -la
        ;; 
      "inode")
        echo "Eseguendo 'ls -ll': Elenca i file e le directory con i dettagli e gli inode."
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
        echo -n "Inserisci l\'ID del processo da terminare: "
        read pid
        echo "Eseguendo 'kill $pid': Termina il processo con l\'ID specificato."
        kill $pid
        ;; 
      "update")
        echo "Eseguendo 'sudo apt update && sudo apt upgrade': Aggiorna l\'elenco dei pacchetti e aggiorna i pacchetti installati."
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
        sudo apt remove $package
        ;; 
      "touch")
        echo -n "Inserisci il nome del file da creare: "
        read filename
        echo "Eseguendo 'touch $filename': Crea un file vuoto con il nome specificato."
        touch $filename
        ;; 
      "tree")
        echo "Eseguendo 'tree -L \$n': Mostra la struttura delle directory ad albero."
        read -p "Fino a che livello vuoi scendere? " n
        echo $n
        if [[ -z "$n" ]]; then
          tree -L 1
        fi
        tree -L $n
        ;; 
      "ln")
        echo -n "Inserisci il percorso di destinazione: "
        read target
        echo -n "Inserisci il nome del collegamento: "
        read link_name
        echo "Eseguendo 'ln -s $target $link_name': Crea un collegamento simbolico."
        ln -s $target $link_name
        ;; 
      "umask")
        echo "=========================================================="
        echo "          SPIEGAZIONE DEL COMANDO UMASK"
        echo "=========================================================="
        echo "umask (User Mask) DEFINISCE i permessi di default per i nuovi file/directory."
        echo ""
        echo "FUNZIONAMENTO LOGICO:"
        echo "UMASK SOTTRAE i permessi che NON vuoi che vengano assegnati, dai massimi permessi possibili."
        echo ""
        echo "   - Massimi per i FILE:      666 (rw-rw-rw-)"
        echo "   - Massimi per DIRECTORY:   777 (rwxrwxrwx)"
        echo ""
        echo "=========================================================="
        echo "1) Umask Attuale"
        echo "=========================================================="
        echo "Mostra la maschera di creazione dei file dell'utente ('umask'):"
        echo "--------------------------------------------------------"
        UMASK_ATTUALE=$(umask)
        umask
        echo "--------------------------------------------------------"
        echo "L'umask corrente è: $UMASK_ATTUALE"
        echo "--------------------------------------------------------"

        echo "Umask impostata a 022. Significa: togli il permesso di scrittura (2) al Gruppo e agli Altri."
        echo ""
        echo "   - Calcolo per DIRECTORY: 777 - 022 = 755 (rwxr-xr-x)"
        echo "   - Calcolo per FILE:      666 - 022 = 644 (rw-r--r--)"
        echo "--------------------------------------------------------"
        echo -n "Inserisci il valore della maschera: "
        read mask
        umask $mask
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
        chown $owner $filename
        ;; 
      "ping")
        echo -n "Inserisci l\'host da pingare: "
        read host
        echo "Eseguendo 'ping $host': Invia pacchetti ICMP all\'host specificato."
        ping $host
        ;; 
      "wget")
        echo -n "Inserisci l\'URL da scaricare: "
        read url
        echo "Eseguendo 'wget $url': Scarica un file dall\'URL specificato."
        wget $url
        ;; 
      "curl")
        echo -n "Inserisci l\'URL da scaricare: "
        read url
        echo "Eseguendo 'curl $url': Scarica il contenuto di un URL."
        curl $url
        ;; 
      "ip")
        echo "Eseguendo 'ip a': Mostra le informazioni sull\'interfaccia di rete."
        ip a
        ;; 
      "netcat")
        echo -n "Inserisci l\'host a cui connettersi: "
        read host
        echo -n "Inserisci la porta: "
        read port
        echo "Eseguendo 'netcat $host $port': Stabilisce una connessione TCP con l\'host e la porta specificati."
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
        echo -n "Inserisci il dominio o l\'indirizzo IP da interrogare: "
        read host
        echo "Eseguendo 'host $host': Esegue una ricerca DNS per l\'host specificato."
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
        echo -n "Inserisci il nome dell\'alias: "
        read alias_name
        echo -n "Inserisci il comando per l\'alias: "
        read command
        echo "Eseguendo 'alias $alias_name=\"$command\"': Crea un alias per un comando."
        alias $alias_name="$command"
        ;; 
      "alias-remove")
        echo -n "Inserisci il nome dell\'alias da rimuovere: "
        read alias_name
        echo "Eseguendo 'unalias $alias_name': Rimuove un alias."
        unalias $alias_name
        ;; 
      "mkdir")
        echo -n "Inserisci il nome della cartella da creare: "
        read folder_name
        echo "Eseguendo 'mkdir $folder_name': Crea una nuova directory."
        mkdir $folder_name
        ;; 
      "useradd")
        echo -n "Inserisci il nome utente da creare: "
        read username
        echo "Eseguendo 'sudo useradd $username': Crea un nuovo utente."
        sudo useradd $username
        ;; 
      "userdel")
        echo -n "Inserisci il nome utente da eliminare: "
        read username
        echo "Eseguendo 'sudo userdel $username': Elimina un utente."
        sudo userdel $username
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
      "usermod")
        echo -n "Inserisci il nome utente da modificare: "
        read username
        echo -n "Inserisci il nuovo gruppo: "
        read group_name
        echo "Eseguendo 'sudo usermod -aG $group_name $username': Aggiunge un utente a un gruppo."
        sudo usermod -aG $group_name $username
        ;; 
      "history")
        echo "Eseguendo 'history': Mostra la cronologia dei comandi."
        history
        ;; 
      "date")
        echo "Eseguendo 'date': Mostra la data e l\'ora correnti."
        date
        ;; 
      "cal")
        echo "Eseguendo 'cal': Mostra il calendario."
        cal
        ;; 
      "weather")
        echo "Eseguendo 'curl wttr.in': Mostra le condizioni meteorologiche correnti."
        curl wttr.in
        ;; 
      "uname")
        echo "Eseguendo 'uname -a': Mostra le informazioni di sistema."
        uname -a
        ;; 
      "du")
        echo "Eseguendo 'du -h': Mostra l\'utilizzo dello spazio su disco in formato leggibile."
        du -h
        ;; 
      "vm_stat")
        echo "Eseguendo 'vm_stat': Mostra le statistiche sulla memoria virtuale."
        vm_stat
        ;; 
      "ifconfig")
        echo "Eseguendo 'ifconfig': Mostra le informazioni sull\'interfaccia di rete."
        ifconfig
        ;; 
      "netstat")
        echo "Eseguendo 'netstat -an': Mostra le connessioni di rete, le tabelle di routing, le statistiche dell\'interfaccia, le connessioni mascherate e le appartenenze multicast."
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
      "psu")
        echo "Eseguendo 'ps -u $USER': Mostra i processi dell'utente corrente."
        ps -u $USER
        ;;
      "sar")
        if ! command -v sar &> /dev/null
        then
          echo "sar could not be found"
          echo "Please install it using: sudo apt install sysstat"
          exit
        fi
        echo "Eseguendo 'sar -u 1 5': Mostra l'utilizzo della CPU negli ultimi 5 secondi."
        sar -u 1 5
        ;;
      "lsof")
        if ! command -v lsof &> /dev/null
        then
          echo "lsof could not be found"
          echo "Please install it using: sudo apt install lsof"
          exit
        fi
        echo "Eseguendo 'lsof': Mostra i file aperti."
        lsof
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
          echo "lspci could not be found"
          echo "Please install it using: sudo apt install pciutils"
          exit
        fi
        echo "Eseguendo 'lspci': Mostra i dispositivi PCI."
        lspci
        ;;
      "lsusb")
        if ! command -v lsusb &> /dev/null
        then
          echo "lsusb could not be found"
          echo "Please install it using: sudo apt install usbutils"
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
      "systemctl")
        echo "Eseguendo 'systemctl': Mostra lo stato dei servizi di sistema."
        systemctl
        ;;
      "timers")
        echo "Eseguendo 'systemctl list-timers': Mostra i timer di sistema."
        systemctl list-timers
        ;;
      "sockets")
        echo "Eseguendo 'systemctl list-sockets': Mostra i socket di sistema."
        systemctl list-sockets
        ;;
      "targets")
        echo "Eseguendo 'systemctl list-units --type=target': Mostra i target di sistema."
        systemctl list-units --type=target
        ;;
      "devices")
        echo "Eseguendo 'systemctl list-units --type=device': Mostra i device di sistema."
        systemctl list-units --type=device
        ;;
      "mounts")
        echo "Eseguendo 'systemctl list-units --type=mount': Mostra i mount di sistema."
        systemctl list-units --type=mount
        ;;
      "automounts")
        echo "Eseguendo 'systemctl list-units --type=automount': Mostra gli automount di sistema."
        systemctl list-units --type=automount
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
