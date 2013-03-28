This is a temporary project. No STARS/FORKS plz, thx.

# Introduction

This is a growing RSS reader app for exercising use. My general idea about this product is to split the reader into two parts: 

* PART.ONE is for managing a list of feeds the user has already subscribed.
	* Users can subscribe/unsubscribe new RSS feeds through tapping top-right Add button or notified by this app through listening to your pasteboard (no leaks absolutely lol.).
	* As important features for managing subscribed, sorting(into different folder),  tagging and favoriting are needed.(These feature is highly related to database, it's technically a little hard for me now).
	* Notification for entries that have been favorited long time ago but haven't been read yet. Notification for user starred feeds when new entries published (A further thought. Web service needed).
	* Clean reading for entries. Share to social networks. Send mail.
	* Reading process saving of Clean Reading feature.
* PART.TWO is a center to find new good website, it's mainly a embedded browser.
	* Webpage links users tapped in PART.ONE will make the view scroll to PART.TWO. In this way, the user can switch from the origin article and the references web pages.
	* This PART will provide some good websites one the home page.

Through all the time the app running, user can easily switch between the two part by swiping from top or bottom.

Environment : 10.8.3/Xcode 4.6/iOS 6 Simulator

# 茫茫多的坑

#### --------------说点仅限于有代码的部分吧，别的不YY了

1. 还得实现Part.Two的第一个功能，得往RCRollerViewController里面加入一个NotificationCenter，在翻滚动画完成后发布Notification通知，在需要接受信息的ViewControllers里面来实现通知的接收。
2. 要同时存在至少两个ViewController在内存中，特别Part.Two中的UIWebView是内存消耗大户。目前粗略想到的办法可能有：
	* Part.Two中缓存载入的当前网页，在翻滚入Part.One后释放Part.Two中WebView，在重新翻滚到Part.Two的时候重新建一个WebView实例并载入缓存(如果重新建WebView实例的开销导致翻滚动画卡顿明显则不释放WebView，让WebView在隐藏前载入一个空页面)
	* Part.One中的Clean Reading使用Core-Text来实现可能会比厚重的WebView占用内存少一些。
3. Decouple RC…ParseOperation and their private class rc_…Parser.
4. RCRollerViewController有不少需要改进的地方
	* 动画变定后的位置可能会产生位移
	* 3.5寸设备上貌似座标有点问题
	* 需要精简逻辑和改代码的同时需要修正一些诸如[[UIApplication sharedApplication] endIgnoringUserInteraction]方法没被调用到和快速反复在Part.One和Part.Two之间roll所导致的view消失的bug.
5. 需添加数据持久化。

# 废话

最近过的够混沌的哈，虽然只是憋出个这么一坨，不过我觉得总比逃避的好，客观原因就不找了，这轮面试收获还是蛮大的，不只是技术还有自我认知。

说点苦逼事儿吧，前天晴天霹雳地接到通知让周六回学校做开题答辩，临时顶着糖酒会的高峰定了张几乎全价机票（不愧是苍老师都参加的活动），于是乎3小时后我又得踏上回学校的旅程。导师要求远程做毕设前得把一部分demo跟他讨论一下，回学校会先集中一两周的精力把毕业设计的东西再缓慢推进一些。之后还是想抽身回成都实习。

十分高兴能认识并接触到地沟(**抱歉用这个不恰当的幽默代替团队名字，怕挂真名不太好**)团队，就这次的收获来说已经不敢奢求更多了。

Greate Appreciation to Joel, Rick and Wade.
