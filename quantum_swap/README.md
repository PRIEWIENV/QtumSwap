## Atomic Swap Script with Qtum and Bitcoin

Suppose A has a unit of qtum and B has b unit of bitcoin and they want to exchange.

Both A and B has qtum address, bitcoin address, noted as A_q, A_b, B_q, B_b

H: Hashlock
S: Secret

1. At time 2T, A sends CLTV1(H(S), qtum_a ) to B
2. B listens the event (off-chain) and gets H(S)
3. At time T, B sends CLTV2(H(S), bitcoin_b) to A
4. A listens the event (off-chain)
5. A spends CLTV2 on BTC, B listens new UXTO and gets S
6. B spends CLTV1 on QTUM


## How to use

```
npm i
npm test
```


## FAQ

* What if there is error msg: `Failed at the bitcore-node@3.1.3 preinstall script './scripts/download'`?

Ans: Install `curl`
