import logo from './logo.svg';
import './App.css';

import React from 'react';
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';
import VotingApp from './components/VotingApp';

function App() {
  return (
      <Router>
        <Switch>
          <Route exact path="/" component={VotingApp} />
          {/* Ajoutez d'autres routes ici pour la gestion de l'administration, l'affichage des résultats, etc. */}
        </Switch>
      </Router>
  );
}

export default App;
