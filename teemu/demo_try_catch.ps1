try 
{

    remove-item 'HKCU:\Control Panel\PowerCfg\PowerPolicies\5' -ErrorAction Stop
}
catch
{
    "remove item pCFG 5 failed" | Out-File c:\temp\asentaja\logi.txt -Append
}

try 
{

    remove-item 'HKCU:\Control Panel\PowerCfg\PowerPolicies\4' -ErrorAction Stop
}
catch
{
    "remove item pCFG 4 failed" | Out-File c:\temp\asentaja\logi.txt -Append
}
