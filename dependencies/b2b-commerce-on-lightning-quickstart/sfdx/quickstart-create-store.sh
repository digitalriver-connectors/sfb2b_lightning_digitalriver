#!/bin/sh
# Use this command to create a new store.
# The name of the store can be passed as a parameter.

function echo_attention() {
  local green='\033[0;32m'
  local no_color='\033[0m'
  echo -e "${green}$1${no_color}"
}

function error_and_exit() {
   echo "$1"
   exit 1
}

storename=""
if [ -z "$1" ]
then
    echo "A new store will be created... Please enter the name of the store: "
    read storename
else
    storename=$1
fi
sfdx force:community:create --name "$storename" --templatename "B2B Commerce (LWR)" --urlpathprefix "$storename" --description "Store $storename created by Quick Start script."
echo "When your site (community) is ready it will appear in the list. After verifying that the new store is created, run the quickstart-setup-store.sh script with the store name ('$storename') as parameter."

## Make sure the Store is created and StoreId is available
storeId=""

while [ -z "${storeId}" ];
do
    echo_attention "Store not yet created, waiting 10 seconds..."
    storeId=$(sfdx force:data:soql:query -q "SELECT Id FROM WebStore WHERE Name='${storename}' LIMIT 1" -r csv |tail -n +2)
    echo "Store ID::>> $storeId"
    sleep 30
done

echo ""

echo_attention "Store found with id ${storeId}"
echo ""