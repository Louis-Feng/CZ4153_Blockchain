import './App.css';
import React, {Component} from "react";
import {Button, Table} from "react-bootstrap";
// import Web3 from 'web3';
// import {Col} from "react-bootstrap";
// import {Row} from "react-bootstrap";
// import Table from "react-bootstrap/Table";


class GlobalOffers extends Component{

  constructor(props) {
    super(props);
    this.state = {
        ordersPrices: [],
        ordersVolumes: [],

        is_loading: true
    }
  }

  componentDidMount() {
    console.log(this.props.tokenToTrade._address)
    console.log(this.props.userAddress)
    this.props.dex.methods
          .getOrders(this.props.tokenToTrade._address, this.props.is_sell)
          .call({from: this.props.userAddress})
          .then(result => {
            result= this.removeElementsWithZeroValue(result);
            console.log(result)
            this.setState(
                {
                    ordersPrices: result[0],
                    ordersVolumes: result[1],
                }
            )
            this.setState({is_loading: false})
          });
  }

  removeElementsWithZeroValue(arr) {
    var array = [];
    for (var i = 0; i < Object.keys(arr).length; i++) {
        array[i] = arr[i].filter(function(value, index, arr){ 
            return value !== "0";
        });
    }
    return array;
}

  updateOrders = () => {
    this.setState({is_loading: true});
    this.props.dex.methods
          .getUserOrders(this.props.tokenToTrade._address, this.props.is_sell)
          .call({from: this.props.userAddress})
          .then(result => {
            result= this.removeElementsWithZeroValue(result);
            console.log(result)
            this.setState(
                {
                    ordersPrices: result[0],
                    ordersVolumes: result[1]
                }
            )
            this.setState({is_loading: false})
          });
  }

  renderOrder() {

        return this.state.ordersPrices.map((p, index) => {
          // const price = this.props.web3.utils.fromWei(p, "Ether");
          const price = this.props.web3.utils.fromWei(p, "Ether");
        //   const amount = web3.utils.fromWei(orderBookAmount[index], "Ether");
          return (
            <>
          <tr>
            <td>{this.props.tokenName.toUpperCase()}</td>
            <td>{price}</td>
            <td>{this.state.ordersVolumes[index]}</td>
          </tr>
        </>
          );
        });
  }


  render() {
    let content;
    if (this.state.is_loading) {
      content = (
        <p id="loader" className="text-center">
          Loading...
        </p>
      );
    } else if (this.state.ordersPrices.length === 0) {
        content = ( <p style={{ color: 'black' }}>Current Order Book is Empty</p>);
    } else {
      content = (
        <>
        <Table striped bordered hover size="sm">
          <thead>
            <tr>
              <th>Token Name</th>
              <th>Price</th>
              <th>Amount</th>
            </tr>
          </thead>
          <tbody>{this.renderOrder()}</tbody>
        </Table>
      </>

      );
    }
    return (
    <div className="GlobalOffers">
      {content}
    </div>
    );
  }
}

export default GlobalOffers;