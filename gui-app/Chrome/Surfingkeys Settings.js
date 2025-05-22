// Advanced settings for Surfingkeys Chrome extension

// 增大滚动步长，默认是 70
settings.scrollStepSize = 100;

settings.omnibarSuggestion = true;

// 按下 r 键以刷新推荐流，而不是刷新页面
api.mapkey("r", "刷新推荐流", function () {
    var btn =
        // Bilibili Evolved, 需要在前面，因为插件实际是把官方页面隐藏起来
        document.querySelector("i.mdi-refresh") ||
        // Bilibili Official
        document.querySelector("button.roll-btn");
    if (btn) {
        btn.click();
    } else {
        api.Front.showBanner("无法定位刷新按钮！");
    }
}, { domain: /bilibili.com/i });

// 视频组件网页全屏的插件
api.unmap("w", /bilibili.com|youtube.com/i);

// 不要和浏览器的历史记录按键产生冲突
api.unmap("<Ctrl-h>");

// 不要和浏览器的下载列表按键产生冲突
api.unmap("<Ctrl-j>");

api.map('H','S'); // 历史后退
api.map('L','D'); // 历史前进
api.map('J','B'); // tab向左
api.map('K','F'); // tab向右

// 在 GitHub 页面会存在冲突
api.unmapAllExcept([], /github.com/i);

// 内联翻译的透明度不能改，这里就不用了
// api.Front.registerInlineQuery({});

// 颜色主题
settings.theme = `
.sk_theme {
    font-family: 'Cascadia Code NF', 'Maple Mono NF CN', sans-serif;
    font-size: 12pt;
}
`;