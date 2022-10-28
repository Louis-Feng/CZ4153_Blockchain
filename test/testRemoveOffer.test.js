const BasicToken = artifacts.require("BasicToken");
const TokenA = artifacts.require("TokenA");
const DEX = artifacts.require("DEX");

contract("DEX", (accounts) => {
  let tokenA, token, dex;
  let owner = accounts[0];

  before("add some buy/sell orders (price 15: 500)  (price 30: 300, 1, 2)", async () => {
      token = await BasicToken.deployed();
      tokenA = await TokenA.deployed();
      dex = await DEX.deployed();
      await dex.storeOrder(tokenA.address,true, 15, 500, accounts[5]);
      await dex.storeOrder(tokenA.address,true, 30, 300, accounts[2]);
      await dex.storeOrder(tokenA.address,true, 30, 1, accounts[4]);
      await dex.storeOrder(tokenA.address,true, 30, 2, accounts[5]);
      await dex.storeOrder(tokenA.address,false, 15, 500, accounts[5]);
      await dex.storeOrder(tokenA.address,false, 30, 300, accounts[2]);
      await dex.storeOrder(tokenA.address,false, 30, 1, accounts[4]);
      await dex.storeOrder(tokenA.address,false, 30, 2, accounts[5]);
  });

    describe("remove a sell offer: only offer at this price", async () => {

      it("remove sell offer", async () => {
        let result = await dex.removeOrder(token.address, tokenA.address, true, 15, {from: accounts[5]});
        result = await dex.getOrderBookInfo(tokenA.address, true);
        assert.equal(result[0], "sell");
        assert.equal(result[1], 1);
        assert.equal(result[2], 30);
        assert.equal(result[3], 30);

        orders = await dex.getOrders(tokenA.address,true);
        assert.equal(orders[0].length, 3)

      });
    });

    describe("remove a sell offer: multiple offer at this price", async () => {

          it("remove sell offer", async () => {
            await dex.removeOrder(token.address, tokenA.address, true, 30, {from: accounts[4]});
            let result = await dex.getOrderBookInfo(tokenA.address, true);
            assert.equal(result[0], "sell");
            assert.equal(result[1], 1);
            assert.equal(result[2], 30);
            assert.equal(result[3], 30);

            let offerList = await dex.getOffersInfo(tokenA.address, true, 30);
            assert.equal(offerList[0], 2);
            assert.equal(offerList[1], 1);
            assert.equal(offerList[2], 3);
            assert.equal(offerList[3], 30);

            orders = await dex.getOrders(tokenA.address,true);
            assert.equal(orders[0].length, 2)

          });
        });

    describe("remove a buy offer: only offer at this price", async () => {

      it("remove buy offer", async () => {
        let result = await dex.removeOrder(token.address, tokenA.address, false, 15, {from: accounts[5]});
        result = await dex.getOrderBookInfo(tokenA.address, false);
        assert.equal(result[0], "buy");
        assert.equal(result[1], 1);
        assert.equal(result[2], 30);
        assert.equal(result[3], 30);

        orders = await dex.getOrders(tokenA.address,false);
        assert.equal(orders[0].length, 3)

      });
    });

    describe("remove a buy offer: multiple offer at this price", async () => {

      it("remove buy offer", async () => {
        await dex.removeOrder(token.address, tokenA.address, false, 30, {from: accounts[4]});
        let result = await dex.getOrderBookInfo(tokenA.address, false);
        assert.equal(result[0], "buy");
        assert.equal(result[1], 1);
        assert.equal(result[2], 30);
        assert.equal(result[3], 30);

        let offerList = await dex.getOffersInfo(tokenA.address, false, 30);
        assert.equal(offerList[0], 2);
        assert.equal(offerList[1], 1);
        assert.equal(offerList[2], 3);
        assert.equal(offerList[3], 30);

        orders = await dex.getOrders(tokenA.address,false);
        assert.equal(orders[0].length, 2)

      });
    });


});