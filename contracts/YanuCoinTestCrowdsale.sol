pragma solidity ^0.4.19;

import './YanuCoinTest.sol';
import 'zeppelin-solidity/contracts/crowdsale/emission/MintedCrowdsale.sol';
import 'zeppelin-solidity/contracts/crowdsale/validation/TimedCrowdsale.sol';
import 'zeppelin-solidity/contracts/crowdsale/validation/WhitelistedCrowdsale.sol';
import 'zeppelin-solidity/contracts/crowdsale/validation/CappedCrowdsale.sol';
import 'zeppelin-solidity/contracts/crowdsale/distribution/FinalizableCrowdsale.sol';
import 'zeppelin-solidity/contracts/crowdsale/distribution/RefundableCrowdsale.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

import "installed_contracts/oraclize-api/contracts/usingOraclize.sol";

contract YanuCoinTestCrowdsale is 
  TimedCrowdsale,
  MintedCrowdsale,
  WhitelistedCrowdsale,
  CappedCrowdsale,
  FinalizableCrowdsale,
  RefundableCrowdsale,
  usingOraclize {
  // ICO Stage
  // ============
  enum CrowdsaleStage { PreICO, ICO }
  CrowdsaleStage public stage = CrowdsaleStage.PreICO; // By default it's Pre Sale
  // =============

  // Token Distribution
  // =============================
  uint256 public maxTokens = 10000000000000000000000; // There will be total 10000 Hashnode Tokens
  uint256 public tokensForEcosystem = 20000000000000000000;
  uint256 public tokensForTeam = 10000000000000000000;
  uint256 public tokensForBounty = 10000000000000000000;
  uint256 public totalTokensForSale = 6000000000000000000000; // 6000 HTs will be sold in Crowdsale
  uint256 public totalTokensForSaleDuringPreICO = 20000000000000000000000; // 200 out of 60 HTs will be sold during PreICO
  // ==============================

  // Amount raised in PreICO
  // ==================
  uint256 public totalWeiRaisedDuringPreICO;
  // ===================

  // ETH price in USD
  // ==================
  uint public ETH_USD = 0;
  // ==================

  // Events
  event EthTransferred(string text);
  event EthRefunded(string text);
  event EthLog(string text);
  event LogPriceUpdate(string price);
  event LogPrice(uint price);
  event LogInfo(string text);
  event LogCallback(string price);

  // Constructor
  // ============
  constructor
    (
      uint256 _openingTime,
      uint256 _closingTime,
      uint256 _rate,
      address _wallet,
      uint256 _goal,
      uint256 _cap,
      MintableToken _token
    )
    CappedCrowdsale(_cap)
    FinalizableCrowdsale()
    RefundableCrowdsale(_goal)
    TimedCrowdsale(_openingTime, _closingTime)
    Crowdsale(_rate, _wallet, _token)
    WhitelistedCrowdsale() public {
      require(_goal <= _cap);
      //OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
      OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
      
      oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
      update(0); // first check at contract creation
  }
  // =============

function __callback(bytes32 myid, string result, bytes proof) public {
    emit LogCallback(result);
    require(msg.sender == oraclize_cbAddress());
    ETH_USD = parseInt(result, 2); // save it as $ cents    
    // update(60); // schedule another check in 60 seconds
  }

  function update(uint delay) public payable {
    if (oraclize_getPrice("URL") > address(wallet).balance) {
        emit LogInfo("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
    } else {
        emit LogInfo("Oraclize query was sent, standing by for the answer..");

        // Using XPath to to fetch the right element in the JSON response
        oraclize_query(delay, "URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHUSD).result.XETHZUSD.c.0");
        // oraclize_query("URL", "json(https://api.coinbase.com/v2/prices/ETH-USD/spot).data.amount");
        // oraclize_query(delay, "URL",
           // "json(https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD).USD");
    }
  }

  // Token Deployment
  // =================
  function createTokenContract() internal returns (MintableToken) {
    emit EthLog('token instaance');
    return new YanuCoinTest(); // Deploys the ERC20 token. Automatically called when crowdsale contract is deployed
  }
  // ==================

  // Crowdsale Stage Management
  // =========================================================

  // Change Crowdsale Stage. Available Options: PreICO, ICO
  function setCrowdsaleStage(uint value) public onlyOwner {
      CrowdsaleStage _stage;

      if (uint(CrowdsaleStage.PreICO) == value) {
        _stage = CrowdsaleStage.PreICO;
      } else if (uint(CrowdsaleStage.ICO) == value) {
        _stage = CrowdsaleStage.ICO;
      }

      stage = _stage;

      if (stage == CrowdsaleStage.PreICO) {
        setCurrentRate(5);
      } else if (stage == CrowdsaleStage.ICO) {
        setCurrentRate(2);
      }
  }

  // Change the current rate
  function setCurrentRate(uint256 _rate) private {
      rate = _rate;
  }

function getETHUSDPrice() public payable {
    if (oraclize.getPrice("URL") > address(wallet).balance) {
      emit LogInfo("Oraclize query was NOT sent, please add some ETH to cover for the query fee");

    } else {
      emit LogInfo("Oraclize query was sent, standing by for the answer..");
      oraclize_query("URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHUSD).result.XETHZUSD.c.0");
    }
  }

  // ================ Stage Management Over =====================

  // Token Purchase
  // =========================
  function () external payable {
      require(ETH_USD > 0);
      
      uint256 ethToYanu = msg.value.mul(ETH_USD); 
      uint256 tokensThatWillBeMintedAfterPurchase = ethToYanu.mul(rate) / 1 ether;
      
      emit LogPrice(ethToYanu);
      emit LogPrice(tokensThatWillBeMintedAfterPurchase);
      emit LogPrice(token.totalSupply());
      emit LogPrice(totalTokensForSaleDuringPreICO);

      if ((stage == CrowdsaleStage.PreICO) && (token.totalSupply() + tokensThatWillBeMintedAfterPurchase > totalTokensForSaleDuringPreICO)) {
        msg.sender.transfer(msg.value); // Refund them
        emit EthRefunded("PreICO Limit Hit");
        return;
      }

      buyTokens(msg.sender);

      if (stage == CrowdsaleStage.PreICO) {
          totalWeiRaisedDuringPreICO = totalWeiRaisedDuringPreICO.add(msg.value);
      }
  }

  function forwardFunds() internal {
      if (stage == CrowdsaleStage.PreICO) {
          wallet.transfer(msg.value);
          emit EthTransferred("forwarding funds to wallet");
      } else if (stage == CrowdsaleStage.ICO) {
          emit EthTransferred("forwarding funds to refundable vault");
          super._forwardFunds();
      }
  }
  // ===========================

  // Finish: Mint Extra Tokens as needed before finalizing the Crowdsale.
  // ====================================================================

  function finish(address _teamFund, address _ecosystemFund, address _bountyFund) public onlyOwner {

      require(!isFinalized);
      uint256 alreadyMinted = token.totalSupply();
      require(alreadyMinted < maxTokens);

      uint256 unsoldTokens = totalTokensForSale - alreadyMinted;
      if (unsoldTokens > 0) {
        tokensForEcosystem = tokensForEcosystem + unsoldTokens;
      }

      MintableToken(token).mint(_teamFund,tokensForTeam);
      MintableToken(token).mint(_ecosystemFund,tokensForEcosystem);
      MintableToken(token).mint(_bountyFund,tokensForBounty);
      finalize();
  }
  // ===============================

  // REMOVE THIS FUNCTION ONCE YOU ARE READY FOR PRODUCTION
  // USEFUL FOR TESTING `finish()` FUNCTION
  function hasEnded() public view returns (bool) {
    return true;
  }
}

/*contract YanuCoinTestCrowdsale is TimedCrowdsale, MintedCrowdsale, WhitelistedCrowdsale  {
  constructor
             (
                 uint256 _openingTime,
                 uint256 _closingTime,
                 uint256 _rate,
                 address _wallet,
                 MintableToken _token
             )
             public
             Crowdsale(_rate, _wallet, _token)
             TimedCrowdsale(_openingTime, _closingTime)
             WhitelistedCrowdsale() {
             }
}*/ 