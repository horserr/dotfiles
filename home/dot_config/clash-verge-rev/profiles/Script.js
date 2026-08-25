// reference: https://www.clashverge.dev/guide/script.html

// two types of main entries
// function main(config) {
// function main(config, profileName) {

function main(config) {
  const prependRules = [
    "PROCESS-NAME,ssh.exe,DIRECT",
    "PROCESS-NAME,Setup.exe,DIRECT",
    "PROCESS-NAME,QQMusic.exe,DIRECT",
    "DOMAIN-SUFFIX,hf.co,DIRECT",
    "DOMAIN-REGEX,.*mirror[sz]?\..*,DIRECT",
    "DOMAIN-SUFFIX,mirrorz.org,DIRECT",
    "DOMAIN-SUFFIX,cr.aliyuncs.com,DIRECT",
    "DOMAIN-SUFFIX,blob.core.windows.net,DIRECT",
    "PROCESS-NAME,SDXHelper.exe,DIRECT",
    "DOMAIN-KEYWORD,nvcr,DIRECT",
    "DOMAIN,nvidia,DIRECT",
    "DOMAIN-KEYWORD,daocloud,DIRECT",
    "DOMAIN-SUFFIX,steamcontent.com,DIRECT",
    "PROCESS-NAME,qbittorrent.exe,DIRECT",
    "PROCESS-NAME,WINWORD.EXE,DIRECT",
    "PROCESS-NAME,rclone.exe,DIRECT",
    "PROCESS-NAME,yt-dlp.exe,DIRECT",
    "PROCESS-NAME,Photos.exe,DIRECT",
    "DOMAIN,cloudconfig.jetbrains.com,DIRECT",
    "PROCESS-NAME,CrossDeviceService.exe,DIRECT",
    "PROCESS-NAME,PhoneExperienceHost.exe,DIRECT",
  ];

  config.rules = [...prependRules, ...config.rules];

  return config;
}
