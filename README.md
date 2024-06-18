# Overview
This Project is for the code for a managed package that will act as the connector to DigitalRiver from Salesforce Lightning B2B Cloud

## Salesforce DX Project: Next Steps

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## Installing the app using a Scratch Org

1. Set up your environment. Follow the steps in the [Quick Start: Lightning Web Components](https://trailhead.salesforce.com/content/learn/projects/quick-start-lightning-web-components/) Trailhead project. The steps include:

    - Enable Dev Hub in your developer org
    - Install Salesforce CLI
    - Install Visual Studio Code
    - Install the Visual Studio Code Salesforce extensions, including the Lightning Web Components extension

1. Clone the DR Connector repository:

    ```
    https://github.com/digitalriver-connectors/SalesforceLightning.git

    Select the latest branch
    ```

1. If you haven't already done so, authorize your hub org and provide it with an alias (**myhuborg** in the command below):

    ```
    sfdx force:auth:web:login -d -a DevHub
    ```
   
1. Execute a script to create a scratch org and provide it with an alias and devhub (it is mandatory to specify the alias of a scratch org, and a devhub that have to be used):

    ```
    bash ./scripts/devops/createDevOrg.bash "drlwrstore" "DevHub" 30
    '''

    OPTIONAL 
    If store creation is taking too much time (More than 10-15 min) then use this below command in powershell
    
    sfdx force:community:create --name "drlwrstore" --templatename "B2B Commerce (LWR)" --urlpathprefix "drlwrstore" --description " LWR Store created by Quick Start script."
    ```

1. Open the scratch org:

    ```
    sfdx force:org:open
    ```
1. Open the link and create Named Credentials

    ``` 
    https://docs.digitalriver.com/salesforce-lightning/v/salesforce-lightning-b2b-commerce-app-1.1/integrate-the-salesforce-lightning-app/step-3-register-external-services#payment-service
    ```

This script will:
- Create new scratch org with required shape to start DR Connector development
- Deploy the B2B Lightning Commerce package to a newly created scratch org
- Create a store in the scratch org with the same name as you assign alias to the org
- Set up the store in the scratch org with all required configurations based on the B2B Lightning Commerce package guide
- Push the DR Connector package code to the scratch org
- Assign DR Connector Admin permission set to the main user in the scratch org

### How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

### Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

### Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)
