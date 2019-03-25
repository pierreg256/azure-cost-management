#!/usr/bin/env bash

LOCATION=francecentral
BASENAME=`curl -s "http://names.drycodes.com/1?nameOptions=starwarsCharacters&case=lower&format=text&combine=1" | tr -cd '[:alpha:]'`
RESOURCE_GROUP="${BASENAME}_RG"
STORAGE_ACCOUNT="${BASENAME}sa"
CONTAINER_NAME="usage"
FUNCTION_APP_NAME="${BASENAME}-fn"

echo "Installing enviroment with the following parameters:"
echo " - Location             : $LOCATION"
echo " - Resource Group       : $RESOURCE_GROUP"
echo " - Storage Account Name : $STORAGE_ACCOUNT"
echo " - Container Name       : $CONTAINER_NAME"
echo ""
echo ""
echo ""

echo "Creating resource group : $RESOURCE_GROUP"
az group create --location $LOCATION --name $RESOURCE_GROUP

echo "Creating storage account : $STORAGE_ACCOUNT"
az storage account create --resource-group $RESOURCE_GROUP --name $STORAGE_ACCOUNT --kind storagev2 --location $LOCATION --sku Standard_LRS
CONNECTION_STRING=`az storage account show-connection-string -g $RESOURCE_GROUP -n $STORAGE_ACCOUNT --output table | tail -n 1`
BLOB_KEY=`az storage account keys list --account-name $STORAGE_ACCOUNT --output table | grep key1 | tr -s " " | cut -f 3 -d " "`

echo "Creating Blob Container : $CONTAINER_NAME"
az storage container create --name $CONTAINER_NAME --connection-string $CONNECTION_STRING

echo "Creating Function App : $FUNCTION_APP_NAME"
az functionapp create -g $RESOURCE_GROUP -n $FUNCTION_APP_NAME -s $STORAGE_ACCOUNT -c $LOCATION --os-type Windows --runtime node

echo "Defining enviroment variables"
az functionapp config appsettings set --name $FUNCTION_APP_NAME --resource-group $RESOURCE_GROUP \
--settings BLOB_NAME=$STORAGE_ACCOUNT \
CONTAINER_NAME=$CONTAINER_NAME \
API_KEY=NOT_SET \
ENROLLMENT_NUMBER=NOT_SET \
BLOB_CONNECTION_STRING=$CONNECTION_STRING \
BLOB_KEY=$BLOB_KEY \
BLOB_NAME=$STORAGE_ACCOUNT

echo "Defining local settings"
cat <<EOF > local.settings.json
{
	"IsEncrypted": false,
	"Values": {
		"FUNCTIONS_WORKER_RUNTIME": "node",
		"AzureWebJobsStorage": "{AzureWebJobsStorage}",
		"API_KEY": "NOT_SET",
		"ENROLLMENT_NUMBER": "NOT_SET",
		"BLOB_CONNECTION_STRING": "$CONNECTION_STRING",
		"BLOB_KEY": "$BLOB_KEY",
		"BLOB_NAME": "$STORAGE_ACCOUNT",
		"CONTAINER_NAME": "$CONTAINER_NAME"
	}
}
EOF

echo "Installing dependencies"
npm install


echo "Function deployment"
func azure functionapp publish $FUNCTION_APP_NAME

