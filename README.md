# deepin-xwall

深度系统15.5下 shadowsocks 全局代理智能分流一键脚本，使用 iptables + chnroute 实现智能分流功能。

## 依赖项

- DeepinLinux 15.5
- Shadowsocks-libev
- iptables
- ipset
- chnroute

## 安装条件

- 配置好的 shadowsocks 服务器

## 使用方法

克隆本仓库到本地，然后赋予 `xwall.sh` 执行权限，接着执行

```bash
./xwall.sh install {SS服务器地址} {通信端口} {密码} {加密方式，比如 aes-256-gcm}
```

脚本将自动执行安装操作，等待操作完成。

安装完成后，即可使用 `sudo systemctl start deepin-xwall` 启动代理服务。

如果出现无法访问网络等情况，请执行 `sudo systemctl status deepin-xwall` 查看服务运行状态。

## 项目结构

`/usr/local/deepin-xwall` 是项目的根目录地址，其内有 `sbin` `etc` `data` 三个子目录，`shadowsocks` 的配置文件存放于 `etc` 目录中。

## 更换 SS 节点

需要更换 SS 节点时，请执行 `./xwall.sh uninstall` 卸载后，重新安装即可。

## 致谢

感谢党让我有了提升技术水平的机会。感谢开源社区让我有了 copy 的机会。
