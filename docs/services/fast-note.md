# Fast Note Sync (FNS) — Mac 用户级部署与 API 联动 Obsidian 详解

> 用途：Obsidian 多端实时同步 + Web 后台 + 原生 MCP（让 AI 读写你的笔记）。
> 本机部署方式：用户级（`~/fast-note` + `~/Library/LaunchAgents`），零 sudo，开机自启，监听 127.0.0.1:9000。

---

## 一、它是什么

Fast Note Sync 是「Obsidian 社区插件 + 独立后端服务」的组合：

- **obsidian-fast-note-sync**：Obsidian 内的同步客户端插件（TypeScript）。
- **fast-note-sync-service**：真正干活的后端（Golang + WebSocket + React）。所有笔记、附件、
  历史、分享都存在它这里，多端只是连它。

后端能力：
- 实时双向同步、附件同步、笔记历史/版本恢复、回收站恢复
- 离线编辑自动合并（多设备不会互覆盖）
- 原生 **MCP**（SSE / StreamableHTTP）——作为 MCP server 接进 AI 客户端，
  让 AI 读写你的 Obsidian 笔记，改动实时同步回所有端
- 默认 SQLite（单文件数据库），零额外依赖，本地单用户最合适
- 可选 Git 自动同步、S3/OSS/R2/WebDAV 备份

---

## 二、Mac 本地安装（用户级，推荐，零 sudo）

### 方式 A：一键脚本（本仓库提供的幂等安装）
```bash
bash ~/dotfiles/scripts/install-fast-note.sh
```
脚本行为：
1. 下载 darwin-arm64 二进制到 `~/fast-note`（已装则跳过，不重下）
2. 写入 config（监听 `127.0.0.1:9000`，仅本机回环）
3. 软链 LaunchAgent plist 到 `~/Library/LaunchAgents/`
4. `launchctl load` 开机自启，并验证 9000 端口监听

### 方式 B：手动（等价于脚本，便于理解）
```bash
cd ~
curl -fSL -o fns.tar.gz \
  https://github.com/haierkeys/fast-note-sync-service/releases/download/3.6.0/fast-note-sync-service-3.6.0-darwin-arm64.tar.gz
mkdir -p fast-note && tar -xzf fns.tar.gz -C fast-note
mkdir -p fast-note/storage/log
# 用仓库模板 config（已绑 127.0.0.1）
cp ~/dotfiles/config/fast-note/config.yaml ~/fast-note/config/config.yaml
# 注册开机自启
ln -s ~/dotfiles/LaunchAgents/com.haierkeys.fast-note.plist ~/Library/LaunchAgents/
launchctl load -w ~/Library/LaunchAgents/com.haierkeys.fast-note.plist
```

### 验证
```bash
lsof -nP -iTCP:9000 -sTCP:LISTEN      # 应看到 fast-note 监听 127.0.0.1:9000
curl -sS -o /dev/null -w "%{http_code}\n" http://127.0.0.1:9000/   # 302 = 正常
```

---

## 三、初始化与 Obsidian 插件对接

1. 浏览器开 **http://127.0.0.1:9000** → 首次访问注册一个账号
   （默认 `user.register-is-enable: true` 开放注册；用熟后可设 `false` 关闭）
2. 登录后台 → 左侧「笔记库」(Note Vaults) → 点「复制 API 配置」(Copy API Config)
3. Obsidian 装插件：
   - 商店搜 `Fast Note Sync` 安装；若未上架就手动把 `main.js`/`styles.css`/`manifest.json`
     放进 `<Vault>/.obsidian/plugins/fast-note-sync/`
   - 插件设置里粘贴第 2 步复制的配置 → 完成授权
   - 也可后台点「一键授权 Obsidian」，自动唤起 Obsidian 填好
4. 验证：在 Obsidian 改个笔记，后台/另一台设备秒级同步

---

## 四、API 联动 Obsidian 详解（核心）

FNS 后端暴露标准 REST API（Base URL `http://127.0.0.1:9000/api`）和 MCP。
这两者都能直接操作你的 Vault 内容——**等价于 Obsidian 插件做的事，但用代码/AI 驱动**。

> ### ⚠️ 实测关键结论（2026-07-20 真实验证，必读）
> 1. **插件「复制 API 配置」拿到的 token 是受限 token**：用它调 REST（`/api/folder/notes`、`/api/files`、`/api/note` 等）和 MCP（`/api/mcp`）都会返回
>    `code:315 "Auth token Scope restricted"`。**这枚 token 只够 Obsidian 插件走 WebSocket 同步，不能当 REST/MCP 全权限用。**
> 2. 后台生成的「个人令牌」实测同样是受限 scope（tokenId=3、6 都试过，均 315）。
>    FNS 当前版本的普通用户 token 不满足 `oauth.required-scopes`（notes:read/files:read/vaults:read），REST/MCP 服务端操作被拒。
> 3. **因此：想用「脚本/AI 直接写后端」联动 Obsidian，最稳的路不是 REST/MCP，而是「路径 Y」——直接写本地 Vault 的 markdown 文件**，
>    由已连接的 FNS 插件自动经 WebSocket 同步到后端与其他端。零 token、不受 315 限制、正是 FNS 设计主用法。
> 4. 若确实要 REST/MCP 程序化写入，需放开后端 `oauth.default-fns-scope`（config.yaml）并用带 scope 的 OAuth 流拿 token——属改后端配置，非开箱可用。

### 路径 Y：直接写本地 Vault 文件（推荐，绕开 315，最稳）

FNS 插件监听本地 Vault 目录的文件变更并实时同步。所以"程序/AI 写笔记"= 直接写本地 md 文件：

```bash
V="/Users/nusun/Documents/Project/MacMiniM4"   # 你的 vault 本地路径
mkdir -p "$V/FNS测试"
cat > "$V/FNS测试/hello.md" <<'EOF'
# 标题
内容...
EOF
# → FNS 插件监听到变更 → 经 WebSocket 推到后端 (127.0.0.1:9000) → 其他端/后台实时出现
```

验证：Obsidian 里看 `FNS测试/hello.md` 出现，或浏览器后台 `http://127.0.0.1:9000/webgui/?vaults` 进对应 vault 看到它。
（实测：文件落盘 100% 确定；后端同步只要插件连着即秒级。本机 2026-07-20 已跑通。）

### 4.1 鉴权模型

> ⚠️ 实测：后端限制 `/api/user/login` 必须 **webgui 客户端** 调用
> （直接 curl 会返回 `code:314 "This action is restricted to webgui client only"`）。
> 所以**不要**用 curl 直接 login，而是走下面任一种拿 token：

**推荐：从 Web 后台「复制 API 配置」拿 token**
1. 浏览器登录 http://127.0.0.1:9000
2. 后台 → 笔记库 → 「复制 API 配置」，那段 JSON 含 `token` / `server` / `vault`
3. 提取 token：
   ```bash
   # 假设复制的内容存到 /tmp/fns_api.json
   TOKEN=$(python3 -c "import json;print(json.load(open('/tmp/fns_api.json'))['token'])")
   VAULT=$(python3 -c "import json;print(json.load(open('/tmp/fns_api.json'))['vault'])")
   ```

**替代：curl 带 webgui 客户端头登录**（仅供脚本自动化）
```bash
TOKEN=$(curl -sS -X POST http://127.0.0.1:9000/api/user/login \
  -H "Content-Type: application/json" \
  -H "X-Client: webgui" \
  -d '{"username":"你的账号","password":"你的密码"}' \
  | python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('data',{}).get('token',''))")
```

之后所有请求带头：`Authorization: Bearer $TOKEN`。
插件「复制 API 配置」的 JSON 即 `{server, token, vault}` 三件套。

### 4.2 标准响应结构
```json
{ "code": 1, "status": true, "message": "ok", "data": ... }
```
- `code`: 0=失败，1+=成功；`status`: 布尔；`data`: 业务数据；`details`: 错误详情（可选）
- 常见错误码：405 注册关闭 / 407 用户名不存在 / 414 Vault 不存在 / 428 笔记不存在 /
  445 需管理员权限 / 507 未登录 / 508 会话过期

### 4.3 笔记 CRUD（联动 Obsidian 的关键）

> 路径参数需 `vault=<你的Vault名>`（即后台「笔记库」名字）。

**列出某文件夹下的笔记**
```bash
curl -sS "http://127.0.0.1:9000/api/folder/notes?vault=MyVault&path=&page=1&page_size=50" \
  -H "Authorization: Bearer $TOKEN"
```

**读取单篇笔记内容**
```bash
curl -sS "http://127.0.0.1:9000/api/note?vault=MyVault&path=日记/2026-07-20.md" \
  -H "Authorization: Bearer $TOKEN"
```

**创建/更新笔记**（PUT 即写，触发同步）
```bash
curl -sS -X PUT "http://127.0.0.1:9000/api/note" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"vault":"MyVault","path":"日记/2026-07-20.md","content":"# 今天\n- 用 FNS API 写了这条"}'
```
→ 这条写入会**实时推送到所有已连 Obsidian 客户端**（和你在 Obsidian 里手打等效）。

**删除笔记**（进回收站，可恢复）
```bash
curl -sS -X DELETE "http://127.0.0.1:9000/api/note?vault=MyVault&path=临时.md" \
  -H "Authorization: Bearer $TOKEN"
```

**笔记历史 / 恢复**
```bash
curl -sS "http://127.0.0.1:9000/api/note/history?vault=MyVault&path=日记/2026-07-20.md&page=1" \
  -H "Authorization: Bearer $TOKEN"
# 恢复到某版本用 POST /api/note/restore，带 versionId
```

### 4.4 文件夹 / 附件

**建文件夹**
```bash
curl -sS -X POST "http://127.0.0.1:9000/api/folder" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"vault":"MyVault","path":"项目/AI"}'
```

**列附件 / 取附件内容**
```bash
curl -sS "http://127.0.0.1:9000/api/files?vault=MyVault&page=1" -H "Authorization: Bearer $TOKEN"
curl -sS "http://127.0.0.1:9000/api/file?vault=MyVault&path=图片/图1.png" -H "Authorization: Bearer $TOKEN" -o 图1.png
```

**上传附件**（图片/PDF 等，会同步到 Obsidian）
```bash
curl -sS -X POST "http://127.0.0.1:9000/api/file" \
  -H "Authorization: Bearer $TOKEN" \
  -F "vault=MyVault" -F "path=图片/图1.png" -F "file=@./图1.png"
```

### 4.5 与 Obsidian 的联动关系（重要）

```
       你写笔记
   ┌────────────────┐
   │  Obsidian 插件  │──WebSocket──┐
   └────────────────┘             │
                                  ▼
                          ┌───────────────────┐
   REST API / MCP  ──────▶│  FNS 后端 :9000   │  (SQLite 存储)
   (脚本/AI 直接写)        └───────────────────┘
                                  │ WebSocket 推送
                                  ▼
                          ┌────────────────┐
                          │ 其他 Obsidian  │  (手机/另一台Mac 实时更新)
                          │   / Web 后台   │
                          └────────────────┘
```
- **Obsidian 插件**：人改笔记 → 经 WebSocket 同步到后端 → 后端推给所有在线端
- **REST API / MCP**：程序或 AI 直接写后端 → 同样经 WebSocket 推给所有 Obsidian 端
- 三者对后端是等价的"写入者"，最终都落在同一份 SQLite，互相同步

典型用法：
- 用脚本批量把网页/微信收藏转成 Markdown 笔记 → 调 API 写入 → Obsidian 自动出现
- AI（经 MCP）帮你整理 Vault、改写笔记、生成每日摘要 → 改动实时回写 Obsidian
- 定时任务把 Vault 备份到 Git / S3（用 `/api/git-sync/config` 或 `git:` 配置段）

---

## 五、MCP 接入（让 AI 读写你的笔记）

后端原生支持 MCP，两种方式：

> ⚠️ **实测：MCP 同样受 token scope 限制。** 用插件「复制 API 配置」或后台生成的普通 token 调 `POST /api/mcp` 会返回
> `code:315 "Auth token Scope restricted"`（与 REST 同因）。要让 AI 经 MCP 读写笔记，token 必须带 `notes:write` 等 scope——
> 当前版本需放开 `oauth.default-fns-scope`(config.yaml) 并走带 scope 的 OAuth 流获取，非开箱可用。
> **当前最稳的「AI/脚本联动 Obsidian」方式见第四节「路径 Y」：直接写本地 Vault 文件，由插件自动同步。**

### StreamableHTTP（推荐，Claude Code / hermes-agent / Cursor 都支持）
端点：`http://127.0.0.1:9000/api/mcp`
```json
{
  "mcpServers": {
    "fns": {
      "url": "http://127.0.0.1:9000/api/mcp",
      "type": "http",
      "headers": {
        "Content-Type": "application/json",
        "Authorization": "Bearer <你的Token>",
        "X-Default-Vault-Name": "<你的Vault名>",
        "X-Client": "hermes-agent",
        "X-Client-Version": "1.0",
        "X-Client-Name": "Mac"
      }
    }
  }
}
```

### SSE（兼容旧客户端，如 Cherry Studio）
端点：`http://127.0.0.1:9000/api/mcp/sse`
```json
{
  "mcpServers": {
    "fns": {
      "url": "http://127.0.0.1:9000/api/mcp/sse",
      "type": "sse",
      "headers": {
        "Content-Type": "application/json",
        "Authorization": "Bearer <你的Token>",
        "X-Default-Vault-Name": "<你的Vault名>"
      }
    }
  }
}
```

Token 获取：Web 后台「复制 API 配置」里那段 JSON 含 token；或按 4.1 登录拿。
`X-Default-Vault-Name` 指定工具调用默认操作的 Vault（不传则需每次指定 vault 参数）。

> 接 Hermes：把上面 StreamableHTTP 那段加进 Hermes 的 MCP 配置即可。
> 接 Cursor/Claude Code：写进对应 `mcp.json` / `.mcp.json`。

---

## 六、备份 / 维护 / 卸载

### 备份（纯本地）
数据全在 `~/fast-note/storage`（SQLite + 附件）。整目录打包即备份：
```bash
tar -czf fns-backup-$(date +%Y%m%d).tgz -C ~ fast-note/storage
```
也可在后台配 Git 自动同步 / S3 备份（无需手动）。

### 查看日志
```bash
tail -f ~/fast-note/storage/log/launchd.err.log   # 启动/运行错误
tail -f ~/fast-note/storage/log/launchd.out.log
```

### 升级
```bash
bash ~/dotfiles/scripts/install-fast-note.sh   # 幂等, 下载新版本并 reload
```

### 卸载（干净回退）
```bash
launchctl unload -w ~/Library/LaunchAgents/com.haierkeys.fast-note.plist
rm ~/Library/LaunchAgents/com.haierkeys.fast-note.plist
rm -rf ~/fast-note        # 数据+程序全清
```

---

## 七、安全要点（本地单用户视角）

- **监听地址**：已设为 `127.0.0.1:9000`（仅本机回环），不要改回 `:9000`（会暴露局域网）。
  要远程访问请走 Cloudflare Tunnel，别直接开 0.0.0.0 端口。
- **默认密钥**：`security.auth-token-key` / `share-token-key` 是示例值。
  纯本地自用风险低；若暴露出去务必改掉：
  ```bash
  openssl rand -base64 32   # 生成后填入 config.yaml security 段
  ```
  改完 `launchctl unload/load` 重启服务生效。
- **注册开关**：用熟后设 `user.register-is-enable: false` 关闭公开注册。
- **数据**：SQLite 单文件 + 附件目录，备份=打包 `storage/`；不进 git（含笔记隐私）。
- 本仓库 dotfiles 只纳入「安装脚本 + config 模板 + plist」，**不纳入任何笔记数据和密钥**。

---

## 八、与其他方案的对比

| 方案 | 实时 | 依赖 | 多端 | AI/MCP | 备注 |
|------|------|------|------|--------|------|
| FNS（本方案） | ✓ | Go 后端(SQLite) | ✓ | ✓ 原生 | 开箱即用、有 Web 后台 |
| Obsidian Git | ✗(手动/定时) | git | ✓ | ✗ | 纯版本化、免费 |
| Self-hosted LiveSync | ✓ | CouchDB | ✓ | ✗ | 要跑 CouchDB |

选 FNS 的理由：开箱即用 + Web 后台 + 原生 MCP（让 AI 直接操作笔记），代价仅一个轻量 Go 服务。
