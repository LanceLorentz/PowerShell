Function Remove-Files
{
Param (
       [Parameter(Mandatory = $True)][String]$Location
       ) 

Get-ChildItem -Path $Location 
Remove-Item -Path $Location -Confirm

<#
.SYNOPSIS
This Command returns all child items in the specified location and then prompts for confirmation to delete all items.
.DESCRIPTION
Returns all child items within the specified location. Deletes all items in the specified location after retrieving them.
Confirmation is required to proceed with the deletion of the items after retrieval. 
The destination folder/file is deleted along with all child items
The desired location is specified with the -Location parameter.
This function only works with the local host.
#>
}