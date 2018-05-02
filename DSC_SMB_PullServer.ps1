# Install these two Modules xSmbShare, cNtfsAccessControl

Configuration DSCSMB {

    Param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()] 
        [string]$DomainName="aztest",

        [ValidateNotNullOrEmpty()] 
        [string]$NodeName = 'localhost',

        [ValidateNotNullOrEmpty()] 
        [string[]]$Clients = @("win10", "winslave"),

        [ValidateNotNullOrEmpty()] 
        [string]$SharePath = 'C:\DSC'
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName cNtfsAccessControl
    Import-DscResource -ModuleName xSmbShare
    
    Node $NodeName {

        File CreateFolder {

            DestinationPath = $SharePath
            Type            = 'Directory'
            Ensure          = 'Present'

        }

        [string[]]$ValidUsers = $Clients | ForEach-Object { 
            $acc = $_ 
            return "$DomainName\$acc$"
        }

        xSMBShare CreateShare {

            Name                  = 'DscSmbShare'
            Path                  = $SharePath
            FullAccess            = 'administrator', 'aztest\bk'
            ReadAccess            = $ValidUsers # "$DomainName\$($Clients[0])$"
            FolderEnumerationMode = 'AccessBased'
            Ensure                = 'Present'
            DependsOn             = '[File]CreateFolder'

        }

        cNtfsPermissionEntry PermissionSet1 {

            Ensure                   = 'Present'
            Path                     = $SharePath
            Principal                = "$DomainName\$($Clients[0])$"
            AccessControlInformation = @(
                cNtfsAccessControlInformation {
                    AccessControlType  = 'Allow'
                    FileSystemRights   = 'ReadAndExecute'
                    Inheritance        = 'ThisFolderSubfoldersAndFiles'
                    NoPropagateInherit = $false
                }
            )
            DependsOn                = '[File]CreateFolder'

        }


    }

}

DSCSMB -DomainName "aztest"
