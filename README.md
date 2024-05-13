# Azure with Terraform Learning Journey! WIP

Build an Azure lab environment using Terraform. Journey into mastering infrastructure as code by creating a real-world cloud architecture that can also be used as a learning lab. Gain hands-on experience with tools like GitHub, Azure DevOps pipelines, and configuring virtual machines. This project focuses on incremental learning to develop skills one step at a time. 🚀🌐🧭

**Step 1: Set Up Your Toolkit**

- [Install Terraform on Windows with Azure PowerShell](https://learn.microsoft.com/en-us/azure/developer/terraform/get-started-windows-powershell)
- [Write basic Terraform scripts to interact with Azure services.](https://developer.hashicorp.com/terraform/tutorials/azure-get-started)

**Step 2: Deploy Network & Virtual Machines**

- [Build your Azure network with Terraform, testing components like VNETs and subnets.](https://learn.microsoft.com/en-us/azure/developer/terraform/hub-spoke-on-prem)
- [Quickstart: Use Terraform to create a Windows VM](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/quick-create-terraform)
- Deploy "Spot" VMs for cost-efficiency, and manage them with Terraform (links below from Registry).
    - [azurerm_windows_virtual_machine](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine)
    - [azurerm_linux_virtual_machine](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine)

**Step 3: Connect & Automate**

- Link your Azure account with your GitHub repository.
- Set up GitHub Actions for automated workflows.
- Connect your GitHub repository with Azure DevOps.
- Prepare Azure DevOps for pipeline creation and Terraform integration.

**Step 4: Build Your Foundation**

- Write a YAML pipeline for Terraform deployments and test it.
- Use Terraform to create and destroy a sub-tenant for controlled deployments.
- Apply simple configurations like Azure AD, storage blobs, or basic applications (e.g., WordPress). 
- Destroy them afterwards for a solid foundation.

**Step 5: Learn & Expand**

- With each apply/destroy cycle, build upon previous components, creating a more complex lab.
- Use Git branches to manage different stages of your lab's evolution.
- Continuously learn and add new features, exploring advanced Terraform techniques and community resources.

**Bonus Tips:**

- Start with smaller, independent modules for easier testing and debugging.
- Utilize Terraform state management for consistent deployments.
- Follow IaC best practices for clean and maintainable code.

**Ready to Start?** 
... me too! <gulp>

**Helpful Links**
- [Terraform Azure | HashiCorp](https://developer.hashicorp.com/terraform/tutorials/azure-get-started)
- [Terraform Azure | Microsoft](https://learn.microsoft.com/en-us/azure/developer/terraform/)
- [Create on-premises virtual network in Azure using Terraform](https://learn.microsoft.com/en-us/azure/developer/terraform/hub-spoke-on-prem)
- [Quickstart: Create a lab in Azure DevTest Labs using Terraform](https://learn.microsoft.com/en-us/azure/devtest-labs/quickstarts/create-lab-windows-vm-terraform)
- [Quickstart: Use Terraform to create a Windows VM - Azure Virtual Machines](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/quick-create-terraform)
- [Deploying an Azure Windows VM using Terraform IaC](https://www.c-sharpcorner.com/article/deploying-an-azure-windows-vm-using-terraform-iac/)
- [Azure - Provisioning a Windows Virtual Machine using Terraform](https://www.patrickkoch.dev/posts/post_12/)
- [The Infrastructure Developer's Guide to Terraform: Azure Edition](https://cloudacademy.com/learning-paths/terraform-on-azure-01-1-2658/)
- [Terraform on Azure | Udemy](https://www.udemy.com/course/terraform-on-azure/)

## Contributions
Contributions are welcome. Please open an issue or submit a pull request if you have any suggestions, questions, or would like to contribute to the project.

### GNU General Public License
This script is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This script is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this script.  If not, see <https://www.gnu.org/licenses/>.
