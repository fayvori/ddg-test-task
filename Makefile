DEBIAN_TRIXIE_QCOW_FILE_NAME = debian-13-generic-amd64.qcow2
DEBIAN_TRIXIE_URL = https://cloud.debian.org/images/cloud/trixie/latest/$(DEBIAN_TRIXIE_QCOW_FILE_NAME)

VIRSH = virsh -c qemu:///session
VIRSH_SYSTEM = sudo virsh -c qemu:///system

TEMP_PRIV_KEY_LOCATION = build/temp_rsa_key
TEMP_PUB_KEY_LOCATION = build/temp_rsa_key.pub

$(TEMP_PUB_KEY_LOCATION):
		@echo "Generating temporary SSH key pair in build/ folder ..."
		@mkdir -p build
		@ssh-keygen -t rsa -b 2048 -f $(TEMP_PRIV_KEY_LOCATION) -N "" -C "temporary-vm-key" -q
		@echo "Public key saved to $(TEMP_PUB_KEY_LOCATION)"

check_if_cloud_localds_is_installed:
	@which cloud-localds > /dev/null 2>&1 || { \
		echo "Error: cloud-localds is not installed. Check README for explanation why we need it"; \
		echo "To install it on Debian/Ubuntu systems:"; \
		echo "  sudo apt update && sudo apt install cloud-image-utils"; \
		echo "For RHEL/CentOS/Fedora systems:"; \
		echo "  sudo dnf install cloud-utils"; \
		exit 1; \
	}

VM_NAMES = iperf-compute-1 iperf-compute-2 monitoring-compute-3

# Check if debian 13 cloud image is presented in current directory, if not - download it
$(DEBIAN_TRIXIE_QCOW_FILE_NAME): check_if_cloud_localds_is_installed $(TEMP_PUB_KEY_LOCATION)
	@echo "To create VMs script needs to download Debian 13 (trixie) cloud image from $(DEBIAN_TRIXIE_URL). Proceed? [Y/n]"
	@read line; if [ $$line = "n" ]; then echo Aborting; exit 1; fi
	
	@echo "Downloading Debian 13 cloud image..."
	curl -L -o $@ $(DEBIAN_TRIXIE_URL)
	@test -f $@ || (echo "Download for Debian 13 (Trixie) cloud image failed!" && exit 1)

# This subnet is defined in files/iperf-network.xml
VIRSH_NETWORK_BASE_IP = "192.168.100"
VIRSH_NETWORK_GATEWAY = "192.168.100.1"
VIRSH_NETWORK_NAME = "iperf-net"

.sudo-init:
	sudo -v	

# Creating a new dedicated subnet for this env
define_iperf_network: .sudo-init
	$(VIRSH_SYSTEM) net-define files/iperf-network.xml
	$(VIRSH_SYSTEM) net-start $(VIRSH_NETWORK_NAME)
	$(VIRSH_SYSTEM) net-autostart $(VIRSH_NETWORK_NAME)

provision_vms: $(DEBIAN_TRIXIE_QCOW_FILE_NAME) define_iperf_network
	@for vm in $(VM_NAMES); do \
		./provision_vm.sh \
			$(DEBIAN_TRIXIE_QCOW_FILE_NAME) \
			$$vm \
			$(VIRSH_NETWORK_NAME) \
			$(VIRSH_NETWORK_BASE_IP) \
			$(VIRSH_NETWORK_GATEWAY) \
			$(TEMP_PUB_KEY_LOCATION); \
	done

	@echo "All VM's successfully provisioned"

clean: .sudo-init
	# Stop & undefine all virtual machines and also remove thier storage
	@for vm in $(VM_NAMES); do \
		$(VIRSH_SYSTEM) destroy --domain $$vm 2>/dev/null || true; \
 		$(VIRSH_SYSTEM) undefine --domain $$vm --remove-all-storage --nvram 2>/dev/null || true; \
	done

	# Stop & undefine iperf-net virsh network
	$(VIRSH_SYSTEM) net-destroy $(VIRSH_NETWORK_NAME) 2>/dev/null || true
	$(VIRSH_SYSTEM) net-undefine $(VIRSH_NETWORK_NAME) 2>/dev/null || true
	
	# Remove build artifacts
	rm -rf build
