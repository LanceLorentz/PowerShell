# READ ME
# THE FOLLOWING SCRIPTS WERE DESIGNED IN A TESTING ENIVRONMENT IN WHICH ACTIVE DIRECTORY WAS ALREADY CONFIGURED WITH THE PROPER DOMAINS, ORGANIZATION UNITS, SECURITY GROUPS ETC.
# TO USE THESE FUNCTIONS IN A PRDUCTION ENVIRONMENT, ENSURE THAT YOU MAKE THE NECESSARY EDITS TO THE SCRIPTS TO ALLOW THEM TO RUN IN YOUR ENIVRONMENT


## Creates a new AD User in the specified Organizational Unit, and adds that user to the associated group.
# Creates a temporary account password of "Pa55w.rd" that must be changed upon initial sign in.
# This function was created in a test environment. To use in a production environment, edit the -Path value to meet your needs.
Function New-User
{
Param(
        [Parameter(Mandatory=$true)][String]$FirstName,
        [Parameter(Mandatory=$True)][String]$LastName, 
        [Parameter(Mandatory=$True)][String]$Unit
        )
      
        
New-ADUser -Path "OU=$Unit,DC=Adatum,DC=com" `
-Name "$FirstName $LastName" `
-GivenName $FirstName `
-Surname $LastName `
-DisplayName "$FirstName $LastName" `
-SamAccountName "$FirstName $LastName" `
-UserPrincipalName "$FirstName$LastName@adatum.com" `
-AccountPassword (ConvertTo-SecureString "Pa55w.rd" -AsPlainText -Force) `
-ChangePasswordAtLogon $True `
-Enabled $True

Add-ADGroupMember -Members "$FirstName $LastName" -Identity $Unit

<#
.SYNOPSIS
Creates a new AD user in the specified organizational unit.

.DESCRIPTION
Creates a new Active Directory user in the specified organizational unit, and adds that user to the associated group for that OU.
Creates a temporary account password of "Pa55w.rd" that must be changed upon initial sign in.
Created in a test environment. If using in a production environment, enusre you edit the -Path value to meet your environment's needs.

.PARAMETER FirstName
Specifies the user's first name

.PARAMETER LastName
Specifies the user's last name

.PARAMETER Unit
Specifies the organizational unit and group that the user will be placed in

.EXAMPLE
New-User -FirstName John -LastName Doe -Unit Sales

.NOTES
#>
}



# The following function is used to create a new Organizational Unit and Secrity Group in Active Driectory.
# The Security Group is created with the scope: Global and Category: Security. The group is placed within the created OU.
# PRIOR TO USE IN A PRODUCTION ENVIRONMENT: Change -Path to the appropriate path for your ActiveDirectory environment.
# If desired, you can change the group scope and category to better suit your needs.
Function New-Unit
{
[CmdletBinding()]
    Param(
            [Parameter(Mandatory=$True)][String]$Name
          )

New-ADOrganizationalUnit -Name $Name -Path "DC=Adatum,DC=com"
New-ADGroup -Name $Name  -GroupScope Global -GroupCategory Security -Path "OU=$Name,DC=Adatum,DC=com"
<#
.SYNOPSIS
Creates a new organizational unit along with a global security group within the created OU.

.DESCRIPTION
Creates a new Organizational Unit as well as a global security group with the same name. Places the security group within the created OU.
Specifiy the desried name of the OU and security group with the -Name parameter.

.PARAMETER Name
-Name 
Required: True
Type: String

.EXAMPLE
New-Unit -Name Sales
Creates an Organizational Unit with the name Sale, and creates a global security group with the name Sales within that OU.

.NOTES
#>
}