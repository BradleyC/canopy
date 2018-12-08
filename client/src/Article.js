import React from 'react';
import { Typography, Button, Card, Divider } from '@material-ui/core';
//import moment from 'moment';

export default class Article extends React.Component {
  render() {

    const {
      title,
      description,
      publishedAt,
      source,
      urlToImage,
      url
    } = this.props.article;
    
    const { noteStyle, featuredTitleStyle } = styles;
   // const time = moment(publishedAt || moment.now()).fromNow();
    const defaultImg =
      'https://wallpaper.wiki/wp-content/uploads/2017/04/wallpaper.wiki-Images-HD-Diamond-Pattern-PIC-WPB009691.jpg';

    return (
   
        <Card
          featuredTitle={title}
          featuredTitleStyle={featuredTitleStyle}
          image={{
            uri: urlToImage || defaultImg
          }}
        >
          <Typography style={{ marginBottom: 10 }}>
            {description || 'Read More..'}
          </Typography>
          <Divider style={{ backgroundColor: '#dfe6e9' }} />

        </Card>
  
    );
  }
}

const styles = {
  noteStyle: {
    margin: 5,
    fontStyle: 'italic',
    color: '#b2bec3',
    fontSize: 10
  },
  featuredTitleStyle: {
    marginHorizontal: 5,
    textShadowColor: '#00000f',
    textShadowOffset: { width: 3, height: 3 },
    textShadowRadius: 3
  }
};