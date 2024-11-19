New-NetIPAddress `
    -AddressFamily IPv4 `
    -DefaultGateway 10.235.60.236 `
    -InterfaceAlias Ethernet0 `
    -IPAddress 10.235.60.1 `
    -PrefixLength 24
    -Type Unicast `

Set-DnsClientServerAddress `
    -InterfaceAlias Ethernet0 `
    -ServerAddresses 1.1.1.1,9.9.9.9

Start-Sleep -Seconds 10
