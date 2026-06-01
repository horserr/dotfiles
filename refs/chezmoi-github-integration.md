根据 chezmoi 的官方文档，gitHubLatestRelease 函数返回的是一个直接从 GitHub API 获取的 JSON 对象。它包含了该 Release 的所有核心元数据。
你可以通过在变量后加点号（例如 $latest.TagName）来访问这些属性。以下是该对象中最常用、最实用的属性列表：
## 核心属性列表

| 属性名称 (Property) | 数据类型 | 示例值 | 说明 |
|---|---|---|---|
| .TagName | string | "v0.5.1-beta" | 最常用。发布的版本标签名。 |
| .Name | string | "N_m3u8DL-RE v0.5.1-beta" | Release 的标题。 |
| .Body | string | "# 更新日志\n- 修复了..." | 开发者写的 Release 说明（Markdown 文本）。 |
| .Prerelease | bool | true 或 false | 是否为预发布版本（Beta/RC版）。 |
| .Draft | bool | true 或 false | 是否为草稿状态。 |
| .CreatedAt | time.Time | 2025-10-29T12:00:00Z | Release 创建的时间。 |
| .PublishedAt | time.Time | 2025-10-29T13:11:00Z | Release 正式发布的时间。 |
| .Assets | array | [...] | 包含所有上传文件（Assets）的列表对象。 |

------------------------------
## 💡 隐藏的高级玩法示例
既然它返回了这么完整的对象，除了用来拼接文件名，你还可以在 chezmoi 的模板中玩出很多高级的花样：
## 1. 过滤掉预览版（Beta），只用正式版
有些软件的最新版可能是个不稳定的 Beta 版。如果你只想用正式版，可以结合 .Prerelease 进行判断：

{{- $latest := gitHubLatestRelease "nilaoda/N_m3u8DL-RE" }}# 如果最新版是预览版，打印一行注释，或者执行别的逻辑
{{- if $latest.Prerelease }}# 提示：当前最新版是预发布版本：{{ $latest.TagName }}
{{- end }}

## 2. 在配置文件中自动注入软件版本说明
你可以把作者写的更新日志（.Body）当成注释直接渲染到你的本地配置文件中，方便你随时查看更新了什么：

# ----------------------------------------------------# 软件更新日志 (来自 GitHub Latest Release):
{{ $latest.Body | comment "# " }}# ----------------------------------------------------

提示：comment "# " 是 chezmoi 的内置函数，能把多行文本前面自动加上 # 号变成合法的 TOML 注释。
## 3. 遍历 .Assets（高级筛选）
如果你不想用 gitHubLatestReleaseAssetURL 的模糊通配符，你甚至可以自己写循环去遍历 .Assets 数组，精确寻找你想要的文件大小、下载量或者特定命名的资产：

{{- $latest := gitHubLatestRelease "nilaoda/N_m3u8DL-RE" }}
{{- range $latest.Assets }}
  {{- if contains "win-x64" .Name }}
    # 找到了文件：{{ .Name }}，下载量是：{{ .DownloadCount }}
  {{- end }}
{{- end }}

你还想了解关于 gitHubLatestTag 或者 chezmoi 其他 GitHub 模板函数的用法吗？我可以为你提供更多的联动高级示例。

