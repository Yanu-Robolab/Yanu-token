const YanuCoinTestCrowdsale = artifacts.require('./YanuCoinTestCrowdsale.sol');
const YanuCoinTest = artifacts.require('./YanuCoinTest.sol');

module.exports = function(deployer, network, accounts) {
    const openingTime = web3.eth.getBlock('latest').timestamp + 2; // two secs in the future
    const closingTime = openingTime + 86400 * 20; // 20 days
    // const openingTime = Math.round((new Date(new Date().getTime() - 86400000).getTime())/1000); // Yesterday
    // const closingTime = Math.round((new Date().getTime() + (86400000 * 20))/1000); // Today + 20 days
    const rate = 5;//new web3.BigNumber(1000);
    const wallet = accounts[9];
    const goal = 200000000000000000000;
    const cap = 50000000000000000000000;

    return deployer
        .then(() => {
            return deployer.deploy(YanuCoinTest);
        })
        .then(() => {
            return deployer.deploy(
                YanuCoinTestCrowdsale,
                openingTime,
                closingTime,
                rate,
                wallet,
                goal,
                cap,
                YanuCoinTest.address
            );
        });
};