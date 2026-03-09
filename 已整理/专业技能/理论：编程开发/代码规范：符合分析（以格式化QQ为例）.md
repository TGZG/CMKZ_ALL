### 一阶
这次是一个C#小项目，用于自动格式化QQ消息记录。
F函数用于输入一个文件路径（存放原消息记录）、产出一个新文件（存放格式化后的消息）。
处理文本函数是核心，对文件内容做格式化。
``` C#
    public class Program {
        public static void F() {
            Console.WriteLine("请输入文件路径：（例如：D:\\Desktop\\测试.txt）");
            var A = Console.ReadLine().Trim();
            if (!File.Exists(A)) {
                Console.WriteLine("文件不存在，请检查路径是否正确。");
                return;
            }
            if (!A.EndsWith(".txt") && !A.EndsWith(".md")) {
                Console.WriteLine("只支持处理txt或md文件。");
                return;
            }
            try {
                File.WriteAllText(Path.Combine(
                    Path.GetDirectoryName(A),
                    Path.GetFileNameWithoutExtension(A) + "_调整" + Path.GetExtension(A)
                ), 处理文本(File.ReadAllText(A, Encoding.UTF8)), Encoding.UTF8);
                Console.WriteLine($"成功！");
            } catch (Exception ex) {
                Console.WriteLine($"失败：{ex.Message}");
            }
        }
        //处理消息记录：合并一个人的各个消息，让每一次换人说话就有一个空行、此外不准有空行
        public static string 处理文本(string X) {
            X = Regex.Replace(X, @"\r", "");
            X = Regex.Replace(X, @"\n+", "\n");
            X = Regex.Replace(X, @"\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}\n", "");//删除消息记录里的时间
            var A = new StringBuilder();
            var currentSpeaker = "";
            foreach (var i in X.Split('\n')) {
                int colonIndex = i.IndexOf(": ");
                if (colonIndex >= 0) {
                    var speaker = i[..colonIndex].Trim();
                    var content = i[(colonIndex + 1)..].Trim();
                    if (speaker != currentSpeaker) {
                        if (currentSpeaker != "") {// 换人时添加空行（首个发言人除外）
                            A.AppendLine("\n");
                        }
                        currentSpeaker = speaker;
                        A.Append($"{speaker}: {content}");
                    } else {
                        A.Append($"{content}");// 同一发言人追加内容
                    }
                } else {
                    A.Append($"\n{i.Trim()}");// 处理无冒号的连续内容行
                }
            }
            return A.ToString().Trim().Replace(": ", "：");
        }
    }
```
这个项目的核心函数里，开篇用了三个正则表达式。
它们完全可以写成一个，高效简洁；但为了可读性，轲目苦津要求写成三个。
### 二阶
上面那个大ForEach还是太复杂了。
它可以改为两步：先删除连续的同名角色名，再对新角色增加空行。
即：（只看处理文本）
``` C#
        public static string 处理文本(string X) {
            X = Regex.Replace(X, @"\r", "");
            X = Regex.Replace(X, @"\n+", "\n");
            X = Regex.Replace(X, @"\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}\n", "");//删除消息记录里的时间
            var A = 解析消息记录(X);
            for (int i = 0; i < A.Count - 1; i++) { //让A中连续相同的项合并
                if (A[i].发言人 == A[i + 1].发言人) {
                    A[i].发言内容 += "\n" + A[i + 1].发言内容;
                    A.RemoveAt(i + 1);
                    i--;
                }
            }
            return string.Join("\n\n", A);
        }
        public static List<消息> 解析消息记录(string 消息记录) {
            var 消息列表 = new List<消息>();
            string[] 消息片段 = Regex.Split(消息记录, @"\n(?=.*: )").Where(s => !string.IsNullOrWhiteSpace(s)).ToArray();
            foreach (var 片段 in 消息片段) {
                int 冒号索引 = 片段.IndexOf(": ");
                if (冒号索引 == -1) {
                    if (消息列表.Count != 0) {
                        消息列表[^1].发言内容 += "\n" + 片段.Trim();
                    }
                } else {
                    消息列表.Add(new 消息 {
                        发言人 = 片段[..冒号索引].Trim(),
                        发言内容 = 片段[(冒号索引 + 1)..].Trim()
                    });
                }
            }
            return 消息列表;
        }
        public class 消息 {
            public string 发言人;
            public string 发言内容;
            public override string ToString() => 发言人 + "：" + 发言内容;
        }
```
### 三阶
二阶看上去已经很棒了，但其实还不够。
foreach里面两层if，还是太丑、容易出错、难以debug。
进一步归一化预处理，把每一行消息都变为【发言人：内容】的格式：
``` C#
        public static string 处理文本(string X) {
            X = Regex.Replace(X, @"\r", "");
            X = Regex.Replace(X, @"\n+", "\n");
            X = Regex.Replace(X, @"\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}\n", "");//删除消息记录里的时间
            X = 发言人显化(X);
            var A = 解析消息记录(X);
            for (int i = 0; i < A.Count - 1; i++) { //让A中连续相同的项合并
                if (A[i].发言人 == A[i + 1].发言人) {
                    A[i].发言内容 += "\n" + A[i + 1].发言内容;
                    A.RemoveAt(i + 1);
                    i--;
                }
            }
            return string.Join("\n\n", A);
        }
        public static string 发言人显化(string X) {
            var 最终消息 = "";
            var 当前角色 = "";
            foreach (var i in X.Split('\n')) {
                int A = i.IndexOf(": ");
                if (A == -1) {
                    最终消息 +="\n"+ 当前角色 + ": " + i;
                } else {
                    当前角色 = i[..A];
                    最终消息 +="\n"+ i;
                }
            }
            return 最终消息;
        }
        public static List<消息> 解析消息记录(string 消息记录) {
            var 消息列表 = new List<消息>();
            string[] 消息片段 = Regex.Split(消息记录, @"\n(?=.*: )").Where(s => !string.IsNullOrWhiteSpace(s)).ToArray();
            foreach (var 片段 in 消息片段) {
                int 冒号索引 = 片段.IndexOf(": ");
                消息列表.Add(new 消息 {
                    发言人 = 片段[..冒号索引].Trim(),
                    发言内容 = 片段[(冒号索引 + 1)..].Trim()
                });
            }
            return 消息列表;
        }
```
### 四阶
设计一个消息记录类。
``` C#
    public class 消息类 {
        public string 发言人;
        public string 发言内容;
        public override string ToString() => 发言人 + "：" + 发言内容;
    }
    public class 消息记录类 : List<消息类> {
        public 消息记录类(string X) {
            X = Regex.Replace(X, @"\r", "");
            X = Regex.Replace(X, @"\n+", "\n");
            X = Regex.Replace(X, @"\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}\n", "");//删除消息记录里的时间
            X = 发言人显化(X);
            foreach (var i in X.Split('\n')) {
                int 冒号索引 = i.IndexOf(": ");
                Add(new 消息类 {
                    发言人 = i[..冒号索引].Trim(),
                    发言内容 = i[(冒号索引 + 1)..].Trim()
                });
            }
        }
        public 消息记录类 合并() {
            for (int i = 0; i < Count - 1; i++) {
                if (this[i].发言人 == this[i + 1].发言人) {
                    this[i].发言内容 += "\n" + this[i + 1].发言内容;
                    RemoveAt(i + 1);
                    i--;
                }
            }
            return this;
        }
        public override string ToString() => string.Join("\n\n", this);
        public static string 发言人显化(string X) {
            var 最终消息 = "";
            var 当前角色 = "";
            foreach (var i in X.Split('\n')) {
                int A = i.IndexOf(": ");
                if (A == -1) {
                    最终消息 += 当前角色 + ": " + i + "\n";
                } else {
                    当前角色 = i[..A];
                    最终消息 += i + "\n";
                }
            }
            return 最终消息.Trim();
        }
    }
```
### 五阶
增加一些奇技淫巧。得到最终优雅的代码。
``` C#
public class Program {
    public static void F() {
        Console.WriteLine("请输入文件路径：（例如：D:\\Desktop\\测试.txt）");
        var A = Console.ReadLine().Trim();
        if (!File.Exists(A)) {
            Console.WriteLine("文件不存在，请检查路径是否正确。");
            return;
        }
        if (!A.EndsWith(".txt") && !A.EndsWith(".md")) {
            Console.WriteLine("只支持处理txt或md文件。");
            return;
        }
        try {
            File.WriteAllText(Path.Combine(
                Path.GetDirectoryName(A),
                Path.GetFileNameWithoutExtension(A) + "_调整" + Path.GetExtension(A)
            ), new 消息记录类(File.ReadAllText(A, Encoding.UTF8)), Encoding.UTF8);
            Console.WriteLine($"成功！");
        } catch (Exception ex) {
            Console.WriteLine($"失败：{ex.Message}");
        }
    }
}
public class 消息类 {
    public string 发言人;
    public string 发言内容;
    public 消息类(string 合法消息) {
        int 冒号索引 = 合法消息.IndexOf(": ");
        发言人 = 合法消息[..冒号索引].Trim();
        发言内容 = 合法消息[(冒号索引 + 1)..].Trim();
    }
    public override string ToString() => 发言人 + "：" + 发言内容;
}
public class 消息记录类 : List<消息类> {
    public 消息记录类(string X) {
        X = Regex.Replace(X, @"\r", "");
        X = Regex.Replace(X, @"\n+", "\n");
        X = Regex.Replace(X, @"\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}\n", "");//删除消息记录里的时间
        X = 发言人显化(X);
        X.Split('\n').ForEach(t => Add(new 消息类(t)));
        合并();
    }
    public void 合并() {
        for (int i = 0; i < Count - 1; i++) {
            if (this[i].发言人 == this[i + 1].发言人) {
                this[i].发言内容 += "\n" + this[i + 1].发言内容;
                RemoveAt(i + 1);
                i--;
            }
        }
    }
    public static string 发言人显化(string X) {
        var 最终消息 = "";
        var 当前角色 = "";
        foreach (var i in X.Split('\n')) {
            int A = i.IndexOf(": ");
            if (A == -1) {
                最终消息 += 当前角色 + ": " + i + "\n";
            } else {
                当前角色 = i[..A];
                最终消息 += i + "\n";
            }
        }
        return 最终消息.Trim();
    }
    public override string ToString() => string.Join("\n\n", this as List<消息类>);
    public static implicit operator string(消息记录类 X) => X.ToString();
}
public static class Helper {
    public static void ForEach<T>(this IEnumerable<T> X, Action<T> Y) {
        foreach (T i in X) {
            Y(i);
        }
    }
}
```
最终的代码就非常容易维护，也非常容易扩展。
改动代码时遇到bug的话很好定位与修复。可读性非常强，思路清晰。
对比一阶的代码，对用户而言虽然功能是一样的，但对程序员而言上天差地别。
用户面向现在，程序员面向未来。