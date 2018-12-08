pragma solidity ^0.4.24;

contract Canopy {

    /*** DATA HANDLING ***/
    struct Post {
        address posterAddress;
        string title;
        string url;
        uint256 timePosted;
        uint256 stake;
        uint256 score;
        uint256 valuePositive;
        uint256 valueNegative;
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
        uint256 indexed timePosted, 
        uint256 stake, 
        uint256 score, 
        bool active
    );
    // TODO: event NewVote(uint256 indexed postId, )

    /*** STORAGE ***/
    Post[] posts;
    address[] private participants; // used for rolling jackpot
    uint256[40] public top40PostIds;

    mapping (uint256 => address) public postIdToOwner;
    mapping (uint256 => uint256) public postIdToTime;
    mapping (uint256 => uint256) public postIdToScore;
    mapping (address => uint256) public userPostCount;
    mapping (address => uint256) public userToTotalScore;
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
    function createPost(string title, string url, uint256 stake)
        // TODO: make sure "stake" transfer is executed properly  
        external 
        returns (
            uint256,
            uint256
        ){
        // below: intentionally ignoring warning; time is non-critical
        uint256 _timePosted = now;
        address _poster = msg.sender;
        // below: start score = (1 up - 0 down) * (1 voter / 1 second since post)
        uint _score = 1;
        Post memory _post = Post({
            posterAddress: _poster,
            title: title,
            url: url,
            timePosted: _timePosted,
            stake: stake,
            score: _score,
            // regardless of stake value, self votes always count as one vote
            valuePositive: 1,
            valueNegative: 0,
            voterTally: 1,
            active: true
        });

        uint256 newPostId = posts.push(_post) - 1;
        postIdToOwner[newPostId] = _poster;
        postIdToTime[newPostId] = _timePosted;
        // below: new post is initiated with score of 1
        postIdToScore[newPostId]++;
        userToTotalScore[_poster]++;
        userPostCount[_poster]++;
        userToVoterTally[_poster]++;
        emit NewPost(
            newPostId, 
            _poster, 
            title, 
            url, 
            _timePosted, 
            stake, 
            _score, 
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
            uint256 timePosted,
            uint256 stake,
            uint256 score,
            uint256 valuePositive,
            uint256 valueNegative,
            uint256 voterTally,
            bool active
        ) {
        Post memory p = posts[_id];
        return(
            p.posterAddress, 
            p.title, 
            p.url, 
            p.timePosted, 
            p.stake,
            p.score,
            p.valuePositive,
            p.valueNegative,
            p.voterTally,
            p.active
        );
    }

    // @dev fetch the list of ranked posts
    function getRankedPosts() internal pure {
        getPost();
    }

    // @dev pass in vote params. return the vote weight instantly, re-rank posts
    function vote() external returns (uint256) {
        // voting logics
        getScoreById();
        rankPosts();
        // update mappings
        return score;
    }

    // @dev process to rank posts
    // evaluate score and if applicable, add to post top 40
    function rankPosts() internal {}

    // ranking
    // iterate over vote totals in list starting with floor = 0
    // create inner top 10 array biggest -> smallest
    // if vote total > floor, loop through inner array.
    // if vote total < current object in inner array, insert and pop last element
    
    function rankPosts() internal {}

    // @dev read from mapping - show 100 of the most recent
    function getMostRecentPost() external {
        //since IDs are sequential, length of array = most recent post id
        return posts.length;
    }

    // @dev read from mapping
    function getScoreById(uint _postID) internal {
        return posts[_postID].score;
    }

    // @dev user can choose when to cash out, make sure to check address
    function cashOut(uint _postId) external payable onlyPoster {
        //check that payout is to posterAddress with onlyPoster
        //Setting the Variables required
        uint _paymentToPoster;
        uint _bonusPayout;
        uint _bonusPayoutVoters;
        uint _totalBonus;
        uint _totalValue;
        uint _totalPayout;

        Post memory p = posts[_postId];
        _totalValue = p.valuePositive + p.valueNegative;
        _paymentToPoster = p.stake * (p.valuePositive / totalValue) + p.valuePositive;
        //check that payout is not more than 50% pool balance and stake amount
        if(poolValue * 0.50 > p.stake) {
            _bonusPayout = (p.stake * 0.50);
            _bonusPayoutVoters = (p.stake * 0.50);
            _totalBonus = _bonusPayout + _bonusPayoutVoters;
            return _totalBonus;
        } else if (poolValue * 0.50 <= p.stake) {
            _totalBonus = 0;
            return _totalBonus;
        }  
        
        _totalPayout = _paymentToPoster + _totalBonus;

        //check valuePositive is greater than 0.75 of TotalValue
        require(p.valuePositive >= (0.75*totalValue), "Not a good post");
        //check that poolValue is positive
            if(poolValue.balance > 0) {
        //send payment from poolAddress to posterAddress
                msg.sender.transfer(address(this)._totalPayout);
            }
        p.active = False;
    }

    // @dev BONUS - get post with highest tally of votes
    // @dev BONUS - get user's total score
    // @dev BONUS - get user's total voter tally

    /*** PERMISSIONS ***/
    // @dev check against addresses 
    modifier onlyPoster(uint _postID) {
        require(msg.sender == posts[_postID].posterAddress, "Only the poster can use this function");
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
