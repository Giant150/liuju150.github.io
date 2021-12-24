Start-Deploy -ComputerName 182.43.196.20 -WebSiteName LiuJu -WebSitePort 8802 -ScriptBlock {
    npm run clean
    npm run deploy
} -OutputPath .\public\