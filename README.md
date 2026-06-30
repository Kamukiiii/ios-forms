# Forma iOS App — SwiftUI 高保真实现

基于 Forma.dc.html 原型，完整转换为 SwiftUI 原生 iOS 代码。

## 项目结构（14 个 Swift 文件，4300+ 行）

```
Forma/
├── FormaApp.swift       ← App 入口 + RootView 全局路由
├── AppState.swift       ← 全局状态管理（ObservableObject）
├── Models.swift         ← 数据模型（FormModel / Question / QuestionType）
├── Theme.swift          ← 设计 Token（颜色、字体、阴影、渐变）
├── SplashView.swift     ← 启动页（Logo 脉冲动画 + 转场）
├── LoginView.swift      ← 登录页（Google OAuth 流程仿真）
├── HomeView.swift       ← 主页（列表/网格、搜索、FAB、筛选）
├── EditorView.swift     ← 表单编辑器容器（Nav bar + 4 标签页）
├── QuestionsTab.swift   ← 题目编辑（15种题型、工具栏）
├── PreviewTab.swift     ← 答题预览（完整答题交互）
├── ResponsesTab.swift   ← 回复统计（柱状图、饼图、个人回复）
├── SettingsTab.swift    ← 表单设置（Toggle 行、合作者管理）
├── Components.swift     ← 通用组件（Toggle、SegControl、卡片等）
└── Sheets.swift         ← 所有底部弹层（菜单、筛选、创建、Pro等）
```

## Xcode 项目创建步骤

1. 打开 Xcode → New Project → iOS → **App**
2. Product Name: `Forma`
3. Interface: `SwiftUI`，Language: `Swift`
4. 最低支持系统：**iOS 16.0**
5. 删除自动生成的 `ContentView.swift`
6. 将 `Forma/` 目录中的所有 `.swift` 文件拖入 Xcode 项目

## 功能覆盖

| 界面 | 实现内容 |
|------|---------|
| Splash | Logo 脉冲 + spinner 动画，1.9s 自动跳转 |
| 登录 | Google 账号选择弹层，Signing in 过渡动画 |
| 主页 | 列表/网格两种布局，搜索、收藏、筛选/排序，FAB 新建 |
| 编辑 Questions | 15种题型（单选/多选/下拉/量表/评分/日期/时间/网格等），题目增删复制，Required toggle |
| 编辑 Preview | 完整可交互答题流程，提交按钮，登录弹层 |
| 编辑 Responses | 统计卡、柱状图、纵向图、文字回复，逐条查看 |
| 编辑 Settings | 所有 toggle 设置项，合作者管理，登出 |
| 弹层 | 更多菜单、筛选排序、创建表单、题型选择、Forma Pro 订阅 |

## 设计还原精度

- 主色 `#5b5bd6`、所有语义色精确还原
- iOS 原生 SF Symbols 对应全部自定义图标
- 圆角、阴影、渐变全部匹配设计规范
- 动画：sheetUp / fadeIn / popIn / spin / splashPulse 全部实现
- Dynamic Island 样式状态栏（390×844 设计基准）
