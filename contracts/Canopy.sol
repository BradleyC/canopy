pragma solidity ^0.4.24;

// TODO: make sure stake is actually paid method
// TODO: stake is going to come in in Wei
// TODO: this.balance = Wei
//

contract Canopy {

    /*** DATA HANDLING ***/
    // add balance increase?
    // add message
    struct Post {
        address posterAddress;
        string title;
        string url;
        string content;
        uint timePosted;
        uint stake;
        uint256 voteTokens;
        uint256 score;
        uint valuePositive;
        uint valueNegative;
        uint256 voterTally;
        bool active;
    }

    address public maintainersAddress;
    address public gameMasterAddress;
    address public newContractAddress;

    constructor () public {
        // This is an empty constructor.
    }

    /*** EVENTS ***/
    event NewPost(
        uint256 indexed postId,
        address posterAddress,
        string title,
        string url,
        string content,
        uint indexed timePosted, 
        uint stake,
        uint256 score,
        bool active
    );
    // TODO: event NewVote(uint256 indexed postId, )
    event ContractUpgrade(address indexed newContract);

    /*** STORAGE ***/
    Post[] posts;
    address[] private participants; // used for rolling jackpot
    // below: uint256 to make sure we can fully support an enormous pool. 
    uint256 public poolValue = address(this).balance;
    bool _scoresCurrentlyUpdating = false;

    mapping (uint256 => address) public postIdToOwner;
    mapping (uint256 => uint256) public postIdToVoteTokens; // ?    
    mapping (uint256 => address[]) public postIdToVoters;
    mapping (address => uint256) public userPostCount;
    mapping (address => uint256) public userToTotalScore; // not likely
    mapping (address => uint256) public userToVoterTally;

    /// @dev canopy is currently in Alpha. Expect upgrades; currently following CK pattern for upgrade.
    /// @param _v2Address new address
    /*
    function setNewAddress(address _v2Address) external onlyGameMaster {
        newContractAddress = _v2Address;
        emit ContractUpgrade(_v2Address);
    }
    */


    /*** CORE ***/
    // @dev function to create a new post
    function createPost(string title, string url, uint256 stake, string content)
        // TODO: make sure "stake" transfer is executed properly  
        external
        payable
        returns (
            uint256,
            uint256
        ){
        // below: intentionally ignoring warning; time is non-critical
        uint timePosted = now;
        address poster = msg.sender;
        // below: start score = (1 up - 0 down) * (1 voter / 1 second since post)
        uint256 score = 1;
        Post memory post = Post({
            posterAddress: poster,
            title: title,
            url: url,
            content: content,
            timePosted: timePosted,
            stake: msg.value,
            voteTokens: 0,
            score: score,
            valuePositive: 0,
            valueNegative: 0,
            voterTally: 0,
            active: true
        });

        uint256 newPostId = posts.push(post) - 1;
        postIdToOwner[newPostId] = poster;
        postIdToVoteTokens[newPostId] = 0;
        // below: new post is initiated with score of 1
        // TODO: remove or refactor, score has been made more ephemeral
        userToTotalScore[poster]++;
        userPostCount[poster]++;
        userToVoterTally[poster]++;
        emit NewPost(
            newPostId, 
            poster, 
            title, 
            url, 
            content,
            timePosted, 
            stake, 
            score, 
            true
        );
        return (newPostId, _score);
    }

    /*
    function getPost(uint256 _id) 
        internal
        view
        returns (
            address posterAddress,
            string title,
            string url,
            string content,
            uint timePosted,
            uint stake,
            uint256 score,
            uint valuePositive,
            uint valueNegative,
            uint256 voterTally,
            bool active
        ) {
        Post memory p = posts[_id];
        return(
            p.posterAddress, 
            p.title, 
            p.url, 
            p.content,
            p.timePosted, 
            p.stake,
            p.score,
            p.valuePositive,
            p.valueNegative,
            p.voterTally,
            p.active
        );
    }

    // @dev pass in vote params. return the vote weight instantly, re-rank posts
    function vote(uint256 _postId, uint256 valuePositive, uint256 valueNegative) external payable returns (uint256) {
        Post memory c = posts[_postId];
        c.valuePositive = valuePositive;
        c.valueNegative = valueNegative;
        c.voterTally++;
        userToVoterTally[c.posterAddress]++;
        c.score = scorePost(_postId);
        updateActiveScores();
        return c.score;
    }

    function updateActiveScores() internal {
        if (_scoresCurrentlyUpdating = false) {
            _scoresCurrentlyUpdating = true;
            for (uint i = 0; i < posts.length; i++) {
                Post memory c = posts[i];
                // if a post is a month old, pay it out and deactivate
                if (c.active = true) {
                    if (c.active = false) {
                        continue;
                    }
                    else if (( now - c.timePosted) > 2592000) {
                        cashOut(currentId);
                    }
                    else scorePost(i);
                }
            }
            _scoresCurrentlyUpdating = false;
        }
    }

    function scorePost(uint256 _postId) internal returns (uint256) {
        Post memory p = posts[_postId];
        // multiply by 100000 to ensure an integer
        uint256 uproot = sqrt((p.valuePositive) * 100000);
        uint256 downroot = sqrt((p.valueNegative) * 100000);
        uint256 totalVoters = p.voterTally;
        uint256 rootTimeSincePost = sqrt(now - p.timePosted); 
        uint256 _score = (uproot / downroot)(totalVoters / rootTimeSincePost);
        posts[_postId].score = _score;
        return _score;
    }

    // below method is borrowed from https://github.com/ethereum/dapp-bin/pull/50/files
    function sqrt(uint256 x) internal returns (uint256 y) {
        if (x == 0) return 0;
        else if (x <= 3) return 1;
        uint z = (x + 1) / 2;
        y = x;
        while (z < y)
        {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    // @dev read from mapping - show 100 of the most recent
    function getMostRecentPost() external {
        //since IDs are sequential, length of array = most recent post id
        return posts.length;
    }

    // @dev read from mapping
    function getScoreById(uint _postId) internal {
        return posts[_postId].score;
    }

    // @dev user can choose when to cash out, make sure to check address
    function cashOut(uint _postId) external payable onlyPoster(_postId) {
        require(poolValue > 0, "no bad checks");
        //check that payout is to posterAddress with onlyPoster
        //Setting the Variables required
        Post memory p = posts[_postId];

        uint totalValue = p.valuePositive + p.valueNegative;
        uint totalRatio = sqrt(valuePositive) / sqrt(valueNegative);
        uint basePaymentToPoster = p.stake * (sqrt(p.valuePositive) / sqrt(totalValue)) + p.valuePositive;
        
        // calculate bonus 
        while (totalRatio >= .75) {
            if (totalRatio < 2) {
                uint bonusRatio = totalRatio;
            }
        else bonusRatio = 2; }

        uint bonusPayout = p.stake * bonusRatio;
        
        // make sure that bonus isn't too much of pool
        if (bonusPayout < (poolValue * .5)) {
            uint totalBonus = bonusPayout;
        }
        else totalBonus = (poolValue * .5);
        
        totalPayout = basePaymentToPoster + totalBonus;
        msg.sender.transfer(address(this).totalPayout);
        posts[_postId].active = False;
        posts[_postId].score = 0;
    }

    // @dev BONUS - get post with highest tally of votes
    // @dev BONUS - get user's total score
    // @dev BONUS - get user's total voter tally

    /*** PERMISSIONS ***/
    // @dev check against addresses 
    modifier onlyPoster(uint _postId) {
        require(msg.sender == posts[_postId].posterAddress, "Only the poster can use this function");
        _;
    }

    modifier onlyMaintainers() {
        require(msg.sender == maintainersAddress, "Only the maintainer is allowed this action");
        // line 19
        _;
    }

    modifier onlyGameMaster() {
        require(msg.sender == gameMasterAddress, "Only the Game Master is able to change the rules");
        // line 20
        _;
    }

}
