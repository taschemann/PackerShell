variable "disk_size" {
    type = uint
    default = 40960
    description = The size, in megabytes, of the hard disk to create for the VM. By default, this is 40 GB.
}

variable "use_legacy_network_adapter" {
    type = bool
    default = "false"
    description = "If true use a legacy network adapter as the NIC. This defaults to false. A legacy network adapter is fully emulated NIC, and is thus supported by various exotic operating systems, but this emulation requires additional overhead and should only be used if absolutely necessary."
}

variable "differencing_disk" {
    type = bool
    default = "false"
    description = "If true enables differencing disks. Only the changes will be written to the new disk. This is especially useful if your source is a VHD/VHDX. This defaults to false."
}

variable "use_fixed_vhd_format" {
    type = bool
    default = "false"
    description = "If true, creates the boot disk on the virtual machine as a fixed VHD format disk. The default is false, which creates a dynamic VHDX format disk. This option requires setting generation to 1, skip_compaction to true, and differencing_disk to false. Additionally, any value entered for disk_block_size will be ignored. The most likely use case for this option is outputing a disk that is in the format required for upload to Azure."
}

variable "disk_block_size" {
    type = uint
    default = 32
    description = "The block size of the VHD to be created. Recommended disk block size for Linux hyper-v guests is 1 MiB. This defaults to 32 MiB."
}

variable "memory" {
    type = uint
    default = "2048"
    description = "The amount, in megabytes, of RAM to assign to the VM. By default, this is 1 GB."
}

variable "secondary_iso_images" {
    type = []string
    default = null
    description = "A list of ISO paths to attach to a VM when it is booted. This is most useful for unattended Windows installs, which look for an Autounattend.xml file on removable media. By default, no secondary ISO will be attached."
}

variable "switch_name" {
    default = "packer-internal-switch"
}
variable "switch_vlan_id" {
    default = "1"
}
variable "vlan_id" {
    default = "1"
}
variable "cpus" {
    default = "2"
}
variable "generation" {
    default = 1
}
variable "enable_mac_spoofing" {
    type = bool
    default = "false"
}
variable "enable_dynamic_memory" {}
variable "enable_secure_boot" {}
variable "secure_boot_template" {}
variable "enable_virtualization_extensions" {}
variable "temp_path" {}
variable "configuration_version" {}
variable "keep_registered" {}
variable "communicator" {}
variable "skip_compaction" {}
variable "skip_export" {}
variable "headless" {}
variable "first_boot_device" {}
variable "http_directory" {
    default = ".\\shared\\http"
}
variable "shutdown_command" {}
variable "shutdown_timeout" {}
variable "floppy_files" {}
variable "floppy_dirs" {}
variable "floppy_label" {}

          "disk_size": "{{user `disk_size`}}",
          "cpus": "{{user `cpu`}}",
          "memory": "{{user `ram_size`}}",
          "http_directory": "scripts",
          "floppy_files": [
            "{{ user `unattend_file` }}",
            "scripts/ConfigureRemotingForAnsible.ps1",
            "scripts/run-sysprep.cmd",
            "scripts/SetupComplete.cmd"
          ],
          "headless": false,
          "generation": "{{user `generation`}}",
          "iso_urls": "{{user `iso_url`}}",
          "iso_checksum_type": "{{user `iso_checksum_type`}}",
          "iso_checksum": "{{user `iso_checksum`}}",
          "communicator": "{{user `communicator`}}",
          "winrm_username": "{{user `username`}}",
          "winrm_password": "{{user `password`}}",
          "winrm_timeout" : "4h",
          "shutdown_command": "a:\\run-sysprep.cmd",
          "output_directory": "{{user `output_directory`}}",
          "skip_export": "{{user `skip_export`}}"

                    "type": "hyperv-iso",
          "vm_name": "{{user `vm_name`}}",
          "disK_size": "{{user `disk_size`}}",
          "cpus": "{{user `cpu`}}",
          "memory": "{{user `ram_size`}}",
          "boot_command": [
            "setup.exe /ConfigFile:http://{{ .HTTPIP }}:{{ .HTTPPort }}/SetupConfig.ini"
          ],
          "floppy_files": [
            "scripts/serverstandard/autounattend.xml",
            "scripts/ConfigureRemotingForAnsible.ps1",
            "scripts/run-sysprep.cmd",
            "../shared/windows/SetupComplete.cmd"
          ],
          "http_directory": "scripts",
          "generation": "1",
          "headless": false,
          "iso_urls": "{{user `iso_url`}}",
          "iso_checksum_type": "{{user `iso_checksum_type`}}",
          "iso_checksum": "{{user `iso_checksum`}}",
          "communicator": "{{user `communicator`}}",
          "winrm_username": "{{user `username`}}",
          "winrm_password": "{{user `password`}}",
          "winrm_timeout" : "4h",
          "output_directory": "output/hyperv"