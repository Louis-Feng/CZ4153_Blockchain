import React from "react";
// import {
//   updateDeposit,
//   newDeposit,
//   BankContractAddress,
//   Testnet,
// } from "./bank.js";

import Web3 from "web3";
import BankJS from "./contracts/Bank.json";
import detectEthereumProvider from "@metamask/detect-provider";


// example from doc: https://reactjs.org/docs/forms.html#controlled-components
class SwapBasicToken extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      queryInput: "",
      depositInput: 0,
      address: "0x0",
      deposit: 0,
    //   web3Provider: null,
    //   userAddress: "0x0",
    //   contract: {},
      is_loading: true,
    };

    

    this.handleQueryChange = this.handleQueryChange.bind(this);
    this.handleQuery = this.handleQuery.bind(this);
    this.handleDepositChange = this.handleDepositChange.bind(this);
    this.handleNewDeposit = this.handleNewDeposit.bind(this);
  }

//   componentDidMount() {
//     this.initiateWeb3();
//     // this.loadUserAddress();
//   }

//   componentDidUpdate(prevProps, prevState) {
//     if (prevState.web3Provider !== this.state.web3Provider) {
//       this.loadUserAddress();
//     }
//     if (prevState.userAddress !== this.state.userAddress) {
//       this.loadContracts();
//     }
//   }

  updateDeposit = async (addr) => {
    // doc here: https://web3js.readthedocs.io/en/v1.2.11/web3-eth-contract.html#methods-mymethod-call
    const newBalance = await this.props.contract.methods.balance().call({ from: addr });
    console.log("newBalance")
    return { address: addr, deposit: newBalance };
  };
  
  newDeposit = async (amount) => {
    // Using MetaMask API to send transaction
    //
    // please read: https://docs.metamask.io/guide/ethereum-provider.html#ethereum-provider-api
    const provider = await detectEthereumProvider();
    const web3 = this.props.web3;
    if (provider) {
      // // From now on, this should always be true:
      // // provider === window.ethereum
      // window.ethereum.request({
      //   method: "eth_sendTransaction",
      //   params: [
      //     {
      //       from: window.ethereum.selectedAddress,
      //       to: this.props.contract._address,
      //       value: web3.utils.toHex(web3.utils.toWei(amount)), // have to convert to hexdemical for big number
      //       data: web3.eth.abi.encodeFunctionCall(
      //         {
      //           name: "deposit",
      //           type: "function",
      //           inputs: [],
      //         },
      //         []
      //       ), // https://web3js.readthedocs.io/en/v1.2.11/web3-eth-abi.html#encodefunctioncall
      //       chainId: 1337, // ganache
      //     },
      //   ],
      // });
      await this.props.contract.methods
      .deposit(
      )
      .send({ from: this.props.userAddress, to: this.props.contract._address, value: web3.utils.toHex(web3.utils.toWei(amount))})
      .on("transactionHash", (hash) => {})
      .on("error", (error) => {
        if (error.message.includes("User denied transaction signature")) {
          this.setState({ is_loading: false });
        }
      });

    } else {
      console.log("Please install MetaMask!");
    }
  };

//   async loadContracts() {
//     console.log("contract");
//     console.log("contract");

//     // const accounts = await web3.eth.getAccounts();
//     // this.setState({ userAddress: accounts[0] });
//     // setTimeout(() => {
//     //   console.log(this.state.userAddress);
//     // }, 1
//     // );
//     // console.log(this.props.web3Provider);
//     const web3 = this.props.web3Provider;
//     const networkId = await web3.eth.net.getId();
//     const BankAddress = BankJS.networks[networkId].address;
//     const bank = new web3.eth.Contract(BankJS.abi, BankAddress);

//     // this.setState({ token, dex });
//     this.setState({
//         bank
//     });
//     this.setState({ is_loading: false });

//     // const tokenBalance = await token.methods.balanceOf(this.state.userAddress).call()
//     // const tokenABalance = await tokenA.methods.balanceOf(this.state.userAddress).call()
//     // console.log(tokenBalance)
//     // console.log(tokenABalance)
//     // await this.getBalance()
//   }

  handleQueryChange = (e) => {
    this.setState({ queryInput: e.target.value });
  };
  handleQuery = async () => {
    let result = await this.updateDeposit(this.state.queryInput);
    this.setState({
      address: result.address,
      deposit: result.deposit,
    });
  };
  handleDepositChange = (e) => {
    this.setState({ depositInput: e.target.value });
  };
  handleNewDeposit = async () => {
    await this.newDeposit(this.state.depositInput)
    const web3 = this.props.web3;
    await this.props.token.methods
      .mint(
        this.props.userAddress,
        web3.utils.toHex(web3.utils.toWei(this.state.depositInput))
      )
      .send({ from: this.props.userAddress })
      .on("transactionHash", (hash) => {})
      .on("error", (error) => {
        if (error.message.includes("User denied transaction signature")) {
          this.setState({ is_loading: false });
        }
      });
  };

  render() {
    return (
      <div>
        <h1>Welcome to Bank dApp</h1>
        <p>Bank Contract Address: {this.props.contract._address}</p>
        <p>Network: </p>
        <hr />
        <input
          type="text"
          placeholder="Enter address to query"
          value={this.state.value}
          onChange={this.handleQueryChange}
        />{" "}
        <input type="submit" value="Query Deposit" onClick={this.handleQuery} />
        <p>
          Query Result: {this.state.address} has deposit of {this.state.deposit}{" "}
          wei
        </p>
        <hr />
        <input
          type="text"
          placeholder="Enter amount (in Ether)"
          value={this.state.value}
          onChange={this.handleDepositChange}
        />{" "}
        <input
          type="submit"
          value="New Deposit"
          onClick={this.handleNewDeposit}
        />
      </div>
    );
  }
}

export default SwapBasicToken;