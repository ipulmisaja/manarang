# Manarang Script
Bash script yang mirip dengan cara kerja laravel homestead tapi digunakan di linux xampp.

## Tata Cara Menggunakan
> Script ini membutuhkan paket yq dari mikefarah [yq yaml](https://mikefarah.gitbook.io/yq) untuk dapat membaca file YAML.
> Script ini membutuhkan dnsmasq untuk automatic dns

1. Setelah memasang Linux XAMPP Langkah Selanjutnya adalah
- Ubah htdocs ke template (tutorial terlampir)
- Aktifkan virtualhost pada linux xampp
- pada file httpd.conf tambahkan pada baris terakhir pattern **# Mulai Aliases** sebagai penanda untuk script mulai mengedit file.
- pada file httpd-vhosts.conf tambahkan pada baris terakhir pattern **# Mulai Vhosts** sebagai penanda untuk script mulai mengedit file.

2. Install nettools dilinux (sudo apt install net-tools)
3. Install yq package dengan cara
   sudo add-apt-repository ppa:rmescandon/yq
   sudo apt update
   sudo apt install yq -y
4. Clone Repo ini ke dalam folder Public
5. Buat script untuk akses global ke folder manarang
   function manarang() {
        cd ~/Public/Manarang
        
        command="$1"
        
        if [ "$command" = "edit" ]; then
            # Sesuaikan dengan editor anda
            kate manarang.yaml 
        elif [ "$command" = "provision" ]; then
            bash manarang.sh
        elif [ "$command" = "up" ]; then
            (sudo /opt/lampp/lampp start)
        elif [ "$command" = "halt" ]; then
            (sudo /opt/lampp/lampp stop)
        else
            (sudo /opt/lampp/lampp restart)
        fi
        
        cd -
   }
