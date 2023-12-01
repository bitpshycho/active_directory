
param([ Parameter(Mandatory = $true)] $JsonFile)


function CreateADGroup() {
    param([ Parameter(Mandatory = $true)] $GroupObject)

    $name = $GroupObject.name
    New-ADGroup -Name $name -GroupScope Global

}
function CreateADUser(){
    param([ Parameter(Mandatory = $true)] $UserObject)

    $name = $UserObject.name
    $firstName, $lastName = $name.Split(" ")
    $password = $UserObject.password
    $userName = ($firstName[0] + $lastName).ToLower()
    $samAccountName = $userName
    $principalName = $userName

    New-ADUser -Name $name -GivenName $firstName -SurName $lastName -SamAccountName $samAccountName -UserPrincipalName $principalName@$Global:Domain -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -PassThru | Enable-ADAccount
    
    foreach($group_name in $UserObject.groups){
        try{
            Get-ADGroup -Identity $group_name
            Add-ADGroupMember -Identity $group_name -Members $userName
        }
            catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
                Write-Warning -Message "AD Object not found"
            }
        
    }
}

$json = (Get-Content $JsonFile | ConvertFrom-Json)

$Global:Domain = $JsonFile.domain

foreach($group in $json.groups){
    CreateADGroup $group
}

foreach($user in $json.users){
    CreateADUser $user
}



 