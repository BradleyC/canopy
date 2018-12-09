# canopy
A Social Feed that uses cryptoeconomics to fight spam and provides rewards for good content!

# The Premise
We want to build a Social Feed that:
  1) fights spam & low quality content
  2) returns value to the users who perform data labor by creating and curating the Feed
  
# The Approach
Techniques employed:
  * Vitalik's concept of Proof of Stake Hash Cache (requiring users to stake some ETH when they make a post)
  * Elements of Quadratic Voting techniques to make sure that no single actor can manipulate the voting
  * Each action in the app is a transaction, capturing the value of data labor performed in posting & voting
  
# User Flow  
  * User chooses a value of ETH to stake when they post their link
  * Other users upvote and downvote as they see fit. A vote in either direction costs ETH, and the "power" of their vote is the square root of the amount of ETH that they pay.
  * Posts on the site are ranked by a score that combines sentiment * popularity 
  ** (sqrt upvotes / sqrt downvotes) * (total voters / sqrt seconds since posted)
  * Posters can cash out and deactivate their post when they feel like they will benefit most
  * Cashing out pays the initial poster:
  ** a portion of the initial stake based on % of upvotes + 
  ** all ETH used to upvote + 
  ** up to 2x bonus on initial stake (triggers if at least 75% upvotes)
  ** all ETH not returned / awarded to poster go into contract to fund bonus pool and community reward pool

# Benefits
This approach to the social feed unlocks three major gaps with the current social media landscape:
  1) Community can retain ownership of the entire platform and its content.
  2) All data labor performed by users is measured and returns some amount of payment to users.
  3) Making every action a transaction creates barriers to those who use asymmetric exploits to subvert online communities (ie bots, sock accounts, trolls)

# What's Next
This is an early experiment in using cryptoeconomics to make social experiences online more like the real world, where every action has a cost and can affect status / reputation.
Ideally, we would mint a token with a massive supply and low individual value (pocket change) to incent users to interact liberally.
We'd also like to be able to issue the community pool with a bit more logic, such as attaching a monetary reward to earning badges and other targeted incentives for good behavior.
