// ref: https://www.clashverge.dev/guide/script.html

const isAbroad = true;

// two types of main entries
// function main(config) {
function main(config, profileName) {
  const prependRules = [
    // "PROCESS-NAME,ssh.exe,DIRECT",
    "PROCESS-NAME,Code.exe,DIRECT",
    "PROCESS-NAME,Setup.exe,DIRECT",
    "PROCESS-NAME,QQMusic.exe,DIRECT",
    "DOMAIN-KEYWORD,deepseek,DIRECT",
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

  const prependRulesAbroad = [
    "DOMAIN-KEYWORD,chatgpt,PROXY",
    "DOMAIN-KEYWORD,openai,PROXY",
    "MATCH,DIRECT",
  ];

  if (isAbroad) {
    config.rules = [...prependRulesAbroad, ...config.rules];
  } else {
    config.rules = [...prependRules, ...config.rules];
  }

  const to = "PROXY";
  const RESERVED = ["DIRECT", "REJECT", "REJECT-DROP", "PASS", "COMPATIBLE"];

  // 从最后一条 MATCH 规则读出兜底组名
  const rules = config.rules ?? [];
  let from = "";
  for (let i = rules.length - 1; i >= 0; i--) {
    const parts = rules[i].split(",");
    if (parts[0].trim().toUpperCase() === "MATCH") {
      from = parts[1].trim();
      break;
    }
  }

  if (from && from !== to && !RESERVED.includes(from)) {
    // 如果配置里已经存在 PROXY 组，就不改名，只把规则出口指过去
    const hasTarget = (config["proxy-groups"] ?? []).some((g) => g.name === to);
    if (!hasTarget) {
      for (const g of config["proxy-groups"] ?? []) {
        if (g.name === from) g.name = to;
        if (Array.isArray(g.proxies))
          g.proxies = g.proxies.map((p) => (p === from ? to : p));
      }
    }
    // 规则出口统一指向 PROXY（名字里的特殊字符先转义，避免正则误伤）
    const esc = (s) => s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
    config.rules = rules.map((r) =>
      r.replace(new RegExp(`(^|,)${esc(from)}(,|$)`), `$1${to}$2`),
    );
  }

  if (profileName === "Default") {
    translateProxies(config);
  }

  return config;
}

const NAME_MAP = [
  [/^🇯🇵日本高速/, "🇯🇵Japan-HS"],
  [/^🇯🇵日本专线/, "🇯🇵Japan-DL"],
  [/^🇭🇰香港高速/, "🇭🇰HongKong-HS"],
  [/^🇸🇬新加坡高速/, "🇸🇬Singapore-HS"],
  [/^🇸🇬新加坡专线/, "🇸🇬Singapore-DL"],
  [/^🇺🇸美国高速/, "🇺🇸US-HS"],
  [/^🇺🇸美国洛杉矶/, "🇺🇸US-LosAngeles"],
  [/^🇬🇧英国伦敦/, "🇬🇧UK-London"],
  [/^🇨🇳台湾专线/, "🇨🇳Taiwan-DL"],
  [/^🇺🇸美国/, "🇺🇸US"],
];

function translateName(name) {
  for (const [re, to] of NAME_MAP) {
    if (re.test(name)) return name.replace(re, to);
  }
  return name; // 没匹配（比如「剩余流量」等假节点）→ 原样保留
}

function translateProxies(config) {
  // 1) 建立 旧名 → 新名 的映射
  const rename = {};
  for (const p of config.proxies ?? []) {
    const newName = translateName(p.name);
    if (newName !== p.name) rename[p.name] = newName;
  }

  // 2) 改节点自己的名字，以及 dialer-proxy 引用
  for (const p of config.proxies ?? []) {
    if (rename[p.name]) p.name = rename[p.name];
    if (rename[p["dialer-proxy"]])
      p["dialer-proxy"] = rename[p["dialer-proxy"]];
  }

  // 3) 同步 proxy-groups 里的引用（自动选择/故障转移/假节点不在映射里，自动原样保留）
  for (const g of config["proxy-groups"] ?? []) {
    if (Array.isArray(g.proxies)) {
      g.proxies = g.proxies.map((x) => rename[x] ?? x);
    }
  }

  return config;
}
