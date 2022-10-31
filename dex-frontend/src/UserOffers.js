// import logo from './logo.svg';
import './App.css';
import React, {Component} from "react";
import {Button, Table} from "react-bootstrap";
// import {Col} from "react-bootstrap";
// import {Row} from "react-bootstrap";
// import Table from "react-bootstrap/Table";


class UserOffers extends Component{

  constructor(props) {
    super(props);
    this.state = {
        ordersPrices: [],
        ordersVolumes: [],
        ordersPriorities: [],

        is_loading: true
    }
  }

  componentDidMount() {
    console.log(this.props.tokenToTrade._address)
    console.log(this.props.userAddress)
    this.props.dex.methods
          .getUserOrders(this.props.tokenToTrade._address, this.props.is_sell)
          .call({from: this.props.userAddress})
          .then(result => {
            result= this.removeElementsWithZeroValue(result);
            console.log(result)
            this.setState(
                {
                    ordersPrices: result[0],
                    ordersVolumes: result[1],
                    ordersPriorities: result[2]
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
        }).map(function(item) {
            return parseInt(item, 10);
        });
    }
    return array;
}
cancelOrder = async (price, priority) => {
    this.setState({is_loading: true});
    await this.props.dex.methods
      .removeOrder(
        this.props.token._address,
        this.props.tokenToTrade._address,
        this.props.is_sell,
        price,
        priority
      )
      .send({from: this.props.userAddress})
      .on("transactionHash", (hash) => {})
      .on("error", (error) => {
        if (error.message.includes("User denied transaction signature")) {
          this.setState({is_loading: false});
        }
      });

    this.setState({is_loading: false});
    this.updateOrders()
  };

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
                    ordersVolumes: result[1],
                    ordersPriorities: result[2]
                }
            )
            this.setState({is_loading: false})
          });
  }

  renderOrder() {

        return this.state.ordersPrices.map((price, index) => {
        //   const price = web3.utils.fromWei(s, "Ether");
        //   const amount = web3.utils.fromWei(orderBookAmount[index], "Ether");
          return (
            <>
              <tr>
                <td>{price}</td>
                <td>{this.state.ordersVolumes[index]}</td>
                <td>
                  <Button
                    size="sm"
                    onClick={() => {
                      this.cancelOrder(price, this.state.ordersPriorities[index]);
                    }}
                  >
                    Cancel
                  </Button>
                </td>
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
        content = ( <p>Current Order Book is Empty</p>);
    } else {
      content = (
        <>
        <Table striped bordered hover size="sm">
          <thead>
            <tr>
              <th>Amount</th>
              <th>Price</th>
              <th>cancle button</th>
            </tr>
          </thead>
          <tbody>{this.renderOrder()}</tbody>
        </Table>
      </>
        // <>
        //     <tr>
        //       <td>price: {this.state.ordersPrices}</td>
        //       <td>amount: {this.state.ordersVolumes}</td>
        //       <td>
        //         <Button
        //           size="sm"
        //           onClick={() => {
        //             this.cancelOrder(price);
        //           }}
        //         >
        //           Cancel
        //         </Button>
        //       </td>
        //     </tr>
        //   </>

      );
    }
    return (
    <div className="UserOffers">
      {content}
    </div>
    );
  }
}

export default UserOffers;