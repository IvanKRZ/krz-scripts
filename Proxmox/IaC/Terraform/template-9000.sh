#!/usr/bin/env bash

# Author: Ivan Krznaric-Bertic, November 2026
# Purpose: Script to set up the Debian cloud image as Proxmox template 9000

# --- CONFIGURATION VARIABLES ---
TEMPLATE_ID="9000"
TEMPLATE_NAME="debian13-cloud"

TARGET_PATH="/var/lib/vz/import/"
IMAGE_FILE_NAME="debian13-cloud.qcow2"
FULL_IMAGE_PATH="${TARGET_PATH}${IMAGE_FILE_NAME}"
AGENT_IMAGE_NAME="debian13-cloud-agent.qcow2"
AGENT_IMAGE_PATH="${TARGET_PATH}${AGENT_IMAGE_NAME}"

TARGET_STORAGE="local-lvm"
BRIDGE="vmbr0"

DOWNLOAD_URL="https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
SHA512SUMS="https://cloud.debian.org/images/cloud/trixie/latest/SHA512SUMS"
# --- END OF CONFIGURATION VARIABLES ---

# Image download
if [ ! -f "${FULL_IMAGE_PATH}" ]; then
    echo -e "\n\e[32mImage: downloading ${IMAGE_FILE_NAME}\e[0m\n"
    wget -O "${FULL_IMAGE_PATH}" "${DOWNLOAD_URL}"
else
    echo -e "\n\e[32mImage file already exists\e[0m\n"
fi

# Checksum variables
EXPECTED_SUM=$(wget -qO- "${SHA512SUMS}" | grep genericcloud-amd64.qcow2 | cut -d' ' -f1)
ACTUAL_SUM=$(sha512sum "${FULL_IMAGE_PATH}" | cut -d' ' -f1)

# Verify checksum of the download
if [ "${EXPECTED_SUM}" = "${ACTUAL_SUM}" ];then
    echo -e "\n\e[32mChecksum correct, image is ready to use\e[0m\n"
else
    echo -e "\n\e[31mERROR: CHECKSUM MISMATCH. DO NOT USE THIS IMAGE!\e[0m\n"
    rm "${FULL_IMAGE_PATH}"
    echo -e "\n\e[31mImage: ${IMAGE_FILE_NAME} removed!\e[0m\n"
    exit 1
fi

# Template configuration
if ! qm config "${TEMPLATE_ID}" > /dev/null 2>&1;then # checks whether the VM already exists
    echo -e "\n\e[32mInstalling qemu-guest-agent into the template image with virt-customize...\e[0m\n"
    cp "${FULL_IMAGE_PATH}" "${AGENT_IMAGE_PATH}"
    if virt-customize -a "${AGENT_IMAGE_PATH}" --install qemu-guest-agent;then # installs guest agent
        echo -e "\n\e[32mQemu guest agent installed in the template image\e[0m\n"
    else
        echo -e "\n\e[31mERROR: qemu-guest-agent installation with virt-customize failed\e[0m\n"
        rm "${AGENT_IMAGE_PATH}"
        echo -e "\n\e[31mFaulty image removed!\e[0m\n"
        exit 1
    fi
    echo -e "\n\e[32mCreating template VM\e[0m\n"
    if qm create "${TEMPLATE_ID}" \
        --name "${TEMPLATE_NAME}" \
        --memory 2048 \
        --cores 2 \
        --net0 virtio,bridge="${BRIDGE}" \
        --scsihw virtio-scsi-pci \
        --scsi0 "${TARGET_STORAGE}":0,import-from="${AGENT_IMAGE_PATH}" \
        --ide2 "${TARGET_STORAGE}":cloudinit \
        --boot order=scsi0 \
        --serial0 socket \
        --vga serial0 \
        --agent enabled=1 \
        --ostype l26;then
        echo -e "\n\e[32mTemplate VM created!\e[0m\n"
    else
        echo -e "\n\e[31mERROR: VM could not be created.\e[0m\n"
        qm destroy "${TEMPLATE_ID}"
        rm "${AGENT_IMAGE_PATH}"
        exit 1
    fi

    if qm template "${TEMPLATE_ID}";then
        echo -e "\n\e[32mTemplate created.\e[0m\n"
    else
        echo -e "\n\e[31mERROR: Template could not be created!\e[0m\n"
        qm destroy "${TEMPLATE_ID}"
        exit 1
    fi

    rm "${AGENT_IMAGE_PATH}"
    echo -e "\n\e[32mModified image no longer needed, removed.\e[0m\n"
    echo -e "\n\e[32mDone!\nTemplate VM created\nVMID: ${TEMPLATE_ID}\nNAME: ${TEMPLATE_NAME}\e[0m\n"
else
    echo -e "\n\e[31mTemplate VM already exists!\nVMID: ${TEMPLATE_ID}\nNAME: ${TEMPLATE_NAME}\e[0m\n"
fi
