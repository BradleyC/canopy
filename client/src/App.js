import React, { Component } from "react";
import SimpleStorageContract from "./contracts/SimpleStorage.json";
import getWeb3 from "./utils/getWeb3";
import truffleContract from "truffle-contract";
import CanopyContract from "./contracts/Canopy.json";
import "./App.css";
//added import for BrowserRouter and Route
import { BrowserRouter, Route, NavLink } from "react-router-dom";


//APPBAR IMPORTS
import PropTypes from 'prop-types';
import { withStyles } from '@material-ui/core/styles';
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import Typography from '@material-ui/core/Typography';
import Button from '@material-ui/core/Button';
import IconButton from '@material-ui/core/IconButton';
import AppBarTest from './AppBarTest';
import MenuItem from '@material-ui/core/MenuItem';

//import BrowserRouter from 'react-router-dom';

import CardStack from './CardStack';
import Article from './Article';


class App extends Component {
  state = { storageValue: 0, web3: null, accounts: null, contract: null };

  handleChange = event => {
    this.setState({ auth: event.target.checked });
  };

  handleMenu = event => {
    this.setState({ anchorEl: event.currentTarget });
  };

  handleClose = () => {
    this.setState({ anchorEl: null });
  };


  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      // await ethereum.enable();
      const web3 = await getWeb3();
      this.setState({ web3 });

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();

      // Get the contract instance.
      const Contract = truffleContract(CanopyContract);
      console.log('web3.currentProvider', web3.currentProvider);
      Contract.setProvider(web3.currentProvider);
      const instance = await Contract.deployed();

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState({ accounts, contract: instance });
    } catch (error) {
      // Catch any errors for any of the above operations.
      console.error(
        `Failed to load web3, accounts, or contract. Check console for details.`
        );
      console.log(error);
    }
  };

  render() {
    return (
      <div>
        <BrowserRouter>
          <Dashboard />
        </BrowserRouter>

     {/* <CardStack web3={this.state.web3} contract={this.state.contract} accounts={this.state.accounts} /> */}


      </div>
      );
    }
  }

  const styles = {
  root: {
    flexGrow: 1,
  },
  grow: {
    flexGrow: 1,
  },
  menuButton: {
    marginLeft: -12,
    marginRight: 20,
  },
};

class Dashboard extends React.Component {



  render() {
    return (
    <AppBar position="static">

      <div id="dashboard">
        <div className="menu">
      
        <MenuItem onClick={this.handleClose}>
          <NavLink exact to="/CardStack">
            Home
          </NavLink>
          </MenuItem>
          <MenuItem onClick={this.handleClose}>
          <NavLink exact to="/Article" >
            Article
          </NavLink>
          </MenuItem>
        </div>
        <div className="content">
          <Route exact path="/CardStack" component={CardStack} />
          <Route exact path="/Article" component={Article} />
        </div>
      </div>
      </AppBar>
    );
  }
}




  export default App;
  



