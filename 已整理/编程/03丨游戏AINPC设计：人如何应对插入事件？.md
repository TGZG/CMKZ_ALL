### 需求
当收到建议时，回复是否答应。
### 一阶：事件
``` C#
OnGetSuggest(t => Reply(t));
```
这有一个问题：瞬间回复，不需要思考吗？
### 二阶：延迟动作
``` C#
OnGetSuggest(t => Random(1, 5).SecondsThen(() => Reply(t)));
```
随机延迟1到5秒后回复，明明瞬间就能得到答案却非要装出一副思考的样子，类似于阿尔法狗固定两分钟走一步棋。虽然后台粗暴失真，但前台看来勉强能用。
但还有一个新问题：忙起来怎么办？收到建议时，忙碌的人会说稍等。
### 三阶：分类讨论
``` C#
OnGetSuggest(t => {
    if (IsBusy) {
        Speek(SpeekType.Wait);
        WaitFor(() => !IsBusy).Then(() => GetSuggest(t));
    } else {
        Speek(SpeekType.Emmm);
        Random(1, 5).SecondsThen(() => Reply(t));
    }
});
```
思路：受到建议时，如果忙碌，那么说稍等，然后等到不忙时再重新处理建议。如果不忙，那么说Emmm，然后随机一到五秒后回复。
这还有一个新问题：如何学习？例如后天签订了一个卖身协议：你要拒绝一切除我之外的人给你的提议。
不定时签协议，不定时撕毁协议，协议内容不定、上面只是一个特例。
目前的架构无法兼容这个新的需求，扩展性不够，因此还需要再修改。
### 四阶：临时记忆
``` C#
OnGetSuggest(t => Memory.InstantAdd(t));
AddRule(() => Memory.InstantHave<Suggest>(), () => {
    var A = Memory.InstantGet<Suggest>();
    if (IsBusy) {
        Speek(SpeekType.Wait);
        WaitFor(() => !IsBusy).Then(() => GetSuggest(A));
    } else {
        Speek(SpeekType.Emmm);
        Random(1, 5).SecondsThen(() => Reply(A));
    }
});
```
临时记忆容量为3到6，新增新内容时自动挤掉旧的内容。
当获得提议时，自动加入临时记忆。使用规则的形式实现对记忆的处理：如果记忆中有提议，那么分类讨论。
这样可以方便的实现规则的新增、修改、删除。要签订卖身协议，那么只需要这样：
``` C#
OnGetSuggest(t => Memory.InstantAdd(t));
AddRule(() => Memory.InstantHave<Suggest>(), () => {
    var A = Memory.InstantGet<Suggest>();
    if (IsBusy) {
        Speek(SpeekType.Wait);
        WaitFor(() => !IsBusy).Then(() => GetSuggest(A));
    } else {
        Speek(SpeekType.Emmm);
        Random(1, 5).SecondsThen(() => Reply(A));
    }
});
//卖身协议，前文默认协议为X
AddRule(() => Memory.InstantHave<Suggest>(), () => {
    var A = Memory.InstantGet<Suggest>();
    if(A.Sender != X.PartyA) {
        Speek(SpeekType.Reject);//拒绝
        Memory.InstantRemove(A);
    }
}, RuleType.High);//高优先级
```
这个结构还有其他好处，例如加入临时记忆时可以对提议进行预处理。
### 总结
上述结构还不与人脑完全一致，但足以实现现阶段的风神界DEMO设计，可以让AI能够处理提议。