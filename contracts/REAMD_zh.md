租房流程：
租客A 他的BTC地址是A_b, Qtum地址是A_q
房东B 他的BTC地址是B_b, Qtum地址是B_q

首先租客和房东已经达成在T时间内租赁房子，付款 V BTC
密码 s_k， hash = hash(s_k)
1、租客A输入时间T，hash, B_b，V，生成一个CLTV脚本，锁定V BTC。
2、房东监听事件，得到hash，调用beginRent, 输入price（price并没有参与运算，只是显示价格，所以可以用V赋值这个price），
   hash, T
3、租客监听事件，得到总房子数，减一得到houseNum，调用book函数，输入houseNum， hash，T。
4、租客解锁门锁，输入s_k, houseNum。
5、房东根据s_k在CLTV脚本上得到V BTC


Gateway原子交换步骤（支持Qtum与BTC, ERC20 token, NTF token交换）:
现在有一个ERC20 token TOK部署在Qtum上，它的合约地址是addr
玩家A和玩家B商量好了，玩家A用1000 TOK 换玩家B 10 BTC。
hash = hash(k)

1、玩家A先调用TOK的合约的approve函数，允许Gateway合约地址使用他地址下1000个TOK。
2、玩家A调用recharge函数，输入hash, 1000, addr, 玩家B的qtum地址（要转换成16进制），锁定时间1day
3、玩家B输入时间T半天，hash, A的比特币地址，10 BTC，生成一个CLTV脚本，锁定10 BTC。
4、玩家A去解锁那个CLTV脚本，输入k，得到10 BTC.
5、玩家B得到k，调用Gateway的withdrawTo，输入k，玩家A的qtum地址，得到1000 TOK
