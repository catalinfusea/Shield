function FindProxyForURL(url, host)

//Romania Proxy
{
if (isInNet(myIpAddress(), "192.168.1.0", "255.255.255.0"))
{ return "PROXY 192.168.1.249:3128";
}

// Israel Poxy
if (isInNet(myIpAddress(), "126.0.0.0", "255.0.0.0"))
{ return "PROXY 126.0.3.51:3128";
}

//UK Proxy
if (isInNet(myIpAddress(), "131.107.2.0", "255.255.255.0"))
{ return "PROXY 131.107.2.112:3128";
}

//US Proxy
if (isInNet(myIpAddress(), "192.168.35.0", "255.255.255.0"))
{ return "PROXY 192.168.35.0:3128";
}

//Modiin Proxy
if (isInNet(myIpAddress(), "192.168.50.0", "255.255.255.0"))
{ return "PROXY 192.168.50.98:3128";
}

else return "PROXY 126.0.3.51:3128";
}

