# Manarang Script
*Script* yang menyerupai cara kerja provision pada laravel homestead.

## Cara Menggunakan
> *Script* ini membutuhkan paket **yq** untuk membaca file **YAML**. Dokumentasi paket dapat dilihat pada [yq documentation](https://mikefarah.gitbook.io/yq).


#### - Linux XAMPP
1. Unduh Linux XAMPP pada website **https://www.apachefriends.org/download.html**.
2. Install Linux XAMPP pada direktori **/opt** menggunakan mode root.
3. Buat symlink command **'php', 'composer', 'mysql'** ke direktori **/usr/local/bin**, dengan perintah
   ```
   $ sudo ln -s /opt/lampp/bin/php /usr/local/bin/php
   ...dst untuk command lain
   ```
   > Unduh composer terlebih dahulu.
4. Edit file **httpd.conf** pada direktori **/opt/lampp/etc** dengan mengubah
   - User dan Group ke username sistem
   - DocumentRoot ke path pilihan anda. Saya menggunakan Direktori Templates untuk pengembangan aplikasi.
   - Aktifkan modul VirtualHost
   - Tambahkan pattern **# Mulai Aliases** pada baris paling akhir.
5. Edit file **httpd-vhosts.conf** pada direktori **/opt/lampp/etc/extra** dengan menambahkan pada baris terakhir pattern **# Mulai Vhosts**.

#### - Install Nettools
Linux XAMPP memerlukan nettools untuk dapat beroperasi. Install dengan cara mengetik
```
$ sudo apt install net-tools
```

#### - YQ Package
YQ diperlukan untuk membaca file YAML yang dijadikan sebagai tempat konfigurasi project kita. Install dengan mengetik

```
$ sudo add-apt-repository ppa:rmescandon/yq
$ sudo apt update
$ sudo install yq -y
```

#### - Clone Repository
Clone repository ini kedalam folder **Public**.

#### - Akses Global Script
Untuk bisa mengakses script dari direktori apapun buat fungsi berikut di dalam file **.bashrc**

```
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
```

#### - Pengaturan DNSMASQ
**dnsmasq** diperlukan sebagai forwarding domain pada server lokal (.test) agar dapat diakses browser.
- Install dnsmasq dengan mengetik
  ```
  $ sudo apt install dnsmasq
  ```
- Jika terjadi error port 53 lakukan troubleshoot berikut.
  Ketik pada terminal
  ```
  $ sudo systemctl stop systemd-resolved
  ```
  
  Kemudian edit file systemd-resolve dengan mengetik
  ```
  $ sudo nano /etc/systemd/resolved.conf
  ```
  Ikuti konfigurasi berikut :
  ```
  DNS=127.0.0.1
  FallbackDNS=
  MulticastDNS=no
  DNSSEC=no
  DNSOverTLS=no
  DNSStubListener=no
  ```
  Simpan, kemudian buat symlink dengan mengetik perintah
  ```
  $ sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
  ```
  Jalankan kembali service systemd-resolve dengan cara
  ```
  $ sudo systemctl start systemd-resolved
  ```
- Kemudian edit file **dnsmasq.conf** pada direktori **/etc** lalu tambahkan pada baris paling akhir konfigurasi berikut.

  ```
  domain-needed
  bogus-priv

  # define local domain part
  # this will allow you to have domains with .test extension,
  # so make sure all your development apps are using .test as extension,
  # e.g. somedomain.test, myapp.test
  local=/test/
  domain=test

  # listen on both local machine and private network
  listen-address=127.0.0.1

  # read domain mapping from this file as well as /etc/hosts
  # isikan dengan path file hosts dalam folder Manarang
  addn-hosts=/home/ipulmisaja/Public/Manarang/hosts
  expand-hosts
  ```
  
- Restart dnsmasq dengan mengetik
  ```
  $ sudo systemctl restart dnsmasq
  ```
- Untuk penggunaan permanen ketik
  ```
  $ sudo systemctl enable dnsmasq
  ```
