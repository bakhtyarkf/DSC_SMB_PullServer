# Install these two Modules xSmbShare, cNtfsAccessControl

Configuration DSCSMB {

    Param
    (
        [string]$DomainName="aztest",
        [string[]]$PCs=@("win10"),
        [string]$SharePath='C:\DSC'
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName cNtfsAccessControl -ModuleVersion "1.3.1"
    Import-DscResource -ModuleName xSmbShare -ModuleVersion "2.0.0.0"
    
    Node localhost {

        File CreateFolder {

            DestinationPath = $SharePath
            Type = 'Directory'
            Ensure = 'Present'

        }

        xSMBShare CreateShare {

            Name = 'DscSmbShare'
            Path = $SharePath
            FullAccess = 'administrator'
            ReadAccess = "$DomainName\$($PCs[0])$"
            FolderEnumerationMode = 'AccessBased'
            Ensure = 'Present'
            DependsOn = '[File]CreateFolder'

        }

        cNtfsPermissionEntry PermissionSet1 {

        Ensure = 'Present'
        Path = $SharePath
        Principal = "$DomainName\$($PCs[0])$"
        AccessControlInformation = @(
            cNtfsAccessControlInformation
            {
                AccessControlType = 'Allow'
                FileSystemRights = 'ReadAndExecute'
                Inheritance = 'ThisFolderSubfoldersAndFiles'
                NoPropagateInherit = $false
            }
        )
        DependsOn = '[File]CreateFolder'

        }


    }

}

DSCSMB