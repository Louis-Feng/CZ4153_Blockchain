import React, { Component } from "react";
import { Tab, Tabs } from "react-bootstrap";
import { Card } from "react-bootstrap";
import "bootstrap/dist/css/bootstrap.css";
import MarketOrderInfoCardContainer from "./marketorderinfocardcontainer";
import { Row, Col } from "react-bootstrap";
import Dropdown from "react-bootstrap/Dropdown";
import DropdownMenu from "react-bootstrap/esm/DropdownMenu";
import LimitOrderInfoCardContainer from "./limitorderinfocardcontainer";

class TabPage extends Component {
  state = {
    tokenToTrade: "TokenA",
    is_loading: false,
    executeLimit: this.props.executeLimit,
    executeMarket: this.props.executeMarket,
  };
  // componentDidUpdate(prevProps) {
  //   if (prevProps.tokenToTrade !== this.state.tokenToTrade) {
  //     this.setState({ is_loading: true, tokenToTrade: this.props.tokenToTrade});
  //     this.setState({ is_loading: false});
  //   }
  // }

  getPrompts(isMarket) {
    const prefix = "select token - ";
    const debug = isMarket ? prefix + "Market Tokens" : prefix + "Limit Tokens";
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
                              tokenToTrade: "TokenA",
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
                              tokenToTrade: "TokenB",
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
                              tokenToTrade: "TokenC",
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
                              tokenToTrade: "TokenA",
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
                              tokenToTrade: "TokenB",
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
                              tokenToTrade: "TokenC",
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
                </Tabs>
              </Card.Body>
            </Card>
          </div>
        </React.Fragment>
      );
    } else {
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
                    <Row>
                      <Col>&nbsp;&nbsp;</Col>
                    </Row>
                    <Row>
                      <Col>&nbsp;&nbsp;</Col>
                    </Row>
                    <div style={centerStyles}>
                      please {this.getPrompts(true)}
                    </div>
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
                              tokenToTrade: "TokenA",
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
                              tokenToTrade: "TokenB",
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
                              tokenToTrade: "TokenC",
                            });
                            this.setState({ is_loading: false });
                          }}
                        >
                          TokenC
                        </Dropdown.Item>
                      </DropdownMenu>
                    </Dropdown>
                    <div>
                      <MarketOrderInfoCardContainer
                        tokenToTrade={this.state.tokenToTrade}
                        executeLimit = {this.props.executeLimit}
                        executeMarket = {this.props.executeMarket}
                      ></MarketOrderInfoCardContainer>
                    </div>
                  </TabPage>
                  <TabPage eventKey="limit" title="Limit Order">
                    <Row>
                      <Col>&nbsp;&nbsp;</Col>
                    </Row>
                    <Row>
                      <Col>&nbsp;&nbsp;</Col>
                    </Row>
                    <Row>
                      <Col>&nbsp;&nbsp;</Col>
                    </Row>
                    <div style={centerStyles}>
                      please {this.getPrompts(false)}
                    </div>
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
                              tokenToTrade: "TokenA",
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
                              tokenToTrade: "TokenB",
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
                              tokenToTrade: "TokenC",
                            });
                            this.setState({ is_loading: false });
                          }}
                        >
                          TokenC
                        </Dropdown.Item>
                      </DropdownMenu>
                    </Dropdown>
                    <div>
                      <LimitOrderInfoCardContainer
                        tokenToTrade={this.state.tokenToTrade}
                        executeLimit = {this.props.executeLimit}
                        executeMarket = {this.props.executeMarket}
                      ></LimitOrderInfoCardContainer>
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
}

export default TabPage;
