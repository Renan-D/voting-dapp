import logo from './logo.svg';
import './App.css';

import React from 'react';
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';
import VotingApp from './components/VotingApp';

function App() {
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();

  return (
      <Router>
        <Switch>
          <Route exact path="/" component={VotingApp} />
        </Switch>
      </Router>
  );
}

export default App;
