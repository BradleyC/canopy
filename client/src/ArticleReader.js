
import React from 'react';

// Import getNews function from news.js
import { getNews } from 'news';
// We'll get to this one later
import Article from 'Article';

export default class App extends React.Component {
  constructor(props) {
    super(props);
    this.state = { articles: [], refreshing: true };
    this.fetchNews = this.fetchNews.bind(this);
  }
  // Called after a component is mounted
  componentDidMount() {
    this.fetchNews();
  }

  fetchNews() {
    getNews()
    .then(articles => this.setState({ articles, refreshing: false }))
    .catch(() => this.setState({ refreshing: false }));
  }

  handleRefresh() {
    this.setState(
    {
      refreshing: true
    },
    () => this.fetchNews()
    );
  }




  render() {
    
    return (
       
        <div>renderItem={({ item })  <p>
   
    
      );
    
  }
}

