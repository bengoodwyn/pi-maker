# pi-maker
Scripts for deploying to Raspberry Pi

## Step 1 - Prepare an SD Card

Using a Linux host, execute `sudo ./01_format_sd_card.sh /dev/sdz` where `/dev/sdz` is your SD card device.
If you are unsure which device has your SD card device execute `sudo ./01_format_sd_card.sh` to see a summary of detected devices.
You will be prompted for the 2.4Ghz Wifi SSID and passphrase so that the device will be accessible on your network on the first boot (as `raspberrypi.local`).

## Step 2 - Boot the Raspberry Pi and Perform Initial Setup

Insert the SD Card into the Raspberry Pi and wait for it to boot.
Then execute `./02_first_boot.sh new-host-name` where `new-host-name` is the name you want this Raspberry Pi to have on the network.
When prompted for the SSH password, provide the default password of `raspberry`.

This script will install your user's SSH key for the pi user and rename the device from a default name to one that you have configured.

## Step 3 - Deploy with Ansible

After completing step 2 and waiting for the Raspberry Pi to reboot, run `./03_first_boot.sh new-host-name.local` using the name you assigned in Step 2.
This will:
- disable password logins for SSH
- disable the password for the pi user (use SSH keys!)
- update the Raspbian OS
- Install Wiring Pi
- Install Prometheus Node Exporter

## Enjoy

Your pi is now baked and you can access it with `ssh pi@new-host-name.local` where `new-host-name` is the name you gave your Pi.
