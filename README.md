Hyper-V:

      {
        "vm_name": "{{user `vm_name`}}",
        "type": "hyperv",
        "iso_urls": "{{user `iso_url`}}",
        "iso_checksum_type": "{{user `iso_checksum_type`}}",
        "iso_checksum": "{{user `iso_checksum`}}",
        "communicator": "{{user `communicator`}}",
        "winrm_username": "{{user `winrm_username`}}",
        "winrm_password": "{{user `winrm_password`}}",
        "winrm_timeout" : "4h",
        "shutdown_command": "run-sysprep.cmd"
      }