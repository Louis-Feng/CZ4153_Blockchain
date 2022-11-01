import React, { Component } from "react";
import { Tab, Tabs } from "react-bootstrap";
import { Card } from "react-bootstrap";
import "bootstrap/dist/css/bootstrap.css";
import SubmitMarketOrderCard from "./submitmarketordercard";
import { Row, Col } from "react-bootstrap";
import Dropdown from "react-bootstrap/Dropdown";
import DropdownMenu from "react-bootstrap/esm/DropdownMenu";

class TabPage extends Component {
  state = {
    isMarket: true,
    tokenToTrade: "TokenA",
    is_loading: false,
    executeLimit: this.props.executeLimit,
    executeMarket: this.props.executeMarket
  };
  // componentDidUpdate(prevProps) {
  //   if (prevProps.tokenToTrade !== this.state.tokenToTrade) {
  //     this.setState({ is_loading: true, tokenToTrade: this.props.tokenToTrade});
  //     this.setState({ is_loading: false});
  //   }
  // }

  getPrompts() {
    const prefix = "select token - ";
    const debug = this.state.isMarket
      ? prefix + "Market Tokens"
      : prefix + "Limit Tokens";
    return debug;
  }

  render() {
    const centerStyles = {
      display: "flex",
      justifyContent: "center",
      alignItems: "center",
    };
    const containerStyle = {
      display: "flex",
      justifyContent: "center",
      alignItems: "center",
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
        <SubmitMarketOrderCard
          tokenToTrade={this.state.tokenToTrade}
          executeLimit = {this.props.executeLimit}
          executeMarket = {this.props.executeMarket}
        ></SubmitMarketOrderCard>
      );
    }
    return (
      <React.Fragment>
        <div className="d-flex flex-column m-5" style={containerStyle}>
          <Card bg="light" className="m-3">
            <Card.Body>
              <Tabs
                defaultActiveKey="market"
                transition={false}
                id="order-type-tab"
                className="m-0"
              >
                <TabPage eventKey="market" title="Market Order">
                  <Row>
                    <Col>&nbsp;&nbsp;</Col>
                  </Row>
                  <div style={centerStyles}>please {this.getPrompts()}</div>
                  <Row>
                    <Col>&nbsp;&nbsp;</Col>
                  </Row>
                  <Dropdown style={centerStyles}>
                    <Dropdown.Toggle
                      id="choose-token-dropdown"
                      variant="secondary"
                      size="lg"
                    >
                      {this.state.tokenToTrade}
                    </Dropdown.Toggle>
                    <DropdownMenu variant="dark">
                      <Dropdown.Item
                        key="tokenA"
                        id="tokenA"
                        href="#"
                        onClick={() => {
                          this.setState({
                            is_loading: true,
                            tokenToTrade: "tokenA",
                          });
                          this.setState({ is_loading: false });
                        }}
                      >
                        TokenA
                      </Dropdown.Item>
                      <Dropdown.Item
                        key="tokenB"
                        id="tokenB"
                        href="#"
                        onClick={() => {
                          this.setState({
                            is_loading: true,
                            tokenToTrade: "tokenB",
                          });
                          this.setState({ is_loading: false });
                        }}
                      >
                        TokenB
                      </Dropdown.Item>
                      <Dropdown.Item
                        key="tokenC"
                        id="tokenC"
                        href="#"
                        onClick={() => {
                          this.setState({
                            is_loading: true,
                            tokenToTrade: "tokenC",
                          });
                          this.setState({ is_loading: false });
                        }}
                      >
                        TokenC
                      </Dropdown.Item>
                    </DropdownMenu>
                  </Dropdown>
                  <div>{content}</div>
                </TabPage>
                <TabPage eventKey="limit" title="Limit Order">
                  <Row>
                    <Col>&nbsp;&nbsp;</Col>
                  </Row>
                  <div style={centerStyles}>please {this.getPrompts()}</div>
                  <Row>
                    <Col>&nbsp;&nbsp;</Col>
                  </Row>
                  <Dropdown style={centerStyles}>
                    <Dropdown.Toggle
                      id="choose-token-dropdown"
                      variant="secondary"
                      size="lg"
                    >
                      {this.state.tokenChosen}
                    </Dropdown.Toggle>
                    <DropdownMenu variant="dark">
                      <Dropdown.Item
                        key="tokenA"
                        id="tokenA"
                        href="#"
                        onClick={() =>
                          this.setState({ tokenToTrade: "tokenA" })
                        }
                      >
                        TokenA
                      </Dropdown.Item>
                      <Dropdown.Item
                        key="tokenB"
                        id="tokenB"
                        href="#"
                        onClick={() =>
                          this.setState({ tokenToTrade: "tokenB" })
                        }
                      >
                        TokenB
                      </Dropdown.Item>
                      <Dropdown.Item
                        key="tokenC"
                        id="tokenC"
                        href="#"
                        onClick={() =>
                          this.setState({ tokenToTrade: "tokenC" })
                        }
                      >
                        TokenC
                      </Dropdown.Item>
                    </DropdownMenu>
                  </Dropdown>
                  <div>
                    <SubmitMarketOrderCard></SubmitMarketOrderCard>
                  </div>
                </TabPage>
              </Tabs>
            </Card.Body>
          </Card>
        </div>
      </React.Fragment>
    );
  }
}

export default TabPage;
