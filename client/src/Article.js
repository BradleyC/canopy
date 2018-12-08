import React from 'react';
import { Typography, Button, Card, Divider } from '@material-ui/core';
//import moment from 'moment';
import { withStyles } from '@material-ui/core/styles';
        import red from '@material-ui/core/colors/red';

 class Article extends React.Component {
  render() {
      return (
        {/* sorting articles by score */}
        articles.sort(function (a, b) {
          return a.score - b.score;
        });

        <div>Testing!!!!!</div>

      );
    }
  }


export default withStyles(styles)(Article);