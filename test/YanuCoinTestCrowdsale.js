var YanuCoinTestCrowdsale = artifacts.require("YanuCoinTestCrowdsale");
var YanuCoinTest = artifacts.require("YanuCoinTest");

contract('YanuCoinTestCrowdsale', function(accounts) {
  it('should deploy the token and store the address', function(done){
      YanuCoinTestCrowdsale.deployed().then(async function(instance) {
          const token = await instance.token.call();
          assert(token, 'Token address couldn\'t be stored');
          done();
     });
  });

  it('should get the ETH_USD conversion when deploys contract', function(done) {
    const openingTime = web3.eth.getBlock('latest').timestamp + 2; // two secs in the future
    const closingTime = openingTime + 86400 * 20; // 20 days
    const rate = 5;
    const wallet = accounts[1];
    const goal = 2000000000000000000;
    const cap = 500000000000000000000;
    YanuCoinTestCrowdsale.new(openingTime,
        closingTime,
        rate,
        wallet,
        goal,
        cap,
        YanuCoinTest.address)
    .then(instance => promisifyLogWatch(instance.LogCallback({ fromBlock: 'latest' })))
    .then(log => {
        assert.equal(log.event, 'LogCallback', 'LogCallback not emitted.');
        assert.isNotNull(log.args.price, 'Price returned was null.');

        console.log('Success! Current price is: ' + parseInt(parseFloat(log.args.price) * 100, 10) + ' cents (USD/ETH)');
        done();
    });
  });

  it('should set stage to PreICO', function(done){
      YanuCoinTestCrowdsale.deployed().then(async function(instance) {
        await instance.setCrowdsaleStage(0);
        const stage = await instance.stage.call();
        assert.equal(stage.toNumber(), 0, 'The stage couldn\'t be set to PreICO');
        done();
     });
  });

  it('one ETH should buy 5 YanuCoinTest Tokens in PreICO', function(done){
      YanuCoinTestCrowdsale.deployed().then(async function(instance) {
        const tokenAddress = await instance.token.call()
        const YanuCoinTestInstance = await YanuCoinTest.at(tokenAddress)
        await YanuCoinTestInstance.transferOwnership(instance.address)
        const balance = await YanuCoinTestInstance.balanceOf(accounts[4])
        assert.equal(balance.toNumber(), 0, 'The balance of the purchaser isn\'t 0')
        await instance.addManyToWhitelist(accounts)
        await instance.sendTransaction({ from: accounts[4], value: web3.toWei(1, "ether") })
        const tokenAmount = await YanuCoinTestInstance.balanceOf(accounts[4]);
        assert.equal(tokenAmount.toNumber(), 5000000000000000000, 'The sender didn\'t receive the tokens as per PreICO rate');
        done();
     });
         
  });

  /**
 * Helper to wait for log emission.
 * @param  {Object} _event The event to wait for.
 */
function promisifyLogWatch(_event) {
    return new Promise((resolve, reject) => {
      _event.watch((error, log) => {
        _event.stopWatching();
        if (error !== null)
          reject(error);
  
        resolve(log);
      });
    });
  }

  
  
});

/*it('should transfer the ETH to wallet immediately in Pre ICO', function(done){
    YanuCoinTestCrowdsale.deployed().then(async function(instance) {
        let balanceOfBeneficiary = await web3.eth.getBalance(accounts[9]);
        balanceOfBeneficiary = Number(balanceOfBeneficiary.toString(10));

        await instance.sendTransaction({ from: accounts[1], value: web3.toWei(1, "ether")});

        let newBalanceOfBeneficiary = await web3.eth.getBalance(accounts[9]);
        newBalanceOfBeneficiary = Number(newBalanceOfBeneficiary.toString(10));

        assert.equal(newBalanceOfBeneficiary, balanceOfBeneficiary + 2000000000000000000, 'ETH couldn\'t be transferred to the beneficiary');

        done();
   });
});

  it('should set variable `totalWeiRaisedDuringPreICO` correctly', function(done){
      YanuCoinTestCrowdsale.deployed().then(async function(instance) {
        const data = await instance.getETHUSDPrice();
        console.log('data', data)
        data.logs.map(a => { console.log('data', a)});
          var amount = await instance.totalWeiRaisedDuringPreICO.call();
          assert.equal(amount.toNumber(), web3.toWei(3, "ether"), 'Total ETH raised in PreICO was not calculated correctly');
          done();
     });
  });

  it('should set stage to ICO', function(done){
      YanuCoinTestCrowdsale.deployed().then(async function(instance) {
        const data = await instance.updateDL();
        console.log('data', data)
        data.logs.map(a => { console.log('data', a)});
        await instance.setCrowdsaleStage(1);
        const stage = await instance.stage.call();
        assert.equal(stage.toNumber(), 1, 'The stage couldn\'t be set to ICO');
        done();
     });
  });

  it('one ETH should buy 2 YanuCoinTest Tokens in ICO', function(done){
      YanuCoinTestCrowdsale.deployed().then(async function(instance) {
          await instance.sendTransaction({ from: accounts[8], value: web3.toWei(1, "ether")});
          const tokenAddress = await instance.token.call();
          const YanuCoinTestToken = YanuCoinTest.at(tokenAddress);
          const tokenAmount = await YanuCoinTestToken.balanceOf(accounts[8]);
          assert.equal(tokenAmount.toNumber(), 2000000000000000000, 'The sender didn\'t receive the tokens as per ICO rate');
          done();
     });
  });

  it('should transfer the raised ETH to RefundVault during ICO', function(done){
      YanuCoinTestCrowdsale.deployed().then(async function(instance) {
          var vaultAddress = await instance.vault.call();

          let balance = await web3.eth.getBalance(vaultAddress);

          assert.equal(balance.toNumber(), 1500000000000000000, 'ETH couldn\'t be transferred to the vault');
          done();
     });
  });

  it('Vault balance should be added to our wallet once ICO is over', function(done){
      YanuCoinTestCrowdsale.deployed().then(async function(instance) {
          let balanceOfBeneficiary = await web3.eth.getBalance(accounts[9]);
          balanceOfBeneficiary = balanceOfBeneficiary.toNumber();

          var vaultAddress = await instance.vault.call();
          let vaultBalance = await web3.eth.getBalance(vaultAddress);

          await instance.finish(accounts[0], accounts[1], accounts[2]);

          let newBalanceOfBeneficiary = await web3.eth.getBalance(accounts[9]);
          newBalanceOfBeneficiary = newBalanceOfBeneficiary.toNumber();

          assert.equal(newBalanceOfBeneficiary, balanceOfBeneficiary + vaultBalance.toNumber(), 'Vault balance couldn\'t be sent to the wallet');
          done();
     });
  });*/