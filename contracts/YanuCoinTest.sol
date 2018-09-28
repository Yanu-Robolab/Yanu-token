pragma solidity ^0.4.19;

import 'zeppelin-solidity/contracts/token/ERC20/MintableToken.sol';

contract YanuCoinTest is MintableToken {
    string public name = "YANU COIN TEST";
    string public symbol = "YAN";
    uint8 public decimals = 18;
}