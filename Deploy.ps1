Start-Deploy -ComputerName 182.43.196.20 -WebSiteName GiantLiu -WebSitePort 8801 -ScriptBlock {
    npm run clean
    npm run deploy
} -OutputPath .\public\