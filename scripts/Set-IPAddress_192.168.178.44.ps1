New-NetIPAddress `
    -AddressFamily IPv4 `
    -DefaultGateway 192.168.178.1 `
    -InterfaceAlias Ethernet0 `
    -IPAddress 192.168.178.44 `
    -PrefixLength 24
    -Type Unicast `

Set-DnsClientServerAddress `
    -InterfaceAlias Ethernet0 `
    -ServerAddresses 1.1.1.1,9.9.9.9

Start-Sleep -Seconds 10
