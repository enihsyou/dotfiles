// 修改 Edge 本地新标签页的快速链接
//
// quickLinks.list()
// quickLinks.get(1)
// await quickLinks.updateUrl(1, "http://192.168.9.2/")
// await quickLinks.updateTitle(1, "新路由器")
// await quickLinks.update(1, "http://192.168.9.2/", "新路由器")
// quickLinks.export()
// await quickLinks.import(jsonOrArray)

(() => {
    const api = globalThis.chrome?.embeddedSearch?.newTabPage
    if (!api) throw new Error("当前页面没有 Embedded Search API")

    const sleep = ms => new Promise(resolve => setTimeout(resolve, ms))
    const ridState = () => api.mostVisited.map(({ rid }) => rid).join(",")

    function getItem(rid) {
        const publicData = api.mostVisited.find(item => item.rid === rid)
        const privateData = api.getMostVisitedItemData(rid)
        return publicData && privateData ? { ...publicData, ...privateData } : null
    }

    function getAll() {
        return api.mostVisited.map(({ rid }) => getItem(rid)).filter(Boolean)
    }

    function requireItem(rid) {
        const item = getItem(rid)
        if (!item) throw new Error(`找不到 rid=${rid}`)
        return item
    }

    async function waitForChange(before, timeout = 3000) {
        const deadline = Date.now() + timeout
        while (Date.now() < deadline) {
            if (ridState() !== before) return
            await sleep(50)
        }
        throw new Error("等待快速链接列表刷新超时")
    }

    async function change(action) {
        const before = ridState()
        action()
        await waitForChange(before)
    }

    async function updateItem(rid, url, title) {
        requireItem(rid)
        await change(() => api.updateCustomLink(rid, url ?? "", title ?? ""))
    }

    function parseImport(input) {
        let data = input
        if (typeof data === "string") {
            try { data = JSON.parse(data) }
            catch { throw new TypeError("导入内容不是有效的 JSON") }
        }

        if (!Array.isArray(data)) throw new TypeError("导入内容必须是数组")

        return data.map((item, index) => {
            const url = typeof item?.url === "string" ? item.url.trim() : ""
            const title = typeof item?.title === "string" ? item.title.trim() : ""
            if (!url) throw new TypeError(`第 ${index + 1} 项缺少有效的 url`)
            return { url, title: title || url }
        })
    }

    globalThis.quickLinks = {
        list() {
            const items = getAll()
            console.table(items.map(({ rid, title, url, domain }) => ({ rid, title, url, domain })))
            return items
        },

        get: getItem,

        update(rid, newUrl, newTitle) {
            return updateItem(rid, newUrl, newTitle)
        },

        updateUrl(rid, newUrl) {
            return updateItem(rid, newUrl)
        },

        updateTitle(rid, newTitle) {
            return updateItem(rid, undefined, newTitle)
        },

        async add(url, title = url) {
            url = typeof url === "string" ? url.trim() : ""
            title = typeof title === "string" ? title.trim() : ""
            if (!url) throw new TypeError("url 不能为空")
            await change(() => api.addCustomLink(url, title || url))
        },

        async remove(rid) {
            requireItem(rid)
            await change(() => api.deleteMostVisitedItem(rid))
        },

        export() {
            const data = getAll().map(({ title, url }) => ({ title, url }))
            const json = JSON.stringify(data, null, 2)
            if (typeof copy === "function") copy(json)
            else navigator.clipboard?.writeText(json)
            console.log(json)
            return data
        },

        async import(input) {
            const data = parseImport(input)
            for (const { url, title } of data) await this.add(url, title)
            return getAll()
        }
    }

    quickLinks.list()
})()
