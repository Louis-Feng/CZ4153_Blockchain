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
import Card from "react-bootstrap/Card";
import Badge from "react-bootstrap/Badge";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import { Row } from "react-bootstrap";

// example from doc: https://reactjs.org/docs/forms.html#controlled-components
class WithDrawETH extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      queryInput: "",
      withdrawInput: 0,
      address: "0x0",
      deposit: 0,
      //   web3Provider: null,
      //   userAddress: "0x0",
      //   contract: {},
      is_loading: true,
    };

    this.handleQueryChange = this.handleQueryChange.bind(this);
    this.handleQuery = this.handleQuery.bind(this);
    this.handleWithdrawChange = this.handleWithdrawChange.bind(this);
    this.handleNewWithdraw = this.handleNewWithdraw.bind(this);
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
    const newBalance = await this.props.contract.methods
      .balance()
      .call({ from: addr });
    console.log("newBalance");
    return { address: addr, deposit: newBalance };
  };

  //   newDeposit = async (amount) => {
  //     // Using MetaMask API to send transaction
  //     //
  //     // please read: https://docs.metamask.io/guide/ethereum-provider.html#ethereum-provider-api
  //     const provider = await detectEthereumProvider();
  //     const web3 = this.props.web3;
  //     if (provider) {
  //       // From now on, this should always be true:
  //       // provider === window.ethereum
  //       window.ethereum.request({
  //         method: "eth_sendTransaction",
  //         params: [
  //           {
  //             from: window.ethereum.selectedAddress,
  //             to: this.props.contract._address,
  //             value: web3.utils.toHex(web3.utils.toWei(amount)), // have to convert to hexdemical for big number
  //             data: web3.eth.abi.encodeFunctionCall(
  //               {
  //                 name: "deposit",
  //                 type: "function",
  //                 inputs: [],
  //               },
  //               []
  //             ), // https://web3js.readthedocs.io/en/v1.2.11/web3-eth-abi.html#encodefunctioncall
  //             chainId: 1337, // ropsten
  //           },
  //         ],
  //       });
  //     } else {
  //       console.log("Please install MetaMask!");
  //     }
  //   };

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
  handleWithdrawChange = (e) => {
    this.setState({ withdrawInput: e.target.value });
  };
  handleNewWithdraw = async () => {
    // await this.newDeposit(this.state.depositInput)
    // this.setState({ is_loading: true })

    // const web3 = this.props.web3;
    // await this.props.contract.methods
    //   .withdraw(
    //     web3.utils.toHex(web3.utils.toWei(this.state.withdrawInput))
    //   )
    //   .send({ from: this.props.userAddress })
    //   .on("transactionHash", (hash) => {})
    //   .on("error", (error) => {
    //     if (error.message.includes("User denied transaction signature")) {
    //       this.setState({ is_loading: false });
    //     }
    //   });

    //   await this.props.token.methods
    //   .burn(
    //     this.props.userAddress,
    //     web3.utils.toHex(web3.utils.toWei(this.state.withdrawInput))
    //   )
    //   .send({ from: this.props.userAddress })
    //   .on("transactionHash", (hash) => {})
    //   .on("error", (error) => {
    //     if (error.message.includes("User denied transaction signature")) {
    //       this.setState({ is_loading: false });
    //     }
    //   });

    const web3 = this.props.web3;
    await this.props.dex.methods
      .withdrawEth(
        this.props.contract._address,
        this.props.token._address,
        web3.utils.toHex(web3.utils.toWei(this.state.withdrawInput))
      )
      .send({ from: this.props.userAddress })
      .on("transactionHash", (hash) => {})
      .on("error", (error) => {
        if (error.message.includes("User denied transaction signature")) {
          this.setState({ is_loading: false });
        }
      });
    // this.setState({ is_loading: false })
  };

  render() {
    const cardStyle = {
      width: "40rem",
    };
    const formClasses = "mb-1";
    const submitButtonStyles = {
      float: "right",
    };
    return (
      <React.Fragment>
        <Card style={cardStyle}>
          <Card.Body>
            <Card.Title>Withdraw BasicToken to ETH</Card.Title>
            <div>
              <Row>
                <span>&nbsp;&nbsp;</span>
              </Row>
              <span>
                User Address:{" "}
                <Badge pill bg="secondary">
                  {this.props.userAddress}
                </Badge>
              </span>
              <Row>
                <span>&nbsp;&nbsp;</span>
              </Row>
              <Form>
                <Form.Group
                  className={formClasses}
                  controlId="formBuyMarketOrderAmount"
                >
                  <Form.Label>Amount</Form.Label>
                  <Form.Control
                    className="pt-2"
                    type="number"
                    //onKeyDown={(evt) => evt.key === "e" && evt.preventDefault()}
                    placeholder="Enter amount (in Ether) to withdraw"
                    value={this.state.value}
                    onChange={this.handleWithdrawChange}
                  />
                </Form.Group>
                <Row>
                  <span>&nbsp;&nbsp;</span>
                </Row>
                <Button
                  className="text-white pt-2"
                  style={submitButtonStyles}
                  variant="info"
                  type="submit"
                  value="New Withdraw"
                  onClick={this.handleNewWithdraw}
                >
                  <b>Submit</b>
                </Button>
              </Form>
              {/* <div>
                <input
                  type="text"
                  placeholder="Enter amount (in Ether)"
                  value={this.state.value}
                  onChange={this.handleWithdrawChange}
                />{" "}
                <input
                  type="submit"
                  value="New WithDraw"
                  onClick={this.handleNewWithdraw}
                />
              </div> */}
            </div>
          </Card.Body>
        </Card>
      </React.Fragment>
    );
  }
}

export default WithDrawETH;
