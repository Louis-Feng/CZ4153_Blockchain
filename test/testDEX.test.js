const BasicToken = artifacts.require("BasicToken");
const TokenA = artifacts.require("TokenA");
const DEX = artifacts.require("DEX");

contract("DEX", (accounts) => {
  let tokenA, token, dex;
  let owner = accounts[0];

  before(async () => {
      token = await BasicToken.deployed();
      tokenA = await TokenA.deployed();
      dex = await DEX.deployed();
  });

  // TokenA successfully deployed
    describe("Deployed TokenA", async () => {
      it("name check", async () => {
        const name = await tokenA.name();
        assert.equal(name, "Token A");
      });
    });

    // BasicToken successfully deployed
    describe("Deployed BasicToken", async () => {
      it("name check", async () => {
        const name = await token.name();
        assert.equal(name, "ND Coin");
      });
    });


    describe("Store 1st sell order", async () => {


        it("Store 1st sell order", async () => {
          let result = await dex.storeOrder(
            tokenA.address,true, 10, 5, accounts[0]
          );
          result = await dex.getOrders(tokenA.address,true);
          assert.equal(result[0][0], 10);
          assert.equal(result[1][0], 5);
        });
      });

      describe("Store 2nd sell order", async () => {


              it("Store 2nd sell order", async () => {
                let result = await dex.storeOrder(
                  tokenA.address,true, 1, 3, accounts[0]
                );
                result = await dex.getOrders(tokenA.address,true);
                assert.equal(result[0][0], 1);
                assert.equal(result[1][0], 3);
                assert.equal(result[0][1], 10);
                assert.equal(result[1][1], 5);
              });
            });
            describe("Store 1 basictoken to accounts[1]", async () => {


              it("Store 1 basictoken to accounts[1]", async () => {
                let result = await token.approve(accounts[0], 1);
                result = await token.transferFrom(accounts[0], accounts[1], 1);
                assert.equal(token.balanceOf(accounts[1]), 1);

              });
            });
            describe("execute market order", async () => {


              it("execute market order", async () => {
                let result = await dex.executeTokenMarket(
                  token.address,tokenA.address,1,web3.utils.asciiToHex("buy"),{from: accounts[1]}
                );
                result = await dex.getOrders(tokenA.address,true);
                assert.equal(result[0][0], 1);
                assert.equal(result[1][0], 2);
                assert.equal(tokenA.balanceOf(accounts[0]), 9999);
                assert.equal(tokenA.balanceOf(accounts[1]), 1);


              });
            });



});