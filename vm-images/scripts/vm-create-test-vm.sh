#!/bin/bash
# shellcheck disable=SC1091

set -e
set -o errexit
set -o pipefail
# set -o xtrace

# Define colours for output
GREEN="\033[0;32m"
NO_COLOUR="\033[0m"

function usage() {
    cat <<USAGE

    Usage: $0 --metadata-url URL

    Options:
        --metadata-url         Path or URL to template metadata
USAGE
    exit 1
}

# if no arguments are provided, return usage function
if [ $# -eq 0 ]; then
    usage # run usage function
fi

while [ "$1" != "" ]; do
    case $1 in
    --metadata-url)
        shift
        METADATA_URL=$1
        ;;
    *)
        echo "Unexpected argument: '$1'"
        usage
        ;;
    esac

    if [[ -z "$2" ]]; then
      # if no more args then stop processing
      break
    fi

    shift # remove the current value for `$1` and use the next
done

# Get Subscription ID
SUBSCRIPTION_ID=$(az account show --query id --output tsv)

if [[ -z "$METADATA_URL" ]]; then
    echo "Please specify the metadata url" 1>&2
    usage
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$DIR/load_metadata.sh" "$METADATA_URL"

# Create test vm
echo -e "  ${GREEN}Creating ${CVM_TEMPLATE_NAME}01 Test VM${NO_COLOUR}"
az vm create  --name "${CVM_TEMPLATE_NAME}01" \
              --resource-group "${CVM_RESOURCE_GROUP}" \
              --admin-username "${CVM_TEST_VM_USERNAME}" \
              --admin-password "${CVM_TEST_VM_PASSWORD}" \
              --location "uksouth" \
              --image "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${CVM_RESOURCE_GROUP}/providers/Microsoft.Compute/galleries/${CVM_GALLERY_NAME}/images/${CVM_IMAGE_DEFINITION}/versions/latest" \
              --os-disk-delete-option Delete \
              --nic-delete-option Delete \
              --nsg "${CVM_TEMPLATE_NAME}01NSG" \
              --size Standard_D2s_v3
              # --size Standard_D4s_v5