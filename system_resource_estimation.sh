#!/bin/bash

# Ini adalah skrip shell Bash yang digunakan untuk mengumpulkan informasi tentang sistem komputer (CPU, RAM, dan lain-lain), 
# serta memberikan estimasi sumber daya yang dibutuhkan untuk menjalankan mesin virtual (VM), container (CT), 
# dan Docker berdasarkan jumlah vCPU yang ditentukan. Skrip ini juga menggunakan beberapa fungsi untuk menampilkan teks dengan warna di terminal.

# Fungsi untuk menambahkan warna
color_red() {
    echo -e "\e[31m$1\e[0m"
}

color_green() {
    echo -e "\e[32m$1\e[0m"
}

color_blue() {
    echo -e "\e[34m$1\e[0m"
}

color_yellow() {
    echo -e "\e[33m$1\e[0m"
}
    

# Dapatkan total RAM sistem dan jumlah core
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Di macOS
    total_ram=$(sysctl hw.memsize | awk '{print $2/1073741824}') # konversi byte ke GB
    total_cores=$(sysctl -n hw.ncpu)
else
    # Di Linux
    total_ram=$(free -g | awk '/Mem:/ {print $2}')
    total_cores=$(grep -c ^processor /proc/cpuinfo)
fi

# Fungsi untuk menampilkan info CPU
display_cpu_info() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # Di macOS
        echo "Informasi CPU:"
        echo "Model name: $(sysctl -n machdep.cpu.brand_string)"
        echo "CPU Speed: $(sysctl -n machdep.cpu.brand_string | awk -F'@' '{print $2}')"
        echo "CPU(s): $(sysctl -n hw.logicalcpu)"
        echo "Core(s) per socket: $(sysctl -n hw.physicalcpu)"
        echo "Thread(s) per core: $(($(sysctl -n hw.logicalcpu) / $(sysctl -n hw.physicalcpu)))"
        echo "Teknologi Virtualisasi: Tidak dapat diambil di macOS"
    else
        # Di Linux
        echo "Informasi CPU:"
        lscpu | grep -E "Architecture|CPU\(s\)|Thread\(s\) per core|Core\(s\) per socket|Socket\(s\)|Model name|Virtualization"
        echo "CPU Speed: $(lscpu | grep 'MHz' | awk '{print $3 " MHz"}')"
        echo
        echo "Informasi Motherboard:"
        sudo dmidecode -t baseboard | grep -E "Manufacturer|Product Name|Version|Serial Number"
    fi
}

# Menampilkan info CPU
echo '================================'
display_cpu_info

# Asumsi untuk estimasi VM, CT, dan Docker
VM_CORE_REQUIREMENT=2.5
VM_RAM_REQUIREMENT=2  # dalam GB
CT_CORE_REQUIREMENT=1.5
CT_RAM_REQUIREMENT=1  # dalam GB

# Menambahkan fungsi untuk mengestimasi VM, CT, dan Docker berdasarkan vCPU
# Fungsi untuk mengestimasi VM, CT, dan Docker berdasarkan vCPU
estimasi_sumber_daya() {
    local core_fisik=$1
    local vcpu_per_core=$2

    local total_vcpu=$(awk "BEGIN {print int($core_fisik * $vcpu_per_core)}")

    local max_vm=$(awk "BEGIN {print int($total_vcpu / $VM_CORE_REQUIREMENT)}")
    local max_ct=$(awk "BEGIN {print int($total_vcpu / $CT_CORE_REQUIREMENT)}")

    color_blue "Dengan asumsi 1 core fisik mendukung $vcpu_per_core vCPU, estimasi sumber daya adalah sebagai berikut:"
    color_green "Total vCPU yang tersedia: $total_vcpu"
    color_green "Jumlah maksimal VM yang bisa dijalankan: $max_vm (menggunakan $VM_CORE_REQUIREMENT core dan $VM_RAM_REQUIREMENT GB RAM per VM)"
    color_green "Jumlah maksimal CT yang bisa dijalankan: $max_ct (menggunakan $CT_CORE_REQUIREMENT core dan $CT_RAM_REQUIREMENT GB RAM per CT)"
    echo
}

# Menambahkan bagian untuk estimasi sumber daya berdasarkan vCPU
read -p "Masukkan jumlah maksimal vCPU per core (misal, antara 2 dan 6): " vcpu_per_core
if [[ $vcpu_per_core -ge 2 && $vcpu_per_core -le 6 ]]; then
    estimasi_sumber_daya $total_cores $vcpu_per_core
else
    echo "Masukkan nilai yang valid (antara 2 dan 6)."
fi
