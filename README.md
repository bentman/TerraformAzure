# Azure with Terraform Learning Journey! WIP

Build Azure lab environments using Terraform. Journey into mastering infrastructure as code by creating a real-world cloud architecture that can also be used as a learning lab. Gain hands-on experience with tools like GitHub, Azure DevOps pipelines, and configuring virtual machines. This project focuses on incremental learning to develop skills one step at a time. 🚀🌐🧭

## Bonus Tips

- Start with smaller, independent modules for easier testing and debugging.
  - **EXAMPLE 1:** `.\v-network.md` (Lab Network - Base for remaining modules)
  - **EXAMPLE 2:** `.\modules\vm-jumpbox` (Windows Client and Linux Desktop)
    - NOTE: Full automation of jumpbox capabilities are "WIP"
  - **EXAMPLE 3:** `.\modules\vm-dc1` (Domain Controller with Dev Tools)
  - **EXAMPLE 4:** `.\modules\sql-ha` (Domain Controller w/ SQL Always On Cluster)
- Utilize Terraform state management for consistent deployments.
- Follow IaC best practices for clean and maintainable code.
- Look for *.md files, comments ('#'), and instructions (more '#' & '/') throughout!

## Ready to Start?
... me too! <gulp>

## Step 1: Set Up Your Toolkit

- [Install Terraform on Windows with Azure PowerShell](https://learn.microsoft.com/en-us/azure/developer/terraform/get-started-windows-powershell)
- [Write basic Terraform scripts to interact with Azure services.](https://developer.hashicorp.com/terraform/tutorials/azure-get-started)

## Step 2: Deploy Network & Virtual Machines

- [Build your Azure network with Terraform, testing components like VNETs and subnets.](https://learn.microsoft.com/en-us/azure/developer/terraform/hub-spoke-on-prem)
- [Quickstart: Use Terraform to create a Windows VM](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/quick-create-terraform)

## Step 3: Connect & Automate

- Link your Azure account with your GitHub repository.
- Set up GitHub Actions for automated workflows.
- Connect your GitHub repository with Azure DevOps.
- Prepare Azure DevOps for pipeline creation and Terraform integration.

## Step 4: Build Your Foundation

- Write a YAML pipeline for Terraform deployments and test it.
- Use Terraform to create and destroy a sub-tenant for controlled deployments.
- Apply simple configurations like Azure AD, storage blobs, or basic applications (e.g., WordPress).
- Destroy them afterwards for a solid foundation.

## Step 5: Learn & Expand

- With each apply/destroy cycle, build upon previous components, creating a more complex lab.
- Use Git branches to manage different stages of your lab's evolution.
- Continuously learn and add new features, exploring advanced Terraform techniques and community resources.

## Helpful Links

- [Terraform Azure | HashiCorp](https://developer.hashicorp.com/terraform/tutorials/azure-get-started)
- [Terraform Azure | Microsoft](https://learn.microsoft.com/en-us/azure/developer/terraform/)
- [Create on-premises virtual network in Azure using Terraform](https://learn.microsoft.com/en-us/azure/developer/terraform/hub-spoke-on-prem)
- [Quickstart: Create a lab in Azure DevTest Labs using Terraform](https://learn.microsoft.com/en-us/azure/devtest-labs/quickstarts/create-lab-windows-vm-terraform)
- [Quickstart: Use Terraform to create a Windows VM - Azure Virtual Machines](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/quick-create-terraform)
- [Deploying an Azure Windows VM using Terraform IaC](https://www.c-sharpcorner.com/article/deploying-an-azure-windows-vm-using-terraform-iac/)
- [Azure - Provisioning a Windows Virtual Machine using Terraform](https://www.patrickkoch.dev/posts/post_12/)
- [The Infrastructure Developer's Guide to Terraform: Azure Edition](https://cloudacademy.com/learning-paths/terraform-on-azure-01-1-2658/)
- [Terraform on Azure | Udemy](https://www.udemy.com/course/terraform-on-azure/)

### Contributions

Contributions are welcome! Please open an issue or submit a pull request if you have suggestions or enhancements.

### License

This script is distributed without any warranty; use at your own risk.
This project is licensed under the GNU General Public License v3. 
See [GNU GPL v3](https://www.gnu.org/licenses/gpl-3.0.html) for details.