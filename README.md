# HackNews - Hacker News iOS 客户端

一个美观、功能完整的 Hacker News iOS 客户端，使用 Objective-C 编写，提供流畅的阅读体验和本地化支持。

## 应用特性

### 🚀 核心功能

- **多类型新闻流**：支持查看 Top、New、Best、Show、Ask、Job 等多种类型的新闻
- **无限滚动**：分页加载新闻，提供流畅的浏览体验
- **下拉刷新**：支持 Pull-to-Refresh 刷新内容
- **内置浏览器**：使用 Safari Services 直接在应用内打开链接
- **翻译功能**：集成翻译管理器，支持新闻标题翻译
- **个性化设置**：
  - 语言切换（中文/英文）
  - 字体大小调整
  - 新闻流类型选择

### 🎨 用户体验

- **现代化 UI**：采用 Apple 最新的设计风格
- **自适应布局**：支持不同屏幕尺寸和方向
- **实时加载**：网络请求状态可视化
- **智能缓存**：优化的网络请求管理
- **响应式交互**：支持点击跳转和长按操作

## 技术架构

### 核心设计模式

- **单例模式**：全局网络管理器 (HNNetworkManager) 和语言管理器 (LanguageManager)
- **MVC 架构**：清晰的模型-视图-控制器分离
- **Block/Closure 回调**：异步网络请求处理
- **NSNotification**：组件间通信机制

### 网络通信

- **Hacker News API**：官方 API 集成
- **Dispatch Group**：并发请求优化
- **错误处理**：完整的网络错误处理机制

### 数据模型

- **HNItem**：新闻项模型类
- **HNStoryCell**：自定义的新闻展示单元格
- **Core Data**：支持本地数据存储

## 项目结构

```
HackNews/
├── HackNews/
│   ├── Models/
│   │   ├── HNItem.h/m              # 新闻项模型
│   │   └── HNTranslation.h/m       # 翻译管理器
│   ├── Network/
│   │   └── HNNetworkManager.h/m    # 网络管理类
│   ├── Views/
│   │   ├── HNStoryCell.h/m         # 新闻列表单元格
│   │   └── HNStoryCell.xib         # 单元格界面文件
│   ├── Controllers/
│   │   ├── ViewController.h/m      # 主视图控制器
│   │   └── SettingsViewController.h/m  # 设置界面
│   ├── Managers/
│   │   └── LanguageManager.h/m     # 语言管理类
│   ├── Resources/
│   │   ├── Assets.xcassets         # 资源文件
│   │   ├── zh-Hans.lproj/          # 中文本地化文件
│   │   ├── en.lproj/               # 英文本地化文件
│   │   └── Base.lproj/             # 基础界面文件
│   └── Supporting Files/
│       ├── Info.plist
│       └── main.m
└── HackNews.xcodeproj
```

## 安装与运行

### 系统要求

- iOS 13.0 或更高版本
- Xcode 12 或更高版本
- Objective-C 开发环境

### 步骤

1. 克隆或下载项目
2. 打开 `HackNews.xcodeproj`
3. 选择合适的 iOS 模拟器或设备
4. 点击 Run 按钮 (⌘R)

## 使用说明

### 导航菜单

- **左侧菜单**：切换新闻流类型
- **右侧设置**：打开应用设置

### 新闻阅读

- 点击新闻标题在应用内打开
- 下拉刷新获取最新内容
- 滑动到底部自动加载更多

### 设置选项

- **Language**：切换界面语言（中文/英文）
- **Font Size**：调整新闻标题字体大小
- **Default Feed Type**：设置默认新闻流类型

## 开发说明

### 网络请求

```objective-c
// 获取单例实例
HNNetworkManager *manager = [HNNetworkManager sharedManager];

// 获取特定类型的新闻
[manager fetchStoryIdsForType:HNFeedTypeTop completion:^(NSArray<NSNumber *> * _Nullable ids, NSError * _Nullable error) {
    if (error) {
        NSLog(@"获取新闻ID失败: %@", error);
    } else {
        NSLog(@"成功获取 %lu 条新闻ID", (unsigned long)ids.count);
    }
}];
```

### 本地化支持

```objective-c
// 设置语言
[LanguageManager sharedManager].currentLanguage = @"zh-Hans";

// 获取本地化字符串
NSString *title = LS(@"title_top"); // 自动根据语言返回对应的翻译
```
