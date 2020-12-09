# Provisioning a Cloud Pak Sandbox using Terraform

The Makefile contain all the commands to use the Terraform, however if you'd like to do it manually, follow these instructions:

1. Make sure you have all the [requirements](#requirements) set. (Terraform, IBM Cloud CLI, IBM Cloud credentials, etc...)

2. Move to the directory of the Cloud Pak to install, for example, if you'd like to install CP4MCM execute:

   ```bash
   cd cp4mcm
   ```

3. Create the file `my_variables.auto.tfvars` with the following Terraform input variables using your own specific values:

   ```hcl
   owner                        = "johandry"
   project_name                 = "cloud-pak-app"
   entitled_registry_user_email = "Johandry.Amador@ibm.com"
   ```

   Append the input variable `cluster_id` if you have an existing Openshift cluster to install the Cloud Pak, like so:

   ```hcl
   cluster_id                   = "bupkhgbd00id2uu15cjg"
   ```

   Open the file `terraform.tfvars` or `variables.tf` and feel free to overwrite the input default values for any of the existing variables.

4. Until the permissions issue is not solved you need to provide the VLANs. Execute the command `ibmcloud ks vlan ls --zone {datacenter}`, get a private and public VLAN, and write them down in the `terraform.tfvars` file. Example:

   ```bash
   ❯ ibmcloud ks vlan ls --zone dal10
   OK
   ID        Name                 Number   Type      Router         Supports Virtual Workers
   2953608                        2737     private   bcr01a.dal10   true
   2832804                        2124     private   bcr02a.dal10   true
   2979296                        1420     private   bcr03a.dal10   true
   2953606                        2299     public    fcr01a.dal10   true
   2832802                        1926     public    fcr02a.dal10   true
   2979294                        1384     public    fcr03a.dal10   true
   ❯ grep vlan cp4mcm/terraform.tfvars
   private_vlan_number = "2979232"
   public_vlan_number  = "2979230"
   ```

5. Execute the following Terraform commands:

   ```bash
   terraform init
   ```

   If you modified the code, execute the following commands to validate and format the code:

   ```bash
   terraform fmt -recursive
   terraform validate
   terraform plan
   ```

6. Execute the following command to execute the Terraform code:

   ```bash
   terraform apply -auto-approve
   ```

   At the end of the execution you'll see the output parameters.

   If something fails, it should be safe to execute the `terraform apply` command again.

7. To get the output parameters again or validate them, execute:

   ```bash
   terraform output

   ibmcloud ks cluster config -cluster $(terraform output cluster_id)
   # Or
   export KUBECONFIG=$(terraform output kubeconfig)

   kubectl cluster-info
   # Or
   oc cluster-info
   ```

8. Finally, when you finish using the infrastructure, cleanup everything you created with the execution of:

   ```bash
   terraform destroy
   ```
