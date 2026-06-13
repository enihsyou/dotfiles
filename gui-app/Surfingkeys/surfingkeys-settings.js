// Advanced settings for Surfingkeys Chrome extension

// 增大滚动步长，默认是 70
settings.scrollStepSize = 100;

settings.omnibarSuggestion = true;

// 按下 r 键以刷新推荐流，而不是刷新页面
api.mapkey(
    "r",
    "刷新推荐流",
    function () {
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
    },
    { domain: /bilibili.com/i }
);

// 视频组件网页全屏的插件
api.unmap("W", /bilibili.com|youtube.com/i);

// YouTube frequent used keyboard shortcuts
// https://support.google.com/youtube/answer/7631406?hl=zh-Hans
["<", ">"].forEach((k) => api.unmap(k, /youtube.com/i));

// Pin 为桌面应用网站不要因为误触而关闭
api.unmap("x", /gemini.google.com/i);

// 不要和浏览器的历史记录按键产生冲突
api.unmap("<Ctrl-h>");

// 不要和浏览器的下载列表按键产生冲突
api.unmap("<Ctrl-j>");

// 不需要 emoji 输入
api.iunmap(":");

// api.map("H", "S"); // 历史后退
// api.map("L", "D"); // 历史前进 (之前是 Regional Hints mode)
// api.map("J", "B"); // tab向左
// api.map("K", "F"); // tab向右

// 在 GitHub 页面会存在冲突
// api.unmapAllExcept(['E', 'R', 'J', 'K', 'j', 'k', 'd', 'e'], /github.com/i);
["/"].forEach((k) => api.unmap(k, /github.com/i));

// 内联翻译的透明度不能改，这里就不用了
// api.Front.registerInlineQuery({});

// Disable PDF viewer
// https://github.com/brookhong/Surfingkeys/issues/1724
api.RUNTIME('updateSettings', {settings: {"noPdfViewer": 1}});

// 选词翻译 (cq)
// https://github.com/brookhong/Surfingkeys/wiki/Register-inline-query
api.Front.registerInlineQuery({
    url: function (q) {
        return `https://dict.youdao.com/w/eng/${q}`;
    },
    parseResult: function (res) {
        var parser = new DOMParser();
        var doc = parser.parseFromString(res.text, "text/html");
        var collinsResult = doc.querySelector("#collinsResult");
        var authTransToggle = doc.querySelector("#authTransToggle");
        var examplesToggle = doc.querySelector("#examplesToggle");
        if (collinsResult) {
            collinsResult
                .querySelectorAll("div>span.collinsOrder")
                .forEach(function (span) {
                    span.nextElementSibling.prepend(span);
                });
            collinsResult
                .querySelectorAll("div.examples")
                .forEach(function (div) {
                    div.innerHTML = div.innerHTML
                        .replace(/<p/gi, "<span")
                        .replace(/<\/p>/gi, "</span>");
                });
            var exp = collinsResult.innerHTML;
            return exp;
        } else if (authTransToggle) {
            authTransToggle.querySelector("div.via.ar").remove();
            return authTransToggle.innerHTML;
        } else if (examplesToggle) {
            return examplesToggle.innerHTML;
        }
    },
});

// 替换 DuckDuckGo 的键位为 Dictionary
api.addSearchAlias(
    "d",
    "youdao",
    "https://dict.youdao.com/w/eng/",
    "s",
    null,
    null
);

// 使用 Google 子域名，其余部分来自
// https://github.com/brookhong/Surfingkeys/blob/c8a5e153ccb4223b3eaa6faf1e5ab21d89a5b108/src/content_scripts/common/default.js#L701C1-L704C8
api.addSearchAlias(
    "g",
    "google",
    "https://www.google.com.hk/search?q=",
    "s",
    "https://www.google.com.hk/complete/search?client=chrome-omni&gs_ri=chrome-ext&oit=1&cp=1&pgcl=7&q=",
    function (response) {
        var res = JSON.parse(response.text);
        return res[1];
    }
);

// "手气不错" 跳转到第一个结果
api.addSearchAlias('f', 'feelinglucky', 'https://duckduckgo.com/?q=%5C');

// 颜色主题
settings.theme = `
.sk_theme {
    font-family: 'Cascadia Code NF', 'Maple Mono NF CN', sans-serif;
    font-size: 12pt;
}
`;
