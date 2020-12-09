# Provisioning a Cloud Pak Sandbox using Schematics

The Makefile contain all the commands to provision a Cloud Pak using IBM Cloud Schematics, however if you'd like to do it manually, follow these instructions.

For group development and testing it is recommended to use Schematics to provision the OpenShift cluster. The Terraform state of the cluster is shared with the team and the management of the cluster can be done in the IBM Web Console by any team member.

There are two ways to create and execute the Schematics workspace, using [IBM Cloud Web Console](#using-ibm-cloud-web-console) or [IBM Cloud CLI](#using-ibm-cloud-cli). However, to automate the process and facilitate maintenance it is recommended to use the CLI for the creation of the workspace.

## Using IBM Cloud CLI

1. set the following required values (`OWNER`, `PROJECT`, `ENV`, `ENTITLED_KEY` and `ENTITLED_KEY_EMAIL`) in the the `workspace.tmpl.json` file and rename it `workspace.json`:

   ```bash
   PROJECT=cp-mcm
   OWNER=$USER
   ENV=sandbox
   ENTITLED_KEY_EMAIL=<Email Address owner of the Entitled Key >
   ENTITLED_KEY=< Your Entitled Key >
   ```

   or

   ```bash
   ENTITLED_KEY=$(cat entitlement.key)

   sed \
     -e "s|{{ PROJECT }}|$PROJECT|" \
     -e "s|{{ OWNER }}|$OWNER|" \
     -e "s|{{ ENV }}|$ENV|" \
     -e "s|{{ ENTITLED_KEY }}|$ENTITLED_KEY|" \
     -e "s|{{ ENTITLED_KEY_EMAIL }}|$ENTITLED_KEY_EMAIL|" \
     workspace.tmpl.json > workspace.json
   ```

   Also modify (if needed) the value of the parameters located in `.template_data[].variablestore[]`. Use the `ibmcloud` command to identify the values, as explained in the [ROKS Input Variables](#roks-input-variables) section and on each variable description.

   Confirm the GitHub URL to the Terraform code in `.template_repo.url` in the `workspace.json` file. This URL could be in a the master branch, a different branch, tag or folder.

2. Create the workspace executing the following commands:

   ```bash
   ibmcloud schematics workspace list
   ibmcloud schematics workspace new --file workspace.json
   ibmcloud schematics workspace list
   ```

   Wait until the workspace status is set to **INACTIVE**. If something goes wrong you can update the workspace or delete it and create it with the correct parameters. To delete it use the command:

   ```bash
   ibmcloud schematics workspace delete --id WORKSPACE_ID
   ```

3. Once the workspace is created and with status **INACTIVE**, it's ready to apply the terraform code

   ```bash
   # Get list of workspaces
   ibmcloud schematics workspace list

   # Set the WORKSPACE_ID
   export WORKSPACE_ID=<name of workspace>

   # (Optional) Plan:
   ibmcloud schematics plan --id $WORKSPACE_ID  # Identify the Activity_ID
   ibmcloud schematics logs --id $WORKSPACE_ID --act-id Activity_ID

   # Apply:
   ibmcloud schematics apply --id $WORKSPACE_ID # Identify the Activity_ID
   ibmcloud schematics logs  --id $WORKSPACE_ID --act-id Activity_ID
   ```

4. Cleanup

   To destroy the Schematics created resources and the workspace execute the following commands:

   ```bash
   ibmcloud schematics destroy --id $WORKSPACE_ID # Identify the Activity_ID
   ibmcloud schematics logs  --id $WORKSPACE_ID --act-id Activity_ID

   # ... wait until it's done

   ibmcloud schematics workspace delete --id $WORKSPACE_ID
   ibmcloud schematics workspace list
   ```

## Using IBM Cloud Web Console

1. In the IBM Cloud Web Console go to: **Navigation Menu** (_top left corner_) > **Schematics**. Click **Create Workspace** in upper right corner of list of workspaces
2. Provide a name, tags, location. Choose **schematics** resource group
3. Once workspace is created, add **https://github.com/ibm-hcbt/cloud-pak-sandboxes/tree/master/terraform** as the github URL
4. Leave **Personal access token** blank
5. Change **Terraform version** to 0.12
6. Click **Save template information**
7. Click on **Generate plan** button at the top, then click on **View log** link and wait until it's completed.
8. Click on the **Apply plan** button, then click on the **View log** link.
9. On the left side menu check the **Resources** item, to see all the resources created or modified from the workspace.
