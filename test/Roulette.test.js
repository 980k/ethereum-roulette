const TestRoulette =  artifacts.require("TestRoulette")
const RandomNumber = artifacts.require("RandomNumber")

function tokens(n) {
    return web3.utils.toWei(n, 'ether')
}

contract("TestRoulette", (accounts) => {
    let roulette, randomNumber

    before(async() => {
        randomNumber = await RandomNumber.deployed()
        roulette = await TestRoulette.deployed()
    })

    it("ensures that deposits and withdrawals are working", async() => {
        let balance

        await roulette.depositOwnerFunds({from: accounts[0], value: tokens('2')})
        balance = await roulette.getOwnerBalance()
        assert.equal(balance, 2000000000000000000, 'The balance should be 2 ETH')

        await roulette.withdrawFunds({to: accounts[0]})
        balance = await roulette.getOwnerBalance();
        assert.equal(balance, 0, 'The balance should be 0')
    })

    it("ensures that players can place bets", async() => {
        let balance, betOnRed, betOnBlack, betOnGreen, betPlaced, betSize

        await roulette.placeBet("red", {from: accounts[1], value: tokens('0.01')})

        balance = await roulette.getPlayerBalance();
        betOnRed = await roulette.getBetOnRed();
        betOnBlack = await roulette.getBetOnBlack();
        betOnGreen = await roulette.getBetOnGreen();
        betPlaced = await roulette.getBetPlaced();
        betSize = await roulette.getBetSize();

        assert.equal(balance, 10000000000000000, 'The balance should be 0.01 ETH')
        assert.equal(true, betOnRed, 'Player bet on red')
        assert.equal(false, betOnBlack, 'Player did not bet on black')
        assert.equal(false, betOnGreen, 'Player did not get on green')
        assert.equal(true, betPlaced, 'Bet should be marked as placed')
        assert.equal(betSize, 10000000000000000, 'Bet size should be 0.01 ETH')
    })

    it("ensures that the bet is evaluated and funds are transferred correctly", async() => {
        let ownerBalance, playerBalance, betOnBlack

        await roulette.depositOwnerFunds({from: accounts[0], value: tokens('5')})

        ownerBalance = await roulette.getOwnerBalance()
        playerBalance = await roulette.getPlayerBalance()

        assert.equal(ownerBalance, 5000000000000000000, 'The balance should be 5 ETH')
        assert.equal(playerBalance, 10000000000000000, 'The balance should be 0.01 ETH' )

        await roulette.setNumber(4)
        
        await roulette.evaluateBet()

        ownerBalance = await roulette.getOwnerBalance()
        playerBalance = await roulette.getPlayerBalance()

        assert.equal(ownerBalance,4990000000000000000, 'Balance should be 4.99 ETH')
        assert.equal(playerBalance, 20000000000000000, 'Balance should be 0.02 ETH')
    })
})