sfdx force:package:version:create \
      --package "Digital River Connector" \
      --definitionfile "config/project-scratch-def.json" \
      --installationkeybypass \
      --apiversion "52.0" \
      --wait 100


      #sfdx force:package:version:create --versionname package-version-0 --installationkeybypass --definitionfile "config\project-scratch-def.json" --wait 100 --targetdevhubusername "devHub" --path src
