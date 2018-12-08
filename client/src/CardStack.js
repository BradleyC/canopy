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


      

        
        class RecipeReviewCard extends React.Component {
          state = { expanded: false };


          handlePost = async (event) => {
            const {web3, accounts, contract} = this.props;
            const amountToStake = web3.utils.toWei(this.state.amountToStake, 'ether');
            const submission = {
              ...this.state,
              amountToStake,
            };
            console.log('handlePost', submission);
            console.log('accounts', accounts);
            console.log('contract', contract);

            console.log(Object.keys(contract.methods));
            console.log();
            const gas = await contract.createPost.estimateGas(submission.title, submission.url, submission.amountToStake);
            const contractCallOptions = {
              from: accounts[0],
              gas: gas + 1000,
            };
            const result = await contract.createPost(submission.title, submission.url, submission.amountToStake, contractCallOptions);
            // const contractCall = contract.methods['createPost(string,string,uint256)'](submission.title, submission.url, submission.amountToStake);
            // const contractCallOptions = {
            //   from: accounts[0],
            //   gas: gas + 1000,
            // };
            // const result = contractCall.send(contractCallOptions);
            console.log('result', result);

            // console.log("EMail: " + this.state.title);
            // console.log("Password: " + this.state.post);
          }

          setStateVariable = (key, e) => {
            e.preventDefault();
            this.setState({ [key]: e.target.value });
            // this.setState(state => ({ post: e.target.value }));
          }

          handleExpandClick = () => {
            this.setState(state => ({ expanded: !state.expanded }));
          };

          render() {
            const { classes } = this.props;

            return (
              <Card className={classes.card}>
              <form>
              <CardHeader
                avatar={
                  <Avatar aria-label="Recipe" className={classes.avatar}>
                    R
                  </Avatar>
                }
                action={
                  <IconButton>
                  <MoreVertIcon />
                  </IconButton>
                }
                title="Submit a News Article"
              />
              <TextField id="standard-uncontrolled" label="Title" defaultValue="Article Title" name="Title"
                className={classes.textField}
                margin="normal"
                variant="outlined"
                onChange={ this.setStateVariable.bind(this, 'title') }
              />

              <TextField id="standard-uncontrolled" label="URL" defaultValue="URL"
                className={classes.textField}
                margin="normal"
                variant="outlined"
                onChange={ this.setStateVariable.bind(this, 'url') }
              />

              <TextField
              id="outlined-number"
              label="Amount to Stake"
              value={this.state.age}
              type="number"
              className={classes.textField}
              InputLabelProps={{
                shrink: true,
              }}
              margin="normal"
              variant="outlined"
              onChange={ this.setStateVariable.bind(this, 'amountToStake') }
              />
              <CardContent>
              
              <TextField id="standard-full-width"
              label="Article"
              multiline rowsMax="20"
              fullWidth
              name="post"
              value={this.state.multiline}
              className={classes.textField}
              margin="normal"
              onChange={ this.setStateVariable.bind(this, 'post') }
              />

              <br/>

              </CardContent>

              <CardActions className={classes.actions} disableActionSpacing>
              <Button size="large" color="primary" onClick={this.handlePost}>
              Publish ArticleS
              </Button>
              
              </CardActions>
              </form>
              <Collapse in={this.state.expanded} timeout="auto" unmountOnExit>
              <CardContent>


              </CardContent>
              </Collapse>
              </Card>
              );

            }
          }

          RecipeReviewCard.propTypes = {
            classes: PropTypes.object.isRequired,
          };




          export default withStyles(styles)(RecipeReviewCard);
