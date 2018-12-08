import React from 'react';
import PropTypes from 'prop-types';
import { withStyles } from '@material-ui/core/styles';
import classnames from 'classnames';
import Card from '@material-ui/core/Card';
import CardHeader from '@material-ui/core/CardHeader';
import CardMedia from '@material-ui/core/CardMedia';
import CardContent from '@material-ui/core/CardContent';
import CardActions from '@material-ui/core/CardActions';
import Collapse from '@material-ui/core/Collapse';
import Avatar from '@material-ui/core/Avatar';
import IconButton from '@material-ui/core/IconButton';
import Typography from '@material-ui/core/Typography';
import red from '@material-ui/core/colors/red';
import FavoriteIcon from '@material-ui/icons/Favorite';
import ShareIcon from '@material-ui/icons/Share';
import ExpandMoreIcon from '@material-ui/icons/ExpandMore';
import MoreVertIcon from '@material-ui/icons/MoreVert';
import MaterialIcon, {colorPalette} from 'material-icons-react';
import TextField from '@material-ui/core/TextField';
import Button from '@material-ui/core/Button';

const styles = theme => ({
  card: {
    maxWidth: 800,
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


class PostListCard extends React.Component {
  state = {
    posts: new Map(),
  };

  async componentDidMount() {
    const { web3, accounts, contract } = this.props;
    // const amountToStake = web3.utils.toWei(this.state.amountToStake, 'ether');
    // const submission = {
    //   ...this.state,
    //   amountToStake,
    // };
    // console.log('handlePost', submission);
    console.log('accounts', accounts);
    console.log('contract', contract);

    console.log(Object.keys(contract.methods));
    console.log();

    const numPosts = (await contract.numPosts()).toNumber();
    console.log('numPosts', numPosts);
    this.fetchLatestPosts(numPosts - 1);

    // const gas = await contract.createPost.estimateGas(submission.title, submission.url, submission.amountToStake);
    // const contractCallOptions = {
    //   from: accounts[0],
    //   gas: gas + 1000,
    // };
    // const result = await contract.createPost(submission.title, submission.url, submission.amountToStake, contractCallOptions);

    // console.log('result', result);
  }

  async fetchLatestPosts (latestPostId) {
    if (latestPostId < 0) {
      return;
    }
    const earliestPostId = Math.max(0, latestPostId  -20);

    for (let postId = latestPostId; postId >= earliestPostId; --postId) {
      await this.fetchPost(postId);
    }
  }

  async fetchPost(postId) {
    const { web3, accounts, contract } = this.props;
    const gas = await contract.posts.estimateGas(postId);
    const contractCallOptions = {
      from: accounts[0],
      gas: gas + 1000,
    };
    const post = await contract.posts(postId);

    console.log('post', postId, post);

    this.state.posts.set(postId, post);

    this.setState({ posts: this.state.posts });
  }

  render() {
    const { classes } = this.props;

    const posts = [...(this.state.posts.entries())];
    console.log('entries', [...(this.state.posts.entries())]);

    return (
      <Card className={classes.card}>
        <h1>Post list</h1>
        { posts.map(([id, post]) => {
          const { title } = post;
          return (<div key={id}>{ id } - { title }</div>);
        }) }
      </Card>
    );
  }
}

PostListCard.propTypes = {
  classes: PropTypes.object.isRequired,
  web3: PropTypes.object.isRequired,
  contract: PropTypes.object.isRequired,
  accounts: PropTypes.array.isRequired,
};

export default withStyles(styles)(PostListCard);
