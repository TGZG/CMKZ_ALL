注：以下过程中想到的解决bug的方案来自于自己、谷歌、克劳德。
- 先查如何使用Node.js实现前后台。发现需要安装Node.js和electron。
- 安装Node.js成功，安装electron失败。
- 使用管理员权限，还是安装失败。
- 开梯子，还是安装失败。
- 使用镜像，还是安装失败。
- 不选择在D盘创建项目，改为在默认的C盘用户下创建。还是失败。
- 尝试书写一个hellowworld，运行，成功。觉得或许不需要electron。
- 使用AI生成一个包含前后台的小项目代码，运行，报错说server.js文件找不到。
- 修改main.js为server.js，运行，报错说package.json找不到。
- 修改packkage.json为package.json，运行，显示的是phpstudy的页面。
- 卸载phpstudy，运行，还是phpstudy的页面。
- 检查hosts文件，没发现问题。
- 将地址栏localhost改为127.0.0.1，没有用，还是phpstudy的页面。
- 打开服务列表，尝试寻找apche服务，无果。
- 清理浏览器缓存，运行，终于不是phpstudy了，但进入一个错误页面。
- 检查代码，将Main.html改为index.html，运行，还是错误。
- 将index.html改为public/index.html，运行，还是错误。
- 把所有文件编码从GBK改为UTF，运行，好了。
总结：JS文件名的问题是真蛋疼。写C#久了之后就忽视文件名。
注：以上过程发生在28分钟内，且这28分钟包含测试那个前后台项目的使用效果。