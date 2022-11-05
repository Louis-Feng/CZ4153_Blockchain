// import logo from './logo.svg';
import "./App.css";
import React, { Component } from "react";
import UserOffers from "./UserOffers";
import GlobalOffers from "./GlobalOffers";
import { Card, Col } from "react-bootstrap";
import { Row } from "react-bootstrap";
import Badge from "react-bootstrap/Badge";

class AllGlobalOffers extends Component {
  constructor(props) {
    super(props);
  }

  renderGlobalOrders() {
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
            <div>
              <Card>
                <Card.Body>
                  <Card.Title>
                    {" "}
                    <h4>
                      <Badge bg="dark">{key}</Badge>
                    </h4>
                  </Card.Title>
                  <Row>
                    <span>&nbsp;&nbsp;</span>
                  </Row>
                  <div style={{ display: "flex", flexDirection: "row" }}>
                    {/* <div className="card mb-4"> */}
                    <Card
                      className="mx-auto my-auto border-0"
                      style={{ width: "50vh" }}
                    >
                      <Card.Body>
                        <Card.Title>
                          <h5>
                            <Badge pill bg="warning">
                              Buy OrderBook
                            </Badge>
                          </h5>
                        </Card.Title>
                        <GlobalOffers
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
                          <h5>
                            <Badge pill bg="warning">
                              Sell OrderBook
                            </Badge>
                          </h5>
                        </Card.Title>
                        <GlobalOffers
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
                    {/* <div className="card-body border-0">
                      <Row className="mb-4">
                        <Col>
                          <h5>
                            <Badge pill bg="warning">
                              Buy OrderBook
                            </Badge>
                          </h5>
                        </Col>
                        <Col>
                          <h5>
                            <Badge pill bg="warning">
                              Sell OrderBook
                            </Badge>
                          </h5>
                        </Col>
                      </Row>
                      <Row>
                        <Col>
                          <div className="card mb-4">
                            <div className="card-body border-0">
                              <GlobalOffers
                                web3={this.props.web3}
                                userAddress={this.props.userAddress}
                                token={this.props.token}
                                tokenToTrade={this.props.tokensToTrade[key]}
                                dex={this.props.dex}
                                tokenName={key}
                                is_sell={false}
                              />
                            </div>
                          </div>
                        </Col>
                        <Col>
                          <div className="card mb-4">
                            <div className="card-body">
                              <GlobalOffers
                                web3={this.props.web3}
                                userAddress={this.props.userAddress}
                                token={this.props.token}
                                tokenToTrade={this.props.tokensToTrade[key]}
                                dex={this.props.dex}
                                tokenName={key}
                                is_sell={true}
                              />
                            </div>
                          </div>
                        </Col>
                      </Row>
                    </div> */}
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

          // <div>
          //     <p>{key}</p>
          //   <GlobalOffers userAddress={this.props.userAddress} token={this.props.token} tokenToTrade={this.props.tokensToTrade[key]} dex={this.props.dex} tokenName = {key} is_sell = {true}/>
          //   <GlobalOffers userAddress={this.props.userAddress} token={this.props.token} tokenToTrade={this.props.tokensToTrade[key]} dex={this.props.dex} tokenName = {key} is_sell = {false}/>
          // </div>
        );
      });
    }
  }

  render() {
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
    const centerStyle = {
      display: "flex",
      justifyContent: "center",
      alignItems: "center",
    };
    return (
      <Card bg="light" style={centerStyle}>
        <Card.Body>
          <Card.Title>
            <h4 style={centerStyle}>Global Order Book</h4>
          </Card.Title>
          <div className="AllGlobalOffers">{this.renderGlobalOrders()}</div>;
        </Card.Body>
      </Card>
    );
  }
}

export default AllGlobalOffers;
