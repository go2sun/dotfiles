#compdef kb
# CliBrain kb 子命令补全
# 用法: 在 zshrc source 本文件, 或放到 fpath 目录

_kb() {
  local -a subcmds
  subcmds=(
    'new:新建笔记(带 frontmatter 模板)'
    'capture:随手记进 inbox(最高频)'
    'grep:ripgrep 直通(精确串/报错)'
    'doctor:健康检查'
    'index:建/更新索引(--full 推倒重建)'
    'ask:语义+RAG 问答(需起 embedding/LLM 服务)'
    'search:BM25 检索(主题, --phrase 短语, --fzf 预览)'
    'notes-pull:Apple Notes 单向汇入(手动)'
  )
  _describe 'subcommand' subcmds
}

_kb "$@"
