# Set $ErrorActionPreference to what's set during Ansible execution
$ErrorActionPreference = "Stop"

# Set the first argument file to a JSON that contains the module args
$args = @("$($pwd.Path)\args.json")

# Import any C# utils referenced with '#AnsibleRequires -CSharpUtil' or 'using Ansible;'

Import-Module -Name "$($pwd.Path)\powershell\Ansible.ModuleUtils.AddType.psm1"

$_csharp_utils = @(
    [System.IO.File]::ReadAllText("$($pwd.Path)\csharp\Ansible.Basic.cs")
)

Add-CSharpType -References $_csharp_utils -IncludeDebugInfo

# Import any PowerShell modules references with '#Requires -Module'
Import-Module -Name "$($pwd.Path)\powershell\Ansible.ModuleUtils.Legacy.psm1"

# End of setup code and start of module code!
#!powershell

# Copyright: (c) 2018, Varun Chopra (@chopraaa)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic

$spec = @{
    options = @{
        path = @{ type = "path"; required = $true }
        state = @{ type = "str"; choices = "absent", "present"; default = "present" }
    }
    required_if = @(,@("state", "present", @("path")))
    supports_check_mode = $false
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$path = $module.Params.path
$state = $module.Params.state

if ($state -eq "absent" -and $path) {
    Remove-Item $path | Out-Null
    $module.Result.changed = $true
}
else {
    New-Item $path -Type File | Out-Null
    $module.Result.changed = $true
}

$module.ExitJson()
