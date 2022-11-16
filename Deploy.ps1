Start-Deploy -ComputerName 139.9.69.110 -WebSiteName LiuJu -WebSitePort 8802 -ScriptBlock {
    npm run clean
    npm run deploy
} -OutputPath .\public\