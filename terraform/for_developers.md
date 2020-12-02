# Instructions to use the Makefiles

You can use `make` to get the Cloud Pak using Terraform locally from your computer or using Schematics remotely. It's recommended to use the Terraform (locally) option when you are developing the Terraform code, and it's recommended to use the Schematics way when you want to test the final version.

Either option you choose, you need first to complete the following steps, then go to the section [Using Terraform](#using-terraform-local-execution) or [Using Schematics](#using-schematics-remote-execution).

1. Clone the repo https://github.com/ibm-hcbt/cloud-pak-sandboxes (if you have not yet) and move to the `terraform/` directory

   ```bash
   cd terraform
   ```

2. Export the variable `TF_VAR_entitled_registry_user_email` with the email used to get the Entitlement Key

   ```bash
   export TF_VAR_entitled_registry_user_email="Johandry.Amador@ibm.com"
   ```

3. Store the Entitlement Key in the file `entitlement.key`

4. Make sure to have your IBM Cloud credentials exported

   ```bash
   export IAAS_CLASSIC_USERNAME="A.B@ibm.com"
   export IAAS_CLASSIC_API_KEY="............"
   export IC_API_KEY="..............."
   ```

5. You need `ibmcloud` and the **Schematics** plugin, verify you have it executing:

   ```bash
   ibmcloud schematics version
   ```

6. Optionally but recommended to export the variable `TF_VAR_project_name` with the project name to use. This is recommended to avoid collision with other projects. If not done, the default value is `cloud-pak-{mcm|app|data}`. This value is used to name and tag multiple IBM Cloud resources.

   ```bash
   export TF_VAR_project_name=cp-mcm
   ```

7. Export the variable `CP` with the Cloud Pak to install. It can have the values: `mcm`, `app` or `data`. This step is optional if the Cloud Pak to install is **MCM**.

   ```bash
   export CP=app
   ```

The Makefile will make sure that all these required parameters are set. If one is missing it will be notified as an error. If you get an error, provide the requested input parameter or requirement, then execute `make` again.

You can also verify all the requirements are set executing `make check` or - if you plan to use Schematics - `make check check-sch`.

## Using Terraform (local execution)

This option is suggested when you are developing or modifying the Terraform code. Make sure to execute or test using the Schematics way before release the code or if you'd like to test what the user will use.

By default the cluster is created on `us-south` region and datacenter `dal10`. If you would like to change any of these parameters, edit the file `terraform.tfvars`.

Also, until the permissions issue is not solved you need to provide the VLANs. Execute the command `ibmcloud ks vlan ls --zone {datacenter}`, get a private and public VLAN, and write them down in the `terraform.tfvars` file. Example:

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

8. Execute `make`. This command will generate all the input parameters, generate the plan and apply it. When complete, the output parameters to access the Cloud Pak are printed out and some tests are executed.

   ```bash
   make
   ```

9. To print again the output parameters to access the Cloud Pak, execute:

   ```bash
   make output-tf
   ```

10. To destroy the cluster, execute:

```bash
make  destroy-tf
```

11. Cleanup everything executing:

```bash
make clean-tf
```

**IMPORTANT**: Do not execute `clean-tf` before executing `destroy-tf` or you'll have to delete the cluster manually.

## Using Schematics (remote execution)

This is the recommended option to follow when the Terraform code is working correctly or if you are doing changes in any of the the `cp4*/workspace.tmpl.json` files.

Make sure everything is working provisioning the Cloud Pak using Schematics before release it.

8. Execute this command to create the Schematics workspace:

   ```bash
   make with-schematics
   ```

9. Go to the displayed link to edit or validate the variables in the workspace. By default the cluster is created on `us-south` region and datacenter `dal10`. If you would like to change any of these parameters, edit the variables at the workspace settings.
   Also, until the permissions issue is not solved you need to provide the VLANs. Execute the command `ibmcloud ks vlan ls --zone {datacenter}`, get a private and public VLAN, and write them down in the variables at the workspace settings. In this example, you can select the VLANs `2979232` (as private) and `2979230` (as public):

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
   ```

   If any input variable is modified in the workspace settings section, make sure to click on "**Save changes**" button.

10. When ready click on "**Generate plan**" or execute: `make plan-sch`, you will get the link to the plan output/log

```bash
make plan-sch
```

11. When the plan successfully finish, click on "**Apply plan**" or execute: `make apply-sch`, you will get the link to the plan output/log.

```bash
make apply-sch
```

12. When the application is completed, you'll see the output parameters to access the Cloud Pak at the end of the logs. Or execute: `make output-sch`.

```bash
make output-sch
```

13. At this moment you can execute the tests to verify the cluster and the Cloud Pak are ready. Execute:

```bash
make test-sch
```

14. To destroy the cluster, execute:

```bash
make  destroy-sch
```

15. To delete the workspace, execute:

```bash
make  delete-sch
```

16. Cleanup all the created files, executing:

```bash
make clean-sch
```

**IMPORTANT**:

- Do not execute `delete-sch` before executing `destroy-sch` or you'll have to delete the cluster manually.
- Do not execute `clean-sch` before executing `destroy-sch` or `delete-sch`, or you'll have to delete the cluster or the workspace manually.
