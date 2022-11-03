//import "./App.css";
import React, { Component } from "react";
import UserOffers from "./UserOffers";
import UserAccountInfo from "./UserAccountInfo";
import AllUserOffers from "./AllUserOffers";
import AllGlobalOffers from "./AllGlobalOffers";
import { Card } from "react-bootstrap";
import { Row } from "react-bootstrap";

class UserPage extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    const containerStyle = {
      display: "flex",
      justifyContent: "center",
      alignItems: "center",
      width: "130vh",
    };
    const cardStyle = {
      display: "flex",
      justifyContent: "center",
      alignItems: "center",
      width: "130vh",
    };

    return (
      <div className="UserPage">
        <div className="pt-5 d-flex flex-column" style={containerStyle}>
          <Card style={cardStyle} bg="light">
            <UserAccountInfo
              userAddress={this.props.userAddress}
              token={this.props.token}
              tokensToTrade={this.props.tokensToTrade}
              dex={this.props.dex}
              web3={this.props.web3}
            />
            <Row>
              <span>&nbsp;&nbsp;</span>
            </Row>
            <Row>
              <span>&nbsp;&nbsp;</span>
            </Row>

            <AllUserOffers
              userAddress={this.props.userAddress}
              token={this.props.token}
              tokensToTrade={this.props.tokensToTrade}
              dex={this.props.dex}
              web3={this.props.web3}
            />
          </Card>
        </div>
      </div>
    );
  }
}

export default UserPage;
