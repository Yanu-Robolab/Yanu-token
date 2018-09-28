# Libraries Solidity
Yanu ICO test.

Use openzeppelin and oraclize-api

## Getting Started
Install packages:
`Truffle`
`Ganache`

Etherum-bride:
```sh
mkdir ethereum-bridge
git clone https://github.com/oraclize/ethereum-bridge ethereum-bridge
cd ethereum-bridge
npm install
```
Run ganache and execute
```sh
node bridge -a 8 -H 127.0.0.1 -p 7545 --dev
```

In dev mode, copy the OAR from etherum-bridge console to the YanuCoinTestCrowdsale contract.

## Truffle

Compile and migrate.

```sh
truffle compile
truffle migrate
```

Test the contract (should be run Ganache and etherum-bridge)

```sh
truffle test
```
