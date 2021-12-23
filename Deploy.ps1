Start-Deploy -ComputerName 182.43.196.20 -WebSiteName Blog -WebSitePort 8100 -ScriptBlock {
    npm run clean
    npm run deploy
} -OutputPath .\public\