# Firebase 接入步骤（15 分钟完成）

## 第一步：创建 Firebase 项目

1. 打开 https://console.firebase.google.com
2. 点击 **添加项目**，随便命名（如 `forma-app`）
3. 关闭 Google Analytics（可选），点击**创建项目**

---

## 第二步：添加 iOS 应用

1. 进入项目 → 点击 **iOS+** 图标
2. **Bundle ID** 填写你 Xcode 项目的 Bundle ID（例如 `com.yourname.forma`）
   - Xcode → 点击项目名 → General → Bundle Identifier
3. 点击**注册应用**
4. 下载 **GoogleService-Info.plist**，拖入 Xcode 项目根目录
   - 确保勾选 "Copy items if needed" + "Add to target: Forma"

---

## 第三步：开启 Google 登录

1. Firebase Console → **Authentication** → **Sign-in method**
2. 点击 **Google** → 开启 → 填写项目支持电子邮件 → 保存

---

## 第四步：创建 Firestore 数据库

1. Firebase Console → **Firestore Database** → **创建数据库**
2. 选择**以生产模式启动**（或测试模式也可）
3. 选择离你最近的服务器地区 → 启用

**安全规则（粘贴到 Rules 标签）：**
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 只有本人能读写自己的表单
    match /users/{userId}/forms/{formId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 第五步：Xcode 添加 SDK（Swift Package Manager）

1. Xcode → File → **Add Package Dependencies**
2. 搜索并添加（两个包）：

**Firebase iOS SDK：**
```
https://github.com/firebase/firebase-ios-sdk
```
勾选：`FirebaseAuth` + `FirebaseFirestore`

**Google Sign-In SDK：**
```
https://github.com/google/GoogleSignIn-iOS
```
勾选：`GoogleSignIn`

---

## 第六步：配置 URL Scheme（Google Sign-In 回调必须）

1. 打开 `GoogleService-Info.plist`，找到 `REVERSED_CLIENT_ID` 字段的值
   - 长这样：`com.googleusercontent.apps.XXXXXX-XXXXXX`
2. Xcode → 点击项目名 → **Info** → **URL Types** → 点击 `+`
3. **URL Schemes** 填入刚才复制的 `REVERSED_CLIENT_ID` 值

---

## 第七步：修改分享链接域名（可选）

`EditorView.swift` 和 `Sheets.swift` 里的链接是占位符：
```swift
"https://forma-app.web.app/f/\(form.id)"
```

如果你要设置真实链接：
- 开启 Firebase Hosting → 部署一个简单重定向页面
- 或直接用 Custom URL Scheme：`forma://f/{formId}`（无需域名）

---

## 完成后的效果

| 功能 | 实现方式 |
|------|---------|
| Google 登录 | Firebase Auth + Google Sign-In SDK，真实 OAuth |
| 数据持久化 | Cloud Firestore，实时同步，支持离线缓存 |
| 表单分享 | iOS 原生 UIActivityViewController（微信/微博/复制/邮件等） |
| 登出 | 清除 Firebase Auth + Google Sign-In session |
| 自动保存 | 离开编辑器时写入 Firestore |

---

## 常见问题

**Q: 登录时出现 `Error 10` 或 `invalid_client`**  
A: 检查 Xcode URL Schemes 是否正确填入了 REVERSED_CLIENT_ID

**Q: Firestore 权限被拒绝**  
A: 检查安全规则，确认已登录

**Q: Build 失败，找不到 FirebaseCore**  
A: 确认 Package 已添加到 Target，并已 import FirebaseCore 在 FormaApp.swift
