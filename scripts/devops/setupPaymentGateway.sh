#!/bin/bash

orgAlias=$1

if [ -z "$orgAlias" ]
then
    echo "You must enter an alias for the scratch org"
    exit 1
else
    echo "Setup Payment Gateway..."
    paymentGatewayApexClassId=`sfdx force:data:soql:query -q "SELECT Id FROM ApexClass WHERE Name='DRB2B_PaymentGatewayAdapter' LIMIT 1" -u "$orgAlias" -r csv |tail -n +2`
    echo "Ape Class Id: $paymentGatewayApexClassId"
    paymentGatewayProviderId=`sfdx force:data:soql:query -q "SELECT Id FROM PaymentGatewayProvider LIMIT 1" -u "$orgAlias" -r csv |tail -n +2`
    echo "Payment Gateway Provider Id: $paymentGatewayProviderId"

    echo "Creating PaymentGatewayProvider record using ApexAdapterId=$paymentGatewayApexClassId."
    sfdx force:data:record:update -s PaymentGatewayProvider -i "$paymentGatewayProviderId" -v "ApexAdapterId=$paymentGatewayApexClassId" -u "$orgAlias"
    sfdx force:apex:execute --apexcodefile ./scripts/devops/packaging/setupPaymentGateway.apex -u "$orgAlias"
fi