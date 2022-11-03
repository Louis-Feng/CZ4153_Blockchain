// import logo from './logo.svg';
// import "./App.css";
import React, { Component } from "react";
import UserOffers from "./UserOffers";
import { Col } from "react-bootstrap";
import { Row } from "react-bootstrap";
import Card from "react-bootstrap/Card";
import Badge from "react-bootstrap/Badge";

class AllUserOffers extends Component {
  constructor(props) {
    super(props);
  }

  renderUserOrders() {
    // const web3 = window.web3;
    // let orderBookPrices = this.state.order[0];
    // let orderBookAmount = this.state.order[1];
    console.log("user order");
    if (Object.keys(this.props.tokensToTrade).length === 0) {
      console.log("no token");
      return <p>There is no token in the system besides Basic Token </p>;
    } else {
      return Object.keys(this.props.tokensToTrade).map((key) => {
        // const price = web3.utils.fromWei(s, "Ether");
        // const amount = web3.utils.fromWei(orderBookAmount[index], "Ether");
        return (
          <React.Fragment>
            {/* {" "} */}
            <div>
              <Card>
                <Card.Body>
                  <Card.Title>
                    <h4>
                      <Badge bg="dark">{key}</Badge>
                    </h4>
                  </Card.Title>
                  <div style={{ display: "flex", flexDirection: "row" }}>
                    <Card
                      className="mx-auto my-auto border-0"
                      style={{ width: "50vh" }}
                    >
                      <Card.Body>
                        <Card.Title>
                          <h5 className="pt-1">
                            <Badge pill bg="warning" text="white">
                              Buy Book
                            </Badge>
                          </h5>
                        </Card.Title>
                        <UserOffers
                          web3={this.props.web3}
                          userAddress={this.props.userAddress}
                          token={this.props.token}
                          tokenToTrade={this.props.tokensToTrade[key]}
                          dex={this.props.dex}
                          tokenName={key}
                          is_sell={false}
                        />
                      </Card.Body>
                    </Card>
                    <Card
                      className="mx-auto my-auto border-0"
                      style={{ width: "50vh" }}
                    >
                      <Card.Body>
                        <Card.Title>
                          <h5 className="pt-1">
                            <Badge pill bg="success">
                              Sell Book
                            </Badge>
                          </h5>
                        </Card.Title>
                        <UserOffers
                          web3={this.props.web3}
                          userAddress={this.props.userAddress}
                          token={this.props.token}
                          tokenToTrade={this.props.tokensToTrade[key]}
                          dex={this.props.dex}
                          tokenName={key}
                          is_sell={true}
                        />
                      </Card.Body>
                    </Card>
                  </div>
                </Card.Body>
              </Card>
            </div>
            <div>
              <Row>
                <span>&nbsp;&nbsp;</span>
              </Row>
            </div>
          </React.Fragment>

          //   </div>
        );
      });
    }
  }

  render() {
    const cardStyle = {
      width: "120vh",
    };
    // let content;
    // if (this.state.is_loading) {
    //   content = (
    //     <p id="loader" className="text-center">
    //       Loading...
    //     </p>
    //   );
    // } else {
    //   content = (
    //     <div>
    //         {this.renderUserOrders()}
    //     </div>
    //   );
    // }
    return (
      <React.Fragment>
        <Card className="border-0" style={cardStyle} bg="light">
          <Card.Body>
            <h3>
              <span>
                <Card.Title
                  style={{ fontSize: 28 }}
                  className="text-dark text-bold"
                >
                  <b>Current Submitted Orders</b>
                </Card.Title>
              </span>
            </h3>
            <Row>
              <span>&nbsp;&nbsp;</span>
            </Row>
            <div className="AllUserOffers">{this.renderUserOrders()}</div>
          </Card.Body>
        </Card>
      </React.Fragment>
    );
  }
}

export default AllUserOffers;
