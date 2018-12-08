import React from 'react';
import { Typography, Button, Card, Divider } from '@material-ui/core';
//import moment from 'moment';
import { withStyles } from '@material-ui/core/styles';
        import red from '@material-ui/core/colors/red';

const styles = theme => ({
  card: {
    maxWidth: 800,
                margin : 'auto',
  },
  media: {
    height: 0,
    paddingTop: '56.25%', // 16:9
  },
  actions: {
    display: 'flex',
  },
  expand: {
    transform: 'rotate(0deg)',
    transition: theme.transitions.create('transform', {
      duration: theme.transitions.duration.shortest,
    }),
    marginLeft: 'auto',
    [theme.breakpoints.up('sm')]: {
      marginRight: -8,
    },
  },
  expandOpen: {
    transform: 'rotate(180deg)',
  },
  avatar: {
    backgroundColor: red[500],
  },
});

 class Article extends React.Component {
  render() {
      return (
        <div>Testing!!!!!</div>
      );
    }
  }


export default withStyles(styles)(Article);