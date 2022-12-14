import logo from "./logo.svg";
//import "./App.css";
import React, { Component } from "react";
import { Link } from "react-router-dom";
import "bootstrap/dist/css/bootstrap.css";
import Badge from "./components/tokenbadge";
import { Col } from "react-bootstrap";
import { Row } from "react-bootstrap";

class UserAccountInfo extends Component {
  constructor(props) {
    super(props);
    this.state = {
      userWallet: {
        token_balance: 0,
        eth_balance: 0,
      },
      is_loading: true,

      tokenAndBalance: [
        { token: "", balance: 0 },
        { token: "", balance: 0 },
        { token: "", balance: 0 },
        { token: "", balance: 0 },
        { token: "", balance: 0 },
      ],
    };
  }

  componentDidMount() {
    this.getBalances();
    // this.loadUserAddress();
  }
  async getBalances() {
    if (this.props.token) {
      let token_balance = await this.props.token.methods
        .balanceOf(this.props.userAddress)
        .call();
      this.setState((prevState) => ({
        userWallet: {
          ...prevState.userWallet,
          token_balance: token_balance,
        },
      }));
      console.log("token balence");
      console.log(this.state.userWallet.token_balance);
    } else {
      window.alert("BasicToken contract not deployed to detected network");
    }
    for (const [key, tradingToken] of Object.entries(
      this.props.tokensToTrade
    )) {
      // var tokenName = key ;
      if (tradingToken) {
        let tradingToken_balance = await tradingToken.methods
          .balanceOf(this.props.userAddress)
          .call();
        // var tradingTokenBalance = {}
        // tradingTokenBalance[key] = tradingToken_balance
        this.setState((prevState) => ({
          userWallet: {
            ...prevState.userWallet,
            [key]: tradingToken_balance,
            // ${tokenName}: tradingToken_balance,
          },
        }));
        console.log("tokenA balence");
        console.log(this.state.userWallet);
      } else {
        window.alert("TokenA contract not deployed to detected network");
      }
    }

    if (this.props.dex) {
      let web3 = this.props.web3;
      console.log(this.props.web3);
      console.log(this.props.userAddress);
      let eth_balance = await web3.eth.getBalance(this.props.userAddress);
      this.setState((prevState) => ({
        userWallet: {
          ...prevState.userWallet,
          eth_balance: eth_balance,
        },
      }));
      console.log("eth balence");
      console.log(this.state.userWallet.eth_balance);
    } else {
      window.alert("dex contract not deployed to detected network");
    }
    this.setState({ is_loading: false });
  }

  //   componentDidUpdate(prevProps, prevState) {
  //     if (prevState.web3Provider !== this.state.web3Provider ){
  //       this.loadUserAddress();
  //     }
  //     if (prevState.userAddress !== this.state.userAddress ){
  //       this.loadContracts();
  //     }

  //   }

  tokensandBalances() {
    const tokenAndBalance = [];
    console.log("calling token balances");
    for (const [key, tokenBalance] of Object.entries(this.state.userWallet)) {
      let temp;
      if (key === "token_balance") {
        temp = "BasicToken";
      } else if (key == "eth_balance") {
        temp = "ETH";
      } else {
        temp = key;
      }
      tokenAndBalance.push(
        <tr>
          <th scope="row">
            <Badge color="dark" badgeName={temp}></Badge>
          </th>
          <td>
            <Badge
              color="info"
              badgeName={this.props.web3.utils.fromWei(tokenBalance)}
            ></Badge>
          </td>
        </tr>
      );
    }
    return <tbody>{tokenAndBalance}</tbody>;
  }

  render() {
    const containerStyle = {
      display: "flex",
      justifyContent: "center",
      alignItems: "center",
      width: "120vh",
      //height: "90vh",
    };
    const cardStyle = {
      display: "flex",
      justifyContent: "center",
      alignItems: "center",
      //width: "120vh",
      //height: "60vh",
    };
    const cardBodyStyle = {
      //width: "120vh",
      //height: "60vh",
    };

    const balanceTableContainerStyle = {
      width: "120vh",
      //height: "50vh",
    };

    const balanceTableStyle = {
      width: "50vh",
      //height: "40vh",
    };

    let content;
    if (this.state.is_loading) {
      content = (
        <p id="loader" className="text-center">
          Loading...
        </p>
      );
    } else {
      content = (
        <React.Fragment>
          <div className="d-flex flex-column" style={containerStyle}>
            <div
              className="card text-bg-light mx-auto my-auto border-0"
              style={cardStyle}
            >
              <div className="card-body" style={cardBodyStyle}>
                <h3 className="pt-5 card-title">
                  <span style={{ fontWeight: "bold" }}>User Profile</span>
                </h3>
                <div
                  className="pt-5 d-flex flex-row"
                  style={balanceTableContainerStyle}
                >
                  <table className="table" style={balanceTableStyle}>
                    <thead>
                      <tr>
                        <th scope="col" style={{ fontSize: 20 }}>
                          Token
                        </th>
                        <th scope="col" style={{ fontSize: 20 }}>
                          Token Balance
                        </th>
                      </tr>
                    </thead>
                    {this.tokensandBalances()}
                  </table>
                  <div
                    className="btn-group-vertical mx-auto my-auto"
                    role="group"
                    aria-label="Vertical radio toggle button group"
                  >
                    <Link
                      style={{ alignSelf: "stretch" }}
                      to={{
                        pathname: "/swapBasicToken",
                        state: { dataPassed: "This is the passed data." },
                      }}
                    >
                      <div>
                        <button
                          className="btn btn-outline-dark btn-lg"
                          style={{ width: "100%" }}
                        >
                          <span style={{ fontWeight: "bold" }}>Swap Token</span>
                        </button>
                      </div>
                    </Link>

                    <Link style={{ alignSelf: "stretch" }} to="/withdrawETH">
                      <button
                        className="btn btn-outline-dark btn-lg"
                        style={{ width: "100%" }}
                      >
                        <span style={{ fontWeight: "bold" }}>
                          Withdraw Token
                        </span>
                      </button>
                    </Link>
                    <Link style={{ alignSelf: "stretch" }} to="/TradeToken">
                      <button
                        className="btn btn-outline-dark btn-lg"
                        style={{ width: "100%" }}
                      >
                        <span style={{ fontWeight: "bold" }}>Trade Token</span>
                      </button>
                    </Link>
                    {/* <button className="btn btn-outline-dark btn-lg">
                      <span style={{ fontWeight: "bold" }}>Withdraw Token</span>
                    </button> */}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </React.Fragment>
      );
    }
    return <div className="UserAccountInfo">{content}</div>;
  }
}

export default UserAccountInfo;
