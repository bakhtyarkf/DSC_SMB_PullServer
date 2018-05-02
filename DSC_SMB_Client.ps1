[DSCLocalConfigurationManager()]
configuration DscSmbClient
{
    Node localhost
    {
        Settings
        {
            RefreshMode = 'Pull'
            RefreshFrequencyMins = 30 
            ConfigurationID = '1ff8614e-82aa-4a27-a554-363b81c1c93b'
            RebootNodeIfNeeded = $true
        }

        ConfigurationRepositoryShare SmbConfigShare
        {
            SourcePath = '\\winslave\DscSmbShare'
        } 

    }
}

DscSmbClient