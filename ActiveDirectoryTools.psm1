# READ ME
# THE FOLLOWING SCRIPTS WERE DESIGNED IN A TESTING ENIVRONMENT IN WHICH ACTIVE DIRECTORY WAS ALREADY CONFIGURED WITH THE PROPER DOMAINS, ORGANIZATION UNITS, SECURITY GROUPS ETC.
# TO USE THESE FUNCTIONS IN A PRODUCTION ENVIRONMENT, ENSURE THAT YOU MAKE THE NECESSARY EDITS TO THE SCRIPTS TO ALLOW THEM TO RUN IN YOUR ENIVRONMENT


# Creates a new AD User in the specified Organizational Unit, and adds that user to the associated group.
# Creates a temporary account password of "Pa55w.rd" that must be changed upon initial sign in.
# This function was created in a test environment. To use in a production environment, edit the -Path value and user principal name.
# Edit SamAccountName to suit any naming conventions you may have, this was written assuming an already established naming convention.
Function New-User
{
Param(
      [Parameter(Mandatory=$True)][String]$FirstName,
      [Parameter(Mandatory=$True)][String]$LastName, 
      [Parameter(Mandatory=$False)][String]$Department
      )
      # This assumes a previously established naming convention for the SamAccountName, edit according to your company
      $SamAccountName = "$FirstName $LastName"
                                      
    If (Get-ADUser -filter {SamAccountName -eq $SamAccountName})
    {  
    Write-Warning "A user with the name $FirstName $LastName already exists in Active Directory."
    }
    
    Else
    {                                             
    New-ADUser -Path "OU=$Department,DC=Adatum,DC=com" `
    -Name "$FirstName $LastName" `
    -GivenName $FirstName `
    -Surname $LastName `
    -DisplayName "$FirstName $LastName" `
    -SamAccountName "$FirstName $LastName" `
    -UserPrincipalName "$FirstName$LastName@adatum.com" `
    -AccountPassword (ConvertTo-SecureString "Pa55w.rd" -AsPlainText -Force) `
    -ChangePasswordAtLogon $True `
    -Department $Department `
    -Company "Adatum" `
    -Enabled $True
  
    # Member name must match SamAccountName, edit this line if your SamAccountName follows different naming conventions
    Add-ADGroupMember -Members "$FirstName $LastName" -Identity $Department

    Write-Host "The user $FirstName $LastName has been created"
    }

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



# The following function imports users from a CSV and creates Active Directory accounts for each user. Each created user is placed in the appropriate OU and Security Group. 
# This function assumes that the OU, Security Group, and Department for each user all use the same name. 
# To edit this function for use in a production environment, edit the name/path of the CSV to import from, and adjust the variables/members as necessary to accomodate your CSV categories. 
# Also ensure that SamAccountName follows your preferred naming conventions.
# A temporary password of "Pa55w.rd" is created for each user that must be changed upon initial sign in.
Function Import-Users 
{
    # Edit this line to match the filepath of your CSV
    $ADUsers = Import-CSV C:\Banshees.csv

    Foreach ($user in $ADUsers)
    {
        # Edit to match the criteria used in your CSV
        $FirstName = $User.First
        $LastName = $User.Last
        $Department = $User.Department
        $Job = $User.Job
        $Company = $User.Company
        $State = $User.State
        $Phone = $User.Phone
        $SamAccountName = ($User.First)+($User.Last)
    
        # Assumes an already established naming convention for SamAccountName, edit to match your naming convention
        If (Get-ADUser -Filter {SamAccountName -eq $SamAccountName}) 
        {
        Write-Warning "User account for $FirstName $LastName already exists in ACtive Directory."
        }

        Else
        {
        # This assumes that the user's department, OU, and security group all use the same name
        # Edit email address to fit the needs of your environment if necessary
        New-ADUser `
        -Name "$FirstName $LastName" `
        -GivenName $FirstName `
        -Surname $LastName `
        -SamAccountName "$FirstName$LastName" `
        -UserPrincipalName "$FirstName$LastName@$Company.com" `
        -DisplayName "$FirstName $LastName" `
        -Title $Job `
        -State $State `
        -Company $Company `
        -OfficePhone $Phone `
        -EmailAddress "$FirstName.$LastName@$Company.com" `
        -AccountPassword (ConvertTo-SecureString "Pa55w.rd" -AsPlainText -Force) `
        -ChangePasswordAtLogon $True `
        -Enabled $True `
        -Path "OU=$Department,DC=$Company,DC=Com"

        Add-ADGroupMember -Members "$FirstName$LastName" -Identity $Department

        Write-Host "The user $FirstName $LastName has been created."
        }   
    }

<#
.SYNOPSIS
Imports new Active Directory Users from a CSV.
.DESCRIPTION 
This function imports users from a CSV and creates user accounts in ACtive Directory. The created users are also placed in the appropriate organizational unit and corresponding security group.
Creates a temporary password of "Pa55w.rd" for each created account that must be changed at initial account sign in.
The function also checks to see if there is already an existing account with the desired name. If an account already exists than a warning message is returned.
If the account is created properly than an output indicating that the account has been created is returned.
.NOTES
This function assumes that the user's OU, security group, and department all use the same name. If they do not, then this will need to be changed.
Variables and other criteria may need to be edited in order to fit your environment and CSV format.
#>
}



# The following function is used to create a new Organizational Unit and Secrity Group in Active Driectory.
# The Security Group is created with the scope: Global and Category: Security. The group is placed within the created OU.
# PRIOR TO USE IN A PRODUCTION ENVIRONMENT: Change -Path to the appropriate path for your Active Directory environment.
# If desired, you can change the group scope and category to better suit your needs.
Function New-Department
{
[CmdletBinding()]
    Param(
          [Parameter(Mandatory=$True)][String]$Name
          )
New-ADOrganizationalUnit `
-Name $Name `
-Path "DC=Adatum,DC=com"

New-ADGroup `
-Name $Name  `
-GroupScope Global `
-GroupCategory Security `
-Path "OU=$Name,DC=Adatum,DC=com"

Write-Host "The organizational unit $Name has been created."
Write-Host "The security group $Name has been created."
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