import "./App.css";
import React, { Component } from "react";
import UserOffers from "./UserOffers";
import UserAccountInfo from "./UserAccountInfo";
import AllUserOffers from "./AllUserOffers";
import AllGlobalOffers from './AllGlobalOffers';

class UserPage extends Component{


  constructor(props) {
    super(props);
  }


  render() {

    return (
    <div className="UserPage">
        <UserAccountInfo
            userAddress={this.props.userAddress}
            token={this.props.token}
            tokensToTrade={this.props.tokensToTrade}
            dex={this.props.dex}
            web3={this.props.web3}
          />
          <AllUserOffers
            userAddress={this.props.userAddress}
            token={this.props.token}
            tokensToTrade={this.props.tokensToTrade}
            dex={this.props.dex}
            web3={this.props.web3}
          />

    </div>);
  }
}


export default UserPage;

