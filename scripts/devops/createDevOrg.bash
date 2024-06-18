#!/bin/bash

orgAlias=$1
devhubAlias=$2
durationDays=$3
syncStoreName="${orgAlias}SyncStore"

function echo_attention() {
  local green='\033[0;32m'
  local no_color='\033[0m'
  echo -e "${green}$1${no_color}"
}

echo ${orgAlias}
if [[ "$orgAlias" =~ ^[[:alnum:]]*$ ]] && [[ ! "orgAlias" =~ ^[[:digit:]]+$ ]]
then
    if [ -z "$orgAlias" ]
    then
        echo "You must enter an alias for the scratch org"
        exit 1
    else
        if [ -z "$devhubAlias" ]
        then
          echo "You must enter a devhub for the scratch org."
          exit 1
        else
          if [ -z "$durationDays" ]
          then
            echo "Creating a Scratch Org with the specified devhub..."
            sfdx force:org:create -s -f config/project-scratch-def.json -a $orgAlias -v $devhubAlias  -d 30 --api-version "55.0" -c            
          else
            echo "Creating a Scratch org with the specified Devhub and duration"
            sfdx force:org:create -s -f config/project-scratch-def.json -a $orgAlias -v $devhubAlias  -d $durationDays --api-version "55.0" -c
          fi
        fi

        sfdx force:org:open
        sleep 10

        echo "Navigate to B2B Commerce Lightning package..."
        cd ./dependencies/b2b-commerce-on-lightning-quickstart/sfdx/

        echo "Set new scratch org as a default for the B2B Commerce Lightning package..."
        sfdx force:config:set target-org=$orgAlias target-dev-hub=$devhubAlias

        echo "Deploy B2B Commerce Lightning package with Metadata API..."
        sfdx project deploy start --target-org $orgAlias

        echo "Navigate back to the DR Connector project root folder..."
        cd ../../../
        echo "Deploying the source of project"
		    sf project deploy start -d ./src/ --target-org $orgAlias
        sf project deploy start -d ./dependencies/b2b-commerce-on-lightning-quickstart/sfdx/force-app/main/default/classes/ --target-org $orgAlias
        sf project deploy start -d ./dependencies/unmanagedPackage/classes/ --target-org $orgAlias

        echo "-------READ BELOW INSTRUCTION-------"
        echo_attention "Creat named credential"
        start chrome https://docs.digitalriver.com/salesforce-lightning/v/salesforce-lightning-b2b-commerce-app-1.1/integrate-the-salesforce-lightning-app/step-3-register-external-services#payment-service
        read -p "After Creation named credential press any key to resume ..."

        sf plugins install @salesforce/commerce
        echo "Navigate to B2B Commerce Lightning package..."
        cd ./dependencies/b2b-commerce-on-lightning-quickstart/sfdx/

        echo "Creating a new store..."
        ./quickstart-create-store.sh "$orgAlias"

        #echo "Create a new Sync store in your new scratch org..."
        #./quickstart-create-store.sh $syncStoreName
        ##echo "Waiting the org to create the store..."
        ##bash ../../../scripts/devops/spinner.sh sleep 60
        
        echo "Setting up the store..."
        ./quickstart-setup-store.sh "$orgAlias"

        echo "Navigate back to the DR Connector project root folder..."
        cd ../../../

        echo "Deploy DR Connector metadata to the org..."
        sfdx project deploy start --ignore-conflicts --target-org $orgAlias

        echo "Deploy unmanaged code..."
        sfdx project deploy start -d ./dependencies/unmanagedPackage/ --target-org $orgAlias -w 10

        echo "Deploy unmanaged code..."
        sfdx project deploy start -d "./src/main/Sync Checkout/flows" --target-org $orgAlias -w 10


        echo "Setup Shipping Service...."
        sfdx force:apex:execute --file ./scripts/devops/packaging/setupShippingService.apex

        echo "Assign required permission set..."
        sfdx force:user:permset:assign -n DigitalRiverConnectorAdmin
        sfdx force:user:permset:assign -n DigitalRiverConnectorShopper
        sfdx force:user:permset:assign -n DigitalRiverConnectorShopper -o "buyer@scratch.org"

        echo "Import tax mapping And ECCN lookup records..."
        sfdx force:data:tree:import -p records/plan-1.json

        echo "Populate DR country Origin on products..."
        sfdx force:apex:execute -f scripts/PopulateProductsFields/PopulateCountryofOrigin

        echo "Populate tax group and type on products..."
        sfdx force:apex:execute -f scripts/PopulateProductsFields/UploadDRTaxGroupandType

        echo "Populate ECCN on products..."
        sfdx force:apex:execute -f scripts/PopulateProductsFields/UploadECCN

        echo "Setup Tax Calculation service..."
        sfdx force:apex:execute --file ./scripts/devops/packaging/setupTaxCalculation.apex

        echo "Setup Payment Gateway..."
        paymentGatewayApexClassId=`sfdx force:data:soql:query -q "SELECT Id FROM ApexClass WHERE Name='DRB2B_PaymentGatewayAdapter' LIMIT 1" -r csv |tail -n +2`
        paymentGatewayProviderId=`sfdx force:data:soql:query -q "SELECT Id FROM PaymentGatewayProvider LIMIT 1" -r csv |tail -n +2`
        echo "Creating PaymentGatewayProvider record using ApexAdapterId=$paymentGatewayApexClassId."
        echo "Creating PaymentGatewayProvider record using paymentGatewayProviderId=$paymentGatewayProviderId."
        sfdx force:data:record:update -s PaymentGatewayProvider -i "$paymentGatewayProviderId" -v "ApexAdapterId=$paymentGatewayApexClassId"
        echo_attention "-------------ORG SETUP IS COMPLETE-------------"
        #sfdx force:apex:execute --file ./scripts/devops/packaging/setupPaymentGateway.apex

    fi
else
    echo "You must enter an alias for the scratch org that contains only alphabetic characters!"
    exit 1
fi
