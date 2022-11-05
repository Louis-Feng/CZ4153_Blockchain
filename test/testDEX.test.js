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
                  tokenA.address,true, 2, 3, accounts[0]
                );
                result = await dex.getOrders(tokenA.address,true);
                assert.equal(result[0][0], 2);
                assert.equal(result[1][0], 3);
                assert.equal(result[0][1], 10);
                assert.equal(result[1][1], 5);
              });
            });
      describe("Store 3rd sell order", async () => {


        it("Store 3rd sell order", async () => {
          let result = await dex.storeOrder(
            tokenA.address,true, 20, 10, accounts[0]
          );
          result = await dex.getOrders(tokenA.address,true);
          assert.equal(result[0][0], 2);
          assert.equal(result[1][0], 3);
          assert.equal(result[0][1], 10);
          assert.equal(result[1][1], 5);
          assert.equal(result[0][2], 20);
          assert.equal(result[1][2], 10);
        });
      });

      describe("Store 4th sell order", async () => {


          it("Store 4th sell order", async () => {
            let result = await dex.storeOrder(
              tokenA.address,true, 20, 15, accounts[0]
            );
            result = await dex.getOrders(tokenA.address,true);
            assert.equal(result[0][0], 2);
            assert.equal(result[1][0], 3);
            assert.equal(result[0][1], 10);
            assert.equal(result[1][1], 5);
            assert.equal(result[0][2], 20);
            assert.equal(result[1][2], 10);
            assert.equal(result[0][3], 20);
            assert.equal(result[1][3], 15);
          });
        });
            describe("Store 2 basictoken to accounts[1]", async () => {


              it("Store 2 basictoken to accounts[1]", async () => {
                let result = await token.approve(accounts[0], 2);
                result = await token.transferFrom(accounts[0], accounts[1], 2);
                const tokenBalance = await token.balanceOf(accounts[1]);
                console.log("accounts[0] balance"+tokenBalance);
                assert.equal(tokenBalance, 2000);

              });
            });
            describe("One market sell order", async () => {


              it("Sell order amount < buy amount", async () => {
                let result = await dex.executeTokenMarket(
                  token.address,tokenA.address,1,web3.utils.asciiToHex("buy"),{from: accounts[1]}
                );
                result = await dex.getOrders(tokenA.address,true);
                assert.equal(result[0][0], 2);
                assert.equal(result[1][0], 2);
                const account0Balance = await tokenA.balanceOf(accounts[0]);
                const account1Balance = await tokenA.balanceOf(accounts[1]);

                console.log("accounts[0] balance"+account0Balance);
                console.log("accounts[1] balance"+account1Balance);
                assert.equal(account0Balance, 999999900);
                assert.equal(account1Balance, 100);


              });
            });

           describe("Store 4 basictoken to accounts[1]", async () => {


             it("Store21 basictoken to accounts[1]", async () => {
               let result = await token.approve(accounts[0], 4);
               result = await token.transferFrom(accounts[0], accounts[1], 4);
               const tokenBalance = await token.balanceOf(accounts[1]);
               console.log("accounts[0] balance"+tokenBalance);
               assert.equal(tokenBalance, 4000);

             });
           });
            describe("One market sell order", async () => {


                  it("Sell order amount = buy amount", async () => {
                    let result = await dex.executeTokenMarket(
                      token.address,tokenA.address,2,web3.utils.asciiToHex("buy"),{from: accounts[1]}
                    );
                    result = await dex.getOrders(tokenA.address,true);
                    console.log("result[0][0]"+result[0][0]);
                    console.log("result[1][0]"+result[1][0]);
                    assert.equal(result[0][0], 10);
                    assert.equal(result[1][0], 5);
                    const account0Balance = await tokenA.balanceOf(accounts[0]);
                    const account1Balance = await tokenA.balanceOf(accounts[1]);

                    console.log("accounts[0] balance"+account0Balance);
                    console.log("accounts[1] balance"+account1Balance);
                    assert.equal(account0Balance, 999999700);
                    assert.equal(account1Balance, 300);


                  });
                });

              describe("Store 70 basictoken to accounts[1]", async () => {


                it("Store 60 basictoken to accounts[1]", async () => {
                  let result = await token.approve(accounts[0], 70);
                  result = await token.transferFrom(accounts[0], accounts[1], 70);
                  const tokenBalance = await token.balanceOf(accounts[1]);
                  console.log("accounts[0] balance"+tokenBalance);
                  assert.equal(tokenBalance, 70000);
    
                });
              });

              describe("Two market sell order", async () => {


                it("Two order at different price + First sell order is fully used", async () => {
                  let result = await dex.executeTokenMarket(
                    token.address,tokenA.address,6,web3.utils.asciiToHex("buy"),{from: accounts[1]}
                  );
                  result = await dex.getOrders(tokenA.address,true);
                  console.log("result[0][0]"+result[0][0]);
                  console.log("result[1][0]"+result[1][0]);
                  assert.equal(result[0][0], 20);
                  assert.equal(result[1][0], 9);
                  const account0Balance = await tokenA.balanceOf(accounts[0]);
                  const account1Balance = await tokenA.balanceOf(accounts[1]);

                  console.log("accounts[0] balance"+account0Balance);
                  console.log("accounts[1] balance"+account1Balance);
                  assert.equal(account0Balance, 999999100);
                  assert.equal(account1Balance, 900);


                });
              });


              describe("Store 200 basictoken to accounts[1]", async () => {


                it("Store 200 basictoken to accounts[1]", async () => {
                  let result = await token.approve(accounts[0], 200);
                  result = await token.transferFrom(accounts[0], accounts[1], 200);
                  const tokenBalance = await token.balanceOf(accounts[1]);
                  console.log("accounts[0] balance"+tokenBalance);
                  assert.equal(tokenBalance, 200000);
    
                });
              });

              describe("Two market sell order", async () => {


                it("Two order at different price + First sell order is fully used", async () => {
                  let result = await dex.executeTokenMarket(
                    token.address,tokenA.address,10,web3.utils.asciiToHex("buy"),{from: accounts[1]}
                  );
                  result = await dex.getOrders(tokenA.address,true);
                  console.log("result[0][0]"+result[0][0]);
                  console.log("result[1][0]"+result[1][0]);
                  assert.equal(result[0][0], 20);
                  assert.equal(result[1][0], 14);
                  const account0Balance = await tokenA.balanceOf(accounts[0]);
                  const account1Balance = await tokenA.balanceOf(accounts[1]);

                  console.log("accounts[0] balance"+account0Balance);
                  console.log("accounts[1] balance"+account1Balance);
                  assert.equal(account0Balance, 999998100);
                  assert.equal(account1Balance, 1900);


                });
              });


              describe("Store 300 basictoken to accounts[1]", async () => {


                it("Store 300 basictoken to accounts[1]", async () => {
                  let result = await token.approve(accounts[0], 300);
                  result = await token.transferFrom(accounts[0], accounts[1], 300);
                  const tokenBalance = await token.balanceOf(accounts[1]);
                  console.log("accounts[0] balance"+tokenBalance);
                  assert.equal(tokenBalance, 300000);
    
                });
              });

              describe("Two market sell order", async () => {


                it("Two order at different price + First sell order is fully used", async () => {
                  let result = await dex.executeTokenMarket(
                    token.address,tokenA.address,15,web3.utils.asciiToHex("buy"),{from: accounts[1]}
                  );
                  result = await dex.getOrders(tokenA.address,true);

                  const account0Balance = await tokenA.balanceOf(accounts[0]);
                  const account1Balance = await tokenA.balanceOf(accounts[1]);

                  console.log("accounts[0] balance"+account0Balance);
                  console.log("accounts[1] balance"+account1Balance);
                  assert.equal(account0Balance, 999996700);
                  assert.equal(account1Balance, 3300);


                });
              });




});